Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8519DC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3EB142184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Jj7ytfkT"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730379AbfC2WCU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:20 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:37052 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730357AbfC2WCU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:20 -0400
Received: by mail-it1-f195.google.com with SMTP id u65so6273032itc.2
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sk5hEwmNGuRpQ8mqJ0jredgsQ1DuWta1EVnnWPCejy0=;
        b=Jj7ytfkTyuENyOANUiXf5vNaGNJyWyc/7r/arR1cfjDcynQlL5A8QQOLembUlUL3As
         JZCXD9Jdli1AQGZ1+J6E2lh3DCorJY8pU3kecVkfSQ4qzlFK8OurC7QyMmItypBWtWbR
         2ylhSfBff684Me9kyyofbwYMhY9+tghgEei6Y33nkEiuyU9PeCRb6NA14fW/bcB5iqhV
         DijabMbxGW/QvdaQ9cbguJS0lEcVCLRXTGz3jWo62KYLOcjfQXsSmL1mKus0f1UlXl9C
         OybBP+Meu1Xu/wEYau3lflIS5Ko7u1e+dbYHQVjZIBjYiplkK+w7IdBPVumy6BeEC6lp
         +Dbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=sk5hEwmNGuRpQ8mqJ0jredgsQ1DuWta1EVnnWPCejy0=;
        b=VuuDMAcWq3Zy+nhTFYfGCCMVuIvM/KfTEnbfH8vXH8h0TMpdWjLBGQyR/uZ60DuJ5M
         g5Lmh0jlIxIJ6iamtnrXtLYq+ky7qP6EUMksNE7+hfKlKLT9WHUiPb7DtF+wJN2ttB8z
         IHGlAkMgNhtbkZdDeEL8q9q6H4hYLc13S+LSrQ5glcCr/IP9uVVOU2tXyjYUvX3D/0y5
         NWFIi4lZLpuTt/vzxuGD4tRdLNkniq72cNAs5axAwrBPOTyDoZ52FVsphslfyD6PPPxU
         B4EHZEPZsQHO/+gChke9QZJN7X+nPbmgk1PSXVkMgx33sZdsbSWj8QO3zAT8156W9pqi
         hnyw==
X-Gm-Message-State: APjAAAVg4OuVAujE+X5UDoMdBMusquxlkM+KdBN3z7iAkcbPLrJP+x04
        /jKEmgWps2VlvGdl62oPfKSwTQE=
X-Google-Smtp-Source: APXvYqz1wL4GBYQ9iiDqQwldWTEYQBlRilo0PTqbacDkM7/5WY2oumUFNlnyYHrbtdzP1Av4Jxym8Q==
X-Received: by 2002:a02:8243:: with SMTP id q3mr5693555jag.37.1553896937988;
        Fri, 29 Mar 2019 15:02:17 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.17
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:17 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 26/28] NFS: Allow signal interruption of NFS4ERR_DELAYed operations
Date:   Fri, 29 Mar 2019 17:59:46 -0400
Message-Id: <20190329215948.107328-27-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-26-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
 <20190329215948.107328-6-trond.myklebust@hammerspace.com>
 <20190329215948.107328-7-trond.myklebust@hammerspace.com>
 <20190329215948.107328-8-trond.myklebust@hammerspace.com>
 <20190329215948.107328-9-trond.myklebust@hammerspace.com>
 <20190329215948.107328-10-trond.myklebust@hammerspace.com>
 <20190329215948.107328-11-trond.myklebust@hammerspace.com>
 <20190329215948.107328-12-trond.myklebust@hammerspace.com>
 <20190329215948.107328-13-trond.myklebust@hammerspace.com>
 <20190329215948.107328-14-trond.myklebust@hammerspace.com>
 <20190329215948.107328-15-trond.myklebust@hammerspace.com>
 <20190329215948.107328-16-trond.myklebust@hammerspace.com>
 <20190329215948.107328-17-trond.myklebust@hammerspace.com>
 <20190329215948.107328-18-trond.myklebust@hammerspace.com>
 <20190329215948.107328-19-trond.myklebust@hammerspace.com>
 <20190329215948.107328-20-trond.myklebust@hammerspace.com>
 <20190329215948.107328-21-trond.myklebust@hammerspace.com>
 <20190329215948.107328-22-trond.myklebust@hammerspace.com>
 <20190329215948.107328-23-trond.myklebust@hammerspace.com>
 <20190329215948.107328-24-trond.myklebust@hammerspace.com>
 <20190329215948.107328-25-trond.myklebust@hammerspace.com>
 <20190329215948.107328-26-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the server is unable to immediately execute an RPC call, and returns
