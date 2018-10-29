Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 252A8C2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E3B9E2082D
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bGkqSd4j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3B9E2082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729505AbeJ3DyV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 23:54:21 -0400
Received: from mail-qt1-f193.google.com ([209.85.160.193]:41912 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725969AbeJ3DyV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 23:54:21 -0400
Received: by mail-qt1-f193.google.com with SMTP id l41-v6so10573971qtl.8;
        Mon, 29 Oct 2018 12:04:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=fwlJnXfUGTRII/SW0YspOWGhfPFdbZ3Rgyeu7Z/VErM=;
        b=bGkqSd4jvN+T3Jg18VKGI4GP4V4VmwVuy/tUtGdRkeI5wzZl0lv3nnhPg2DvxcYBia
         nOXnmo4doGUALHp/Q5rLtrJ/jr32c0tN24HubNgsdTB17dLz6yvaOeohxa6Nm3YY87Wy
         jEXiDIoKsjKgH0eJNW8r1RGpSX4e22+dvdf4C26BAhQz/DXbqGmFrffsXmPJKoMdv773
         9N6ohzVd9A/N66zQrUY27aexNUdtRWO70d3xIltcQjKCsWe6qr3ZFMMZWEl/s1aBDg8S
         O6Yj3WWBpCiPROcxfWJeQbe5ZTGfXyg7Z9aWQIc9O422Oyge7eTPUKvIndBgCMLi9+tr
         qegA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=fwlJnXfUGTRII/SW0YspOWGhfPFdbZ3Rgyeu7Z/VErM=;
        b=j4YbMx7LxkWmjROYux0+0kjhgQd8F9Lb4YqgqhtF5fcsBx5dT5gi7dzs8yPHtqlMhT
         +8mOiRhbQAqlzhG+QrHmsw6tPumR1dQuCSrvY7tk5lK41Ag5M11WvThw6YpssKpovK+F
         ftEwNrHEGJpRwoopepTmeTx4+12qhHwhpDfK943R1tkdkdWbTAhtS3gug0sLIhsVBkjR
         zpqoQJzq8VfwGaCl5Qsq/tfJOY1hZc69A3vzhkOa6QirSGkKnUKGpOsJeOpTE7P93WF9
         gHnbRRO85wBEAkoBSr6iqNOluBQuRVSLLQUNj6krqPqFI0h3sCWyPUi1ch44HkUrr/ak
         6H8g==
X-Gm-Message-State: AGRZ1gIy1Io299swxgDOfeIXhdzHIShYpla337D6wGU77tjtdvDBfPjV
        1u5lP14eGzOVIz4tvZcPY/Wg/Baw
X-Google-Smtp-Source: AJdET5elM1dsFDyqq09yYrEcyJFqaGRQj94/ULj3D8zXo8LBcpY0GTopLwca/argRL/NSLE/CiXIBg==
X-Received: by 2002:a0c:eb07:: with SMTP id j7mr9516163qvp.128.1540839862007;
        Mon, 29 Oct 2018 12:04:22 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id c5-v6sm2714373qtj.55.2018.10.29.12.04.20
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 12:04:21 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v6 11/12] NFS: COPY handle ERR_OFFLOAD_DENIED
Date:   Mon, 29 Oct 2018 15:03:56 -0400
Message-Id: <20181029190357.38439-13-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
References: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

If server sends ERR_OFFLOAD_DENIED error, the client must fall
back on doing copy the normal way. Return ENOTSUPP to the vfs and
fallback to regular copy.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 00809b3..c7c2ffa 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -395,7 +395,8 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 			args.sync = true;
 			dst_exception.retry = 1;
 			continue;
-		} else if (err == -ESTALE &&
+		} else if ((err == -ESTALE ||
+				err == -NFS4ERR_OFFLOAD_DENIED) &&
 				!nfs42_files_from_same_server(src, dst)) {
 			nfs42_do_offload_cancel_async(src, &args.src_stateid);
 			err = -EOPNOTSUPP;
-- 
1.8.3.1

