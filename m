Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63496 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932638Ab3DBVqT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 17:46:19 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 16/19] NFSv4.2: Only allocate labels on v4.2 mounts
Date: Tue,  2 Apr 2013 17:45:57 -0400
Message-Id: <1364939160-20874-17-git-send-email-SteveD@redhat.com>
In-Reply-To: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

Before allocating a label or security initialization
make sure the v4 minor version is at least 2.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/inode.c    | 4 ++++
 fs/nfs/nfs4proc.c | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 91920fc..cc1c85d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -287,6 +287,10 @@ void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
 struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags)
 {
 	struct nfs4_label *label = NULL;
+	int minor_version = server->nfs_client->cl_minorversion;
+
+	if (minor_version < 2)
+		return label;
 
 	if (!(server->caps & NFS_CAP_SECURITY_LABEL))
 		return label;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b7eae1e..3e18d39 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -94,6 +94,10 @@ nfs4_label_init_security(struct inode *dir, struct dentry *dentry,
 	struct iattr *sattr, struct nfs4_label *l)
 {
 	int err;
+	int minor_version = NFS_SERVER(dir)->nfs_client->cl_minorversion;
+
+	if (minor_version < 2)
+		return NULL;
 
 	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
 		err = security_dentry_init_security(dentry, sattr->ia_mode,
-- 
1.8.1.4

