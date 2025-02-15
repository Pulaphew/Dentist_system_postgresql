{
    "title": "clinic",
    "required": ["_id", 
                "clinic_id",
                "clinic_tel",
                "gps_location",
                "clinic_province",
                "clinic_district", 
                "clinic_sub_district", 
                "clinic_street", 
                "clinic_number", 
                "clinic_zip", 
                "dentist_in_clinic"],
    "properties": {
        "_id": { "bsonType": "objectId" },
        "clinic_id": { "bsonType": "int" },
        "clinic_tel": { "bsonType": "int" },
        "gps_location": { 
            "bsonType": "geography",
            "description": "WKT (Well-Known Text) format of GPS coordinates"
        },
        "clinic_province": { "bsonType": "string" },
        "clinic_district": { "bsonType": "string" },
        "clinic_sub_district": { "bsonType": "string" },
        "clinic_street": { "bsonType": "string" },
        "clinic_number": { "bsonType": "string" },
        "clinic_zip": { "bsonType": "string" },
        "service_available": {
            "bsonType": "array",
            "items": {
                "bsonType": "object",
                "properties": {
                    "_id": { "bsonType": "objectId" },
                    "service_name": { "bsonType": "string" },
                    "clinic_id": { "bsonType": "int" }
                }
            }
        }
    }
}
