From: =?iso-8859-1?q?Amey=20Inamdar?= <amey_inamdar@yahoo.com>
Subject: Retransmissions over TCP ...
Date: Wed, 10 Sep 2003 21:04:44 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030910200444.49715.qmail@web21104.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xBCn-0004jU-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Sep 2003 13:04:45 -0700
Received: from web21104.mail.yahoo.com ([216.136.227.106])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19xBCn-00054K-1z
	for nfs@lists.sourceforge.net; Wed, 10 Sep 2003 13:04:45 -0700
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

Hi,
    I could not understand why does RPC layer
underneath NFS client retransmit the request while
using NFS over TCP. TCP does reliable delivery of RPC,
ain't it?  Is it because NFS server may drop the
requests/connection at its end?

Thanks in anticipation

Amey

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
