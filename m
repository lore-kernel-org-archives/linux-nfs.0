Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1AEBC6786F
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 70D3A2080A
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NUZ/hVL0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70D3A2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728043AbeJaFvn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 01:51:43 -0400
Received: from mail-qk1-f194.google.com ([209.85.222.194]:38037 "EHLO
        mail-qk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728030AbeJaFvm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 01:51:42 -0400
Received: by mail-qk1-f194.google.com with SMTP id p3-v6so8212892qkb.5;
        Tue, 30 Oct 2018 13:56:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=4PksShieLrh4Cf0smwQQ0hWXC8t13fGxowZ1fcGZ/Dw=;
        b=NUZ/hVL0rdhHoPrCqxoePsrXZ47FbpMwrTIO9a6khMsFtE9Y07hcbr3IaHJqeUppOh
         M6HA6e4l8ZLw27LhmCwSzE5mhjh7XJQCVStxATiWiONhxHbx/pDZguoxtQx9RVqhgyMh
         ppear2qDXeemm9Nz3GYyHCJoKfmPp+GDs/Jl50OLsKGPCuHlh9b7SPg/AV1S4KeL2nrQ
         6iAgeyPyfVeb1yLZ1oLcKsSJ5wsPbh5hO5k+hF/++Rj6KTKCQntgaPH2BP9cy0XO7C2U
         KHG6EaYJ0bzVn0aHtB+QD4BWO2/5Yb7egZT5vZtNMqabZ0E4vcf5UmQMnKDCcrKrWTLu
         wvRg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=4PksShieLrh4Cf0smwQQ0hWXC8t13fGxowZ1fcGZ/Dw=;
        b=HlQVTlzQArbSoGDZJS6j1mHz/gN1M2IoHjQm1BNrqWYuO5hAoNsqxIvNB/DDr3G9dZ
         6PExqfNx3K0G9CKaeyBsEY3ZDjqGIcum64A2d855LNh0Obc67DFfet5ldMyLs5DFg4pl
         M2Cza9wGl7P2bROjADs929ZFcWgBhCNRuEJl/7ToTYy/H3YoD9qCI/lx9O6YdNDQStDw
         eyl98a3dFuspFYoXozRC56vBkaGJMN1g3JSkZljsZ0BkIlCMDQrwaGpr4AXoyUapf5+C
         HjePwnahDdNtJ+ZIHcfaQkXzNwgAnF+gpVeSdEaKtR0AhYAz171RaZ92MmSSIMzoHw1a
         Cy4w==
X-Gm-Message-State: AGRZ1gLQ66ii+ACTvVk9Cd0XTM7h12Udq5P3mxTut0Mdp7Q7B4cn1V7E
        SpytHKnBVAEtOeQfgtqnr3o=
X-Google-Smtp-Source: AJdET5dzh3xpbNKXR2zXHiqQJu1S4R+dOUzTBPLEvoIr2gLYsUCgDDo868BLmKwGtj5RMrOEADV7fQ==
X-Received: by 2002:ae9:ee02:: with SMTP id i2-v6mr313391qkg.0.1540932997892;
        Tue, 30 Oct 2018 13:56:37 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id i11-v6sm23478157qtc.96.2018.10.30.13.56.36
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Oct 2018 13:56:36 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v7 08/11] NFS: skip recovery of copy open on dest server
Date:   Tue, 30 Oct 2018 16:56:11 -0400
Message-Id: <20181030205614.40754-10-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
References: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
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

