Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.agmk.net ([91.192.224.71]:50622 "EHLO mail.agmk.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758534Ab0LNSr2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Dec 2010 13:47:28 -0500
Received: from localhost (unknown [91.192.224.71])
	by mail.agmk.net (Postfix) with ESMTP id 73D0D8706EF
	for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 19:14:59 +0100 (CET)
Received: from mail.agmk.net ([91.192.224.71])
	by localhost (agmk.net [91.192.224.71]) (amavisd-new, port 10024)
	with ESMTP id xWrN4R8JaObb for <linux-nfs@vger.kernel.org>;
	Tue, 14 Dec 2010 19:14:58 +0100 (CET)
Received: from vmx.localnet (unknown [89.79.206.92])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.agmk.net (Postfix) with ESMTP id B4F682428102
	for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 19:14:58 +0100 (CET)
From: =?utf-8?q?Pawe=C5=82_Sikora?= <pluto@agmk.net>
To: linux-nfs@vger.kernel.org
Subject: nondeterministic exportfs? /home/users (ext4) does not support NFS export.
Date: Tue, 14 Dec 2010 19:14:54 +0100
Content-Type: Text/Plain;
  charset="utf-8"
Message-Id: <201012141914.55076.pluto@agmk.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

i have a new machine with fresh linux distro (2.6.36.2 kernel, nfs-1.2.3)
and the configured export doesn't work sometimes.

following md1, md2 partitions are mounted and configured for exporting:

Filesystem            Size  Used Avail Use% Mounted on
/dev/md0              7.6G  1.4G  5.8G  19% /
/dev/md1              1.9T   42G  1.9T   3% /home/atest
/dev/md2              798G  116G  682G  15% /home/users

# /etc/rc.d/init.d/nfs status
Configured NFS exports:
/home/atest     *(rw,async,no_subtree_check,no_root_squash,insecure_locks)
/home/users     *(rw,sync,no_wdelay,no_subtree_check,no_root_squash,insecure_locks)

Active NFS exports:
/home/atest     <world>(rw,async,wdelay,no_root_squash,no_subtree_check,insecure_locks)
/home/users     <world>(rw,no_root_squash,no_subtree_check,insecure_locks)

rpc.mountd (pid 3195) is running...
nfsd (pid 3213 3212 3211 3210 3209 3208 3207 3206) is running...

# exportfs -v
/home/atest     <world>(rw,async,wdelay,no_root_squash,no_subtree_check,insecure_locks)
/home/users     <world>(rw,no_root_squash,no_subtree_check,insecure_locks)

but the /home/users doesn't work and (bad workaround) re-export is needed.

# exportfs -rv
exporting *:/home/users
exportfs: /home/users does not support NFS export
exporting *:/home/atest

# exportfs -rv
exporting *:/home/users
exporting *:/home/atest

/home/atest works fine, /home/users has weird problems.

what's wrong with this /home/users @ ext4 ?
thanks for any hints.

BR,
Pawel.
