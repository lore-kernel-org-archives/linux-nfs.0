Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50840 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932079AbdGXOTi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Jul 2017 10:19:38 -0400
Date: Mon, 24 Jul 2017 22:19:35 +0800
From: Eryu Guan <eguan@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [4.13-rc2 regression] NFSv4 fails file permission tests in fstests
 generic/126
Message-ID: <20170724141935.GF9167@eguan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I saw a new NFS failure in 4.13-rc2 kernel when running fstests
generic/126 on NFSv4 mounts, 4.13-rc1 kernel passed the same test.

git bisect pointed the first bad to commit bd8b2441742b.

commit bd8b2441742b49c76bec707757bd9c028ea9838e
Author: Trond Myklebust <trond.myklebust@primarydata.com>
Date:   Tue Jul 11 17:54:34 2017 -0400

    NFS: Store the raw NFS access mask in the inode's access cache
    
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
    Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

I can reproduce it manually with these steps:

mount -t nfs -o vers=4.1 server:/export /mnt/nfs
cp /usr/bin/ls /mnt/nfs
chmod 001 /mnt/nfs/ls
chown 99:99 /mnt/nfs/ls
su testuser -c "/mnt/nfs/ls"

(testuser uid and gid are not 99.)

The last command got permission denied with 4.13-rc2.

Thanks,
Eryu
