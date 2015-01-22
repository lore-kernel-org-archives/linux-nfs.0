Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.226]:12592 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753052AbbAVO2E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 09:28:04 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        Sasha Levin <sasha.levin@oracle.com>,
        David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: [PATCH v3 08/13] locks: remove i_flock field from struct inode
Date: Thu, 22 Jan 2015 09:27:52 -0500
Message-Id: <1421936877-27529-9-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
References: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@primarydata.com>

Nothing uses it anymore. Also add a forward declaration for struct
file_lock to silence some compiler warnings that the removal triggers.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/fs.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2ddec3cf81b9..ce0873af0b97 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -625,7 +625,6 @@ struct inode {
 	atomic_t		i_readcount; /* struct files open RO */
 #endif
 	const struct file_operations	*i_fop;	/* former ->i_op->default_file_ops */
-	struct file_lock	*i_flock;
 	struct file_lock_context	*i_flctx;
 	struct address_space	i_data;
 	struct list_head	i_devices;
@@ -886,6 +885,8 @@ static inline struct file *get_file(struct file *f)
 /* legacy typedef, should eventually be removed */
 typedef void *fl_owner_t;
 
+struct file_lock;
+
 struct file_lock_operations {
 	void (*fl_copy_lock)(struct file_lock *, struct file_lock *);
 	void (*fl_release_private)(struct file_lock *);
-- 
2.1.0

