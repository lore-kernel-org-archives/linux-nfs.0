Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7EBFC10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 14:44:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B6C292084F
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 14:44:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="u0HbqZec"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726497AbfDIOoU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 10:44:20 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:53058 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726492AbfDIOoT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2019 10:44:19 -0400
Received: by mail-it1-f193.google.com with SMTP id x132so5299914itf.2
        for <linux-nfs@vger.kernel.org>; Tue, 09 Apr 2019 07:44:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=pgCF7oSCfT22iLs5Hc2ih/3Lc5kyQTsxvZlDXHjQaNc=;
        b=u0HbqZecDw83KVNSTRCdgnKGRIPTq/fW6eWkjonuNzNCzXwdErGJnhwdWtFqFZBe+O
         9J74ZF9+4Ir4wBvTuZ8FOyoqX+6Od0aLp4ZkIHm8VeLYcyhcrT407tahbnm5WAaXB1BL
         Cr7HGiWKgVYEGRNosCNs8hLbR24LFT5rRyx4wPo81qJEk6qGjNHgvHyf143sOrtiGscB
         p/RRK5DoIl5tYPJq7FrhncBgW+YgNucbI5UMt/0G/7swGcBORSEw9krUMKUDnUfUaWMc
         SBfzXrMrKPZCCSGy1N2OvxPMvebCUUcKH09HA85bBJaSAboEn3gWwN7UTuQSjMYxQVzs
         WZQQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=pgCF7oSCfT22iLs5Hc2ih/3Lc5kyQTsxvZlDXHjQaNc=;
        b=q8FnHVrDGHZ3X0pz/+wCTUIjVV9AiyGNMsbNVIq7ItYbwECpb86O8uUdgcZ+t47jjZ
         rOdAg71oj5JWGO/042yXYNg1QFQ20KiweBPUixf3zZ46vwfFhxbxXBtXYXZpV4K2bui9
         X/hZ/JtPJkRvkaGHg5j+ygS2B+TpcKeTLDk3lthnHDGQu/1xkeUW6FUJIJ5se5OoBZg1
         +r2ttfIxyqWp9Cuh9ORO/sn8WLLYVmL3d1JEICse7h+G6nbtviKZA1YI/mktQPep0re9
         wCr9FKh2K5QGhyPdBQHKRRs7zSE6s+vX2My9XQdkCo5i5gvb3aqpr+wHDTdcWizqa8yx
         caKA==
X-Gm-Message-State: APjAAAUeauTBf1H4f5Jcd2yENP0uJOTouOKLaaag9WG751bAsZjcUXJe
        L5+N3IIpoBr29zdUChOriq4UZtoT
X-Google-Smtp-Source: APXvYqwFEDwi1paU5+DYpOFvjWYajS5R3sMAO7AlfZFwsvYjuO+4qwl+vQXbH6me6d9bUeCnZeahbg==
X-Received: by 2002:a02:c845:: with SMTP id r5mr26465234jao.110.1554821059250;
        Tue, 09 Apr 2019 07:44:19 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id i12sm4920562itb.11.2019.04.09.07.44.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 07:44:18 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x39EiG9P001000;
        Tue, 9 Apr 2019 14:44:17 GMT
Subject: [PATCH] NFS: Fix handling of reply page vector
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com, trondmy@hammerspace.com
Cc:     linux-nfs@vger.kernel.org
Date:   Tue, 09 Apr 2019 10:44:16 -0400
Message-ID: <20190409144353.2886.54126.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

NFSv4 GETACL and FS_LOCATIONS requests stopped working in v5.1-rc.

These two need the extra padding to be added directly to the reply
length.

Reported-by: Olga Kornievskaia <aglo@umich.edu>
Fixes: 02ef04e432ba ("NFS: Account for XDR pad of buf->pages")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Olga Kornievskaia <aglo@umich.edu>
---
 fs/nfs/nfs4xdr.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Hi-

Can this be applied to v5.1-rc please? Thanks!

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index cfcabc3..6024461 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2589,7 +2589,7 @@ static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
 			ARRAY_SIZE(nfs4_acl_bitmap), &hdr);
 
 	rpc_prepare_reply_pages(req, args->acl_pages, 0,
-				args->acl_len, replen);
+				args->acl_len, replen + 1);
 	encode_nops(&hdr);
 }
 
@@ -2811,7 +2811,7 @@ static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
 	}
 
 	rpc_prepare_reply_pages(req, (struct page **)&args->page, 0,
-				PAGE_SIZE, replen);
+				PAGE_SIZE, replen + 1);
 	encode_nops(&hdr);
 }
 

