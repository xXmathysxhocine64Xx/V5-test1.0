#!/usr/bin/env python3
"""
GetYourSite Backend Testing Suite - Publications Management System
Tests all admin authentication, JWT verification, content management, message management, and NEW PUBLICATIONS MANAGEMENT APIs
"""

import requests
import json
import time
import os
from datetime import datetime

# Configuration - Using localhost due to external URL 502 issues
BASE_URL = "http://localhost:3000"
API_BASE = f"{BASE_URL}/api"

# Admin credentials from review request
ADMIN_CREDENTIALS = {
    "username": "admin_getyoursite",
    "password": "AdminGYS2024"  # Updated to match .env file
}

class BackendTester:
    def __init__(self):
        self.session = requests.Session()
        self.admin_token = None
        self.test_results = []
        self.message_id = None
        self.created_publications = []  # Track created publications for cleanup
        
    def log_test(self, test_name, success, details=""):
        """Log test results"""
        status = "✅ PASS" if success else "❌ FAIL"
        result = {
            "test": test_name,
            "status": status,
            "success": success,
            "details": details,
            "timestamp": datetime.now().isoformat()
        }
        self.test_results.append(result)
        print(f"{status}: {test_name}")
        if details:
            print(f"   Details: {details}")
        print()

    def test_admin_login(self):
        """Test admin authentication with provided credentials"""
        print("🔐 Testing Admin Authentication...")
        
        try:
            response = self.session.post(
                f"{API_BASE}/admin/login",
                json=ADMIN_CREDENTIALS,
                headers={"Content-Type": "application/json"},
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success') and data.get('token'):
                    self.admin_token = data['token']
                    self.log_test(
                        "Admin Login", 
                        True, 
                        f"Successfully authenticated with token. Message: {data.get('message', 'N/A')}"
                    )
                    return True
                else:
                    self.log_test("Admin Login", False, f"Login successful but missing token or success flag: {data}")
                    return False
            else:
                self.log_test("Admin Login", False, f"HTTP {response.status_code}: {response.text}")
                return False
                
        except Exception as e:
            self.log_test("Admin Login", False, f"Exception: {str(e)}")
            return False

    def test_unauthorized_publications_access(self):
        """Test that publications admin endpoints require authentication"""
        print("🚨 Testing Unauthorized Publications Access...")
        
        endpoints = [
            "/admin/publications",
            "/admin/publications/test123"
        ]
        
        all_passed = True
        
        for endpoint in endpoints:
            try:
                # Test GET without token
                response = self.session.get(f"{API_BASE}{endpoint}", timeout=10)
                if response.status_code == 401:
                    self.log_test(f"Unauthorized GET {endpoint}", True, "Correctly blocked unauthorized access")
                else:
                    self.log_test(f"Unauthorized GET {endpoint}", False, f"Expected 401, got {response.status_code}")
                    all_passed = False
                    
                # Test POST without token (for publications endpoint)
                if endpoint == "/admin/publications":
                    response = self.session.post(
                        f"{API_BASE}{endpoint}",
                        json={"title": "Test", "content": "Test", "author": "Test"},
                        timeout=10
                    )
                    if response.status_code == 401:
                        self.log_test(f"Unauthorized POST {endpoint}", True, "Correctly blocked unauthorized POST")
                    else:
                        self.log_test(f"Unauthorized POST {endpoint}", False, f"Expected 401, got {response.status_code}")
                        all_passed = False
                        
            except Exception as e:
                self.log_test(f"Unauthorized Access - {endpoint}", False, f"Request failed: {str(e)}")
                all_passed = False
        
        return all_passed

    def create_publication(self, title, content, author, status="draft"):
        """Create a new publication"""
        if not self.admin_token:
            self.log_test("Create Publication", False, "No admin token available")
            return None
            
        try:
            headers = {"Authorization": f"Bearer {self.admin_token}"}
            data = {
                "title": title,
                "content": content,
                "author": author,
                "status": status
            }
            
            response = self.session.post(
                f"{API_BASE}/admin/publications",
                json=data,
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success') and result.get('publication'):
                    publication = result['publication']
                    self.created_publications.append(publication['id'])
                    self.log_test(f"Create Publication ({status})", True, f"Created publication: {title}", f"ID: {publication['id']}")
                    return publication
                else:
                    self.log_test(f"Create Publication ({status})", False, "Response missing publication data", result)
                    return None
            else:
                self.log_test(f"Create Publication ({status})", False, f"Failed with status {response.status_code}", response.text)
                return None
                
        except Exception as e:
            self.log_test(f"Create Publication ({status})", False, f"Request failed: {str(e)}")
            return None

    def test_publication_validation(self):
        """Test publication validation rules"""
        if not self.admin_token:
            return False
            
        headers = {"Authorization": f"Bearer {self.admin_token}"}
        
        # Test validation cases
        test_cases = [
            {"data": {"title": "", "content": "Test content", "author": "Test Author"}, "expected": "empty title"},
            {"data": {"title": "Test Title", "content": "", "author": "Test Author"}, "expected": "empty content"},
            {"data": {"title": "Test Title", "content": "Test content", "author": ""}, "expected": "empty author"},
            {"data": {"title": "A" * 201, "content": "Test content", "author": "Test Author"}, "expected": "title too long"},
            {"data": {"title": "Test Title", "content": "A" * 5001, "author": "Test Author"}, "expected": "content too long"},
            {"data": {"title": "Test Title", "content": "Test content", "author": "A" * 101}, "expected": "author too long"},
            {"data": {"title": "Test Title", "content": "Test content", "author": "Test Author", "status": "invalid"}, "expected": "invalid status"}
        ]
        
        all_passed = True
        
        for test_case in test_cases:
            try:
                response = self.session.post(
                    f"{API_BASE}/admin/publications",
                    json=test_case["data"],
                    headers=headers,
                    timeout=10
                )
                
                if response.status_code == 400:
                    self.log_test(f"Validation - {test_case['expected']}", True, "Correctly rejected invalid data")
                else:
                    self.log_test(f"Validation - {test_case['expected']}", False, f"Expected 400, got {response.status_code}")
                    all_passed = False
                    
            except Exception as e:
                self.log_test(f"Validation - {test_case['expected']}", False, f"Request failed: {str(e)}")
                all_passed = False
        
        return all_passed

    def get_admin_publications(self):
        """Get all publications via admin endpoint"""
        if not self.admin_token:
            return None
            
        try:
            headers = {"Authorization": f"Bearer {self.admin_token}"}
            response = self.session.get(
                f"{API_BASE}/admin/publications",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                publications = response.json()
                self.log_test("Get Admin Publications", True, f"Retrieved {len(publications)} publications", f"Count: {len(publications)}")
                return publications
            else:
                self.log_test("Get Admin Publications", False, f"Failed with status {response.status_code}", response.text)
                return None
                
        except Exception as e:
            self.log_test("Get Admin Publications", False, f"Request failed: {str(e)}")
            return None

    def get_public_publications(self):
        """Get public publications (no auth required)"""
        try:
            response = self.session.get(
                f"{API_BASE}/publications",
                timeout=10
            )
            
            if response.status_code == 200:
                publications = response.json()
                # Verify all returned publications are published
                all_published = all(pub.get('status') == 'published' for pub in publications)
                if all_published:
                    self.log_test("Get Public Publications", True, f"Retrieved {len(publications)} published publications", f"All {len(publications)} publications have status 'published'")
                else:
                    self.log_test("Get Public Publications", False, "Some publications are not published", publications)
                return publications
            else:
                self.log_test("Get Public Publications", False, f"Failed with status {response.status_code}", response.text)
                return None
                
        except Exception as e:
            self.log_test("Get Public Publications", False, f"Request failed: {str(e)}")
            return None

    def update_publication(self, publication_id, updates):
        """Update an existing publication"""
        if not self.admin_token:
            return False
            
        try:
            headers = {"Authorization": f"Bearer {self.admin_token}"}
            response = self.session.put(
                f"{API_BASE}/admin/publications/{publication_id}",
                json=updates,
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success'):
                    self.log_test("Update Publication", True, f"Successfully updated publication {publication_id}", updates)
                    return True
                else:
                    self.log_test("Update Publication", False, "Update response missing success flag", result)
                    return False
            else:
                self.log_test("Update Publication", False, f"Failed with status {response.status_code}", response.text)
                return False
                
        except Exception as e:
            self.log_test("Update Publication", False, f"Request failed: {str(e)}")
            return False

    def delete_publication(self, publication_id):
        """Delete a publication"""
        if not self.admin_token:
            return False
            
        try:
            headers = {"Authorization": f"Bearer {self.admin_token}"}
            response = self.session.delete(
                f"{API_BASE}/admin/publications/{publication_id}",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success'):
                    self.log_test("Delete Publication", True, f"Successfully deleted publication {publication_id}")
                    return True
                else:
                    self.log_test("Delete Publication", False, "Delete response missing success flag", result)
                    return False
            else:
                self.log_test("Delete Publication", False, f"Failed with status {response.status_code}", response.text)
                return False
                
        except Exception as e:
            self.log_test("Delete Publication", False, f"Request failed: {str(e)}")
            return False

    def test_existing_functionality(self):
        """Test that existing functionality still works"""
        all_passed = True
        
        # Test contact form endpoint
        try:
            response = self.session.post(
                f"{API_BASE}/contact",
                json={
                    "name": "Test User Publications",
                    "email": "test@example.com",
                    "message": "Test message for publications testing",
                    "subject": "Publications Test"
                },
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success'):
                    self.log_test("Existing - Contact Form", True, "Contact form still working")
                else:
                    self.log_test("Existing - Contact Form", False, "Contact form response missing success", result)
                    all_passed = False
            else:
                self.log_test("Existing - Contact Form", False, f"Contact form failed with status {response.status_code}")
                all_passed = False
                
        except Exception as e:
            self.log_test("Existing - Contact Form", False, f"Contact form request failed: {str(e)}")
            all_passed = False
        
        # Test content retrieval
        try:
            response = self.session.get(f"{API_BASE}/content", timeout=10)
            if response.status_code == 200:
                content = response.json()
                if content.get('hero') and content.get('services'):
                    self.log_test("Existing - Content API", True, "Content API still working")
                else:
                    self.log_test("Existing - Content API", False, "Content API missing expected fields")
                    all_passed = False
            else:
                self.log_test("Existing - Content API", False, f"Content API failed with status {response.status_code}")
                all_passed = False
                
        except Exception as e:
            self.log_test("Existing - Content API", False, f"Content API request failed: {str(e)}")
            all_passed = False
        
        return all_passed

    def cleanup_test_publications(self):
        """Clean up test publications"""
        for pub_id in self.created_publications:
            self.delete_publication(pub_id)

    def run_publications_test(self):
        """Run comprehensive publications management tests"""
        print("=" * 80)
        print("STARTING COMPREHENSIVE PUBLICATIONS MANAGEMENT TESTING")
        print("=" * 80)
        print(f"Testing against: {API_BASE}")
        print(f"Admin credentials: {ADMIN_CREDENTIALS['username']} / {'*' * len(ADMIN_CREDENTIALS['password'])}")
        print("=" * 80)
        print()
        
        # Step 1: Admin login
        if not self.test_admin_login():
            print("❌ Cannot proceed without admin authentication")
            return False, 1
        
        # Step 2: Test unauthorized access
        print("\n--- Testing Unauthorized Access ---")
        self.test_unauthorized_publications_access()
        
        # Step 3: Test validation
        print("\n--- Testing Publication Validation ---")
        self.test_publication_validation()
        
        # Step 4: Create test publications
        print("\n--- Creating Test Publications ---")
        draft_pub = self.create_publication(
            "Test Draft Publication",
            "This is a draft publication for testing purposes. It should not appear in public API.",
            "Test Author",
            "draft"
        )
        
        published_pub = self.create_publication(
            "Test Published Publication",
            "This is a published publication for testing purposes. It should appear in public API.",
            "Test Author",
            "published"
        )
        
        # Step 5: Test retrieval endpoints
        print("\n--- Testing Publication Retrieval ---")
        admin_pubs = self.get_admin_publications()
        public_pubs = self.get_public_publications()
        
        # Verify that admin sees both, public sees only published
        if admin_pubs is not None and public_pubs is not None:
            admin_count = len(admin_pubs)
            public_count = len(public_pubs)
            
            if admin_count >= 2:  # Should have at least our 2 test publications
                self.log_test("Admin Publications Count", True, f"Admin endpoint shows {admin_count} publications (including drafts)")
            else:
                self.log_test("Admin Publications Count", False, f"Admin endpoint shows only {admin_count} publications, expected at least 2")
            
            # Check that public endpoint shows fewer or equal publications (only published)
            if public_count <= admin_count:
                self.log_test("Public Publications Count", True, f"Public endpoint shows {public_count} publications (published only)")
            else:
                self.log_test("Public Publications Count", False, f"Public endpoint shows more publications ({public_count}) than admin ({admin_count})")
        
        # Step 6: Test publication updates
        print("\n--- Testing Publication Updates ---")
        if draft_pub:
            # Update draft to published
            success = self.update_publication(draft_pub['id'], {
                "title": "Updated Draft Publication",
                "content": "This draft has been updated and published.",
                "author": "Updated Author",
                "status": "published"
            })
            
            if success:
                # Verify it now appears in public API
                time.sleep(1)  # Brief delay for database consistency
                updated_public_pubs = self.get_public_publications()
                if updated_public_pubs:
                    found_updated = any(pub['id'] == draft_pub['id'] for pub in updated_public_pubs)
                    if found_updated:
                        self.log_test("Status Update Verification", True, "Draft publication now appears in public API after status change")
                    else:
                        self.log_test("Status Update Verification", False, "Updated publication not found in public API")
        
        # Step 7: Test existing functionality
        print("\n--- Testing Existing Functionality ---")
        self.test_existing_functionality()
        
        # Step 8: Cleanup (delete test publications)
        print("\n--- Cleaning Up Test Publications ---")
        self.cleanup_test_publications()
        
        # Final summary
        print("\n" + "=" * 80)
        print("TESTING SUMMARY")
        print("=" * 80)
        
        total_tests = len(self.test_results)
        passed_tests = len([r for r in self.test_results if "✅ PASS" in r['status']])
        failed_tests = total_tests - passed_tests
        
        print(f"Total Tests: {total_tests}")
        print(f"Passed: {passed_tests}")
        print(f"Failed: {failed_tests}")
        print(f"Success Rate: {(passed_tests/total_tests)*100:.1f}%")
        
        if failed_tests > 0:
            print("\n❌ FAILED TESTS:")
            for result in self.test_results:
                if "❌ FAIL" in result['status']:
                    print(f"  - {result['test']}: {result['details']}")
        
        print("\n" + "=" * 80)
        return passed_tests, failed_tests

if __name__ == "__main__":
    tester = BackendTester()
    passed, failed = tester.run_publications_test()
    
    if failed == 0:
        print("🎉 ALL TESTS PASSED! Publications management system is working correctly.")
    else:
        print(f"⚠️  {failed} tests failed. Please review the issues above.")
    
    exit(0 if failed == 0 else 1)