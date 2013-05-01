Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.19]:58647 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756935Ab3EAJJj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 May 2013 05:09:39 -0400
Received: from mailout-de.gmx.net ([10.1.76.35]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0M950d-1Ujs3J3tE5-00CQv4 for
 <linux-nfs@vger.kernel.org>; Wed, 01 May 2013 11:09:37 +0200
Message-ID: <5180DBCF.8070303@gmx.de>
Date: Wed, 01 May 2013 11:09:35 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Pseudoflavor 390004 not found!
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With current git kernel 3.9-X (since 1 or 2 days) I'm getting the messages
seen below at a user mode linux guest on which I run trinity.

On the guest I mount via NFSv4 (and in parallel via hostfs) an EXT4 fs from the host system.
The EXT4 resides within a file on a tmpfs which is mounted via loop device.

So on the hosts it looks like :
$> df -m
tmpfs               3072   135      2938   5% /mnt/ramdisk
/dev/loop0           241     5       224   3% /mnt/trinity

$ cat /etc/exports
# /etc/exports: NFS file systems being exported.  See exports(5).
/mnt/trinity    192.168.0.0/16(rw,fsid=0,insecure,no_subtree_check,async,no_root_squash)

and the UML mounts the share /mnt/trinity just onto its mount points /mnt/n22 and /mnt/nfs/n22 respectively.
And these are the messages I'm curious about :

2013-05-01T10:22:55.613+02:00 trinity kernel: gss_create: Pseudoflavor 390004 not found!
2013-05-01T10:22:55.613+02:00 trinity kernel: RPC: Couldn't create auth handle (flavor 390004)

-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
