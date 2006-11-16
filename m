From: Helge Bahmann <hcb@chaoticmind.net>
Subject: lockd and krb5
Date: Thu, 16 Nov 2006 11:37:27 +0100
Message-ID: <200611161137.28079.hcb@chaoticmind.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gkecn-0005A4-OR
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 02:37:41 -0800
Received: from m4s07.vlinux.de ([83.151.27.105])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1Gkecn-0000gQ-OW
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 02:37:43 -0800
Received: from pinguin.informatik.tu-freiberg.de ([139.20.16.62])
	by m4s07.vlinux.de with asmtp (Exim 3.35 #1 (Debian))
	id 1Gkecg-0007OI-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Nov 2006 11:37:34 +0100
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

Hello,

I am trying to use NFSv3+sec=krb5 for user home directories and I am still 
hitting lockd problems; server is 2.6.18.1 and client is 2.6.17.9

The symptoms are:
- withouth sec=krb5 everything works fine
- with sec=krb5 file locking breaks in strange ways

With sec=krb5:
- processes on the client "hang" waiting for locks
- /proc/locks on the client shows the corresponding files to be not locked
- /proc/locks on the server shows the corresponding files to be locked, by 
processes that do not exist on either the server nor the client (from the pid 
they must be client processes that have exited already)
- sometimes I receive the message "VFS is out of sync with lock manager!"

Unfortunately I have not been able to write a simple testcase, however KDE 
startup triggers the problem very frequently (lots of apps taking a flurry of 
locks and doing funny things with fork)

Can anyone enlighten me what difference sec=krb5 would make with regards to 
locking behaviour so I can narrow down the problem? I am unfortunately 
completely in the dark.

Best regards
-- 
Mathematicians stand on each other's shoulders while computer scientists stand 
on each other's toes.
-- Richard Hamming

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
