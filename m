Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38452 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751633AbdEPOKJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 May 2017 10:10:09 -0400
Date: Tue, 16 May 2017 22:09:55 +0800
From: Eryu Guan <eguan@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Olga Kornievskaia <kolga@netapp.com>
Subject: [4.12-rc1 regression] copy_file_range(2) stuck in infinite loop
Message-ID: <20170516140955.GZ7250@eguan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

fstests test generic/430 would hang when testing NFSv4.2 using 4.12-rc1
kernel based client. And this is a regression, 4.11 kernel has no
problem. A simple reproducer is like:

# mount -t nfs -o vers=4.2 nfs-server:/export /mnt/nfs
# xfs_io -fc "pwrite 0 4k" /mnt/nfs/testfile
# xfs_io -fc "copy_range /mnt/nfs/testfile" /mnt/nfs/testfile.copy

The last copy_range command never returns, and xfs_io process is in D
state. Some kernel debug code shows that it stuck in infinite loop in
nfs42_proc_copy(), _nfs42_proc_copy() always returns -EAGAIN.

So this looks like a problem introduced by this commit

commit e092693443b995c8e3a565a73b5fdb05f1260f9b
Author: Olga Kornievskaia <kolga@netapp.com>
Date:   Mon May 8 18:02:24 2017 -0400

    NFS append COMMIT after synchronous COPY

    Instead of messing with the commit path which has been causing issues,
    add a COMMIT op after the COPY and ask for stable copies in the first
    space.

    It saves a round trip, since after the COPY, the client sends a COMMIT
    anyway.

    Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Reverting this patch did solve the problem. If you need more info please
let me know.

Thanks,
Eryu
