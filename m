Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 640E5ECDE46
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 266B120824
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="us/pX2VX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 266B120824
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728039AbeJ0Eti (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 00:49:38 -0400
Received: from mail-qt1-f194.google.com ([209.85.160.194]:41042 "EHLO
        mail-qt1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728020AbeJ0Eth (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 00:49:37 -0400
Received: by mail-qt1-f194.google.com with SMTP id l41-v6so2673260qtl.8;
        Fri, 26 Oct 2018 13:11:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=7UYm6KwHepkUcFRejYDPg8EOERI1MmALOURzx0oOqU8=;
        b=us/pX2VXNVNIXS3Dz9jBEsGC8SHaLzpwS+9z9N2pETU7WmquajvHoekye2NMdP9NbV
         awm2R+jNJBQlZuLsoHOFaZcOpXdJjud3ZDPc+Tj8W12UBCUjVo1vL2pAN9RUcqBilxQP
         wMKFbQmGEVqtAgFkvbXnTzofXLf9TrHHDkrbNWn//T7g7ACVKJiFI+i4cyjjAFqZEYs8
         IbQX1+KuebNFQwm2WrUNZAn7hoUSYGVD0Mr/gfc1La0YP1ridT+NN3WeLMecqxDmOp0u
         44MaxViSPUsCCl6ThJk6v058V336NHm436Y3tLBP76OzG3SC1LZ1Je9+rexWVxmx8fkl
         DgEg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=7UYm6KwHepkUcFRejYDPg8EOERI1MmALOURzx0oOqU8=;
        b=rVzZwDyy3GCCmrFAwNWbUXYtIioNPvPaxuTg4kR8Uxyv5KzH8o1MUo5ktbd2oWn41E
         8eP6590IzkOl2mIMNKDs5ARXHgwZIw4sgzJxQvApx5yfzuQ7qkYjrX3CLVYaI6Ym8mWI
         r7MNSm0wGlD/ZmNcV6pUfxISrQbTvmVX/nWG/Jp4KfguoMH7OeGAOCO+sKmpOsBxbMuk
         qSHz+3ia9hnlkTJF3d7dU1U3vBChrs/Uivzevu7JJh4hITx8Z54mqYULQZd7jXL1z10K
         xGFgOO+vvnzpMLXYNNk0U8rxST33wSgYm1EJSiRoz4o4ux+nV/3yC9cxT07bbWZgfGNR
         e5Xw==
X-Gm-Message-State: AGRZ1gIOYUGd2NrTTiECxKBBOt8EOIsR8RBYUMw5pEkkkjd6UMY366wE
        NqwSZ/aZv7KxkzZPawNAV2X9gHtf
X-Google-Smtp-Source: AJdET5dJrg8Pvw44yacYD9HNujm6fnsP2UBuWeTJ+7M3W6/7keNkmBjZEMvjV9oxCd4SYd8sy2x0SA==
X-Received: by 2002:a0c:e809:: with SMTP id y9mr4122206qvn.83.1540584673787;
        Fri, 26 Oct 2018 13:11:13 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm8037667qkc.96.2018.10.26.13.11.12
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Oct 2018 13:11:13 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v4 09/11] NFS: for "inter" copy treat ESTALE as ENOTSUPP
Date:   Fri, 26 Oct 2018 16:10:55 -0400
Message-Id: <20181026201057.36899-11-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
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

