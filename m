Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9464 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965819Ab3FUM65 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Jun 2013 08:58:57 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v4 03/14] locks: make generic_add_lease and generic_delete_lease static
Date: Fri, 21 Jun 2013 08:58:11 -0400
Message-Id: <1371819502-26363-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1371819502-26363-1-git-send-email-jlayton@redhat.com>
References: <1371819502-26363-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: J. Bruce Fields <bfields@fieldses.org>
---
 fs/locks.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index d732e22..804bb9e 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1337,7 +1337,7 @@ int fcntl_getlease(struct file *filp)
 	return type;
 }
 
-int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
+static int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
 {
 	struct file_lock *fl, **before, **my_before = NULL, *lease;
 	struct dentry *dentry = filp->f_path.dentry;
@@ -1402,7 +1402,7 @@ out:
 	return error;
 }
 
-int generic_delete_lease(struct file *filp, struct file_lock **flp)
+static int generic_delete_lease(struct file *filp, struct file_lock **flp)
 {
 	struct file_lock *fl, **before;
 	struct dentry *dentry = filp->f_path.dentry;
-- 
1.7.1

