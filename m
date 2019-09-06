Return-Path: <SRS0=moVq=XB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21B61C00307
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Sep 2019 19:46:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E81292070C
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Sep 2019 19:46:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AJ+6oI8A"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727053AbfIFTqn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 6 Sep 2019 15:46:43 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:32927 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2392364AbfIFTqn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Sep 2019 15:46:43 -0400
Received: by mail-io1-f67.google.com with SMTP id m11so15469746ioo.0
        for <linux-nfs@vger.kernel.org>; Fri, 06 Sep 2019 12:46:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=OMSnhxhLm9jAGT4vNx3iX0q57Vtf9G2yxU8MZWSWriQ=;
        b=AJ+6oI8AxoCVtperw48ywjEiKV7Nr8FpahrRokJJT+UrQ9atAkAEeq8CoKeZSmAphM
         tZ55WgDTLaFNV1M7g5W70ENU21s+vVZ3oPaFUsXYbbDPz4ueuD5qH/A5WRB4p80nyO0v
         QSWPzczdjLvob2kEyesoofJgbUwxEgP5Ro98Jw4jidT0PpD82A+8mFYNiKZycZsz2sxZ
         U5DOPaeD01amlEumSUiuooHdloVWW9W8pr1QQ2+k9O7TfPATmniRurvw4ilEhuVJ01mT
         Ob7kMNB5RW/xduk3VrgZo55YhKr5JLJtpU/hoTNTufF+M3rTZq2id8dwqUq0E8RZ9oks
         tR+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=OMSnhxhLm9jAGT4vNx3iX0q57Vtf9G2yxU8MZWSWriQ=;
        b=lqk2cPwszmMb20DdqEKoQiZnRXGrOCBCUy45PMEUye0cJgHtXJv82rKM/NRwUAuZkF
         9H+CmXT73YqXYXzzNMG76QLwAb+VRkR7XuSp3y0o4/sBOzTlNOPFs2K+1zIWhIW4wH+Z
         R50Fv4X1l6G8OXAjhCF3r+QFeshAmqTwUBHgxjJ9KEiXNqpT/iR/r/7MDgDyB7OaRZBG
         vJo2GgNHQ51m6K3x2nusl7/BzwLT489peb4ZW5JDT251Iz0Pf44yw4qJAcxI2UAwXzED
         5RYzKYc2c+OgrIO+rZjc0GwEJAFFh1AJZPZYsnWuSMEZj3PSNKbmdiitE0Nd7NszmeLT
         DHbg==
X-Gm-Message-State: APjAAAUSs9zp+Nf2+kgfIyAewXhirsWdBeJuaU3QVBBPNafaaOrZ9Dva
        D19jALJLctB2Cko7soLJ5B7hgsOUITY=
X-Google-Smtp-Source: APXvYqx/z1hSw4+ZKCKigYmnRRHx9D1VNUfLUzGH34a+8LX9ShMwcEEEg12lNkp1L2lc4UMlVYfh9A==
X-Received: by 2002:a5e:a80a:: with SMTP id c10mr1814936ioa.122.1567799202252;
        Fri, 06 Sep 2019 12:46:42 -0700 (PDT)
Received: from Olgas-MBP-201.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id i14sm5118085ioi.47.2019.09.06.12.46.41
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Sep 2019 12:46:41 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v6 08/19] NFS: COPY handle ERR_OFFLOAD_DENIED
Date:   Fri,  6 Sep 2019 15:46:20 -0400
Message-Id: <20190906194631.3216-9-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20190906194631.3216-1-olga.kornievskaia@gmail.com>
References: <20190906194631.3216-1-olga.kornievskaia@gmail.com>
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
index f8ebd77..705fe69 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -393,7 +393,8 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
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

