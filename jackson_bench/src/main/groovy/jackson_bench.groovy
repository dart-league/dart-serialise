import com.fasterxml.jackson.databind.ObjectMapper

class Simple {
    String id;
    Double value;
    Boolean flag;
}


class Complex {
    Simple simple;
    List<Simple> list;
}

def objectMapper = new ObjectMapper()

def data = '''{
		"simple": {
			"id": "something",
			"value": 42.0,
			"flag": true
		},
		"list": [
			{"id":"item 0","value":0,"flag":true},
			{"id":"item 1","value":1,"flag":false},
			{"id":"item 2","value":2,"flag":true}
		]
	}'''


int serializeTimeTotal = 0;
int deserializeTimeTotal = 0;

for (int j = 0; j < 50; j++) {
    def startTime = System.currentTimeMillis()

    for (int i = 0; i < 1000; i++) {
        def complex = new Complex(
                list: [
                        new Simple(id: "item 0", value: 0.0, flag: true),
                        new Simple(id: "item 1", value: 1.0, flag: false),
                        new Simple(id: "item 2", value: 2.0, flag: true)
                ],
                simple: new Simple(id: "something", value: 42.0, flag: true)
        )

        objectMapper.writeValueAsString(complex)
    }

    def serializeTime = System.currentTimeMillis() - startTime
    serializeTimeTotal += serializeTime

    startTime = System.currentTimeMillis()

    for (int i = 0; i < 1000; i++) {
        objectMapper.readValue(data, Complex)
    }

    def deserializeTime = System.currentTimeMillis() - startTime
    deserializeTimeTotal += deserializeTime
}

print """totals:
    serializedTime:     $serializeTimeTotal
    deserializedTime:   $deserializeTimeTotal"""
