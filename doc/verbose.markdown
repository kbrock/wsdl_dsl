- Hello I'm keenan brock
	- today I'd like to share with you a tool that I used to be _agile with soap_
	- the tool is _a dsl to produce wsdls_

---
---

- The topics of this discussion are:
- Agile: Agile is a development methodology
	- incrementally adding functionality in short quick iterations until the web application is complete
- the web applications interface can be soap and wsdl - Who here has developed with soap?
- Every web application has code. the best code is the code you don't have to write.
	- doesn't need to exist or it was produced for you
- And that is the role of the Domain Specific Languages. Who has developed in Ruby on Rails? (DSLs?)
	- a targeted language to describe a limited domain
		- in this case web services.
	- I use a dsl to help me produce web services.
		- wsdl
		- xsd
		- developer documentation

---
- Since there are many ways to describe a web service in wsdl
	- the team needs to agree upon a standard template.

---
---
- One thing that comes into play is the target platform
- All platforms have tools to assist with soap development
	- but the various tools don't all support the same feature
	- The standard template needs to just use the features of the targeted platforms

---
- Having a standard template is great
	- but producing a WSDL that conforms to the template is a tedious task

---
---

- Lets talk about something tangible
- Here is a data model with
	- a person who has many addresses and one company
	- The company also has an address

- just focusing on the xsd, which holds the data model portion of the web service
	- it is 36 lines, 15 of which are standard boiler plate
		- it defines the data structures 1 time
		- and line count wise it looks similar to dsl.
	- the 15 lines basically makes up the difference between the two

---
---
- The XSD describes all the data types
	- with comments have descriptions to further help developer

---
---
- Here is the DSL that produced the XSD (and the picture on the previous page)
- They look about the same
	- stating the data types, descriptions

---
- Nice thing about the DSL is it will produce formats that
	- may be easier for developers to consume

---
---
- Java, diagrams

---
also the picture

---
---
- The WSDL describes all the methods
- No that is larger
	- 230 lines, half of which are boiler plate
	- inline wsdl (...) is made up of the xsd and wsdl
		- roughly the size of both combined, but it has a little less fluff
- This is where you can see a difference in the length of the DSL
	- it is 31 lines
		- and the lines are less dense
	- the dsl was enhanced for crud web services specifically,
		- so those can be produced in 1 line

---
- one key thing to note is the number of times the data type fields are listed

---
---
- Tools work better if simple types are listed in field declarations.
	- So all the fields are listed in the update and create operation

---
- This wsdl is 2 pages, and only performs the update operation

---
---

The dsl for this 

- the explode argument lists out all the fields of person
	- and exclude says not to include that field
- this eliminates the duplicate definition of the person fields
	- Next iteration if the person data type is modified,
		- this wsdl will pick up those changes

---
C.R.U.D is almost boiler plate, so it can be reduced to 1 line

---
---

at the bottom

...

---
---
- The DSL is more efficient
	- less test
	- less redundant information to maintain
	- focus on business technology (not the wsdl)
- More consistent
	- documents and diagrams are standardized
	- template changes propagate
- all this results in a significant speedup
	- ...
- This speed up effects the team dynamics
	- more willing to 
	