From: Helge Bahmann <hcb@chaoticmind.net>
Subject: NFSv3 server: lockd hangs
Date: Wed, 18 Oct 2006 11:30:42 +0200 (CEST)
Message-ID: <Pine.LNX.4.44.0610181118190.8690-100000@lothlorien.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ga7lC-0004zs-6Y
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 02:30:50 -0700
Received: from m4s07.vlinux.de ([83.151.27.105])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1Ga7lB-000166-U3
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 02:30:51 -0700
Received: from pd95de393.dip.t-dialin.net ([217.93.227.147]
	helo=lothlorien.local)
	by m4s07.vlinux.de with asmtp (Exim 3.35 #1 (Debian))
	id 1Ga7l6-0001cg-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Oct 2006 11:30:44 +0200
Received: from helge (helo=localhost)
	by lothlorien.local with local-esmtp (Exim 4.50) id 1Ga7l4-0002IC-MH
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 11:30:42 +0200
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

I have problems with lockd on an NFS server (stock 2.6.17 kernel); I have
no easy test case to reproduce the problem, but after one to two weeks of
uptime the lockd process is simply stuck. It fails to shutdown
("lockd_down: lockd failed to exit"; afterwards the "[lockd]" thread is
still around and stuck in D state) and is otherwise unresponsive. No other
kernel messages are logged.

Only full reboot solves the problem.

Can you tell me
- if there is a known lockd problem? I could not find anything in the
archives, but maybe I have missed something
- if it may be a file-system-specific problem (reiserfs in the present
case)?
- what else can I do to provide more useful diagnostics?

Thanks and best regards
-- 
Helge Bahmann <hcb@chaoticmind.net>                     /| \__
The past: Smart users in front of dumb terminals       /_|____\
                                                     _/\ |   __)
Wer im finally-Block sitzt, sollte nicht             \\ \|__/__|
mit exceptions werfen.                                \\/___/ |
                                                        |


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
