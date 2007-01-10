From: "wim appermans" <wim.lists@gmail.com>
Subject: NFS3ERR_ACCES on getattribute
Date: Thu, 11 Jan 2007 00:52:01 +0100
Message-ID: <e468ef330701101552n2e2ee36w47497e19dd9cf136@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2035638725=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H4nEg-0000qi-AO
	for nfs@lists.sourceforge.net; Wed, 10 Jan 2007 15:52:02 -0800
Received: from an-out-0708.google.com ([209.85.132.247])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H4nEh-00036G-4n
	for nfs@lists.sourceforge.net; Wed, 10 Jan 2007 15:52:04 -0800
Received: by an-out-0708.google.com with SMTP id d40so309576and
	for <nfs@lists.sourceforge.net>; Wed, 10 Jan 2007 15:52:02 -0800 (PST)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============2035638725==
Content-Type: multipart/alternative;
	boundary="----=_Part_617_1611699.1168473121933"

------=_Part_617_1611699.1168473121933
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

I'm struggeling for a while now with nfs, and I don't really know how
to go forward anymore, so I was hoping someone over here could give me
some ideas...

The setup is rather simple: one linux machine, acting running an nfs
server and a few linux clients. Athentication and stuff is done via
ldap

What we're seeing is that on the clients, files seem to be randomly
inaccessable.
I'm mounting /home. and if I do someting like 'find .' in my homedir,
nfs will give randomly errors on files that are not accessible. The
thing is, the files it list have the right permissions. And if I run
the command a few times in a row, the files it complains about are not
the same. It also gives 'stale filehandler' errors.

I got a small test now that fails consistently. It goes like this:

* mount the nfs drive
* do an ls of a specific directory (this is a dir that I saw turning up
a lot in the 'find' errors)
* ls works correctly
* do an ls again
* now ls fails and gives me 'access denied'

If I unmount and repeat: same behaviour

I made a trace with wireshark, and this is what I get:

  V3 NULL Call (Reply In 42)
  V3 NULL Reply (Call In 40)
  V3 NULL Call (Reply In 82)
  V3 NULL Reply (Call In 80)
  V3 FSINFO Call (Reply In 85), FH:0x0493dc00
  V3 FSINFO Reply (Call In 84)
  V3 GETATTR Call (Reply In 87), FH:0x0493dc00
  V3 GETATTR Reply (Call In 86)  Directory mode:2775 uid:0 gid:50
  V3 ACCESS Call (Reply In 92), FH:0x0493dc00
  V3 ACCESS Reply (Call In 91)
  V3 LOOKUP Call (Reply In 95), DH:0x0493dc00/chrisr
  V3 LOOKUP Reply (Call In 94), FH:0x086861a2
  V3 ACCESS Call (Reply In 97), FH:0x086861a2
  V3 ACCESS Reply (Call In 96)
  V3 LOOKUP Call (Reply In 99), DH:0x086861a2/.evolution
  V3 LOOKUP Reply (Call In 98), FH:0x446a61a2
  V3 GETATTR Call (Reply In 101), FH:0x446a61a2
  V3 GETATTR Reply (Call In 100)  Directory mode:0777 uid:2000
gid:2000
  V3 ACCESS Call (Reply In 103), FH:0x446a61a2
  V3 ACCESS Reply (Call In 102)
  V3 READDIRPLUS Call (Reply In 106), FH:0x446a61a2
  V3 READDIRPLUS Reply (Call In 104) . .. addressbook cache calendar
mail memos signatures tasks camel-cert.db cert8.db key3.db secmod.db
  V3 GETATTR Call (Reply In 109), FH:0x446a61a2
  V3 GETATTR Reply (Call In 108) Error:NFS3ERR_ACCES

