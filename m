Return-Path: <SRS0=WqcA=WP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C9EBC3A5A0
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Aug 2019 19:29:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 164A822CEC
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Aug 2019 19:29:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VJPQy38R"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728447AbfHST3F (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Aug 2019 15:29:05 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:33996 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728415AbfHST3F (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Aug 2019 15:29:05 -0400
Received: by mail-io1-f66.google.com with SMTP id s21so6869978ioa.1
        for <linux-nfs@vger.kernel.org>; Mon, 19 Aug 2019 12:29:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=23wLHJSmn/ZxNKzqVt7PQBC+yvBjUAUPtEmuEjnDvDQ=;
        b=VJPQy38RQnAW/fXuBxHxMgp7i1Jc4K9BNYwFwTr3JZiIwwJyRAevzRwlhvHThdBQat
         nZ0fY9qALusCfn3GsRKiaYgR+5wtn3cGVmmxslDRSaqPSe7O8P2Yd88R4ULm9DJyhmEQ
         z7+nckN2YEO75fBn+43n9UxV5k8DeG9lf/oblrWh/AsAxpBjBBQRtvGZuyTV3EjAOe/F
         +HsjEnzWAUDa4FBe/Va6DTDjN4g22wR/IyAiST6nsQNBN+Rqm61opv/OIPsR4Jxys4kz
         zd0qulp1O8Ee7Zj7/fcIvhfdJLPeqDsI88LSwtk+ajQp1QPnZDXGNNYz7eFtV+do63hT
         skgA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=23wLHJSmn/ZxNKzqVt7PQBC+yvBjUAUPtEmuEjnDvDQ=;
        b=D/wMSiR3MzLxjqF+sUOPxuFh/mgSQf7INAmYpU6NLoxDnhh1MPvxyAtWR0dZJyRiBS
         EeiI5I95iB3baErQP3TO9XcmHa5LiV5xWk8vR+74LaLqah/CcsmdFebbVnvwLrmqgTHX
         5PKDGHh4OpglNJDQcylxCmduGn7P2F3FcKiasFwVn0qVt5GFSkRoEKIKaccpebZePfac
         bZb+8+3depaltEn8DaUSu9NJP1tiCPLAITpgxUu2FQbBEf0YYyp/qU4gkc5dGsQwMfd9
         uL1A0aIJ4esO1YsKlAHq2p4x9JvuDaJr6kZsk/JgiZ4ZAS5Tbqa19LgPrAbfKH/R/GDq
         Hkdw==
X-Gm-Message-State: APjAAAWsk48GmBsWRCyNsgow14jt55L3/wPPqFgCLzlcexdj7WOc3gR0
        abrDeROHrPdl+UGwMarg+lU=
X-Google-Smtp-Source: APXvYqxK0FdC6KvIzew0S1iVnVH4Fbe8MiT2mjd4kdc8+GAadOjN0RQq35k5PSiXBpCH826FXqcvxA==
X-Received: by 2002:a6b:f910:: with SMTP id j16mr8093272iog.135.1566242944212;
        Mon, 19 Aug 2019 12:29:04 -0700 (PDT)
Received: from gouda.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.gmail.com with ESMTPSA id v23sm16243957ioh.58.2019.08.19.12.29.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 19 Aug 2019 12:29:03 -0700 (PDT)
From:   schumaker.anna@gmail.com
X-Google-Original-From: Anna.Schumaker@Netapp.com
To:     Trond.Myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Cc:     Anna.Schumaker@Netapp.com
Subject: [PATCH 2/6] NFS: Have nfs4_proc_setclientid() call nfs4_call_sync_custom()
Date:   Mon, 19 Aug 2019 15:28:56 -0400
Message-Id: <20190819192900.19312-3-Anna.Schumaker@Netapp.com>
X-Mailer: git-send-email 2.22.1
In-Reply-To: <20190819192900.19312-1-Anna.Schumaker@Netapp.com>
References: <20190819192900.19312-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Rather than running the task manually

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e5b6499c0b8b..234312240f33 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6023,7 +6023,6 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		.rpc_resp = res,
 		.rpc_cred = cred,
 	};
-	struct rpc_task *task;
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = clp->cl_rpcclient,
 		.rpc_message = &msg,
@@ -6056,17 +6055,12 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 	dprintk("NFS call  setclientid auth=%s, '%s'\n",
 		clp->cl_rpcclient->cl_auth->au_ops->au_name,
 		clp->cl_owner_id);
-	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task)) {
-		status = PTR_ERR(task);
-		goto out;
-	}
-	status = task->tk_status;
+
+	status = nfs4_call_sync_custom(&task_setup_data);
 	if (setclientid.sc_cred) {
 		clp->cl_acceptor = rpcauth_stringify_acceptor(setclientid.sc_cred);
 		put_rpccred(setclientid.sc_cred);
 	}
-	rpc_put_task(task);
 out:
 	trace_nfs4_setclientid(clp, status);
 	dprintk("NFS reply setclientid: %d\n", status);
-- 
2.22.1

