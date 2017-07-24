Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41284 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752092AbdGXDbq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 23 Jul 2017 23:31:46 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 24 Jul 2017 13:18:50 +1000
Subject: [PATCH 2/2] NFS: Optimize fallocate by refreshing mapping when
 needed.
Cc: linux-nfs@vger.kernel.org
Message-ID: <150086633062.13837.17311566890209843076.stgit@noble>
In-Reply-To: <150086579083.13837.3550463220871996964.stgit@noble>
References: <150086579083.13837.3550463220871996964.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

posix_fallocate() will allocate space in an NFS file by considering
the last byte of every 4K block.  If it is before EOF, it will read
the byte and if it is zero, a zero is written out.  If it is after EOF,
the zero is unconditionally written.

For the blocks beyond EOF, if NFS believes its cache is valid, it will
expand these writes to write full pages, and then will merge the pages.
This results if (typically) 1MB writes.  If NFS believes its cache is
not valid (particularly if NFS_INO_INVALID_DATA or
NFS_INO_REVAL_PAGECACHE are set - see nfs_write_pageuptodate()), it will
send the individual 1-byte writes. This results in (typically) 256 times
as many RPC requests, and can be substantially slower.

Currently nfs_revalidate_mapping() is only used when reading a file or
mmapping a file, as these are times when the content needs to be
up-to-date.  Writes don't generally need the cache to be up-to-date, but
writes beyond EOF can benefit, particularly in the posix_fallocate()
case.

So this patch calls nfs_revalidate_mapping() when writing beyond EOF -
i.e. when there is a gap between the end of the file and the start of
the write.  If the cache is thought to be out of date (as happens after
taking a file lock), this will cause a GETATTR, and the two flags
mentioned above will be cleared.  With this, posix_fallocate() on a
newly locked file does not generate excessive tiny writes.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/file.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index d264363559db..af330c31f627 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -617,6 +617,8 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 		if (result)
 			goto out;
 	}
+	if (iocb->ki_pos > i_size_read(inode))
+		nfs_revalidate_mapping(inode, file->f_mapping);
 
 	nfs_start_io_write(inode);
 	result = generic_write_checks(iocb, from);


