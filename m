Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E64ECC2BC61
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A5E2820827
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EYIPGGYU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5E2820827
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728055AbeJaFvp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 01:51:45 -0400
Received: from mail-qt1-f193.google.com ([209.85.160.193]:38906 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728030AbeJaFvo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 01:51:44 -0400
Received: by mail-qt1-f193.google.com with SMTP id v1-v6so11048474qtq.5;
        Tue, 30 Oct 2018 13:56:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=7UYm6KwHepkUcFRejYDPg8EOERI1MmALOURzx0oOqU8=;
        b=EYIPGGYUB15cBohrLbQ1H7xRmewHyk12yScSrEhUOIEB8Bdo+5Pt0fSdXUuzIG/6mK
         yzNkLHK0/1uWcemMFOaYiKvajSvk9IqbbgaqIF9/2xJR3kNZ0ZRmGtWCCG088vq8QBIR
         eEddIB861PuM6RXm+YJGzv7Gxaol7VNg71077QOUK6KTl/msgFJKjJCimXq/CFHyJ9/W
         n+/v1R63wBV6Lnk8xR7ViM4kqFC8J49W7vaOm90QkHbbTHuUEMCyj1EQPrLOkN9XeYLP
         DuMsA2p9O7UdafxPCDNa2SJTq/k+cdTxRLZ9oIYBpFH6CzUbHdWNlGcv8ZujG2GvqGIB
         aDRw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=7UYm6KwHepkUcFRejYDPg8EOERI1MmALOURzx0oOqU8=;
        b=uZzrrF9ep4rqhZfHCL0ac1+733bk1pCPsKIE5Uka0d78RR31ULeT7TilnPogjyMHMI
         XO8/4JuYwK1cKuWRGE/hXir0Y7lcUtYv+7P6ybC6J2kKLoOY4812G0lgZ+6vcWGuzSxj
         Ty9E5g3QNLQl1w4nQ259hivX5LSyuzZy88EDUvrRP59g9lt3iK7zLx/XVZBVKkgx3YHo
         UUBTt+Rt1QF8YgFooruJljEPNYRsoC0JEbC5Vb0Kw8RBJ+OwWwJHfUy0bVCaNRv83SBh
         odVJdW3X0gFNbBKWs52r8/lWiNU0GAX0tY/DtxTGiYedpuCCvbaMIUO2V9rNJACF4YgP
         Xheg==
X-Gm-Message-State: AGRZ1gLZ9alUP2v35IUKWuVbqap1GT/kIuav/JKMjcPa2DOpbB8AUzNe
        YoaVeX2Dae662eumeYg44Mw=
X-Google-Smtp-Source: AJdET5cfONjqbSf9Ih1IMfHw0q6IIX43hA16mJ8T1YoolkobyMYHt0c8r44y1h9Xpf07qoxukXbwtQ==
X-Received: by 2002:ac8:2249:: with SMTP id p9-v6mr311543qtp.200.1540933000179;
        Tue, 30 Oct 2018 13:56:40 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id i11-v6sm23478157qtc.96.2018.10.30.13.56.37
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Oct 2018 13:56:38 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v7 09/11] NFS: for "inter" copy treat ESTALE as ENOTSUPP
Date:   Tue, 30 Oct 2018 16:56:12 -0400
Message-Id: <20181030205614.40754-11-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
References: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

If the client sends an "inter" copy to the destination server but
it only supports "intra" copy, it can return ESTALE (since it
doesn't know anything about the file handle from the other server
and does not recognize the special case of "inter" copy). Translate
this error as ENOTSUPP and also send OFFLOAD_CANCEL to the source
server so that it can clean up state.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 98fe00b..00809b3 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -395,6 +395,11 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 			args.sync = true;
 			dst_exception.retry = 1;
 			continue;
+		} else if (err == -ESTALE &&
+				!nfs42_files_from_same_server(src, dst)) {
+			nfs42_do_offload_cancel_async(src, &args.src_stateid);
+			err = -EOPNOTSUPP;
+			break;
 		}
 
 		err2 = nfs4_handle_exception(server, err, &src_exception);
-- 
1.8.3.1

