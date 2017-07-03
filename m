Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51352 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750793AbdGCF17 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Jul 2017 01:27:59 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 03 Jul 2017 15:27:26 +1000
Subject: [PATCH 0/2] Protect against a demented NFS server.
Cc: linux-nfs@vger.kernel.org
Message-ID: <149905933708.6926.8527235505351389675.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

You wouldn't expect an NFS server to get be unable to decide if
something is a file or a directory, but

[32337914.127428] nfs_update_inode: inode 134 mode changed, 0100600 to 0040755
[32337914.127447] nfs_update_inode: inode 136 mode changed, 0100640 to 0040755
[32337914.128485] nfs_update_inode: inode 138 mode changed, 0100640 to 0040755
[32337914.128497] nfs_update_inode: inode 139 mode changed, 0100640 to 0040755
[32337914.128510] nfs_update_inode: inode 140 mode changed, 0100640 to 0040755
[32337914.128521] nfs_update_inode: inode 141 mode changed, 0100640 to 0040755
[32337914.129614] nfs_update_inode: inode 142 mode changed, 0100640 to 0040755
[32337916.233248] nfs_update_inode: inode 144 mode changed, 0100640 to 0040700
[33296458.909828] nfs_update_inode: inode 132 mode changed, 0042770 to 0100755
[33296458.909847] nfs_update_inode: inode 133 mode changed, 0042770 to 0100755

is an actual excerpt from the 'dmesg' logs of a production machine.

You might expect this to cause various system calls to return ESTALE
or EIO or EISDIR or similar, but it actually resulted in a crash.
->private_data is very different for a directory and a file, and
on a 3.0 kernel, the above can lead to confusion of the two data structures.

I'm not sure if the same sequence would cause the same problem on a
current kernel, but there are a couple of places where extra checks
will make us safer.  The following two patches add those checks.

Thanks,
NeilBrown


---

NeilBrown (2):
      NFS: guard against confused server in nfs_atomic_open()
      NFS: check for nfs_refresh_inode() errors in nfs_fhget()


 fs/nfs/dir.c   |    6 ++++--
 fs/nfs/inode.c |   10 ++++++++--
 2 files changed, 12 insertions(+), 4 deletions(-)

--
Signature

