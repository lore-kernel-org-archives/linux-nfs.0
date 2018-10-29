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
	by smtp.lore.kernel.org (Postfix) with ESMTP id C48B9C0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 90D7B2082B
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LE05cVLr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90D7B2082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728128AbeJ3Ca6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:30:58 -0400
Received: from mail-qt1-f195.google.com ([209.85.160.195]:33940 "EHLO
        mail-qt1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726330AbeJ3Ca5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:30:57 -0400
Received: by mail-qt1-f195.google.com with SMTP id z2-v6so10273678qts.1;
        Mon, 29 Oct 2018 10:41:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=fwlJnXfUGTRII/SW0YspOWGhfPFdbZ3Rgyeu7Z/VErM=;
        b=LE05cVLrmi50hLTsHjbNyTGf5u3HgS7+jLOBQ0FG7NsP7CsOpeJLmjpuNgpJ3tajhL
         Gr2e06fmz/CYv4iTo3ocC90qv/WFQ097Euqp6HGVHrQnh5Xs6zyHgcu30u7vGQNylk/x
         mteE+Tff2EiRhaMdbemN4tx94y8poqSayp2cPDs3M9EoZBEuR1ghTCbWuvcTKW3Cp0LI
         JoJagwVx2aZfH3X2BGDMVZiR5GsMJ5eAXQFowYEU6CWhfuslMkvqm2aZWBCmlRBh1Gmk
         hYTS+t9P4M4+E99GYNXasQJiWAZXvb8JDUt4CZAfA0m050xT+vWLeVVTcuQC9OKL03vL
         O60w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=fwlJnXfUGTRII/SW0YspOWGhfPFdbZ3Rgyeu7Z/VErM=;
        b=U90SvcHRtvBA5ANofhJ/lMB++G0bfC+FWvRCNpzj0unIH/rdZ6u6mLP2DOHq38xA9n
         6s21o2CX4zI/vibNuF/rsb/l/Pb6G40KL2+FEVMJ3xUFFM3EZ4VEhkGwjow3VJkP74/K
         LfjBSRtkCKb5Uh/59Z4a+hR1VXHgpmHVaJBB5hgAiVS0/q2qla7b3RkMywvzt2FBYPVw
         ZqQlw+pqifEP7OcF+THnG6P3X2iOLZgRoD8VXiq5tqiAsNWtwPH2/Yj7w+cqNqzM6uDK
         GRqkfnD/QyL3JyBw2orFPVGJySjrkJ9zd/jOJmIoXmJoqqpHQwN1bzVirLPhCzUXVGco
         Giiw==
X-Gm-Message-State: AGRZ1gJqYUGjRZF6V2xrPNaUy7oBZvTf1tGCWp1G8XmzH9DT6an7MqO/
        gYiA48rI4zZJTWuLv+HOEhM=
X-Google-Smtp-Source: AJdET5cIOObKO6k+MFIZu6KNCsmcVIlFwF8eQ4ym0TyVJVErZJrdT/LZlzeDk4sG0zq2fRRTyckohw==
X-Received: by 2002:ac8:6119:: with SMTP id a25-v6mr13521964qtm.130.1540834880282;
        Mon, 29 Oct 2018 10:41:20 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id n190-v6sm13148929qkb.29.2018.10.29.10.41.18
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 10:41:19 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v5 11/12] NFS: COPY handle ERR_OFFLOAD_DENIED
Date:   Mon, 29 Oct 2018 13:40:58 -0400
Message-Id: <20181029174059.38326-13-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
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

