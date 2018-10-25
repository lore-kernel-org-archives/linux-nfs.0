Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8A80ECDE46
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:52:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ACCD92082E
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:52:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tmxjIaXp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACCD92082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727678AbeJZG0b (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 02:26:31 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:46449 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727661AbeJZG0a (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 02:26:30 -0400
Received: by mail-qt1-f196.google.com with SMTP id c16-v6so11760530qtj.13;
        Thu, 25 Oct 2018 14:52:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=fwlJnXfUGTRII/SW0YspOWGhfPFdbZ3Rgyeu7Z/VErM=;
        b=tmxjIaXpFKzT42MuR+J4HEaA8coMXyYeRDHl84TMOr2N4wI8FqfFfQlmjwK8TuS87x
         D/d0dXNuXfp26WYtHrtTwHbhcGJlpUjWzzEV8vHEjl6LE5tyKuj8Se1I+Lm9PyaAeFxB
         +qRZsBp0j8xWfNEXwd/pgTxYz/RNk6dR7w+K5Dxgb4X+z1LPRTrCYEibDVbkkAJe0ALo
         ufsvPS1axuYyjUGHISfIH72VRibc23W6PRqC0weu09DduiLz7J9VX3BSX86SlvKQJOfG
         1wJ4g40ZvyDAc1FMl5xmeYkfOL7c8o4ztvMwuLxE2FB3xyL6omfTPWXChhuNiGvFxoMP
         Ytiw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=fwlJnXfUGTRII/SW0YspOWGhfPFdbZ3Rgyeu7Z/VErM=;
        b=orbPVtEVailCgYecElBngDXoX94YL057JjcPn+DE1hlwII1/my0bQyH+IzQyt/9oRm
         cVcyoOYVABruz3SYtBvzY3XbnXcLsjxtgY+whgzNQSDfsL1NVHoRfRA9QDkp2aZNKIuu
         WQ3Wl5C5G7kbu2YuwngH3AXzW4Lawo56Kagixn4KoFS+B/4mYW+OzJylCihS+CGi7sTt
         HF3vJpnDWXF/2UqhLTuzq/iFxeQBcqAVH6u7X9bcKI962WRRxYFggAAhrnKE3DM6s++N
         Gf+mDmzr4IBXcxnb4enKlkodeyrVbg5QmCKqjh009U+EDN0eagfJZM72gAy0bCoLZ1J9
         ID9g==
X-Gm-Message-State: AGRZ1gJia5GDwNv4kR50AfP+UlYycS+gO4VF6OhD2fkhGFeUYgVPgdI/
        b8DZt4PIAN5tgrZHu9Hfqf8=
X-Google-Smtp-Source: AJdET5eaqQIhrZgQrhSjY/7UYldsMnKMLUBRZbDI0qRKZRWEKzIrCnWHmiTMcOr9wx6ziKtLXCRFyQ==
X-Received: by 2002:aed:35cb:: with SMTP id d11-v6mr932170qte.212.1540504326208;
        Thu, 25 Oct 2018 14:52:06 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm5895927qkc.96.2018.10.25.14.52.04
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Oct 2018 14:52:05 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v3 10/11] NFS COPY handle ERR_OFFLOAD_DENIED
Date:   Thu, 25 Oct 2018 17:51:46 -0400
Message-Id: <20181025215147.36248-12-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
References: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
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

