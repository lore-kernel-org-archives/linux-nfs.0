Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:40571 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719Ab3KEBQd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 20:16:33 -0500
Received: by mail-qc0-f182.google.com with SMTP id n7so4486657qcx.27
        for <linux-nfs@vger.kernel.org>; Mon, 04 Nov 2013 17:16:33 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, chutzpah@gentoo.org, liguangc@cn.ibm.com
Subject: [PATCH] [RFC] vfs: don't revalidate dentries that serve as mountpoints
Date: Mon,  4 Nov 2013 20:16:26 -0500
Message-Id: <1383614186-8039-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We had a couple of reports of people that are mounting NFS filesystems,
and then bind mounting certain local files onto dentries in that nfs
mount (sort of like a poor-man's unionmount).

This all works well until the dentry serving as the mountpoint fails
d_revalidate. The dentry will end up being invalidated which makes the
bind mount unreachable via pathwalk.

It doesn't make much sense to me to allow dentries to serve as
mountpoints to end up invalidated, so there's no real point in
attempting to d_revalidate them at all.

Reported-by: Patrick McLean <chutzpah@gentoo.org>
Reported-by: Guang Cheng Li <liguangc@cn.ibm.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/namei.c b/fs/namei.c
index caa2805..5b10ad0 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -585,6 +585,9 @@ drop_root_mnt:
 
 static inline int d_revalidate(struct dentry *dentry, unsigned int flags)
 {
+	/* dentries that serve as mountpoints are always considered valid */
+	if (d_mountpoint(dentry))
+		return 1;
 	return dentry->d_op->d_revalidate(dentry, flags);
 }
 
-- 
1.8.3.1