So if I understand correclty (I'm new to nfs. bear with me), The client
first gets the filehandler of the directory of which I do an ls, and
then does a READDIRPLUS. All is fine so far.
When I do the second ls, it does a GETATTR, which gets an NFS3ERR_ACCES
back.

So there are a few things I don't understand.

* why does a GETATTR goes well the first time, and gets an error the
second time
* why is the second GETATTR done in the first place, isn't this
supposed to be cached? (I remeber reading something about attribute
caching somewhere, but I'm not sure it has anything to do with this)
* what does the NFS3ERR_ACCES mean. Can it have something to do with
file locking?

Another thing I should probably tell is that the same dirs are also
shared with CIFS. Can there be some kind of conflict between CIFS and
NFS

And if it has something to do with locking, is there a way to find out
who is locking what and why?
(some pointers to a comprehensive description of the whole lcoking
thing would also be appreciated. this is all rather obscure to me)

Can the LDAP setup have anything to do with it? I think not, since nfs
just compares gid and uid numbers and doesn't have to do a lookup of
any group or user names, but maybe I'm missing something.

Any help would be greatly appreciated. Also pointers on how to get more
information on what's happening on the NFS server side or what there is
still to do to get a better understanding on what is going on..

Thanks,

Wim

------=_Part_617_1611699.1168473121933
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,<br><br>I&#39;m struggeling for a while now with nfs, and I don&#39;t really know how<br>to go forward anymore, so I was hoping someone over here could give me<br>some ideas...<br><br>The setup is rather simple: one linux machine, acting running an nfs
<br>server and a few linux clients. Athentication and stuff is done via<br>ldap<br><br>What we&#39;re seeing is that on the clients, files seem to be randomly<br>inaccessable.<br>I&#39;m mounting /home. and if I do someting like &#39;find .&#39; in my homedir,
<br>nfs will give randomly errors on files that are not accessible. The<br>thing is, the files it list have the right permissions. And if I run<br>the command a few times in a row, the files it complains about are not<br>
the same. It also gives &#39;stale filehandler&#39; errors.<br><br>I got a small test now that fails consistently. It goes like this:<br><br>* mount the nfs drive<br>* do an ls of a specific directory (this is a dir that I saw turning up
<br>a lot in the &#39;find&#39; errors)<br>* ls works correctly<br>* do an ls again<br>* now ls fails and gives me &#39;access denied&#39;<br><br>If I unmount and repeat: same behaviour<br><br>I made a trace with wireshark, and this is what I get:
<br><br> &nbsp; V3 NULL Call (Reply In 42)<br> &nbsp; V3 NULL Reply (Call In 40)<br> &nbsp; V3 NULL Call (Reply In 82)<br> &nbsp; V3 NULL Reply (Call In 80)<br> &nbsp; V3 FSINFO Call (Reply In 85), FH:0x0493dc00<br> &nbsp; V3 FSINFO Reply (Call In 84)
<br> &nbsp; V3 GETATTR Call (Reply In 87), FH:0x0493dc00<br> &nbsp; V3 GETATTR Reply (Call In 86) &nbsp;Directory mode:2775 uid:0 gid:50<br> &nbsp; V3 ACCESS Call (Reply In 92), FH:0x0493dc00<br> &nbsp; V3 ACCESS Reply (Call In 91)<br> &nbsp; V3 LOOKUP Call (Reply In 95), DH:0x0493dc00/chrisr
<br> &nbsp; V3 LOOKUP Reply (Call In 94), FH:0x086861a2<br> &nbsp; V3 ACCESS Call (Reply In 97), FH:0x086861a2<br> &nbsp; V3 ACCESS Reply (Call In 96)<br> &nbsp; V3 LOOKUP Call (Reply In 99), DH:0x086861a2/.evolution<br> &nbsp; V3 LOOKUP Reply (Call In 98), FH:0x446a61a2
<br> &nbsp; V3 GETATTR Call (Reply In 101), FH:0x446a61a2<br> &nbsp; V3 GETATTR Reply (Call In 100) &nbsp;Directory mode:0777 uid:2000<br>gid:2000<br> &nbsp; V3 ACCESS Call (Reply In 103), FH:0x446a61a2<br> &nbsp; V3 ACCESS Reply (Call In 102)<br>
 &nbsp; V3 READDIRPLUS Call (Reply In 106), FH:0x446a61a2<br> &nbsp; V3 READDIRPLUS Reply (Call In 104) . .. addressbook cache calendar<br>mail memos signatures tasks camel-cert.db cert8.db key3.db secmod.db<br> &nbsp; V3 GETATTR Call (Reply In 109), FH:0x446a61a2
<br> &nbsp; V3 GETATTR Reply (Call In 108) Error:NFS3ERR_ACCES<br><br>So if I understand correclty (I&#39;m new to nfs. bear with me), The client<br>first gets the filehandler of the directory of which I do an ls, and<br>then does a READDIRPLUS. All is fine so far.
<br>When I do the second ls, it does a GETATTR, which gets an NFS3ERR_ACCES<br>back.<br><br>So there are a few things I don&#39;t understand.<br><br>* why does a GETATTR goes well the first time, and gets an error the<br>
second time<br>* why is the second GETATTR done in the first place, isn&#39;t this<br>supposed to be cached? (I remeber reading something about attribute<br>caching somewhere, but I&#39;m not sure it has anything to do with this)
<br>* what does the NFS3ERR_ACCES mean. Can it have something to do with<br>file locking?<br><br>Another thing I should probably tell is that the same dirs are also<br>shared with CIFS. Can there be some kind of conflict between CIFS and
<br>NFS<br><br>And if it has something to do with locking, is there a way to find out<br>who is locking what and why?<br>(some pointers to a comprehensive description of the whole lcoking<br>thing would also be appreciated. this is all rather obscure to me)
<br><br>Can the LDAP setup have anything to do with it? I think not, since nfs<br>just compares gid and uid numbers and doesn&#39;t have to do a lookup of<br>any group or user names, but maybe I&#39;m missing something.<br>
<br>Any help would be greatly appreciated. Also pointers on how to get more<br>information on what&#39;s happening on the NFS server side or what there is<br>still to do to get a better understanding on what is going on..
<br><br>Thanks,<br><br>Wim

------=_Part_617_1611699.1168473121933--


--===============2035638725==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============2035638725==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============2035638725==--
