Return-Path: <SRS0=WqcA=WP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43C71C3A5A0
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Aug 2019 22:41:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 131D42070B
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Aug 2019 22:41:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VuIGbQ0h"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728538AbfHSWlU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Aug 2019 18:41:20 -0400
Received: from mail-oi1-f195.google.com ([209.85.167.195]:44668 "EHLO
        mail-oi1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728402AbfHSWlU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Aug 2019 18:41:20 -0400
Received: by mail-oi1-f195.google.com with SMTP id k22so2602463oiw.11;
        Mon, 19 Aug 2019 15:41:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=XwonKW5E3QU6ws/Gywd0FV6ntfQVppu+1SLDZCu7wNk=;
        b=VuIGbQ0hRsOODEPtA3aFhe+GcTKcRyJsXycC9v3WDyf9JKrqYeneZ04DPqthoNjOnn
         r/xA1XbPLidUfTg2TM9Iw6HkEcLsKCRjd2f+lv2iyJ29ewMHLGJ1Aash58fKM3eY3ScZ
         r2LLxLMk2twedq5ctJsRnkDNsr1TmWhvrUZosecvmguKNZb9ObHArE/cQAycmfVvj1dp
         uf6oThfM0CxuQEFNjSeUZ1H5B/nfiX+XvoMnIIOnID8Y43zEk3V6BlmHD4xUz+PlpXV+
         tY+trSZCYD10YupqRhyxx+tjkO5HfIATNW8jpC2ZUTCXoBxqo2Hkh8Otv/WiWwEhFXI3
         EY/w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=XwonKW5E3QU6ws/Gywd0FV6ntfQVppu+1SLDZCu7wNk=;
        b=ZSZQ4eNZCRJDbY+OLKSV7pV+ci5OR11xZi0jR1UwzKpomt5KhxHLLnpZ4P5bVH/FGK
         TKFSaRbCiqDhvjdlwccMkJHSzaSNJydMXeeJo+7+G5UBYn1TZiUXCoAeBry9gF3I1TFF
         FCdm5eksWrZhoSlw12GTNZPDE1KbDRt04Udnv6dGmDoGbbVv2ul4B8qblroaL3TfTekD
         pdzHS7JAohZgdLTBWoipsKYW0iS2WfBBoB4cO6XYDdtyFpuIhqltMPk+QShdkX+mpwsQ
         s6utPMbkx57krgzl127BREZqhnMSwch9bT7bu3EG1reLRXERzFAxl14OLq37qeeEdTVj
         fqyw==
X-Gm-Message-State: APjAAAUh6qeI8SXqdFzPqp52TBunDmQyMori0LTqHg76MqGbmR4DNzzx
        YDxH41LGwZG25AvfB+2PZxcrl4TR
X-Google-Smtp-Source: APXvYqzCFUSW6iqGsIYX+XwSmETDf9wMbH1eND1jHODm5YypBG49i13QLCbEdYIiwFeSLDawwQd5/w==
X-Received: by 2002:a54:4f09:: with SMTP id e9mr15430015oiy.89.1566254479449;
        Mon, 19 Aug 2019 15:41:19 -0700 (PDT)
Received: from seurat29.1015granger.net ([12.235.16.3])
        by smtp.gmail.com with ESMTPSA id q85sm4924518oic.52.2019.08.19.15.41.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Aug 2019 15:41:19 -0700 (PDT)
Subject: [PATCH v2 07/21] xprtrdma: Boost client's max slot table size to
 match Linux server
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date:   Mon, 19 Aug 2019 18:40:58 -0400
Message-ID: <156625443812.8161.1304836419453818534.stgit@seurat29.1015granger.net>
In-Reply-To: <156625401091.8161.14744201497689200191.stgit@seurat29.1015granger.net>
References: <156625401091.8161.14744201497689200191.stgit@seurat29.1015granger.net>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I've heard rumors of an NFS/RDMA server implementation that has a
default credit limit of 1024. The client's default setting remains
at 128.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprtrdma.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index 86fc38ff0355..16c239e0d6dd 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -49,9 +49,9 @@
  * fully-chunked NFS message (read chunks are the largest). Note only
  * a single chunk type per message is supported currently.
  */
-#define RPCRDMA_MIN_SLOT_TABLE	(2U)
+#define RPCRDMA_MIN_SLOT_TABLE	(4U)
 #define RPCRDMA_DEF_SLOT_TABLE	(128U)
-#define RPCRDMA_MAX_SLOT_TABLE	(256U)
+#define RPCRDMA_MAX_SLOT_TABLE	(16384U)
 
 #define RPCRDMA_MIN_INLINE  (1024)	/* min inline thresh */
 #define RPCRDMA_DEF_INLINE  (4096)	/* default inline thresh */

