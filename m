From: Vaclav Stepan <w@linux.fjfi.cvut.cz>
Subject: fh_verify: no squashed_root access at session/lastsession (2.4.23
 knfsd and Solaris 9)
Date: Wed, 10 Dec 2003 17:25:54 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1071073554.1392.15.camel@tp>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AU7Ow-0007Gy-W3
	for nfs@lists.sourceforge.net; Wed, 10 Dec 2003 08:41:26 -0800
Received: from kmlinux.fjfi.cvut.cz ([147.32.8.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AU7Ow-0003BO-AU
	for nfs@lists.sourceforge.net; Wed, 10 Dec 2003 08:41:26 -0800
Received: from kmlinux.fjfi.cvut.cz (root@localhost)
	by kmlinux.fjfi.cvut.cz (8.12.8/8.12.8) with SMTP id hBAGfIqd003538
	for <nfs@lists.sourceforge.net>; Wed, 10 Dec 2003 17:41:18 +0100
Received: from bobr ([192.168.1.13])
	by kmlinux.fjfi.cvut.cz (8.12.8/8.12.8) with ESMTP id hBAGfIui003530
	for <nfs@lists.sourceforge.net>; Wed, 10 Dec 2003 17:41:18 +0100
Received: from [192.168.1.7] (helo=tp ident=mail)
	by bobr with esmtp (Exim 3.35 #1 (Debian))
	id 1AU7Oo-0002hb-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Dec 2003 17:41:18 +0100
Received: from w by tp with local (Exim 3.35 #1 (Debian))
	id 1AU79v-0000xI-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Dec 2003 17:25:55 +0100
To: NFS mailing list <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

we ran in trouble while upgrading from 2.4.20pre1 to 2.4.23 kernel
on a GNU/Linux box which serves two Solaris 9 clients and one Linux
client.

When the export get set up and some mount attempt comes, the server
starts flooding the logs and screen with:

fh_verify: no root_squashed access at session/lastsession

(several messages per second). The server doesn't panic or crash --- I
am able to shut down knfsd without any harm --- everything works, just
the NFS drives are inaccessible.

There is a workaround using no_subtree_check as an option in the exports
file, but can anyone help me explain this? I found only two relevant
posts using Google with "fh_verify root_squashed" as keywords:

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=110421
http://www.ussg.iu.edu/hypermail/linux/kernel/0309.1/1159.html

Thanks for your time

Vaclav Stepan
-- 
Vaclav Stepan
w@linux.fjfi.cvut.cz
http://linux.fjfi.cvut.cz/~w/


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
