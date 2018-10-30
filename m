Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB78BECDE44
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6E26C2080A
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pitGpPth"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E26C2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728018AbeJaFvk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 01:51:40 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:42027 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727984AbeJaFvj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 01:51:39 -0400
Received: by mail-qt1-f196.google.com with SMTP id z20-v6so15256981qti.9;
        Tue, 30 Oct 2018 13:56:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=DqnHnZrMSvA0or48b6pnWzyYDz4iWYc8+TMTuA2+K94=;
        b=pitGpPthvATx7Y+Z/PDpsfEse4t5ETFcqXXMzejc/21sepODoe9FwVxELC45RV9uzX
         Dzuke16lPijmo9ASIjOU9KTe8YoFiwt358Rom5IOmj9tw6F4tR1xnkoqbzco/6Y4rc7B
         EEPxSe10Gqc9e9gxnCxMEbvrKia+U7d4i3r59jCZbaqJeFYTpPNqa1WHtN/QprMTuMyO
         N3AInCTFmZM55nE04Fb0DHq5JfEE/YEJCVJb1eosckbRBylvaBE2xxCkMvYGEvgiGuX2
         fP1+d0JE35js7ORLDLApWXeFIa4o5XVhRlUhrSNapKPjUJf9qxJWj/w05F+WhAZI7Ti9
         cGRA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=DqnHnZrMSvA0or48b6pnWzyYDz4iWYc8+TMTuA2+K94=;
        b=Z62SOWEGrHvRY8L12d8qdmnhNz5K1+fM/jrM1OxE5//rggINh5Mc2Ax44YnTvsudTa
         GNY9TN3XnbkzLjz3I4bTKYoXnj/KOYUL5qSaXe0uK85/dk+m6pERbwFyBZ0oCRqe4O8m
         +gf5bhMrWLjkhiJMNMQCkF63uKZbYWQ0q86XQrAq4pvVBoc80aBQdZMnKyfDBvs5eeGu
         06kvWlyOxNx9NVcVucD+M2yhJ8eqnX654VYnjhAr05CCxbZNmWFe4tfcdbmN1J3WWs2V
         dFY1DfCGJyL3+31OMGHSOWfvL8HxoySkzddw4bj6eRUvxsTgJEOg2LiblMQ0CxCgt+3Y
         w1KQ==
X-Gm-Message-State: AGRZ1gJfifbVKITFnA0ZeO00r67dCKrU6gRNK/Nk2QkAe6KNnc30o3kK
        H/bZg3MF8yv4+sumGbPNPvQ=
X-Google-Smtp-Source: AJdET5cw4bUgLaX5mP9GhRZljgm4D7CH97WDY78dRn0Hjmie9aSSzA+HAvt1ILETBBv27lIhM9cSIQ==
X-Received: by 2002:aed:35c5:: with SMTP id d5mr303046qte.212.1540932994677;
        Tue, 30 Oct 2018 13:56:34 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id i11-v6sm23478157qtc.96.2018.10.30.13.56.32
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Oct 2018 13:56:33 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v7 06/11] NFS: also send OFFLOAD_CANCEL to source server
Date:   Tue, 30 Oct 2018 16:56:09 -0400
Message-Id: <20181030205614.40754-8-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
References: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
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

