Return-Path: <SRS0=rzd8=OA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4C16C43441
	for <linux-nfs@archiver.kernel.org>; Wed, 21 Nov 2018 16:24:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 77BCA21479
	for <linux-nfs@archiver.kernel.org>; Wed, 21 Nov 2018 16:24:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qU3HRWs8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77BCA21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731718AbeKVC7a (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 21 Nov 2018 21:59:30 -0500
Received: from mail-oi1-f193.google.com ([209.85.167.193]:40629 "EHLO
        mail-oi1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730375AbeKVC7a (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Nov 2018 21:59:30 -0500
Received: by mail-oi1-f193.google.com with SMTP id t204so5001433oie.7
        for <linux-nfs@vger.kernel.org>; Wed, 21 Nov 2018 08:24:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=I5BHecX1v6dAd3BBBjLLZ212UReh+sg3coXoT+ACBIE=;
        b=qU3HRWs8m3zUPYSfYtYblObAXxaDCZ56LVgBcRh2mVq1SVP+Mv3C8rU/RTbFsz/IMd
         cLq/hKOB49qiGezlYsfOJiQ+T2pmlCKkMzWrzzye0UwYqvXB424X4Y99l+3drIzg9zWT
         jeIG35A0ql6lnou1ykueToOdRaMVvxpWwNyF4vuje7JPFqwefy0LZGUcynMvip1co5FD
         YVP4H3aQjcIowziAHr3Ac4qEhVwQT+ivzRb7HxDjnFPV+hJN/kb84W/tB2Wpf9NeD/S8
         jxty0401/BUWtcXxep06VC2MG9vinbwDd4We7eFPHmlHStuAsRCHCWtd+po0v6rOUIz/
         PXBQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=I5BHecX1v6dAd3BBBjLLZ212UReh+sg3coXoT+ACBIE=;
        b=lwKIZTZTfKC1LgMxSvHfrWG319z54i1q7/uS4UJHo/NJXYEQDXlZq0OmuHx42W6QXy
         gjezuLRIvM6l5E7KI9uQwRZhY9uTvba4consTuMCIguO4ItFRKLTUaMVtg2GsqdCHGW7
         8YyNPEj8RpYiaecNYwztETEWCZ3PPmGSu0IdE3aW/fag0V12CsaJnMvp6Avje0+7mSUW
         wl8RNJsohdo6IYb9rSJuo9s5FGNnlRum1bFdYqA91X0HznOAAHCfhqk6HQKTMcFjMWNA
         Ba0eT698iBpv3UagJoEW84DX/tadGKUF6SyyXo+rmr4DrEcvxwIpuvDtIOWq0RoYQHVZ
         A+5Q==
X-Gm-Message-State: AGRZ1gJ0+sWCj18lXWSUDZUIgHgcm3MdIVDijzbF96Bf5IsgPXAm1lJ6
        rgPHaXYz1Spu2D57qtILk7I=
X-Google-Smtp-Source: AJdET5dBy6/9QzWYll64SNbApS/M+zW+NobCs+TQxy082KrWrsEA/mqwf4mz5ClLN2DMJgXZDsawbg==
X-Received: by 2002:aca:bd41:: with SMTP id n62-v6mr4168845oif.336.1542817462197;
        Wed, 21 Nov 2018 08:24:22 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id a201sm25762824oii.27.2018.11.21.08.24.20
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Nov 2018 08:24:21 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v4 1/1] NFSv4.2 copy do not allocate memory under the lock
Date:   Wed, 21 Nov 2018 11:24:22 -0500
Message-Id: <20181121162422.53774-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Bruce pointed out that we shouldn't allocate memory while holding
a lock in the nfs4_callback_offload() and handle_async_copy()
that deal with a racing CB_OFFLOAD and reply to COPY case.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/callback_proc.c | 22 +++++++++++-----------
 fs/nfs/nfs42proc.c     | 19 ++++++++++---------
 2 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index fa515d5..48b2e90 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -686,20 +686,24 @@ __be32 nfs4_callback_offload(void *data, void *dummy,
 {
 	struct cb_offloadargs *args = data;
 	struct nfs_server *server;
-	struct nfs4_copy_state *copy;
+	struct nfs4_copy_state *copy, *tmp_copy;
 	bool found = false;
 
+	copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
+	if (!copy)
+		return htonl(NFS4ERR_SERVERFAULT);
+
 	spin_lock(&cps->clp->cl_lock);
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, &cps->clp->cl_superblocks,
 				client_link) {
-		list_for_each_entry(copy, &server->ss_copies, copies) {
+		list_for_each_entry(tmp_copy, &server->ss_copies, copies) {
 			if (memcmp(args->coa_stateid.other,
-					copy->stateid.other,
+					tmp_copy->stateid.other,
 					sizeof(args->coa_stateid.other)))
 				continue;
-			nfs4_copy_cb_args(copy, args);
-			complete(&copy->completion);
+			nfs4_copy_cb_args(tmp_copy, args);
+			complete(&tmp_copy->completion);
 			found = true;
 			goto out;
 		}
@@ -707,15 +711,11 @@ __be32 nfs4_callback_offload(void *data, void *dummy,
 out:
 	rcu_read_unlock();
 	if (!found) {
-		copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
-		if (!copy) {
-			spin_unlock(&cps->clp->cl_lock);
-			return htonl(NFS4ERR_SERVERFAULT);
-		}
 		memcpy(&copy->stateid, &args->coa_stateid, NFS4_STATEID_SIZE);
 		nfs4_copy_cb_args(copy, args);
 		list_add_tail(&copy->copies, &cps->clp->pending_cb_stateids);
-	}
+	} else
+		kfree(copy);
 	spin_unlock(&cps->clp->cl_lock);
 
 	return 0;
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index c7c2ffa..5cd02a2 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -158,31 +158,32 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 			     struct file *dst,
 			     nfs4_stateid *src_stateid)
 {
-	struct nfs4_copy_state *copy;
+	struct nfs4_copy_state *copy, *tmp_copy;
 	int status = NFS4_OK;
 	bool found_pending = false;
 	struct nfs_open_context *ctx = nfs_file_open_context(dst);
 
+	copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
+	if (!copy)
+		return -ENOMEM;
+
 	spin_lock(&server->nfs_client->cl_lock);
-	list_for_each_entry(copy, &server->nfs_client->pending_cb_stateids,
+	list_for_each_entry(tmp_copy, &server->nfs_client->pending_cb_stateids,
 				copies) {
-		if (memcmp(&res->write_res.stateid, &copy->stateid,
+		if (memcmp(&res->write_res.stateid, &tmp_copy->stateid,
 				NFS4_STATEID_SIZE))
 			continue;
 		found_pending = true;
-		list_del(&copy->copies);
+		list_del(&tmp_copy->copies);
 		break;
 	}
 	if (found_pending) {
 		spin_unlock(&server->nfs_client->cl_lock);
+		kfree(copy);
+		copy = tmp_copy;
 		goto out;
 	}
 
-	copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
-	if (!copy) {
-		spin_unlock(&server->nfs_client->cl_lock);
-		return -ENOMEM;
-	}
 	memcpy(&copy->stateid, &res->write_res.stateid, NFS4_STATEID_SIZE);
 	init_completion(&copy->completion);
 	copy->parent_state = ctx->state;
-- 
1.8.3.1

