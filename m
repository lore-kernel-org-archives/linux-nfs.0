Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9798BC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:07:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 59F6F205C9
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:07:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YICu1lQs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59F6F205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727230AbeK0HC3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:02:29 -0500
Received: from mail-it1-f181.google.com ([209.85.166.181]:54857 "EHLO
        mail-it1-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727227AbeK0HC3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:02:29 -0500
Received: by mail-it1-f181.google.com with SMTP id m123-v6so6161606ita.4;
        Mon, 26 Nov 2018 12:07:14 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Tke2KOJ89T4vcbDVIGt35hCRU2JIcQsMOR9LJ34omWk=;
        b=YICu1lQsDkVYRiGtL5MDiaRtiZpGE8wMlvkOXWvADgHSIaw9r+sogeoXqweROImDT7
         HGr7rP8QDtaiJVMe4K4dK2loRzkmem3KgU1tPKlhxJHqj17EzjryH65rRwKcBFJxzoNo
         hSS0kidkZ+bl4LLHNXClO0wPvgCZGPu1EqtDpRnCAPdY3XWolst0Mmm2byBrKcZgqLVa
         lN9eJKG8cicfrJstYEGWtmoRi6lDSx/3zfhXelLjkpXaAHLHV9ZE+2UX9/vWCh/idaMh
         jlNSs1zHtPMve3VACgZRWLFMhbjxzHH9LbZE7j4UKH4yjAx4+o7x46N8ue2GJUZz4y3E
         MblQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Tke2KOJ89T4vcbDVIGt35hCRU2JIcQsMOR9LJ34omWk=;
        b=IME1indCFh2tCGA7xp2i1NOlzseWB1pCFpw1j90+LtfeeOtvVuR345KBkIcu2BXP8i
         4m5Dw0tfDmePW1dXsaEM3DyZD+5eCaqUWXF/NpB4QlWHdhUjCX19iPJif6VM2SJIC2j3
         xtx4AxUdcSFVrwSXniWWMiDib0GWHyUvvVBeHlE6WZ5leo8HMPnbUd/STEeO2N7aq5LI
         EWo9D1/I7obWlAa7YjyWECLKoVxRLAaxUB+66IDhnzK/qBODwFdN+dew4YBrR+l3VXpb
         1bKektMYk0JJWScYJLj6n/TVAXEzaRy969yAAUhHxKURMgQ6QBt45NckDLBonpsqT7bb
         XpfQ==
X-Gm-Message-State: AA+aEWadjuPn9qONLhrdscavtOfGzem/jdcQBz8KPywT2lOyjFWzXTa0
        /15nBnv2q3pPQuJxJXguwc0D9SY/
X-Google-Smtp-Source: AFSGD/XPPwoiMYN9t0cVIIceA/niPC6QP1EF5nmDlAnp8pmdyxaaHzlXEg40onWO8eMYDMljRomk4g==
X-Received: by 2002:a24:7284:: with SMTP id x126mr8716737itc.96.1543262834150;
        Mon, 26 Nov 2018 12:07:14 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id l2sm450301iop.26.2018.11.26.12.07.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:07:13 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK7ChN010690;
        Mon, 26 Nov 2018 20:07:12 GMT
Subject: [PATCH v2 16/20] NFS: Make "port=" mount option optional for RDMA
 mounts
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:07:12 -0500
Message-ID: <20181126200712.10321.13977.stgit@manet.1015granger.net>
In-Reply-To: <20181126194611.10321.71714.stgit@manet.1015granger.net>
References: <20181126194611.10321.71714.stgit@manet.1015granger.net>
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
 

