From: "=?iso-8859-1?q?Mark=20A.=20Tagliaferro?=" <be_lak@yahoo.co.uk>
Subject: Unable to connect to NFS Server - mountd crashing
Date: Tue, 7 Oct 2003 11:51:28 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031007105128.34052.qmail@web86001.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A6pRi-0001MC-00
	for <nfs@lists.sourceforge.net>; Tue, 07 Oct 2003 03:52:02 -0700
Received: from web86001.mail.ukl.yahoo.com ([217.12.12.32])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A6pRg-00017T-5c
	for nfs@lists.sourceforge.net; Tue, 07 Oct 2003 03:52:00 -0700
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

Hi all,

This is driving me nuts because up to yesterday the system was working but
suddenly it went berserk.  I'm trying to connect to m NFS shares on my SuSE 7.1
server and I'm getting the following error:

mount: RPC: Unable to receive; errorno = Connection refused

After a lot of investigation I stumbled on what is happening.  When the nfs
server is started, 'nfsserver status' gives me 'NFS Server is up'.  When I
check with rpcinfo -p server I see portmap, mountd, nfs and ypbind (i'm using
NIS as well which is still working).

When I try to connect from the client and get the error message something
really weird happens on the server. 'nfsserver status' returns 'NFS server
down' and rpcinfo -p server doesn't show mountd anymore.  

I figure that somehow when the call is made mountd is crashing thus shutting
down the nfs server.

Any idea of why this is happening or how to solve it?

________________________________________________________________________
Want to chat instantly with your online friends?  Get the FREE Yahoo!
Messenger http://mail.messenger.yahoo.co.uk


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
