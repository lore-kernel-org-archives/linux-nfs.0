Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B3BCECDE46
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:52:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C9AE220834
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:52:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OwZECMbq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9AE220834
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727660AbeJZG01 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 02:26:27 -0400
Received: from mail-qk1-f195.google.com ([209.85.222.195]:41579 "EHLO
        mail-qk1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726511AbeJZG00 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 02:26:26 -0400
Received: by mail-qk1-f195.google.com with SMTP id g13-v6so6717780qke.8;
        Thu, 25 Oct 2018 14:52:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=8X4GVYfVELw2Szc0EZ8voYGJMXx3lhsTV5J69B65SO4=;
        b=OwZECMbqjpjx23SymjfX61H8dIcQhuxWZeihLjSi5viZ+ZRdb2O9UVU1NMxyQLZQF4
         RFBEF2rji9oRy5LXpCX0K2NTKo0u1t4Vtz2LQIuTNAxglBOfsptT9glfE9hIboKffwPw
         vwz13og8MjZyhKz2L+5tQESxUz6jzb0nOQ6b5SRH1bJQ/2exkYik/pJBuuY0kTr/qtYm
         pMlyCzMc3Qwf/IQzX4jRw4OIkb35O7lEDQCqfVdzChDbc8xwE761ir9E03P2J2yLQaEY
         yAbVyXzVEK1HYcWmWAZIhFnnMEyvGmsny+4H3Vr560p/I1pkS02T0qKLEPalpXnNF+RQ
         IitQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=8X4GVYfVELw2Szc0EZ8voYGJMXx3lhsTV5J69B65SO4=;
        b=P4IE+7j48rFf57EHJivVnHws+qo5hHovNT3P0BJez8VfE0uVLfggm1cam8Vd9mKfUT
         ti593xF6E/hYZTz8cmj5b6YvqyeZd3fJRlieb5EeCnWd6oOe9GA8mg2sbpWetdfrMQW1
         pQLvYIpci0VsVcQETeXSI6/VuEgcLOds3yK15Vep5JnaLhyIdCwrnMsXJmFefSoW4Cfh
         lYUHn3hM9QBubV2WpKRJ3gK3+fDcTh2wVLM/o+PgR8qMp6DE8oVEVm5UUk79ofx+G7ze
         +8gp6wPCqgdhdaa0QFVLHIs+6jd0kTvn+gsiY9fSZaFP9kpjm3FD08RUN1TAuGF5bZZd
         nhlw==
X-Gm-Message-State: AGRZ1gImu/A3J/rpllN23dkirH3tcxoZhvahfDPAPxg95b1qqPMWaHqV
        t9gEgcCigRRrl+67i5aOFik=
X-Google-Smtp-Source: AJdET5dgn389rI6Pabv1b7PVam3EOWPa5Oe99tb4yWvZRngQczqBBz3R3zbMDDEQBMCX5ptaC3ulEQ==
X-Received: by 2002:a37:7006:: with SMTP id l6-v6mr799060qkc.243.1540504321496;
        Thu, 25 Oct 2018 14:52:01 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm5895927qkc.96.2018.10.25.14.52.00
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Oct 2018 14:52:00 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v3 07/11] NFS inter ssc open
Date:   Thu, 25 Oct 2018 17:51:43 -0400
Message-Id: <20181025215147.36248-9-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
References: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

NFSv4.2 inter server to server copy requires the destination server to
READ the data from the source server using the provided stateid and
file handle.

Given an NFSv4 stateid and filehandle from the COPY operaion, provide the
destination server with an NFS client function to create a struct file
suitable for the destiniation server to READ the data to be copied.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4_fs.h  |  7 ++++
 fs/nfs/nfs4file.c | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c |  5 ++-
 3 files changed, 106 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 7d17b31..9c566a4 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -307,6 +307,13 @@ extern int nfs4_set_rw_stateid(nfs4_stateid *stateid,
 		const struct nfs_open_context *ctx,
 		const struct nfs_lock_context *l_ctx,
 		fmode_t fmode);
+extern int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
+			     struct nfs_fattr *fattr, struct nfs4_label *label,
+			     struct inode *inode);
+extern int update_open_stateid(struct nfs4_state *state,
+				const nfs4_stateid *open_stateid,
+				const nfs4_stateid *deleg_stateid,
+				fmode_t fmode);
 
 #if defined(CONFIG_NFS_V4_1)
 extern int nfs41_sequence_done(struct rpc_task *, struct nfs4_sequence_res *);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 032996b..25ba405 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -8,6 +8,7 @@
 #include <linux/file.h>
 #include <linux/falloc.h>
 #include <linux/nfs_fs.h>
+#include <linux/file.h>
 #include "delegation.h"
 #include "internal.h"
 #include "iostat.h"
