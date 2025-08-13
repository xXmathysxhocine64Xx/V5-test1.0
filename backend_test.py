#!/usr/bin/env python3
"""
Backend API Tests for GetYourSite
Tests the actual implemented functionality in app/api/[[...path]]/route.js
"""

import requests
import json
import os
from datetime import datetime

# Get base URL from environment
BASE_URL = "https://e224a7b4-7185-467b-bbd1-5966cfe3d1eb.preview.emergentagent.com"
API_BASE = f"{BASE_URL}/api"

def test_api_get_endpoint():
    """Test GET /api endpoint"""
    print("\n=== Testing GET /api endpoint ===")
    try:
        response = requests.get(f"{API_BASE}")
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 200:
            data = response.json()
            required_fields = ['message', 'path', 'timestamp', 'status']
            missing_fields = [field for field in required_fields if field not in data]
            
            if not missing_fields:
                print("✅ GET /api endpoint working correctly")
                return True
            else:
                print(f"❌ Missing fields in response: {missing_fields}")
                return False
        else:
            print(f"❌ GET /api endpoint failed with status {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ GET /api endpoint test failed: {str(e)}")
        return False

def test_contact_form_valid_data():
    """Test POST /api/contact with valid data"""
    print("\n=== Testing POST /api/contact with valid data ===")
    try:
        contact_data = {
            "name": "Jean Dupont",
            "email": "jean.dupont@example.com",
            "message": "Bonjour, je souhaite créer un site web pour mon entreprise. Pouvez-vous me contacter ?",
            "subject": "Demande de devis site web"
        }
        
        response = requests.post(
            f"{API_BASE}/contact",
            json=contact_data,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success') and 'message' in data and 'timestamp' in data:
                print("✅ Contact form with valid data working correctly")
                return True
            else:
                print("❌ Contact form response missing required fields")
                return False
        else:
            print(f"❌ Contact form failed with status {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Contact form test failed: {str(e)}")
        return False

def test_contact_form_missing_name():
    """Test POST /api/contact with missing name"""
    print("\n=== Testing POST /api/contact with missing name ===")
    try:
        contact_data = {
            "email": "test@example.com",
            "message": "Test message without name"
        }
        
        response = requests.post(
            f"{API_BASE}/contact",
            json=contact_data,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 400:
            data = response.json()
            if 'error' in data and 'nom' in data['error'].lower():
                print("✅ Missing name validation working correctly")
                return True
            else:
                print("❌ Error message doesn't mention missing name")
                return False
        else:
            print(f"❌ Expected 400 status code, got {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Missing name validation test failed: {str(e)}")
        return False

def test_contact_form_missing_email():
    """Test POST /api/contact with missing email"""
    print("\n=== Testing POST /api/contact with missing email ===")
    try:
        contact_data = {
            "name": "Test User",
            "message": "Test message without email"
        }
        
        response = requests.post(
            f"{API_BASE}/contact",
            json=contact_data,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 400:
            data = response.json()
            if 'error' in data and 'email' in data['error'].lower():
                print("✅ Missing email validation working correctly")
                return True
            else:
                print("❌ Error message doesn't mention missing email")
                return False
        else:
            print(f"❌ Expected 400 status code, got {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Missing email validation test failed: {str(e)}")
        return False

def test_contact_form_missing_message():
    """Test POST /api/contact with missing message"""
    print("\n=== Testing POST /api/contact with missing message ===")
    try:
        contact_data = {
            "name": "Test User",
            "email": "test@example.com"
        }
        
        response = requests.post(
            f"{API_BASE}/contact",
            json=contact_data,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 400:
            data = response.json()
            if 'error' in data and 'message' in data['error'].lower():
                print("✅ Missing message validation working correctly")
                return True
            else:
                print("❌ Error message doesn't mention missing message")
                return False
        else:
            print(f"❌ Expected 400 status code, got {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Missing message validation test failed: {str(e)}")
        return False

def test_contact_form_empty_fields():
    """Test POST /api/contact with empty fields"""
    print("\n=== Testing POST /api/contact with empty fields ===")
    try:
        contact_data = {
            "name": "",
            "email": "",
            "message": ""
        }
        
        response = requests.post(
            f"{API_BASE}/contact",
            json=contact_data,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 400:
            data = response.json()
            if 'error' in data:
                print("✅ Empty fields validation working correctly")
                return True
            else:
                print("❌ No error message for empty fields")
                return False
        else:
            print(f"❌ Expected 400 status code, got {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Empty fields validation test failed: {str(e)}")
        return False

def test_contact_form_malformed_json():
    """Test POST /api/contact with malformed JSON"""
    print("\n=== Testing POST /api/contact with malformed JSON ===")
    try:
        response = requests.post(
            f"{API_BASE}/contact",
            data="invalid json",
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 500:
            print("✅ Malformed JSON handled with server error")
            return True
        else:
            print(f"❌ Expected 500 status code, got {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Malformed JSON test failed: {str(e)}")
        return False

def test_non_contact_post_endpoint():
    """Test POST to non-contact endpoint"""
    print("\n=== Testing POST /api/other endpoint ===")
    try:
        response = requests.post(
            f"{API_BASE}/other",
            json={"test": "data"},
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 200:
            data = response.json()
            if 'message' in data and 'timestamp' in data:
                print("✅ Non-contact POST endpoint working correctly")
                return True
            else:
                print("❌ Non-contact POST response missing required fields")
                return False
        else:
            print(f"❌ Non-contact POST failed with status {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Non-contact POST test failed: {str(e)}")
        return False

def test_put_endpoint():
    """Test PUT endpoint"""
    print("\n=== Testing PUT /api endpoint ===")
    try:
        response = requests.put(
            f"{API_BASE}/test",
            json={"test": "data"}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 200:
            data = response.json()
            if 'message' in data and 'timestamp' in data:
                print("✅ PUT endpoint working correctly")
                return True
            else:
                print("❌ PUT response missing required fields")
                return False
        else:
            print(f"❌ PUT endpoint failed with status {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ PUT endpoint test failed: {str(e)}")
        return False

def test_delete_endpoint():
    """Test DELETE endpoint"""
    print("\n=== Testing DELETE /api endpoint ===")
    try:
        response = requests.delete(f"{API_BASE}/test")
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 200:
            data = response.json()
            if 'message' in data and 'timestamp' in data:
                print("✅ DELETE endpoint working correctly")
                return True
            else:
                print("❌ DELETE response missing required fields")
                return False
        else:
            print(f"❌ DELETE endpoint failed with status {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ DELETE endpoint test failed: {str(e)}")
        return False

def run_all_tests():
    """Run all backend tests"""
    print("🚀 Starting GetYourSite Backend API Tests")
    print(f"Testing against: {API_BASE}")
    print("=" * 60)
    
    tests = [
        ("GET /api endpoint", test_api_get_endpoint),
        ("Contact form - valid data", test_contact_form_valid_data),
        ("Contact form - missing name", test_contact_form_missing_name),
        ("Contact form - missing email", test_contact_form_missing_email),
        ("Contact form - missing message", test_contact_form_missing_message),
        ("Contact form - empty fields", test_contact_form_empty_fields),
        ("Contact form - malformed JSON", test_contact_form_malformed_json),
        ("Non-contact POST endpoint", test_non_contact_post_endpoint),
        ("PUT endpoint", test_put_endpoint),
        ("DELETE endpoint", test_delete_endpoint)
    ]
    
    results = []
    passed = 0
    failed = 0
    
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
            if result:
                passed += 1
            else:
                failed += 1
        except Exception as e:
            print(f"❌ {test_name} failed with exception: {str(e)}")
            results.append((test_name, False))
            failed += 1
    
    print("\n" + "=" * 60)
    print("📊 TEST SUMMARY")
    print("=" * 60)
    
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} - {test_name}")
    
    print(f"\nTotal Tests: {len(tests)}")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print(f"Success Rate: {(passed/len(tests)*100):.1f}%")
    
    return results, passed, failed

if __name__ == "__main__":
    run_all_tests()