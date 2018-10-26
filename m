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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F508ECDE46
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2ECA32086B
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hsdZlzJP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2ECA32086B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728066AbeJ0Etk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 00:49:40 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:46365 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728027AbeJ0Eti (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 00:49:38 -0400
Received: by mail-qt1-f196.google.com with SMTP id c16-v6so2651637qtj.13;
        Fri, 26 Oct 2018 13:11:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=fwlJnXfUGTRII/SW0YspOWGhfPFdbZ3Rgyeu7Z/VErM=;
        b=hsdZlzJP+lg2ilLI9mm6YTVgXUFIGNm/8aeMU/xI96CNZ/O6ZjEsUMjQIx5DEDDtb/
         MmSJheEuau/VvbVEW/1EkOXz+J17WjcyWSTdE9BPAMZiR1E21e7X1hG10ruUgdd7wkn/
         PT/wK300R1c1s/OWFW1fm/FyOj6XpMDJHcNsiBhbxxfPJ5CGNAUMqSNIvCyRxs5eRMNa
         Y2N6l3EkoRdOOsL599g5Buv3Xou+K7awaAoUSGTgy+jVDwobl8yglmwqRwtA/STahnOS
         D3yQgSyzHLGvLksEOwTZ3T8/nlQ/lfgc5eo97efVEp5h8tlQiFjdnNEMPag/J3vpgSUq
         IukA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=fwlJnXfUGTRII/SW0YspOWGhfPFdbZ3Rgyeu7Z/VErM=;
        b=qx4iOD57PNX8UdT5u7I+bhwqtsPtF6n/HKz/bfWsvQW7FQCtSXrBmKJm07qEnJadJm
         oPZZcLB4qwrMESGuz56g045LJyhEZfp2pt+QEknbSajNzOGURh2fpMaDYdtcqjwxjV70
         boE7hezg2LUHt+295yUV3V6YBJGid5y7TubrTLRuEfuhAAd9C9JSou4hEoDzgbNK+CcK
         3gp3J5QW1/9+TwCeO2qHPsldZiViMTGP9gCZ5oLrVWEGwsu35dl5YiQ0uWltjzA2W2qt
         gpWXcaPTnl/+dPb0k1YlHkMS0TvB97uLGPnql6QXgSBfiMPE0eMhNuSdIRpLdV6UclrA
         xDpQ==
X-Gm-Message-State: AGRZ1gKhgcFr7DKv8ZHnD5MgGdxo22SYeB2RE8mnlxcI8X1dibT2dfyR
        TckNuh6aeM/xvFqIz+8UHos=
X-Google-Smtp-Source: AJdET5eLgr/+izpbRZvmdeQCkP1nEAVSx/2x479svsaOWjsmMKXK/2L5yovSgUVxmAsbe9gPkyrzng==
X-Received: by 2002:ac8:901:: with SMTP id t1-v6mr4456032qth.335.1540584675107;
        Fri, 26 Oct 2018 13:11:15 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm8037667qkc.96.2018.10.26.13.11.13
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Oct 2018 13:11:14 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v4 10/11] NFS: COPY handle ERR_OFFLOAD_DENIED
Date:   Fri, 26 Oct 2018 16:10:56 -0400
Message-Id: <20181026201057.36899-12-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
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

