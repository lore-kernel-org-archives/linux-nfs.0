From: =?iso-8859-1?q?Hank=20Shah?= <hankshah@yahoo.co.in>
Subject: how to enable locking in NFS?
Date: Sat, 17 May 2003 07:12:02 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030517061202.38292.qmail@web8201.mail.in.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web8201.mail.in.yahoo.com ([203.199.70.114])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GuvX-0007Pq-00
	for <nfs@lists.sourceforge.net>; Fri, 16 May 2003 23:12:15 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



   Hello,

   We want to enable mandatory locking in NFS?
   Currently whaen two clients access the same file
for read/write, both are allowed to make changes to
the file.The changes that are reflected are the ones
which are made by the client who closed the file last.

we would like only one client to make changes to the
file at one time.

Is fcntl locking used for the same?
If yes,how do we enable it?
Do we have to include a seperate code for it in nfsd?
We are using Redhat Linux 7.2 , kernel 2.4.7-10, NFSv3

Any suggestions?

Thank You.




=====
H arshit  Shah
A nkit    Shah
N ishit   Shah
K rushita Shah

________________________________________________________________________
Missed your favourite TV serial last night? Try the new, Yahoo! TV.
       visit http://in.tv.yahoo.com


-------------------------------------------------------
This SF.net email is sponsored by: If flattening out C++ or Java
code to make your application fit in a relational database is painful, 
don't do it! Check out ObjectStore. Now part of Progress Software.
http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
