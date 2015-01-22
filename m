Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.226]:17865 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752011AbbAVO2C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 09:28:02 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        Sasha Levin <sasha.levin@oracle.com>,
        David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: [PATCH v3 04/13] ceph: move spinlocking into ceph_encode_locks_to_buffer and ceph_count_locks
Date: Thu, 22 Jan 2015 09:27:48 -0500
Message-Id: <1421936877-27529-5-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
References: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@primarydata.com>

There is only a single call site for each of these functions, and the
caller takes the i_lock prior to calling them and drops it just
afterward. Move the spinlocking into the functions instead.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 fs/ceph/locks.c      | 4 ++++
 fs/ceph/mds_client.c | 4 ----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/ceph/locks.c b/fs/ceph/locks.c
index c35c5c614e38..366dc2412605 100644
--- a/fs/ceph/locks.c
+++ b/fs/ceph/locks.c
@@ -251,12 +251,14 @@ void ceph_count_locks(struct inode *inode, int *fcntl_count, int *flock_count)
 	*fcntl_count = 0;
 	*flock_count = 0;
 
+	spin_lock(&inode->i_lock);
 	for (lock = inode->i_flock; lock != NULL; lock = lock->fl_next) {
 		if (lock->fl_flags & FL_POSIX)
 			++(*fcntl_count);
 		else if (lock->fl_flags & FL_FLOCK)
 			++(*flock_count);
 	}
+	spin_unlock(&inode->i_lock);
 	dout("counted %d flock locks and %d fcntl locks",
 	     *flock_count, *fcntl_count);
 }
@@ -279,6 +281,7 @@ int ceph_encode_locks_to_buffer(struct inode *inode,
 	dout("encoding %d flock and %d fcntl locks", num_flock_locks,
 	     num_fcntl_locks);
 
+	spin_lock(&inode->i_lock);
 	for (lock = inode->i_flock; lock != NULL; lock = lock->fl_next) {
 		if (lock->fl_flags & FL_POSIX) {
 			++seen_fcntl;
@@ -306,6 +309,7 @@ int ceph_encode_locks_to_buffer(struct inode *inode,
 		}
 	}
 fail:
+	spin_unlock(&inode->i_lock);
 	return err;
 }
 
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index d2171f4a6980..5f62fb7a5d0a 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -2700,20 +2700,16 @@ static int encode_caps_cb(struct inode *inode, struct ceph_cap *cap,
 		struct ceph_filelock *flocks;
 
 encode_again:
-		spin_lock(&inode->i_lock);
 		ceph_count_locks(inode, &num_fcntl_locks, &num_flock_locks);
-		spin_unlock(&inode->i_lock);
 		flocks = kmalloc((num_fcntl_locks+num_flock_locks) *
 				 sizeof(struct ceph_filelock), GFP_NOFS);
 		if (!flocks) {
 			err = -ENOMEM;
 			goto out_free;
 		}
-		spin_lock(&inode->i_lock);
 		err = ceph_encode_locks_to_buffer(inode, flocks,
 						  num_fcntl_locks,
 						  num_flock_locks);
-		spin_unlock(&inode->i_lock);
 		if (err) {
 			kfree(flocks);
 			if (err == -ENOSPC)
-- 
2.1.0

