Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 157FCC0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CD02A205F4
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WBbuc9jA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD02A205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726830AbeKBBt3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 21:49:29 -0400
Received: from mail-ot1-f65.google.com ([209.85.210.65]:46479 "EHLO
        mail-ot1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726375AbeKBBtX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 21:49:23 -0400
Received: by mail-ot1-f65.google.com with SMTP id q5so12885153otl.13;
        Thu, 01 Nov 2018 09:45:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=0Ld/1Zld8R8avZQSZVI4eRsvqLOCfV8kYBvr9LN+UEk=;
        b=WBbuc9jAU3zoI9kkwxv83TsMqaucABDyHmqySUvUN0dpMGJw/FN5EycieSMHxL3rkR
         Ml032JCGhLsjK3KhYNTaZxH5ZbIWf/zhPB0i7Wz9V6Epfj8l54ueYgg8gkDbkE92rcoj
         CdWffRqkygejcKUYXN+y/JYLDflkmLF2JDuGeMLbE3h7uuBX3Sn2FICGWWwGv84mQvQV
         UZItT5iT81X7JicZJVYWgsX1T4p9P74GCiZAJ4/UKtr9WG9lVpDfjg81h6dz8mcCBZF+
         Bm8csGEKhxgToddnYnm+8vy3wtOY4fvAnTVzzAXQahwq4W6p+6bxT7Jx/h7bqyh9LmsL
         xAUA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=0Ld/1Zld8R8avZQSZVI4eRsvqLOCfV8kYBvr9LN+UEk=;
        b=uLl0IzCtZvk01EjdROqefIO3SW9iOgODd6Y0XuqYKAWvkbKd0N9X7cq+rT+i5Wqhcn
         Nv9QWjH/DqZwFm4mJXmTk8rs7aDtpqQqU3ihnEjtZGCmvnpdzbP1XFuWGUKKBsM14OR7
         CxOW8XKLZNOh2NDUW/os7uaBiZfTvC9XMu2SkVX3OhBgejS1Lrxsl8HZmFCqAqRZULHE
         5BrqqNS4i6XGllNnDQPkoLx5kXKcfomgeFRsqF0fsZg72Y9dxEC+FoT47WyJYTgSEbgX
         QGf4iLjpwhzE3L7vtdQiuAQxk87B/xfHo7b15NP/f3eaN3lgzqGtrJfI8DOUFi4iTb3j
         IgBQ==
X-Gm-Message-State: AGRZ1gKqRMxPtuUYpw/GY7SIniiGy3pJOgM72kXvCoYJo1k8T33mIzIJ
        w5brSHRsz6+0Pfl4z8JEdYyDZVc7
X-Google-Smtp-Source: AJdET5eczrCIL6ile6u1lPdq/OP7hdZbDjlORERi4VS35oN6Qo37XIDMZuP99yDtWIPNmKoGY5CI6g==
X-Received: by 2002:a9d:30c2:: with SMTP id r2mr5173899otg.53.1541090738435;
        Thu, 01 Nov 2018 09:45:38 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id r62-v6sm1834301oig.14.2018.11.01.09.45.36
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Nov 2018 09:45:37 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org
Subject: [PATCH v8 08/11] NFS: skip recovery of copy open on dest server
Date:   Thu,  1 Nov 2018 12:45:20 -0400
Message-Id: <20181101164523.41812-9-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
References: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Mark the open created for the source file on the destination
server. Then if this open is going thru a recovery, then fail
the recovery as we don't need to be recoving a "fake" open.
We need to fail the ongoing READs and vfs_copy_file_range().

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4_fs.h   |  1 +
 fs/nfs/nfs4file.c  |  1 +
 fs/nfs/nfs4state.c | 14 ++++++++++++++
 3 files changed, 16 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9c566a4..482754d 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -165,6 +165,7 @@ enum {
 	NFS_STATE_CHANGE_WAIT,		/* A state changing operation is outstanding */
 #ifdef CONFIG_NFS_V4_2
 	NFS_CLNT_DST_SSC_COPY_STATE,    /* dst server open state on client*/
+	NFS_SRV_SSC_COPY_STATE,		/* ssc state on the dst server */
 #endif /* CONFIG_NFS_V4_2 */
 };
 
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index df468a2..12c34b3 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -336,6 +336,7 @@ struct file *
 	if (ctx->state == NULL)
 		goto out_stateowner;
 
+	set_bit(NFS_SRV_SSC_COPY_STATE, &ctx->state->flags);
 	set_bit(NFS_OPEN_STATE, &ctx->state->flags);
 	memcpy(&ctx->state->open_stateid.other, &stateid->other,
 	       NFS4_STATEID_OTHER_SIZE);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 62ae0fd..b0b82c6 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1606,6 +1606,9 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 {
 	struct nfs4_state *state;
 	int status = 0;
+#ifdef CONFIG_NFS_V4_2
+	bool found_ssc_copy_state = false;
+#endif /* CONFIG_NFS_V4_2 */
 
 	/* Note: we rely on the sp->so_states list being ordered 
 	 * so that we always reclaim open(O_RDWR) and/or open(O_WRITE)
@@ -1625,6 +1628,13 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 			continue;
 		if (state->state == 0)
 			continue;
+#ifdef CONFIG_NFS_V4_2
+		if (test_bit(NFS_SRV_SSC_COPY_STATE, &state->flags)) {
+			nfs4_state_mark_recovery_failed(state, -EIO);
+			found_ssc_copy_state = true;
+			continue;
+		}
+#endif /* CONFIG_NFS_V4_2 */
 		refcount_inc(&state->count);
 		spin_unlock(&sp->so_lock);
 		status = __nfs4_reclaim_open_state(sp, state, ops);
@@ -1671,6 +1681,10 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 	}
 	raw_write_seqcount_end(&sp->so_reclaim_seqcount);
 	spin_unlock(&sp->so_lock);
+#ifdef CONFIG_NFS_V4_2
+	if (found_ssc_copy_state)
+		return -EIO;
+#endif /* CONFIG_NFS_V4_2 */
 	return 0;
 out_err:
 	nfs4_put_open_state(state);
-- 
1.8.3.1

