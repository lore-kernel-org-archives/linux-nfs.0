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
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7527C0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 904662082D
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FXoZ44PX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 904662082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729471AbeJ3DyO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 23:54:14 -0400
Received: from mail-qt1-f194.google.com ([209.85.160.194]:33331 "EHLO
        mail-qt1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725969AbeJ3DyO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 23:54:14 -0400
Received: by mail-qt1-f194.google.com with SMTP id i15-v6so10613396qtr.0;
        Mon, 29 Oct 2018 12:04:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=DqnHnZrMSvA0or48b6pnWzyYDz4iWYc8+TMTuA2+K94=;
        b=FXoZ44PXZaoiI5U/LlShSfMtLHpKwDvZEDri1ITE0YaMbnkGD1XLdLHUC9ppdaNp16
         hT0IrrpcbCqNK13NJLpZQJFlRqgrynw+TXt/2vrgNFiZsn/vlIMnNHGphVU9Bk7VHDdP
         wTUXZ0qTejBsJ3+j4+R1a3Lp3TOybON2i/hUrVmhRJOU8EvbEMPA3KBzU114eHuDRW96
         1R4HeDR96bYr2boI+ykW9SN1QdPWqFrKeWZgQNNT0JHyiB8nejF40fNE+D1Z8FbMy5aq
         Ndn5TnXl/74Fm1MQcvMQbaPAGXDPEFFXtKmo5oby3jjN5dXXFGD2M+6kWgWK+i8cikHn
         /4NQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=DqnHnZrMSvA0or48b6pnWzyYDz4iWYc8+TMTuA2+K94=;
        b=FowflJdxMOhbiHGlv9L5RPG9LIcdCjy+RKZ1hUXNm5u1MjT2tamYsMhXpx2zLfG+TF
         MRj9ahYF3s7nsKfNwZ1muY8zmYmEDV3chpdA+QaEIIjcFwCPAVFAtekQKYWh7VYsWb3+
         0OPnr78hCxRCDHL/hucEvrsSzWq38jNA0gyxxsHqQJMxXC22qB3zdo+6lfJcqpbqE9Dd
         gSdx60Ex/7suu9gSEsQpfatGafbYUYwSVxk3Ot24XFcvqZmbVAtZxvO6bW9HDCjE3aQe
         V0P1DJ24ZLrHNhAYj0L7M8ek/Z7Sd6YHjn8lb6qEMnhEcejgaX9MAJ7Dd9GhBgK31vTg
         i2Mw==
X-Gm-Message-State: AGRZ1gIiYWSppxjoCYhSgvNNBBcIJlzrlf/UqlDT9kdNSqlOBz94T69e
        gvU/THKh25wkc0wipvvu/r0=
X-Google-Smtp-Source: AJdET5f/kGKaYiahxprOoOnVYpdRB3PtFuUyLNGUcOLZnvHYogiFOoWqKbw3aIN3Y+3wkS7fr2FvCA==
X-Received: by 2002:ac8:191a:: with SMTP id t26-v6mr13444924qtj.327.1540839855192;
        Mon, 29 Oct 2018 12:04:15 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id c5-v6sm2714373qtj.55.2018.10.29.12.04.13
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 12:04:14 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v6 07/12] NFS: also send OFFLOAD_CANCEL to source server
Date:   Mon, 29 Oct 2018 15:03:52 -0400
Message-Id: <20181029190357.38439-9-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
References: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

In case of copy is cancelled, also send OFFLOAD_CANCEL to the source
server.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index bb9e799..98fe00b 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -205,12 +205,14 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 	memcpy(&res->write_res.verifier, &copy->verf, sizeof(copy->verf));
 	status = -copy->error;
 
+out_free:
 	kfree(copy);
 	return status;
 out_cancel:
 	nfs42_do_offload_cancel_async(dst, &copy->stateid);
-	kfree(copy);
-	return status;
+	if (!nfs42_files_from_same_server(src, dst))
+		nfs42_do_offload_cancel_async(src, src_stateid);
+	goto out_free;
 }
 
 static int process_copy_commit(struct file *dst, loff_t pos_dst,
-- 
1.8.3.1

