Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB415C2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6D7982082D
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sQo6XU2y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D7982082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729405AbeJ3DyG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 23:54:06 -0400
Received: from mail-qt1-f195.google.com ([209.85.160.195]:44027 "EHLO
        mail-qt1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725923AbeJ3DyG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 23:54:06 -0400
Received: by mail-qt1-f195.google.com with SMTP id q41-v6so10562061qtq.10;
        Mon, 29 Oct 2018 12:04:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=VV4M/cnS3hlXxtfqYU3EINln0tSbPvkrsIvgg+rY9zg=;
        b=sQo6XU2y5z0GSR+MhXF9q4GJTy/GWyIaBH1ljb3hGh5DWAuh0LLFCLeWiNYC4dVwXg
         flUQQad9Ik5JDuHMfQ29T5FxeZ2CrFrXgpmjIFD1rBztnbN35eBJcWcNHspzQCUME4m4
         MSAe99xkXtWTDzAyCmm8OjG0wo1QMQuPikcvpXe5i9k51Gibf0/jKvwjbMWO96fACip3
         /JLaPqsalwMLRS55kJcsnLTbougrqtXMpOroHWkECpflHMrPfK6KS2KBE98ik3l7PVMv
         yzK+ZisGxG+OIgOM/9+/n0Du/AEEeIpF7Ve1BO1WzHhHhUf3VZxoON274VggEl00Yngq
         cXtQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=VV4M/cnS3hlXxtfqYU3EINln0tSbPvkrsIvgg+rY9zg=;
        b=hIvgrJuUW5xVv+adYiXZjSICSVCumZCzETGnO46azezWv3ElFoT5x7wA+JEXvQXDuS
         yBlxFDmfgsDG/tL32TgoiBh6+rcurj4NDo2S4HW8BYlqtxkxm9hSy2VwgO6dt3nbFP3M
         RYmRFbEsg+8kL8/1dkkhpBm/qLy8QzebIdCP4WgE3fTfMPMrFNC6RVhUkfNTHEsGZXR6
         zVCKeiDYWyuljvW+6frafXBLz8VsFsd4+AJfsSHu1+eMAjt77eev2bCKZFGt4TuLerrW
         Yq1o7n0c5xEmHKT/+Mrq0JcN9o+U09QlySwgpPOIxQP9Gdx74SoAAUNtvHIZjnXP7zIr
         pCxQ==
X-Gm-Message-State: AGRZ1gI8DIVQn9NjInDB97F4oFxWC6zk5fpcCtNu+nQ308uxfk/W/bfP
        HBPu+VpBO6ZC3c0SnAYvyQo=
X-Google-Smtp-Source: AJdET5dTxJl/I0yHj2Q+jRYmUXASNnuvPHcwDmcaD3T5lxxbvzovrkPu2FkV0yM+9PtDXA9AQQhF6A==
X-Received: by 2002:aed:2429:: with SMTP id r38-v6mr3975681qtc.128.1540839846651;
        Mon, 29 Oct 2018 12:04:06 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id c5-v6sm2714373qtj.55.2018.10.29.12.04.04
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 12:04:05 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v6 02/12] VFS: move cross device copy_file_range() check into filesystems
Date:   Mon, 29 Oct 2018 15:03:47 -0400
Message-Id: <20181029190357.38439-4-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
References: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

This patch makes it the responsibility of individual filesystems to
allow or deny cross device copies.  Both NFS and CIFS have operations
for cross-server copies, and later patches will implement this feature.

Note that as of this patch, the copy_file_range() function might be passed
superblocks from different filesystem types. -EXDEV should be returned
if cross device copies aren't supported.

Reviewed-by: Amir Goldstein <amir73il@gmail.com>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Steve French <stfrench@microsoft.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 Documentation/filesystems/porting | 7 +++++++
 fs/cifs/cifsfs.c                  | 3 +++
 fs/nfs/nfs4file.c                 | 3 +++
 fs/overlayfs/file.c               | 3 +++
 fs/read_write.c                   | 5 ++---
 5 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
index 7b7b845..897e1e7 100644
--- a/Documentation/filesystems/porting
+++ b/Documentation/filesystems/porting
@@ -622,3 +622,10 @@ in your dentry operations instead.
 	alloc_file_clone(file, flags, ops) does not affect any caller's references.
 	On success you get a new struct file sharing the mount/dentry with the
 	original, on failure - ERR_PTR().
+--
+[mandatory]
+	->copy_file_range() may now be passed files which belong to two
+	different superblocks of the same file system type or which belong
+	to two different filesystems types all together. As before, the
+	destination's copy_file_range() is the function which is called.
+	If it cannot copy ranges from the source, it should return -EXDEV.
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 7065426..ca8fc87 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -1114,6 +1114,9 @@ static ssize_t cifs_copy_file_range(struct file *src_file, loff_t off,
 	unsigned int xid = get_xid();
 	ssize_t rc;
 
+	if (file_inode(src_file)->i_sb != file_inode(dst_file)->i_sb)
+		return -EXDEV;
+
 	rc = cifs_file_copychunk_range(xid, src_file, off, dst_file, destoff,
 					len, flags);
 	free_xid(xid);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 4288a6e..5a73c90 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 {
 	ssize_t ret;
 
+	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
+		return -EXDEV;
+
 	if (file_inode(file_in) == file_inode(file_out))
 		return -EINVAL;
 retry:
diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
index aeaefd2..0331e33 100644
--- a/fs/overlayfs/file.c
+++ b/fs/overlayfs/file.c
@@ -483,6 +483,9 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
 				   struct file *file_out, loff_t pos_out,
 				   size_t len, unsigned int flags)
 {
+	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
+		return -EXDEV;
+
 	return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
 			    OVL_COPY);
 }
diff --git a/fs/read_write.c b/fs/read_write.c
index 70f6939..cff59bd 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1594,11 +1594,10 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 		}
 	}
 
-	if (inode_in->i_sb == inode_out->i_sb &&
-	    file_out->f_op->copy_file_range) {
+	if (file_out->f_op->copy_file_range) {
 		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
 						      pos_out, len, flags);
-		if (ret != -EOPNOTSUPP)
+		if (ret != -EOPNOTSUPP && ret != -EXDEV)
 			goto done;
 	}
 
-- 
1.8.3.1

