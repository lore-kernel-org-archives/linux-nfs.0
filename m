From: Helge Bahmann <hcb@chaoticmind.net>
Subject: NFS over localhost?
Date: Mon, 5 Dec 2005 09:37:29 +0100 (CET)
Message-ID: <Pine.LNX.4.44.0512050921200.18221-100000@lothlorien.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EjBqm-0008IY-JP
	for nfs@lists.sourceforge.net; Mon, 05 Dec 2005 00:37:32 -0800
Received: from m4s07.vlinux.de ([83.151.27.105])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1EjBql-0008W6-A5
	for nfs@lists.sourceforge.net; Mon, 05 Dec 2005 00:37:32 -0800
Received: from p54b4e15f.dip.t-dialin.net ([84.180.225.95] helo=lothlorien.local)
	by m4s07.vlinux.de with asmtp (Exim 3.35 #1 (Debian))
	id 1EjBqg-00014e-00
	for <nfs@lists.sourceforge.net>; Mon, 05 Dec 2005 09:37:27 +0100
Received: from helge (helo=localhost)
	by lothlorien.local with local-esmtp (Exim 3.35 #1 (Debian))
	id 1EjBqj-0004ke-00
	for <nfs@lists.sourceforge.net>; Mon, 05 Dec 2005 09:37:29 +0100
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hello list!

Setup: One volume ("/export") exported to 192.168.1.1 via kernel-space
NFSv3 server; imported from the same machine 192.168.1.1 (at "/import");
this setup is only for configuration testing purposes.

Symptoms: Under heavy write load ("dd if=/dev/zero of=/import/x") both NFS
client and NFS server deadlock reproducibly, various kernels 2.6.8 -
2.6.15-rc4 affected, both SMP and non-SMP. All accesses to "/import" hang
indefinitely, sometimes also the mount-point "/export" becomes unusable;
both reiserfs and ext3 as back-end filesystems are affected. This
situation happens as the "free" memory (as reported by vmstat)
approaches zero, so it may possibly be an out-of-memory-thing.

Question(s): Is this kind of deadlock "supposed" to happen? I mean, there
is no purpose in using NFS in this kind of way (except for configuration
testing), so I can imagine no one bothers to clean up the interaction
between NFS client and server in this scenario. However I am slightly
concerned that a similiar scenario might be possible with our "real" NFS
server, as it can receive data faster over the network than it can write
out to the disks. Is this possible?

Any comments? Thanks and best regards
-- 
Helge Bahmann <hcb@chaoticmind.net>                     /| \__
The past: Smart users in front of dumb terminals       /_|____\
                                                     _/\ |   __)
$ ./configure                                        \\ \|__/__|
checking whether build environment is sane... yes     \\/___/ |
checking for AIX... no (we already did this)            |



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
