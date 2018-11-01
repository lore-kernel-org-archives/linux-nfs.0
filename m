Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3C79C0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7DC03205F4
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="syGNnlih"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DC03205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726750AbeKBBt0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 21:49:26 -0400
Received: from mail-oi1-f196.google.com ([209.85.167.196]:46389 "EHLO
        mail-oi1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726712AbeKBBtZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 21:49:25 -0400
Received: by mail-oi1-f196.google.com with SMTP id k64-v6so17122310oia.13;
        Thu, 01 Nov 2018 09:45:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=fwlJnXfUGTRII/SW0YspOWGhfPFdbZ3Rgyeu7Z/VErM=;
        b=syGNnlihDkFdEtO/6CTLrG9vXXYlNGx2N4uhly/4Ghj/EHrih9UXpFOqLQLWcqjp4D
         dbdfQzqfC/1j2nAwtek4muoyBVGJ7uNt5cQiHYY/d/5CSVxMqgISR7pgE3PIl9red4j3
         IWCMVwpecTHZMymAfvJoDCab3P8xSSczuUcX5vxkoLuFZj9fVQCa36PZr3Wvd3LAFaDL
         KtkFOxDIoJ55K5BezOGh2wUWwpgJezROWkXQDvcbARFMh2wy8lLCLXgdMvorkWjv0sST
         OD/yts9RZxeSNBav/aJBrc8USdABG1PVmoCOPeNpSAiK4gbH0RhKUok22ZQXmeVBRDr8
         hznw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=fwlJnXfUGTRII/SW0YspOWGhfPFdbZ3Rgyeu7Z/VErM=;
        b=FZu1b5hT0n9NzOwmlUhtOSaecY9kFtoCOFkbx4gz7CfTKS9CUc4ZUZuRsEyYn7Rr2R
         /aEGP6W9s+9JsfHXtEU3oYFoJFrW9ed1Nv++f1yJOAL4zMbfBQ88ZsspSkfAVbsnvVGm
         Y13Pbu7cYxr0m1Z63gqwf2yGz8oHk8ugzYXG0Afdp0uv/FpAM8TVl3XYT4XPhKxnnzAr
         6rCMRqrvRBWz+DxOmEq+noWvVQsPWR1c8CEaztZcJgOHKd6I8VGSjABaA4rx4BW0Zm+V
         g6f6e3D83U2HWVGPpe598VgqvroasJh+EAVxHv0N686iBGeSf9hbZtzma++0qP0swCQG
         qCTQ==
X-Gm-Message-State: AGRZ1gKN/cPbQamwhOEFTPZj6AOhwjVDAoVvACHnKyWzSh0HYHcZ7r1t
        V/Llnk8ClzIFfMRxCxyJywI=
X-Google-Smtp-Source: AJdET5fT7X56DvGCN8sqGPN5x6DPIu0vcuwt9W1iQSSq4/4UYd+sfH6adVV8Hx4AdQVWA35Y1fqzAA==
X-Received: by 2002:aca:f084:: with SMTP id o126-v6mr4919459oih.21.1541090740939;
        Thu, 01 Nov 2018 09:45:40 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id r62-v6sm1834301oig.14.2018.11.01.09.45.39
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Nov 2018 09:45:40 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org
Subject: [PATCH v8 10/11] NFS: COPY handle ERR_OFFLOAD_DENIED
Date:   Thu,  1 Nov 2018 12:45:22 -0400
Message-Id: <20181101164523.41812-11-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
References: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
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

