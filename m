Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39258 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756517Ab1IBXJv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Sep 2011 19:09:51 -0400
From: Jan Kara <jack@suse.cz>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>,
        Josh Boyer <jwboyer@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] nfs: Enclose hostname in brackets when needed in nfs_do_root_mount
Date: Sat,  3 Sep 2011 01:09:43 +0200
Message-Id: <1315004983-10271-1-git-send-email-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When hostname contains colon (e.g. when it is an IPv6 address) it needs
to be enclosed in brackets to make parsing of NFS device string possible.
Fix nfs_do_root_mount() to enclose hostname properly when needed. NFS code
actually does not need this as it does not parse the string passed by
nfs_do_root_mount() but the device string is exposed to userspace in
/proc/mounts.

CC: Josh Boyer <jwboyer@redhat.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/nfs/super.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b961cea..42b74f8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2694,11 +2694,15 @@ static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
 	char *root_devname;
 	size_t len;
 
-	len = strlen(hostname) + 3;
+	len = strlen(hostname) + 5;
 	root_devname = kmalloc(len, GFP_KERNEL);
 	if (root_devname == NULL)
 		return ERR_PTR(-ENOMEM);
-	snprintf(root_devname, len, "%s:/", hostname);
+	/* Does hostname needs to be enclosed in brackets? */
+	if (strchr(hostname, ':'))
+		snprintf(root_devname, len, "[%s]:/", hostname);
+	else
+		snprintf(root_devname, len, "%s:/", hostname);
 	root_mnt = vfs_kern_mount(fs_type, flags, root_devname, data);
 	kfree(root_devname);
 	return root_mnt;
-- 
1.7.1

