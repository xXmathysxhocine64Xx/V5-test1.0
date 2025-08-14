#!/usr/bin/env python3
"""
GetYourSite Admin Panel Backend Testing Suite
Tests all admin authentication, JWT verification, content management, and message management APIs
"""

import requests
import json
import time
import os
from datetime import datetime

# Configuration
BASE_URL = "http://localhost:3000"  # Using localhost due to external URL 502 issues
API_BASE = f"{BASE_URL}/api"

# Admin credentials from review request
ADMIN_CREDENTIALS = {
    "username": "admin_getyoursite",
    "password": "GYS2024!SecurePanel#"
}

class AdminPanelTester:
    def __init__(self):
        self.session = requests.Session()
        self.admin_token = None
        self.test_results = []
        self.message_id = None
        
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
            # Debug: Check what credentials we're sending
            print(f"   Sending credentials: {ADMIN_CREDENTIALS}")
            
            response = self.session.post(
                f"{API_BASE}/admin/login",
                json=ADMIN_CREDENTIALS,
                headers={"Content-Type": "application/json"},
                timeout=10
            )
            
            print(f"   Response status: {response.status_code}")
            print(f"   Response body: {response.text}")
            
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

    def test_invalid_login(self):
        """Test login with invalid credentials"""
        print("🚫 Testing Invalid Login...")
        
        try:
            invalid_creds = {
                "username": "wrong_admin",
                "password": "wrong_password"
            }
            
            response = self.session.post(
                f"{API_BASE}/admin/login",
                json=invalid_creds,
                headers={"Content-Type": "application/json"},
                timeout=10
            )
            
            if response.status_code == 401:
                data = response.json()
                self.log_test(
                    "Invalid Login Rejection", 
                    True, 
                    f"Correctly rejected invalid credentials with 401. Error: {data.get('error', 'N/A')}"
                )
                return True
            else:
                self.log_test("Invalid Login Rejection", False, f"Expected 401, got {response.status_code}: {response.text}")
                return False
                
        except Exception as e:
            self.log_test("Invalid Login Rejection", False, f"Exception: {str(e)}")
            return False

    def test_jwt_verification(self):
        """Test JWT token verification endpoint"""
        print("🔍 Testing JWT Token Verification...")
        
        if not self.admin_token:
            self.log_test("JWT Verification", False, "No admin token available")
            return False
            
        try:
            headers = {
                "Authorization": f"Bearer {self.admin_token}",
                "Content-Type": "application/json"
            }
            
            response = self.session.get(
                f"{API_BASE}/admin/verify",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('valid') and data.get('user'):
                    self.log_test(
                        "JWT Verification", 
                        True, 
                        f"Token verified successfully. User: {data.get('user', {}).get('username', 'N/A')}"
                    )
                    return True
                else:
                    self.log_test("JWT Verification", False, f"Token verification failed: {data}")
                    return False
            else:
                self.log_test("JWT Verification", False, f"HTTP {response.status_code}: {response.text}")
                return False
                
        except Exception as e:
            self.log_test("JWT Verification", False, f"Exception: {str(e)}")
            return False

    def test_unauthorized_access(self):
        """Test access without token"""
        print("🚨 Testing Unauthorized Access...")
        
        try:
            # Test admin verify without token
            response = self.session.get(f"{API_BASE}/admin/verify", timeout=10)
            
            if response.status_code == 401:
                self.log_test(
                    "Unauthorized Access Block", 
                    True, 
                    "Correctly blocked access without token (401)"
                )
                return True
            else:
                self.log_test("Unauthorized Access Block", False, f"Expected 401, got {response.status_code}")
                return False
                
        except Exception as e:
            self.log_test("Unauthorized Access Block", False, f"Exception: {str(e)}")
            return False

    def test_content_retrieval(self):
        """Test site content retrieval"""
        print("📄 Testing Content Retrieval...")
        
        try:
            response = self.session.get(f"{API_BASE}/content", timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if data and 'hero' in data and 'services' in data:
                    self.log_test(
                        "Content Retrieval", 
                        True, 
                        f"Successfully retrieved site content. Type: {data.get('type', 'N/A')}, Hero title: {data.get('hero', {}).get('title', 'N/A')}"
                    )
                    return True
                else:
                    self.log_test("Content Retrieval", False, f"Content structure invalid: {list(data.keys()) if data else 'Empty response'}")
                    return False
            else:
                self.log_test("Content Retrieval", False, f"HTTP {response.status_code}: {response.text}")
                return False
                
        except Exception as e:
            self.log_test("Content Retrieval", False, f"Exception: {str(e)}")
            return False

    def test_content_update(self):
        """Test admin content update"""
        print("✏️ Testing Content Update...")
        
        if not self.admin_token:
            self.log_test("Content Update", False, "No admin token available")
            return False
            
        try:
            headers = {
                "Authorization": f"Bearer {self.admin_token}",
                "Content-Type": "application/json"
            }
            
            update_data = {
                "type": "hero",
                "data": {
                    "title": "Test Update",
                    "subtitle": "Updated by admin test",
                    "description": "This is a test update from the admin panel testing suite"
                }
            }
            
            response = self.session.put(
                f"{API_BASE}/admin/content",
                json=update_data,
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    self.log_test(
                        "Content Update", 
                        True, 
                        f"Successfully updated content. Message: {data.get('message', 'N/A')}"
                    )
                    return True
                else:
                    self.log_test("Content Update", False, f"Update failed: {data}")
                    return False
            else:
                self.log_test("Content Update", False, f"HTTP {response.status_code}: {response.text}")
                return False
                
        except Exception as e:
            self.log_test("Content Update", False, f"Exception: {str(e)}")
            return False

    def create_test_message(self):
        """Create a test contact message for admin message management testing"""
        print("📝 Creating Test Contact Message...")
        
        try:
            test_message = {
                "name": "Jean Dupont",
                "email": "jean.dupont@example.com",
                "subject": "Demande de devis site web",
                "message": "Bonjour, je souhaiterais obtenir un devis pour la création d'un site vitrine pour mon entreprise. Merci de me recontacter."
            }
            
            response = self.session.post(
                f"{API_BASE}/contact",
                json=test_message,
                headers={"Content-Type": "application/json"},
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    self.log_test(
                        "Test Message Creation", 
                        True, 
                        f"Test contact message created successfully. Message: {data.get('message', 'N/A')}"
                    )
                    return True
                else:
                    self.log_test("Test Message Creation", False, f"Message creation failed: {data}")
                    return False
            else:
                self.log_test("Test Message Creation", False, f"HTTP {response.status_code}: {response.text}")
                return False
                
        except Exception as e:
            self.log_test("Test Message Creation", False, f"Exception: {str(e)}")
            return False

    def test_messages_retrieval(self):
        """Test admin messages retrieval"""
        print("📬 Testing Messages Retrieval...")
        
        if not self.admin_token:
            self.log_test("Messages Retrieval", False, "No admin token available")
            return False
            
        try:
            headers = {
                "Authorization": f"Bearer {self.admin_token}",
                "Content-Type": "application/json"
            }
            
            response = self.session.get(
                f"{API_BASE}/admin/messages",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                if isinstance(data, list):
                    # Store first message ID for further testing
                    if data and '_id' in data[0]:
                        self.message_id = data[0]['_id']
                    
                    self.log_test(
                        "Messages Retrieval", 
                        True, 
                        f"Successfully retrieved {len(data)} messages. First message from: {data[0].get('name', 'N/A') if data else 'No messages'}"
                    )
                    return True
                else:
                    self.log_test("Messages Retrieval", False, f"Expected array, got: {type(data)}")
                    return False
            else:
                self.log_test("Messages Retrieval", False, f"HTTP {response.status_code}: {response.text}")
                return False
                
        except Exception as e:
            self.log_test("Messages Retrieval", False, f"Exception: {str(e)}")
            return False

    def test_message_mark_read(self):
        """Test marking message as read"""
        print("👁️ Testing Mark Message as Read...")
        
        if not self.admin_token:
            self.log_test("Mark Message Read", False, "No admin token available")
            return False
            
        if not self.message_id:
            self.log_test("Mark Message Read", False, "No message ID available for testing")
            return False
            
        try:
            headers = {
                "Authorization": f"Bearer {self.admin_token}",
                "Content-Type": "application/json"
            }
            
            response = self.session.put(
                f"{API_BASE}/admin/messages/read",
                json={"messageId": self.message_id},
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    self.log_test(
                        "Mark Message Read", 
                        True, 
                        f"Successfully marked message as read. Message ID: {self.message_id}"
                    )
                    return True
                else:
                    self.log_test("Mark Message Read", False, f"Mark read failed: {data}")
                    return False
            else:
                self.log_test("Mark Message Read", False, f"HTTP {response.status_code}: {response.text}")
                return False
                
        except Exception as e:
            self.log_test("Mark Message Read", False, f"Exception: {str(e)}")
            return False

    def test_message_deletion(self):
        """Test message deletion"""
        print("🗑️ Testing Message Deletion...")
        
        if not self.admin_token:
            self.log_test("Message Deletion", False, "No admin token available")
            return False
            
        if not self.message_id:
            self.log_test("Message Deletion", False, "No message ID available for testing")
            return False
            
        try:
            headers = {
                "Authorization": f"Bearer {self.admin_token}",
                "Content-Type": "application/json"
            }
            
            response = self.session.delete(
                f"{API_BASE}/admin/messages/{self.message_id}",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    self.log_test(
                        "Message Deletion", 
                        True, 
                        f"Successfully deleted message. Message: {data.get('message', 'N/A')}"
                    )
                    return True
                else:
                    self.log_test("Message Deletion", False, f"Deletion failed: {data}")
                    return False
            else:
                self.log_test("Message Deletion", False, f"HTTP {response.status_code}: {response.text}")
                return False
                
        except Exception as e:
            self.log_test("Message Deletion", False, f"Exception: {str(e)}")
            return False

    def test_database_initialization(self):
        """Test automatic database content initialization"""
        print("🗄️ Testing Database Initialization...")
        
        try:
            # Get content to trigger initialization
            response = self.session.get(f"{API_BASE}/content", timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                
                # Check if default content structure exists
                required_fields = ['hero', 'services', 'portfolio', 'contact']
                missing_fields = [field for field in required_fields if field not in data]
                
                if not missing_fields:
                    self.log_test(
                        "Database Initialization", 
                        True, 
                        f"Default content properly initialized with all required fields: {required_fields}"
                    )
                    return True
                else:
                    self.log_test("Database Initialization", False, f"Missing required fields: {missing_fields}")
                    return False
            else:
                self.log_test("Database Initialization", False, f"HTTP {response.status_code}: {response.text}")
                return False
                
        except Exception as e:
            self.log_test("Database Initialization", False, f"Exception: {str(e)}")
            return False

    def run_all_tests(self):
        """Run complete admin panel test suite"""
        print("🚀 Starting GetYourSite Admin Panel Testing Suite")
        print("=" * 60)
        print(f"Testing against: {API_BASE}")
        print(f"Admin credentials: {ADMIN_CREDENTIALS['username']} / {'*' * len(ADMIN_CREDENTIALS['password'])}")
        print("=" * 60)
        print()
        
        # Test sequence
        tests = [
            ("Database Initialization", self.test_database_initialization),
            ("Admin Login", self.test_admin_login),
            ("Invalid Login Rejection", self.test_invalid_login),
            ("JWT Verification", self.test_jwt_verification),
            ("Unauthorized Access Block", self.test_unauthorized_access),
            ("Content Retrieval", self.test_content_retrieval),
            ("Content Update", self.test_content_update),
            ("Test Message Creation", self.create_test_message),
            ("Messages Retrieval", self.test_messages_retrieval),
            ("Mark Message Read", self.test_message_mark_read),
            ("Message Deletion", self.test_message_deletion),
        ]
        
        passed = 0
        failed = 0
        
        for test_name, test_func in tests:
            try:
                if test_func():
                    passed += 1
                else:
                    failed += 1
            except Exception as e:
                print(f"❌ CRITICAL ERROR in {test_name}: {str(e)}")
                failed += 1
            
            time.sleep(0.5)  # Brief pause between tests
        
        # Summary
        print("=" * 60)
        print("🏁 ADMIN PANEL TESTING COMPLETE")
        print("=" * 60)
        print(f"✅ PASSED: {passed}")
        print(f"❌ FAILED: {failed}")
        print(f"📊 SUCCESS RATE: {(passed/(passed+failed)*100):.1f}%")
        print()
        
        if failed == 0:
            print("🎉 ALL TESTS PASSED! Admin panel is fully functional.")
        else:
            print("⚠️ Some tests failed. Check details above.")
        
        print()
        print("📋 DETAILED TEST RESULTS:")
        print("-" * 40)
        for result in self.test_results:
            print(f"{result['status']}: {result['test']}")
            if result['details']:
                print(f"   {result['details']}")
        
        return failed == 0

if __name__ == "__main__":
    tester = AdminPanelTester()
    success = tester.run_all_tests()
    exit(0 if success else 1)