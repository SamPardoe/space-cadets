import httplib2
from bs4 import BeautifulSoup, SoupStrainer
import time
import threading
links = []
names = []



completeScrape = False

http = httplib2.Http()
def scrape(start,end):
    fileName = "storage.txt"
    file = open(fileName, "w")
    for i in range(start,end):
        status, response = http.request('http://www.southampton.ac.uk/people?page='+str(i))
        
        for link in BeautifulSoup(response, 'html.parser', parse_only=SoupStrainer('a')):
            if link.has_attr('href'):
                if link['href'] in links:
                    pass
                else:
                    print(link['href'])
                    links.append(link['href'])
                    try:
                        file.write(link['href']+"\n")
                    except UnicodeEncodeError:
                        pass
    file.close()
    global completeScrape
    completeScrape = True

lock = threading.Lock()

timer = 0
def backgroundTime():
    global completeScrape
    global timer
    while completeScrape == False:
        time.sleep(1)
        with lock:
            timer+=1
        

timeThread = threading.Thread(target = backgroundTime)
timeThread.start()
scrape(0,437)
print(timer)
newLinks = []
letterDrop = 0

for linky in links:
    nLink = ''
    offset = 0
    split_linky = [linky[i:i + 1] for i in range(0,len(linky))]

    if linky.__contains__('/people'):
        letterDrop = 15
    elif linky.__contains__('mailto'):
        letterDrop = 7
        linky = linky.lower()
    elif linky.__contains__('tel') and linky.__contains__('+'):
        letterDrop = 4
        linky = linky.strip()

    if (not(linky.__contains__('/people/')) and not(linky.__contains__('mailto'))) and (not(linky.__contains__('tel:')) and not(linky.__contains__('+44'))):
        pass
    
    elif (linky.__contains__('/people/') or linky.__contains__('mailto')) or (linky.__contains__('tel:') or linky.__contains__('+')):
        loop = ["|","/","-","\\"]
        l = 0
        while letterDrop > 0:
            try:
                split_linky.pop(0)
#                letterDrop -= 1
                print(loop[l&len(loop)],l,end="\r")
                l+=1
            except (ValueError, IndexError):
                pass
            letterDrop -= 1
    
        for letter in split_linky:
    
            if letter == ' ' and linky.__contains__('+'):
                letter = ''

            if letter == '-' and not(linky.__contains__('mailto')):
                letter = ' '
            
            nLink += letter
    
        newLinks.append(nLink)

    else:
        pass
    #split into seperate arrays
print(newLinks)

#open and close files to clear?

nameFile = open("nameFile.txt", "w")
nameFile.write('')
nameFile.close()
emailFile = open("emailFile.txt", "w")
emailFile.write('')
emailFile.close()
phoneFile = open("phoneFile.txt", "w")
phoneFile.write('')
phoneFile.close()

nameFile = open("nameFile.txt","a")
emailFile = open("emailFile.txt","a")
phoneFile = open("phoneFile.txt","a")

previousEntry = ''
counter = 1
for entry in newLinks:
    if entry == 'N/A':
        continue

    if not(entry.__contains__('@')) and not(entry.__contains__('+')) and not(entry.__contains__('tel:')):
        nameFile.write(entry.lower()+"\n")
    elif entry.__contains__('@') and not(entry.__contains__('+')):
        emailFile.write(entry.lower()+'\n')
    elif not(entry.__contains__('@')) and entry.__contains__('+'):
        phoneFile.write(entry+'\n')
    
    if (not(entry.__contains__('@')) and not(entry.__contains__('+'))) and (not(previousEntry.__contains__('@')) and not(previousEntry.__contains__('+'))) and counter != 1:
        emailFile.write('N/A \n')
        phoneFile.write('N/A \n')
    elif (not(entry.__contains__('@')) and not(entry.__contains__('+'))) and (previousEntry.__contains__('@')) and counter != 1:
        phoneFile.write('N/A \n')

    previousEntry = entry
    counter += 1

nameFile.close()
emailFile.close()
phoneFile.close()
print("finish")
with lock:
    print(timer)

FileIndex = 0
noPerson = False

def returnDetails():
    #getline - into array and index?
    #pull info from that line in parallel files
    #return to user

    #same for other given info

    nameFile = open("nameFile.txt","r+")
    mailFile = open("emailFile.txt","r+")
    phoneFile = open("phoneFile.txt","r+")

    global FileIndex
    global noPerson

    NameArr = nameFile.readlines()
    MailArr = mailFile.readlines()
    PhoneArr = phoneFile.readlines()

    def fromName(name):
        global FileIndex
        for i in range(0,len(NameArr)):
            if NameArr[i].__contains__(name):
                FileIndex = i
                break
            else:
                continue
        if FileIndex == 0 and not(NameArr[0].__contains__(name)):
            global noPerson
            noPerson = True
            print("no person under the name "+name)
    def fromMail(mail):
        global FileIndex
        for i in range(0,len(MailArr)):
            if MailArr[i].__contains__(mail):
                FileIndex = i
                break
            else:
                continue
        if FileIndex == 0 and not(MailArr[0].__contains__(mail)):
            global noPerson
            noPerson = True
            print("no person under the email "+mail)
        else:
            pass



    def fromNum(number):
        global FileIndex
        for i in range(0,len(PhoneArr)):
            if PhoneArr[i].__contains__(number):
                FileIndex = i
                break
            else:
                continue
        if FileIndex == 0 and not(PhoneArr[0].__contains__(number)):
            global noPerson
            noPerson = True
            print("no person under the number "+number)
        else:
            pass

    finishLookup = False
    while finishLookup == False:
        if (input("Would you like to search for a person? (y/n) ")) == "n":
            finishLookup = True
            print("Goodbye.")
        else:
            

            lookupTerm = input("Enter name, E-Mail, or phone number: ")
        
            if lookupTerm.__contains__('@'):
                fromMail(lookupTerm.lower())
            elif lookupTerm.__contains__('+') and not(lookupTerm.__contains__('@')):
                fromNum(lookupTerm.strip())
            elif not(lookupTerm.__contains__('@')) and not(lookupTerm.__contains__('+')):
                fromName(lookupTerm.lower())
            else:
                print("Enter term in one of the available formats")
    
            if noPerson == False:
                try:
                    print("Name: "+NameArr[FileIndex]+"\n"+"E-Mail: "+MailArr[FileIndex]+"\n"+"Phone Number: "+PhoneArr[FileIndex])
                except ValueError:
                    pass
            else:
                pass
            noPerson = False
    nameFile.close()
    mailFile.close()
    phoneFile.close()

returnDetails()
