Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D675C5CFFE
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4062520821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hhjLQJ1F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4062520821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727329AbeLJQal (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:30:41 -0500
Received: from mail-io1-f46.google.com ([209.85.166.46]:43148 "EHLO
        mail-io1-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726261AbeLJQal (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:30:41 -0500
Received: by mail-io1-f46.google.com with SMTP id f10so9207919iop.10;
        Mon, 10 Dec 2018 08:30:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Tke2KOJ89T4vcbDVIGt35hCRU2JIcQsMOR9LJ34omWk=;
        b=hhjLQJ1FRhfihk2mlkRrFEPc71efCjP/sOLCdkywD45p5f5BVCmeuLieXAW+zzAG4n
         IvXxfPEq1T69DXDrfPDHj/yUzyzpW2YI9SJWT5Oe0gUt1Quspiqx7vpHvIofhcpBR27l
         KsJt5fpJZ0zAQyN+H6utj1jBUmphOSPQhHB+u8PGujKkoCCckQ9aK+7WRVxXpUlDv76K
         q+y6Y9lGKfgOa7Tmj03TZHzvmrhoSJ+fRfiM4dIwCDy0Spa8L/GuBSsUwvigtdCm/ug4
         Kqmh1lxEpYazqgwsBElEVK3YDh+UDfgX2997VJejgcM7PuPc60b+/tB2N/ppI4PJb4Kq
         m6ZQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Tke2KOJ89T4vcbDVIGt35hCRU2JIcQsMOR9LJ34omWk=;
        b=BvapxsK3OWw8weor6/Y9jg3+LCZm/ttcE4MRli/5bJMk9B6W4f23xkFkMCQgTXT9J7
         fJPvCIzY+CgqEX6rk11UCm22OFZ5UtLTLfGSFQz5pTMO1RhG19TI/l3HVeHg2nlN0y4z
         qyr1Xd8dTQTM81jI0slrBrIizaWyu0FsFErjip0PqLGkl128/kYINomzprqkYxzVTU/V
         fb1PobPCQPMDCFJYKFnNFi96gORbPsjI7HqnLB9MS0ugKksETfFmoZlfBcm4Ja4VK6az
         HFAMZJ8b05TW1jxUOIC5wITdP/NRjXGr5rlmb4mjdYfDCanZbjGEsFs0xtbu56NIDNhW
         F2LA==
X-Gm-Message-State: AA+aEWY5TfiorNnq7M+QqkUfhpK++gtL9k9MZueHPGsOtxaXzOCHMZ5Z
        ZxmThTiIkwVIdj8/MuBhwHE=
X-Google-Smtp-Source: AFSGD/U3QKlseC3WcaNLiPz9s6nbH6g8F3kAsxTegeCrSg3bKjnAKdyt28js1U4Hf9XTuCY1wNZOHw==
X-Received: by 2002:a6b:7903:: with SMTP id i3mr9834943iop.273.1544459440446;
        Mon, 10 Dec 2018 08:30:40 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id s13sm4903975iop.36.2018.12.10.08.30.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:30:39 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGUdP9031067;
        Mon, 10 Dec 2018 16:30:39 GMT
Subject: [PATCH v3 15/24] NFS: Make "port=" mount option optional for RDMA
 mounts
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:30:39 -0500
Message-ID: <20181210163038.4198.21374.stgit@manet.1015granger.net>
In-Reply-To: <20181210161723.4198.51071.stgit@manet.1015granger.net>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Having to specify "proto=rdma,port=20049" is cumbersome.

RFC 8267 Section 6.3 requires NFSv4 clients to use "the alternative
well-known port number", which is 20049. Make the use of the well-
known port number automatic, just as it is for NFS/TCP and port
2049.

For NFSv2/3, Section 4.2 allows clients to simply choose 20049 as
the default or use rpcbind. I don't know of an NFS/RDMA server
implementation that registers it's NFS/RDMA service with rpcbind,
so automatically choosing 20049 seems like the better choice. The
other widely-deployed NFS/RDMA client, Solaris, also uses 20049
as the default port.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/super.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ac4b2f0..22247c2 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2168,7 +2168,10 @@ static int nfs_validate_text_mount_data(void *options,
 
 	if (args->version == 4) {
 #if IS_ENABLED(CONFIG_NFS_V4)
-		port = NFS_PORT;
+		if (args->nfs_server.protocol == XPRT_TRANSPORT_RDMA)
+			port = NFS_RDMA_PORT;
+		else
+			port = NFS_PORT;
 		max_namelen = NFS4_MAXNAMLEN;
 		max_pathlen = NFS4_MAXPATHLEN;
 		nfs_validate_transport_protocol(args);
@@ -2178,8 +2181,11 @@ static int nfs_validate_text_mount_data(void *options,
 #else
 		goto out_v4_not_compiled;
 #endif /* CONFIG_NFS_V4 */
-	} else
+	} else {
 		nfs_set_mount_transport_protocol(args);
+		if (args->nfs_server.protocol == XPRT_TRANSPORT_RDMA)
+			port = NFS_RDMA_PORT;
+	}
 
 	nfs_set_port(sap, &args->nfs_server.port, port);
 

