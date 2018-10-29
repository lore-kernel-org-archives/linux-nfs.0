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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CE6BC0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D01272082B
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="B5XFtVXG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D01272082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728112AbeJ3Caz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:30:55 -0400
Received: from mail-qk1-f194.google.com ([209.85.222.194]:44783 "EHLO
        mail-qk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726330AbeJ3Cay (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:30:54 -0400
Received: by mail-qk1-f194.google.com with SMTP id n12so5451026qkh.11;
        Mon, 29 Oct 2018 10:41:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=4PksShieLrh4Cf0smwQQ0hWXC8t13fGxowZ1fcGZ/Dw=;
        b=B5XFtVXGV8sUhpMihOc21WdIyMlot5CKoCJDneZChSnI+V9pfHXWrV9apRl/IGAEbF
         L37LwSS05B3Wy/fnzsR0J2sLhg61e4s5Vgnjhxk3gVme4Hk4ekBDdwjqmAaq3ZD3tcHP
         a7HjVCwE9JV7/kAEv69GEU4GInlbCf2ejcnB5jxbJzoTA/srSjMW9uTcSSFZhsJbXs9P
         SF+jGlE9je6cUyDTUKWHcv3gZr5NwFEWASnaFpqvT0ajw+3L594gfl3uGy7jaqr/f/YO
         uEcMDD2lB518SmmsUNWcMtu1bqI1hBWIMly91gu4kyEupAXM56/sc5hDYDDRIYk9kBp5
         qJfg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=4PksShieLrh4Cf0smwQQ0hWXC8t13fGxowZ1fcGZ/Dw=;
        b=as5dORLGev/Lz5ffsmTE1Yv0axklMf4HUgTgMT2U60tBOE9yDWnJ+WNQfC0eyEyuZ7
         clZiAx/f6ncccbdRwMEGiaxpFRjEs3/qciz3ggk9Gv6Yc6wbOtEWqF9GfW6mIBVkv+Qh
         yWmnKG9NKUJx9QX57hR6YWzmLZmI/ZntVKNJ4LDd65SM/E3YMNZW3/j80Y6+bfbdD8/D
         aTQ0FHuzD9ZJ9dmFvxRUDfl/tH6KxZzeu/XnUV2uAnn1C0LkD782+z1RTRu39u/bNy5m
         aq0M+ZkYa8gpbROGiST1HLktr58iL2YQ5Ot7IOG1EeNNql6U8Xe54anflzXqrqTevffk
         aI/Q==
X-Gm-Message-State: AGRZ1gJ3D51h5s7P7Yo2jRY0CalH7VW4OWLPoax6eJ8bcv5B0K6JnRpG
        fksli+a+A1I05A1WKPTEHBc=
X-Google-Smtp-Source: AJdET5fCdbTOLLP62g5x7zPHlxiwxvqjA1AgT2gC3zH3ud6r/+pTYfmD9EJza44DLA0FzH8HRgm9hA==
X-Received: by 2002:a37:5906:: with SMTP id n6-v6mr12948710qkb.73.1540834877334;
        Mon, 29 Oct 2018 10:41:17 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id n190-v6sm13148929qkb.29.2018.10.29.10.41.15
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 10:41:16 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v5 09/12] NFS: skip recovery of copy open on dest server
Date:   Mon, 29 Oct 2018 13:40:56 -0400
Message-Id: <20181029174059.38326-11-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
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
index 0b1dcf9..989f174 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -333,6 +333,7 @@ struct file *
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

