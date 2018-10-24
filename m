Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89725ECDE44
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:59:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4B6C020832
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:59:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dFOerZNw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B6C020832
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727535AbeJYE21 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 00:28:27 -0400
Received: from mail-qk1-f195.google.com ([209.85.222.195]:33191 "EHLO
        mail-qk1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727502AbeJYE20 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 00:28:26 -0400
Received: by mail-qk1-f195.google.com with SMTP id o89so4245104qko.0;
        Wed, 24 Oct 2018 12:59:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=fwlJnXfUGTRII/SW0YspOWGhfPFdbZ3Rgyeu7Z/VErM=;
        b=dFOerZNwKxzWjYWepyVme3Fh9Q3k55q5/TxJq/G9IV0dpPWWmMo45lS6MkgkyggYyh
         ol63X1kCOUowfnx2WPGuu8VIvkKZfZeQOGl9LgXvTIyLerV3h3cAufKFMQrmz+zwb6QV
         s3ArQBrzmPK30QRYN/XdABVj0XQxn0Uk6mGWCJUj1O+7Dz4D36TTKf4Xi4lGTJJHHkLe
         GbGlvev0QSyYut7kR1o9/c4MzEobfLEev1T5YV8ty6C81+UMSPGqRytwl4ORlRDpX7Sn
         9W9sM8LfmrfQCqiTWXXGZChl1oUs4pOX2wi5TwOmrT/BnkaUvNbK5fCnQinTJnnbOOkr
         x1qA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=fwlJnXfUGTRII/SW0YspOWGhfPFdbZ3Rgyeu7Z/VErM=;
        b=rM9cczdSD7oo6JR4uUFyYK7Cy2OwQtFQT6O8YETL+gHhZZfMKE7y2R2cSuJlhF14Y8
         vpibYnejg+h9WsEyWpo7f1b3YOnVkdxYzspjbKclaQYfGBC4BHkrP2gGNY2lJcJLK208
         rQ9kgqnJUzlzhr+9RAaiunGkFdUg0bhLomVHoVzAK9/TIl+YuKauTHOuKLsfAS2ag5eu
         2A1jvgD8uJ2GJHf/Xt1zcPEv2B04xHV3430C5qnY6ZqkJLPtC2Lw+uXlbtUjgXV/WIlX
         mrUWKFNLLhn6wVRp7Fli8/1w4mVWyImye3hoAe7qtH4r652a4hRQAA60deUTn6Xev/5C
         fdWg==
X-Gm-Message-State: AGRZ1gK41R5djaFN1CbzqfC78MMrj//YKRm+Org/sZVWsgOyqYLpiKth
        A6mOouIFzCSg9RH/+HjgTNcim1lZ
X-Google-Smtp-Source: AJdET5f3q2pM5N014v9sq0oZkZuTaJ+CoqOz3wvAeKsFUHXj4ne0G6PTwZbyoqi8jNHw/gy46folyQ==
X-Received: by 2002:a37:ae06:: with SMTP id x6-v6mr3756794qke.238.1540411139695;
        Wed, 24 Oct 2018 12:58:59 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id d124-v6sm3872380qkf.85.2018.10.24.12.58.58
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Oct 2018 12:58:59 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v2 13/13] NFS COPY handle ERR_OFFLOAD_DENIED
Date:   Wed, 24 Oct 2018 15:58:37 -0400
Message-Id: <20181024195837.35532-15-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
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

