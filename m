From: David Myer <davidmyer800@yahoo.com>
Subject: NFS over TCP
Date: Tue, 27 May 2003 16:40:58 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030527234058.81598.qmail@web21003.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web21003.mail.yahoo.com ([216.136.227.57])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Ko3u-0001DO-00
	for <nfs@lists.sourceforge.net>; Tue, 27 May 2003 16:40:58 -0700
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

I have a few questions doing NFS mount over TCP in
kernel 2.4.18.

1) Doing a few mount operations, I noticed that
sometimes it uses V3 GETATTR call and sometimes it
uses V2 GETATTR call, how does client ( or server )
decide witch version to use ? Strange enough, in case
it did use V3 GETATTR, the prior GETPORT is V2.. does
this make a difference later on ?

2) In reply to the V2 GETATTR call, server reply to
the client socket (port 800) with ACK, then send
another packet ( with PSH/ACK flags on ) with
requested data to port 799,this causes RST from the
client. Anyone seen this behavior of decrementing dest
port ( client port number ) by one ?

Thanks
Dave

__________________________________
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo.
http://search.yahoo.com


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
