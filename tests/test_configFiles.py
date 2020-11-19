import json, unittest

def read_json(json_file="parameters_template.json"):
    with open(json_file, 'rb') as fp:
        data = json.load(fp)
        return data

class TestJson(unittest.TestCase):



    def test_json_format(self):
        self.assertEqual(type(read_json()), dict)


if __name__ == "__main__":
    #if len(sys.argv) > 1:
    unittest.main()
        
        