From: basilis <bts@the.forthnet.gr>
Subject: root over nfs and fsck
Date: Sun, 15 Feb 2004 23:00:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <76271145.20040215230021@the.forthnet.gr>
Reply-To: basilis <bts@the.forthnet.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AsTQ1-0001Xu-B5
	for nfs@lists.sourceforge.net; Sun, 15 Feb 2004 13:03:13 -0800
Received: from athmta04.forthnet.gr ([193.92.150.25] helo=forthnet.gr)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AsTI2-0003VH-8h
	for nfs@lists.sourceforge.net; Sun, 15 Feb 2004 12:54:58 -0800
Received: from GIGAS (ppp1-adsl-167.the.forthnet.gr [213.16.182.167])
	by forthnet.gr (8.12.2-20030919/8.12.2) with ESMTP id i1FKxqaH005064
	for <nfs@lists.sourceforge.net>; Sun, 15 Feb 2004 22:59:52 +0200
To: nfs@lists.sourceforge.net
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

Hello everybody!

   I  am running debian unstable (kernel 2.4.22) and I am mounting the
root over nfs from another debian machine.

   cat /proc/mounts

rootfs / rootfs rw 0 0
/dev/root / nfs rw,v3,rsize=4096,wsize=4096,hard,tcp,nolock,addr=10.107.13.66 0 0
proc /proc proc rw 0 0
devpts /dev/pts devpts rw 0 0
tmpfs /dev/shm tmpfs rw 0 0

   I  would like to ask, whether the options I use are safe, regarding
the  filesystem health in case of power failure. I mean, if there is a
power  failure, is there any danger for filesystem corruption? If yes,
is there any way to avoid it (besides buying a ups ;-) )?

   BTW, after a power failure, I ran fsck / but nothing happened.. How
can I fsck my "root over nfs" partition? Below, I cat my fstab:

10.107.11.11:/rootnfs / nfs rw,tcp,vers=3 0 0

   Thanx in advance,

-- 
Best regards,
 basilis                          mailto:bts@the.forthnet.gr



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
