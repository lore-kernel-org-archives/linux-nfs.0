Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09B77C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C9917217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y9D1iII7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729408AbeLSP7P (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:59:15 -0500
Received: from mail-it1-f170.google.com ([209.85.166.170]:55496 "EHLO
        mail-it1-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727829AbeLSP7P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:59:15 -0500
Received: by mail-it1-f170.google.com with SMTP id m62so10359383ith.5;
        Wed, 19 Dec 2018 07:59:14 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Tke2KOJ89T4vcbDVIGt35hCRU2JIcQsMOR9LJ34omWk=;
        b=Y9D1iII7K9ZCQYP8u3f00lqVSzYiJV0UIO6OK3NRq5pTULlG7ALDKudtKKHjMzzn4b
         USDULsDnMlDV364nksli2oqMYL/7uqWnSRyywychrPiOwr1gA3lHl190/Ytb4isd3Dnw
         atUPEEqXkIHbSqKJNWRIViaLh2ILhHFwHZO6I62R3gEcaQKf5H6pMG9vZ7bZ7PCi2H28
         uVOM2n1xQR2IiOJFQyMhqWHg8D4PoGHsEIr/bkZBR7L3rJ6MZv3To9vGcfWCzlp0YgDC
         JjTnQdowVBgXnV3DmZu+0KYxpe0/1CkuOyQkulCYNBIGrtyDRa6Ho+bgZKCPSiZ3UQ9c
         gWFQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Tke2KOJ89T4vcbDVIGt35hCRU2JIcQsMOR9LJ34omWk=;
        b=jken/hNiMtfRCzk8K1/WP7Lwwgp/lmZ8xu3RY1m9krEvHIcP3dZZp3SADfuNSfs3V5
         uBsh3plEZRdCJkLQPreLcuG35CkCpl/Kp+9IPclihDJiUms0l1zHtd++8ShPplrQB8yh
         HIlgqJ5o+0a0wdQPkRSd6Q0Hjd2ZBfjcdNVZlhZhFnUzbIKhiKwgXDZHX13dJk6leCfA
         pF3wWWTMWq5Y1yZubbdy4IE0nrh/hy/6lN6FCwTN5BvHcj0zSAxO3Rynza22Xd+DP+a3
         XFDEF/LmA+Jdc31GDTqDsXp/fQjDz0e3MWBSEViRD0NOtiMS7EZBMNpkaV8duyUksxF0
         TlAQ==
X-Gm-Message-State: AA+aEWbr1lznSUBwJzb3Rm+PbQA7GQimTSoxT8IlXakIoyZbziQjtda1
        1NqhXRpD/Baj4KCSRchLyBcD371T
X-Google-Smtp-Source: AFSGD/UMtlVH7RDjEi4niC6BnMIIKpG2u0q4pHswQ7vKRTWFJ3Gu/kxsg9DWBdbjtwWuf+IiYgqO3w==
X-Received: by 2002:a05:660c:74b:: with SMTP id a11mr6885696itl.27.1545235153930;
        Wed, 19 Dec 2018 07:59:13 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id j8sm3320894itb.30.2018.12.19.07.59.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:59:13 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFxCmH025792;
        Wed, 19 Dec 2018 15:59:12 GMT
Subject: [PATCH v5 12/30] NFS: Make "port=" mount option optional for RDMA
 mounts
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:59:12 -0500
Message-ID: <20181219155912.11602.87201.stgit@manet.1015granger.net>
In-Reply-To: <20181219155152.11602.18605.stgit@manet.1015granger.net>
References: <20181219155152.11602.18605.stgit@manet.1015granger.net>
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
 

