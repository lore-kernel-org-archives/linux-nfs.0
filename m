Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C0B2C2BC61
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E6DD32080A
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bHfCf83v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6DD32080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727978AbeJaFvi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 01:51:38 -0400
Received: from mail-qk1-f195.google.com ([209.85.222.195]:42380 "EHLO
        mail-qk1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727953AbeJaFvh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 01:51:37 -0400
Received: by mail-qk1-f195.google.com with SMTP id u68so4244739qkg.9;
        Tue, 30 Oct 2018 13:56:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=L/lyESnrT7eI5UkekwLVWgapYd9jVCBDfyygHzXaoSk=;
        b=bHfCf83vEqDe1kJa8LqKvoyMt77m//NSuIdFss3B/hVV2F/aJsyizET8JOhhHDZzdr
         wE8qQExtYa3PmmGjDzGF576ffnm/se+/8Q65WNiox7hFA3nmCizisq+lbquuy3k7RWPC
         usEeA8rQHt+AES8aALGn5+ABeF37HYVxM4pLLCDvDHhf+NAmp3ERNirAcd7eO+xkEGWA
         +m7ZndrFRy1YcHP13QWJhEUwxmJU0PO4CngICx3tnFtpAdZiOuju+NScos4utD86FEsY
         c3kEjUJJ3mfjht2Ui2fyCtb4DfL8BB4/x2lHoIKuV+p3TaIF0R7studF4m5kN+4cRpxq
         3VIw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=L/lyESnrT7eI5UkekwLVWgapYd9jVCBDfyygHzXaoSk=;
        b=pKV6vDD+gjh5EJsb/SzPkanVU5PS4o8FAEOMM3i0aAe75igvwW/dgoWl8chSxZwLqa
         rxLdIWUMLoLDnj6YCpVLjTTOGMuwWPW2IiMKgNZ7T26EwEl0ae3gTcXAo0Lpj6L9Zuxw
         X5HDF4DGCa7jn4z0N5vDDg9nqSJ5H9N66BTFzWuC0AJw1WFL5UOh9Q0HdxhjAMTE30Dl
         uyJ0mnelz3vQjhDxvhXtYuydAxhXcdwfv0BoV4E8x9iM8UuG/lUlbyScpz6w1XNDRzkh
         s5TMCyEMCCqZZZ0TNZty5PIKKgWkNs+u+emW8JgZAtK6SBH0M25CLuE7+tn/fJfm24h2
         tN1g==
X-Gm-Message-State: AGRZ1gL9MGpA30U2/W4+I/ebtAnA1qmLGZj/PfJBzNbY9BQxjRcIwb0s
        iMQzkL9uTSShCD5lkY8HMAU=
X-Google-Smtp-Source: AJdET5cj7eG8xATQov0LQJTFULOqNXGRs7LhBuLh1bAH1fVzWRW11OvCFV+fb7Q6QNS3/g6LHClnfQ==
X-Received: by 2002:a37:4f92:: with SMTP id d140-v6mr263258qkb.17.1540932992822;
        Tue, 30 Oct 2018 13:56:32 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id i11-v6sm23478157qtc.96.2018.10.30.13.56.31
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Oct 2018 13:56:32 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v7 05/11] NFS: add ca_source_server<> to COPY
Date:   Tue, 30 Oct 2018 16:56:08 -0400
Message-Id: <20181030205614.40754-7-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
References: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Support only one source server address: the same address that
the client and source server use.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42.h          |  3 ++-
 fs/nfs/nfs42proc.c      | 26 +++++++++++++++++---------
 fs/nfs/nfs42xdr.c       | 12 ++++++++++--
 fs/nfs/nfs4file.c       |  7 ++++++-
 include/linux/nfs_xdr.h |  1 +
 5 files changed, 36 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index bbe49a3..28dcee5 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -15,7 +15,8 @@
 /* nfs4.2proc.c */
 #ifdef CONFIG_NFS_V4_2
 int nfs42_proc_allocate(struct file *, loff_t, loff_t);
-ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t, size_t);
+ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t, size_t,
+			struct nl4_server *, nfs4_stateid *);
 int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
 loff_t nfs42_proc_llseek(struct file *, loff_t, int);
 int nfs42_proc_layoutstats_generic(struct nfs_server *,
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index b1c57a4..bb9e799 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -242,7 +242,9 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 				struct file *dst,
 				struct nfs_lock_context *dst_lock,
 				struct nfs42_copy_args *args,
-				struct nfs42_copy_res *res)
+				struct nfs42_copy_res *res,
+				struct nl4_server *nss,
+				nfs4_stateid *cnr_stateid)
 {
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COPY],
@@ -256,11 +258,15 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	size_t count = args->count;
 	ssize_t status;
 
-	status = nfs4_set_rw_stateid(&args->src_stateid, src_lock->open_context,
-				     src_lock, FMODE_READ);
-	if (status)
-		return status;
-
+	if (nss) {
+		args->cp_src = nss;
+		nfs4_stateid_copy(&args->src_stateid, cnr_stateid);
+	} else {
+		status = nfs4_set_rw_stateid(&args->src_stateid,
+				src_lock->open_context, src_lock, FMODE_READ);
+		if (status)
+			return status;
+	}
 	status = nfs_filemap_write_and_wait_range(file_inode(src)->i_mapping,
 			pos_src, pos_src + (loff_t)count - 1);
 	if (status)
@@ -324,8 +330,9 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 }
 
 ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
-			struct file *dst, loff_t pos_dst,
-			size_t count)
+			struct file *dst, loff_t pos_dst, size_t count,
+			struct nl4_server *nss,
+			nfs4_stateid *cnr_stateid)
 {
 	struct nfs_server *server = NFS_SERVER(file_inode(dst));
 	struct nfs_lock_context *src_lock;
@@ -370,7 +377,8 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 		inode_lock(file_inode(dst));
 		err = _nfs42_proc_copy(src, src_lock,
 				dst, dst_lock,
-				&args, &res);
+				&args, &res,
+				nss, cnr_stateid);
 		inode_unlock(file_inode(dst));
 
 		if (err >= 0)
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index e6e7cbf..c96c3f8 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -21,7 +21,10 @@
 #define encode_copy_maxsz		(op_encode_hdr_maxsz +          \
 					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
 					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
-					 2 + 2 + 2 + 1 + 1 + 1)
+					 2 + 2 + 2 + 1 + 1 + 1 +\
+					 1 + /* One cnr_source_server */\
+					 1 + /* nl4_type */ \
+					 1 + XDR_QUADLEN(NFS4_OPAQUE_LIMIT))
 #define decode_copy_maxsz		(op_decode_hdr_maxsz + \
 					 NFS42_WRITE_RES_SIZE + \
 					 1 /* cr_consecutive */ + \
@@ -186,7 +189,12 @@ static void encode_copy(struct xdr_stream *xdr,
 
 	encode_uint32(xdr, 1); /* consecutive = true */
 	encode_uint32(xdr, args->sync);
-	encode_uint32(xdr, 0); /* src server list */
+	if (args->cp_src == NULL) { /* intra-ssc */
+		encode_uint32(xdr, 0); /* no src server list */
+		return;
+	}
+	encode_uint32(xdr, 1); /* supporting 1 server */
+	encode_nl4_server(xdr, args->cp_src);
 }
 
 static void encode_offload_cancel(struct xdr_stream *xdr,
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index beda4b3..e5c1a68 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -134,6 +134,8 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 				    size_t count, unsigned int flags)
 {
 	struct nfs42_copy_notify_res *cn_resp = NULL;
+	struct nl4_server *nss = NULL;
+	nfs4_stateid *cnrs = NULL;
 	ssize_t ret;
 
 	if (pos_in >= i_size_read(file_inode(file_in)))
@@ -154,9 +156,12 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 		ret = nfs42_proc_copy_notify(file_in, file_out, cn_resp);
 		if (ret)
 			goto out;
+		nss = &cn_resp->cnr_src;
+		cnrs = &cn_resp->cnr_stateid;
 	}
 
-	ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
+	ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count, nss,
+				cnrs);
 out:
 	kfree(cn_resp);
 	if (ret == -EAGAIN)
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index dfc59bc..3a40b17 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1400,6 +1400,7 @@ struct nfs42_copy_args {
 
 	u64				count;
 	bool				sync;
+	struct nl4_server		*cp_src;
 };
 
 struct nfs42_write_res {
-- 
1.8.3.1

