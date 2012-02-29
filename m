Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:56939 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755586Ab2B2BYe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Feb 2012 20:24:34 -0500
Date: Tue, 28 Feb 2012 17:06:29 -0800
From: Simon Kirby <sim@netnation.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [3.2.5] Stale NFS file handle issue on subdirectory of NFSv3 mount
Message-ID: <20120229010629.GC24948@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Since upgrading from 2.6.39-ish to 3.1-ish, and on 3.2.5, we are seeing a
lot of occurrences of Stale NFS file handle errors when accessing a mount
whose NFSv3 source is a subdirectory of another mount point. For example,
in this case:

# mount | grep /shared
10.10.1.1:/storage/vg1/shared on /shared type nfs (rw,hard,intr,tcp,timeo=300,retrans=2,vers=3,addr=10.10.1.1)
10.10.1.1:/storage/vg1/shared/fp on /usr/local/fp type nfs (rw,hard,intr,tcp,timeo=300,retrans=2,vers=3,addr=10.10.1.1)

When the issue occurs, the /shared mount point is fine as is /shared/fp,
but "df" or "ls" or anything on /usr/local/fp will ESTALE. This somehow
corrected itself while I was trying to gather information this time, but
usually the d_ino returned by getdents() on the parent directory shows a
different inode number than for /shared/fp.

When this happens, I am unable to umount -f or umount -l /usr/local/fp
(ESTALE), but I can actually umount /shared; umount /usr/local/fp; and
mount -a, which seems to "fix" it.

is this acting similar to a bind mount internally now and revalidation or
something is breaking in this case? This is happening fairly often, so I
will try to collect more info again next time.

Simon-