@@ -264,6 +265,102 @@ static int nfs42_clone_file_range(struct file *src_file, loff_t src_off,
 out:
 	return ret;
 }
+
+static int read_name_gen = 1;
+#define SSC_READ_NAME_BODY "ssc_read_%d"
+
+struct file *
+nfs42_ssc_open(struct vfsmount *ss_mnt, struct nfs_fh *src_fh,
+		nfs4_stateid *stateid)
+{
+	struct nfs_fattr fattr;
+	struct file *filep, *res;
+	struct nfs_server *server;
+	struct inode *r_ino = NULL;
+	struct nfs_open_context *ctx;
+	struct nfs4_state_owner *sp;
+	char *read_name;
+	int len, status = 0;
+
+	server = NFS_SERVER(ss_mnt->mnt_root->d_inode);
+
+	nfs_fattr_init(&fattr);
+
+	status = nfs4_proc_getattr(server, src_fh, &fattr, NULL, NULL);
+	if (status < 0) {
+		res = ERR_PTR(status);
+		goto out;
+	}
+
+	res = ERR_PTR(-ENOMEM);
+	len = strlen(SSC_READ_NAME_BODY) + 16;
+	read_name = kzalloc(len, GFP_NOFS);
+	if (read_name == NULL)
+		goto out;
+	snprintf(read_name, len, SSC_READ_NAME_BODY, read_name_gen++);
+
+	r_ino = nfs_fhget(ss_mnt->mnt_root->d_inode->i_sb, src_fh, &fattr,
+			NULL);
+	if (IS_ERR(r_ino)) {
+		res = ERR_CAST(r_ino);
+		goto out;
+	}
+
+	filep = alloc_file_pseudo(r_ino, ss_mnt, read_name, FMODE_READ,
+				     r_ino->i_fop);
+	if (IS_ERR(filep)) {
+		res = ERR_CAST(filep);
+		goto out;
+	}
+	filep->f_mode |= FMODE_READ;
+
+	ctx = alloc_nfs_open_context(filep->f_path.dentry, filep->f_mode,
+					filep);
+	if (IS_ERR(ctx)) {
+		res = ERR_CAST(ctx);
+		goto out_filep;
+	}
+
+	res = ERR_PTR(-EINVAL);
+	sp = nfs4_get_state_owner(server, ctx->cred, GFP_KERNEL);
+	if (sp == NULL)
+		goto out_ctx;
+
+	ctx->state = nfs4_get_open_state(r_ino, sp);
+	if (ctx->state == NULL)
+		goto out_stateowner;
+
+	set_bit(NFS_OPEN_STATE, &ctx->state->flags);
+	memcpy(&ctx->state->open_stateid.other, &stateid->other,
+	       NFS4_STATEID_OTHER_SIZE);
+	update_open_stateid(ctx->state, stateid, NULL, filep->f_mode);
+
+	nfs_file_set_open_context(filep, ctx);
+	put_nfs_open_context(ctx);
+
+	file_ra_state_init(&filep->f_ra, filep->f_mapping->host->i_mapping);
+	res = filep;
+out:
+	dprintk("<-- %s error %ld filep %p r_ino %p\n",
+		__func__, PTR_ERR_OR_ZERO(res), res, r_ino);
+
+	return res;
+out_stateowner:
+	nfs4_put_state_owner(sp);
+out_ctx:
+	put_nfs_open_context(ctx);
+out_filep:
+	fput(filep);
+	goto out;
+}
+EXPORT_SYMBOL_GPL(nfs42_ssc_open);
+void nfs42_ssc_close(struct file *filep)
+{
+	struct nfs_open_context *ctx = nfs_file_open_context(filep);
+
+	ctx->state->flags = 0;
+}
+EXPORT_SYMBOL_GPL(nfs42_ssc_close);
 #endif /* CONFIG_NFS_V4_2 */
 
 const struct file_operations nfs4_file_operations = {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fec6e6b..e5178b2f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -91,7 +91,6 @@
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
-static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *, struct nfs4_label *label, struct inode *inode);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label, struct inode *inode);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
@@ -1653,7 +1652,7 @@ static void nfs_state_clear_delegation(struct nfs4_state *state)
 	write_sequnlock(&state->seqlock);
 }
 
-static int update_open_stateid(struct nfs4_state *state,
+int update_open_stateid(struct nfs4_state *state,
 		const nfs4_stateid *open_stateid,
 		const nfs4_stateid *delegation,
 		fmode_t fmode)
@@ -3936,7 +3935,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
-static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
+int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 				struct nfs_fattr *fattr, struct nfs4_label *label,
 				struct inode *inode)
 {
-- 
1.8.3.1

