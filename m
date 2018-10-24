Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 000C6ECDE46
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B9B2D20832
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Orrg4+IU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9B2D20832
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727501AbeJYE2W (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 00:28:22 -0400
Received: from mail-qt1-f194.google.com ([209.85.160.194]:33525 "EHLO
        mail-qt1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727456AbeJYE2U (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 00:28:20 -0400
Received: by mail-qt1-f194.google.com with SMTP id p24-v6so1171028qtq.0;
        Wed, 24 Oct 2018 12:58:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=DqnHnZrMSvA0or48b6pnWzyYDz4iWYc8+TMTuA2+K94=;
        b=Orrg4+IUS70/He9/HvyiGLpqKLwtqiRg87WVasQElYQxC+5MivRe1/v6oHV48X9rY5
         Ry95VOLwXVCKmKwmVSMvz1t1aqVC+kK7XcUc40uHsekLGUMZ28PW5qSk+JcwizwKeewB
         7YKomlImk2Hpi36BFTTB7rEw/A/nUdxxXuCKwEJAone2wFdagqYgxYUtGuOLmxu78WH7
         H7uGQuRznQ9cEcADNeQoA+65zhmm5QbZi2oCDEVzauqwzwi2dCP/7s3zvPGm+60cjROa
         5wVSi5vkwy8bLpt4x7w0kVAmXM7pB8GBPye47dkJt+JfDp+80fRVHBpCodups4hj+aBT
         SdNg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=DqnHnZrMSvA0or48b6pnWzyYDz4iWYc8+TMTuA2+K94=;
        b=hVbb2lByNiHbYw5VtuP7hH0jXAJEu04vxz2Zagoj/ziD9zyuUgjIqMSWlAkvsDmPdu
         VglZj+ffL4D6HjUkS5n4SCh/Bi38oanO4ZeYhDOGxapUxc/oqvYkIVvgatlr3rBmOL1r
         FxCaD1DVYE2CMPIrWaZMnLdj6cfzq0LpGf2FQb4r7pshIsIxqNyJD07x8RbgGKtkoIZj
         VePQTjaTyFF99LaOFaLBVnkCJM817o6/w3s8e9w+taKOyMVgW2/Nd+ok7INPCoGJkfKP
         dx5bkH+NUkxoBAheaJJFd0fLRnhKkk2tseiGE9ChHC7FG8fcHN2Bv8A/64LHiIzf3oxP
         Rxnw==
X-Gm-Message-State: AGRZ1gLugwC7Gf1rqJZV+RiEbUrJL65POZxfkfERF+d8Wir9Dfst6MMi
        j1uUEnTkSAFfJ8/MGj2pGS8=
X-Google-Smtp-Source: AJdET5cWwxoYfGXCvAm0girlk0mnHAzk6UXKSJl28Oqgablw+G0cx/Fh4hQ7wmLx5gnlD7BaPUL1FA==
X-Received: by 2002:a0c:f651:: with SMTP id s17mr3910667qvm.46.1540411133978;
        Wed, 24 Oct 2018 12:58:53 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id d124-v6sm3872380qkf.85.2018.10.24.12.58.52
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Oct 2018 12:58:53 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v2 09/13] NFS also send OFFLOAD_CANCEL to source server
Date:   Wed, 24 Oct 2018 15:58:33 -0400
Message-Id: <20181024195837.35532-11-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
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

