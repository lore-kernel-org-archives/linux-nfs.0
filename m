Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E5A4ECDE47
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:52:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3284220834
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:52:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QnddPkDc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3284220834
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727651AbeJZG0Z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 02:26:25 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:46431 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726511AbeJZG0Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 02:26:24 -0400
Received: by mail-qt1-f196.google.com with SMTP id c16-v6so11760243qtj.13;
        Thu, 25 Oct 2018 14:52:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=DqnHnZrMSvA0or48b6pnWzyYDz4iWYc8+TMTuA2+K94=;
        b=QnddPkDckqKa+JGCUJ7qr20TkexVq9wwfMJ38AvmzQ0qFwrB83H8J41/+FMivXcM+0
         XwfJGJ39jkSgZ5F8Q1ehgoHdYKd+wmMuCsk3Z7WfdRbhVCysitutBAY/gg2Mxm414/NL
         hYE1uQljuQaqfJRs4JX5E95CWhqf56D7dzDLEu7+Nm3B5TErB5Qnkkiu/w/MIX8hDqIC
         udQtDdXWxn0Ek/kheRnAQmroDkUpqAPThXKLCqjQkgmfDcfhllXBYIDF4FHRo/n9wkkl
         kyeB+rvNWG3vc/YbgCNLAlH1PB6TVtm3/LoxHRnQEcB1SzyeLKx0lKS8Gjmp7eO4mDZF
         tSow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=DqnHnZrMSvA0or48b6pnWzyYDz4iWYc8+TMTuA2+K94=;
        b=ThMCo2C1aY6zdEX//w3AI8rTEOk3q97gmhjFRHGebT0QmqN317j6TENpIzSkv3ZjxR
         AFRdHwy2nt6lGLV2eVhefcUMZnLedfyJET7GCOd9BQWWPkpq0OZ0YstHaghO7+sHQcZ3
         z5zcaPfqAyfaxv4Ukbw1HVHpiXqBNZJBRlrgPYTZ2D6pAJE2FVKRM9n+WXxL9OObd4G+
         D5tKo52HcOLPNzDOwDeqPM72cftTbXT0WtBwL36/uLZpD/9E6HKZHZswVGq43C9qHuVF
         IsjUmVxySTJ9qt4Zx6yjbuKnUmDMhVovtjLk0N+y23DgUHTNNctLOF71CiJcrmyK+aXi
         Wqfw==
X-Gm-Message-State: AGRZ1gIsfmGzvcbdLooXresB5lwoCAxflzYi96LBPL+m4Low/hIRtaWv
        HXqAilZ6LTN3xdjCuvYFCrA=
X-Google-Smtp-Source: AJdET5cplp7pEsL4Fsfq5cs3nFx59YRz/fKsRd5savlaDa4uwJmNEHFgw5eq463Y2kxksXgNVjZ1eg==
X-Received: by 2002:ac8:2932:: with SMTP id y47-v6mr929670qty.42.1540504320076;
        Thu, 25 Oct 2018 14:52:00 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm5895927qkc.96.2018.10.25.14.51.58
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Oct 2018 14:51:59 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v3 06/11] NFS also send OFFLOAD_CANCEL to source server
Date:   Thu, 25 Oct 2018 17:51:42 -0400
Message-Id: <20181025215147.36248-8-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
References: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
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

