From: Tim Cullen <timcullen2001@yahoo.com>
Subject: [NFS] Trouble exporting OCFS2 via NFS
Date: Mon, 28 Sep 2009 19:15:40 +0000 (GMT)
Message-ID: <710118.59930.qm@web43139.mail.sp1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:44697 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752983AbZI1TQ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2009 15:16:57 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1MsLiV-0000UH-U3
	for linux-nfs@vger.kernel.org; Tue, 29 Sep 2009 05:17:00 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've been attempting to export an OCFS2 filesystem via NFS without success. My NFS client mounts the exported filesystem without problem but all subsequent access to the mount point results in Stale NFS File Handle error. On the NFS server in /var/log/messages I see error messages like the ones below complaining about attempts to access beyond the end of the disk.

I've spoken with a supporting engineer at Oracle who didn't know what the problem might be and suggested I try this list. I'm hoping somebody here might be familiar with this problem.

Sep 24 10:52:36 devapp1 kernel: ocfs2: Mounting device (8,3) on (node 2, slot 0)
with ordered data mode.
Sep 24 10:53:16 devapp1 kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4
state recovery directory
Sep 24 10:53:16 devapp1 kernel: NFSD: starting 90-second grace period
Sep 24 10:53:32 devapp1 mountd[15182]: authenticated mount request from
10.100.0.50:723 for /mnt/rna (/mnt/rna)
Sep 24 10:53:53 devapp1 kernel: attempt to access beyond end of device
Sep 24 10:53:53 devapp1 kernel: sda3: rw=0, want=301300545749000, limit=348803280
Sep 24 10:53:53 devapp1 kernel: (15178,3):ocfs2_read_locked_inode:460 ERROR:
status = -5
Sep 24 10:54:11 devapp1 kernel: attempt to access beyond end of device
Sep 24 10:54:11 devapp1 kernel: sda3: rw=0, want=301334905487368, limit=348803280
Sep 24 10:54:11 devapp1 kernel: (15178,3):ocfs2_read_locked_inode:460 ERROR:
status = -5
Sep 24 10:54:12 devapp1 kernel: attempt to access beyond end of device
Sep 24 10:54:12 devapp1 kernel: sda3: rw=0, want=301300545749000, limit=348803280
Sep 24 10:54:12 devapp1 kernel: (15178,3):ocfs2_read_locked_inode:460 ERROR:
status = -5
Sep 24 10:54:12 devapp1 kernel: attempt to access beyond end of device
Sep 24 10:54:12 devapp1 kernel: sda3: rw=0, want=301334905487368, limit=348803280
Sep 24 10:54:12 devapp1 kernel: (15178,3):ocfs2_read_locked_inode:460 ERROR:
status = -5
Sep 24 10:54:15 devapp1 kernel: attempt to access beyond end of device
Sep 24 10:54:15 devapp1 kernel: sda3: rw=0, want=301334905487368, limit=348803280
Sep 24 10:54:15 devapp1 kernel: (15178,3):ocfs2_read_locked_inode:460 ERROR:
status = -5
Sep 24 10:54:15 devapp1 kernel: attempt to access beyond end of device
Sep 24 10:54:15 devapp1 kernel: sda3: rw=0, want=301334905487368, limit=348803280
Sep 24 10:54:15 devapp1 kernel: (15178,3):ocfs2_read_locked_inode:460 ERROR:
status = -5



      

------------------------------------------------------------------------------
Come build with us! The BlackBerry&reg; Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9&#45;12, 2009. Register now&#33;
http://p.sf.net/sfu/devconf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

