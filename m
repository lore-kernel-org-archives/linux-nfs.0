Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37B4FC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 072D92133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mrYyQNqv"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388257AbeLQQk2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:40:28 -0500
Received: from mail-it1-f172.google.com ([209.85.166.172]:37941 "EHLO
        mail-it1-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388108AbeLQQk2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:40:28 -0500
Received: by mail-it1-f172.google.com with SMTP id h65so20903471ith.3;
        Mon, 17 Dec 2018 08:40:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Tke2KOJ89T4vcbDVIGt35hCRU2JIcQsMOR9LJ34omWk=;
        b=mrYyQNqvPVMg1z9imePsy3XTU6ZWwoj09cMaJVnX0pH50Q92e+bLTMUwh1K5Uwm81f
         d+yK0DRfv6bM89ZzU9winzaoIFhKVZIADXKFJ/BSV4L+9WzZJqNe62C5CcSJxAKUQJGK
         V6x+opFOQUre0+ewBE4XM7wH5oxgjHj3eQkCyCg8aR9nMoOsI0A8ISEnmw+qlycfVi5S
         jaKKZAK8ya/rIx9z0FsNMRSno1bJnq28bT+kdq+2NpLnwGWYm6A0VuQKKuEyPwwvSBOZ
         ltx7UBvMEKtPBaoIuOzRTy5+zoRZZik53BVk0BFiTPAQTs/TVyBYnZCXzkPnwV4xO3y0
         H+kg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Tke2KOJ89T4vcbDVIGt35hCRU2JIcQsMOR9LJ34omWk=;
        b=qTkLQVpW9a4xsah8q4EKrumtK6CemxTt2IzcjmMJ/6gieFlK0ZiRIbiekAH6nKXhBL
         Dd299NQ2+tt224EDbGAuEjV2Nerf0RmPDlUDT9FlkIyjXHqlKul3FEtMuLjzprwiGw+S
         X5iPgjsNJarzQZWoo9poqfIXAJ1hDCWNAVtTyfJZJB9aTvw7w0uyQrhZU5auQ2j/tqxp
         ZfSY0uCsy1UQGmgTZsAWbM3zMERkdyzZVM/xpKHpC7yCiPnFhaXysLBtadcAhcPLWGRO
         vyU2+/CJqNmiXFwm21zEqu6Zq0I6IjJ7e4VbKAvnMR1F4qR/JbALY7ZelNnHahNS1I9z
         1SuA==
X-Gm-Message-State: AA+aEWbIwAZKt6zWb6HextW8GwYfgnhThRQGE56Z1MP+Ny6AVMTbnjpp
        u3/k0/JsjGnLgxBrG5LiZOI/Hb5F
X-Google-Smtp-Source: AFSGD/W9d2gYcPBPH+I29Xs6YcI+jdWKmEumP7+aRo2S8v9KgaEpGz0G7krZMNEuVlh4xfYB1jVkNw==
X-Received: by 2002:a02:98d2:: with SMTP id c18mr11908250jak.11.1545064826893;
        Mon, 17 Dec 2018 08:40:26 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id m81sm7214014itb.43.2018.12.17.08.40.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:40:26 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGePPm018614;
        Mon, 17 Dec 2018 16:40:25 GMT
Subject: [PATCH v4 12/30] NFS: Make "port=" mount option optional for RDMA
 mounts
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:40:25 -0500
Message-ID: <20181217164025.24133.45942.stgit@manet.1015granger.net>
In-Reply-To: <20181217162406.24133.27356.stgit@manet.1015granger.net>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
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
 

