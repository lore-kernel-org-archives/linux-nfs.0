From: Eric Paris <eparis@redhat.com>
Subject: [PATCH] NFS/LSM: Make NFSv4 set LSM mount options
Date: Thu, 17 Apr 2008 10:04:51 -0400
Message-ID: <1208441091.2985.8.camel@localhost.localdomain>
References: <1204744818.3216.254.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	steved@redhat.com, jlayton@redhat.com, sds@tycho.nsa.gov,
	jmorris@namei.org, chuck.lever@oracle.com,
	akpm@linux-foundation.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751390AbYDQOG7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Apr 2008 10:06:59 -0400
In-Reply-To: <1204744818.3216.254.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv3 get_sb operations call into the LSM layer to set security options
passed from userspace.  NFSv4 hooks were not originally added since it
was reasonably late in the merge window and NFSv3 was the only thing
that had regressed (v4 has never supported any LSM options)

This patch makes NFSv4 call into the LSM to set security options rather
than just blindly dropping them with no notice to the user as happens
today.  This patch was tested in a simple NFSv4 environment with the
context= option and appeared to work as expected.

Signed-off-by: Eric Paris <eparis@redhat.com>

---

 fs/nfs/super.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f921902..ffd46f8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1946,6 +1946,10 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 		goto error_splat_super;
 	}
 
+	error = security_sb_set_mnt_opts(s, &data.lsm_opts);
+	if (error)
+		goto error_splat_root;
+
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
@@ -1962,6 +1966,8 @@ out_free:
 	nfs_free_server(server);
 	goto out;
 
+error_splat_root:
+	dput(mntroot);
 error_splat_super:
 	up_write(&s->s_umount);
 	deactivate_super(s);
@@ -2041,6 +2047,8 @@ static int nfs4_xdev_get_sb(struct file_system_type *fs_type, int flags,
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
 
+	security_sb_clone_mnt_opts(data->sb, s);
+
 	dprintk("<-- nfs4_xdev_get_sb() = 0\n");
 	return 0;
 
@@ -2120,6 +2128,8 @@ static int nfs4_referral_get_sb(struct file_system_type *fs_type, int flags,
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
 
+	security_sb_clone_mnt_opts(data->sb, s);
+
 	dprintk("<-- nfs4_referral_get_sb() = 0\n");
 	return 0;
 