an NFS4ERR_DELAY then we can assume it is safe to interrupt the operation
in order to handle ordinary signals. This allows the application to
service timer interrupts that would otherwise have to wait until the
server is again able to respond.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4_fs.h  |   1 +
 fs/nfs/nfs4proc.c | 139 ++++++++++++++++++++++++++++++++++------------
 2 files changed, 106 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 06ac3d9ac7c6..8a38a254f516 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -206,6 +206,7 @@ struct nfs4_exception {
 	unsigned char delay : 1,
 		      recovering : 1,
 		      retry : 1;
+	bool interruptible;
 };
 
 struct nfs4_state_recovery_ops {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 96b988689f0e..c29cbef6b53f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -400,17 +400,32 @@ static long nfs4_update_delay(long *timeout)
 	return ret;
 }
 
-static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
+static int nfs4_delay_killable(long *timeout)
 {
-	int res = 0;
-
 	might_sleep();
 
 	freezable_schedule_timeout_killable_unsafe(
 		nfs4_update_delay(timeout));
-	if (fatal_signal_pending(current))
-		res = -ERESTARTSYS;
-	return res;
+	if (!__fatal_signal_pending(current))
+		return 0;
+	return -EINTR;
+}
+
+static int nfs4_delay_interruptible(long *timeout)
+{
+	might_sleep();
+
+	freezable_schedule_timeout_interruptible(nfs4_update_delay(timeout));
+	if (!signal_pending(current))
+		return 0;
+	return __fatal_signal_pending(current) ? -EINTR :-ERESTARTSYS;
+}
+
+static int nfs4_delay(long *timeout, bool interruptible)
+{
+	if (interruptible)
+		return nfs4_delay_interruptible(timeout);
+	return nfs4_delay_killable(timeout);
 }
 
 /* This is the error handling routine for processes that are allowed
@@ -546,7 +561,8 @@ int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_
 
 	ret = nfs4_do_handle_exception(server, errorcode, exception);
 	if (exception->delay) {
-		ret = nfs4_delay(server->client, &exception->timeout);
+		ret = nfs4_delay(&exception->timeout,
+				exception->interruptible);
 		goto out_retry;
 	}
 	if (exception->recovering) {
@@ -3066,7 +3082,9 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 					int *opened)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	struct nfs4_state *res;
 	struct nfs4_open_createattrs c = {
 		.label = label,
@@ -3679,7 +3697,9 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 
 int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
@@ -3721,7 +3741,9 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 		struct nfs_fsinfo *info)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 	do {
 		err = _nfs4_lookup_root(server, fhandle, info);
@@ -3948,7 +3970,9 @@ static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 				struct nfs_fattr *fattr, struct nfs4_label *label,
 				struct inode *inode)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 	do {
 		err = _nfs4_proc_getattr(server, fhandle, fattr, label, inode);
@@ -4071,7 +4095,9 @@ static int nfs4_proc_lookup_common(struct rpc_clnt **clnt, struct inode *dir,
 				   const struct qstr *name, struct nfs_fh *fhandle,
 				   struct nfs_fattr *fattr, struct nfs4_label *label)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	struct rpc_clnt *client = *clnt;
 	int err;
 	do {
@@ -4175,7 +4201,9 @@ static int _nfs4_proc_lookupp(struct inode *inode,
 static int nfs4_proc_lookupp(struct inode *inode, struct nfs_fh *fhandle,
 			     struct nfs_fattr *fattr, struct nfs4_label *label)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 	do {
 		err = _nfs4_proc_lookupp(inode, fhandle, fattr, label);
@@ -4222,7 +4250,9 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 
 static int nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 	do {
 		err = _nfs4_proc_access(inode, entry);
@@ -4277,7 +4307,9 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
 static int nfs4_proc_readlink(struct inode *inode, struct page *page,
 		unsigned int pgbase, unsigned int pglen)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 	do {
 		err = _nfs4_proc_readlink(inode, page, pgbase, pglen);
@@ -4353,7 +4385,9 @@ _nfs4_proc_remove(struct inode *dir, const struct qstr *name, u32 ftype)
 
 static int nfs4_proc_remove(struct inode *dir, struct dentry *dentry)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	struct inode *inode = d_inode(dentry);
 	int err;
 
@@ -4374,7 +4408,9 @@ static int nfs4_proc_remove(struct inode *dir, struct dentry *dentry)
 
 static int nfs4_proc_rmdir(struct inode *dir, const struct qstr *name)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 
 	do {
@@ -4533,7 +4569,9 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, const struct
 
 static int nfs4_proc_link(struct inode *inode, struct inode *dir, const struct qstr *name)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(inode),
@@ -4640,7 +4678,9 @@ static int _nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
 static int nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
 		struct page *page, unsigned int len, struct iattr *sattr)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	struct nfs4_label l, *label = NULL;
 	int err;
 
@@ -4679,7 +4719,9 @@ static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	struct nfs4_label l, *label = NULL;
 	int err;
 
@@ -4739,7 +4781,9 @@ static int _nfs4_proc_readdir(struct dentry *dentry, const struct cred *cred,
 static int nfs4_proc_readdir(struct dentry *dentry, const struct cred *cred,
 		u64 cookie, struct page **pages, unsigned int count, bool plus)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 	do {
 		err = _nfs4_proc_readdir(dentry, cred, cookie,
@@ -4790,7 +4834,9 @@ static int nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr, dev_t rdev)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	struct nfs4_label l, *label = NULL;
 	int err;
 
@@ -4832,7 +4878,9 @@ static int _nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 
 static int nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsstat *fsstat)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
@@ -4863,7 +4911,9 @@ static int _nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
 
 static int nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsinfo *fsinfo)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	unsigned long now = jiffies;
 	int err;
 
@@ -4925,7 +4975,9 @@ static int _nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle
 static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 		struct nfs_pathconf *pathconf)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 
 	do {
@@ -5494,7 +5546,9 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 
 static ssize_t nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	ssize_t ret;
 	do {
 		ret = __nfs4_get_acl_uncached(inode, buf, buflen);
@@ -5628,7 +5682,9 @@ static int _nfs4_get_security_label(struct inode *inode, void *buf,
 static int nfs4_get_security_label(struct inode *inode, void *buf,
 					size_t buflen)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 
 	if (!nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL))
@@ -6269,7 +6325,9 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 
 static int nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 
 	do {
@@ -6833,6 +6891,7 @@ static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *
 	struct nfs4_exception exception = {
 		.state = state,
 		.inode = state->inode,
+		.interruptible = true,
 	};
 	int err;
 
@@ -7246,7 +7305,9 @@ int nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
 			   struct nfs4_fs_locations *fs_locations,
 			   struct page *page)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 	do {
 		err = _nfs4_proc_fs_locations(client, dir, name,
@@ -7389,7 +7450,9 @@ int nfs4_proc_get_locations(struct inode *inode,
 	struct nfs_client *clp = server->nfs_client;
 	const struct nfs4_mig_recovery_ops *ops =
 					clp->cl_mvops->mig_recovery_ops;
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int status;
 
 	dprintk("%s: FSID %llx:%llx on \"%s\"\n", __func__,
@@ -7513,7 +7576,9 @@ int nfs4_proc_fsid_present(struct inode *inode, const struct cred *cred)
 	struct nfs_client *clp = server->nfs_client;
 	const struct nfs4_mig_recovery_ops *ops =
 					clp->cl_mvops->mig_recovery_ops;
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int status;
 
 	dprintk("%s: FSID %llx:%llx on \"%s\"\n", __func__,
@@ -7579,7 +7644,9 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name,
 		      struct nfs4_secinfo_flavors *flavors)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 	do {
 		err = -NFS4ERR_WRONGSEC;
@@ -9269,7 +9336,9 @@ static int
 nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
 			   struct nfs_fsinfo *info, struct nfs4_secinfo_flavors *flavors)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 	do {
 		/* first try using integrity protection */
@@ -9436,7 +9505,9 @@ static int nfs41_test_stateid(struct nfs_server *server,
 		nfs4_stateid *stateid,
 		const struct cred *cred)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.interruptible = true,
+	};
 	int err;
 	do {
 		err = _nfs41_test_stateid(server, stateid, cred);
-- 
2.20.1

