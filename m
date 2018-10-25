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
	by smtp.lore.kernel.org (Postfix) with ESMTP id A602BC46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:51:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6A2FA2082E
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:51:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aERug/GC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A2FA2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727578AbeJZG0T (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 02:26:19 -0400
Received: from mail-qt1-f193.google.com ([209.85.160.193]:41928 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727574AbeJZG0T (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 02:26:19 -0400
Received: by mail-qt1-f193.google.com with SMTP id l41-v6so11782966qtl.8;
        Thu, 25 Oct 2018 14:51:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=wQTh7a3iW+fR8lVGhprFKaZ8IC1UlQ+XS8yHtG409Gc=;
        b=aERug/GCLLTYP2ZvVGXcTdJbMJfTXldMEd/SnYhA4sfToXGf1hCQRZ5VjEz2bK6hlG
         00v6RPSBIkFwDYA3g9rOfoPnT8hJce0FPFqRLUxki/+XvZXThKcvmSptZC51YVp+SXax
         64hj4iX7808vwIrWDvvGlf72XsfBwlfyl8V/3hFlULDM6jbHasOifjzf8gkzFsZYqfk9
         444deJBdtSJWY71R8OFg5rIaYcWCMpNB/Cdtq7+d2m7U9+25tykOy5mXkYiQ3iGlO/8S
         MyRgvobiEmuGfgtSSOZuBj90phec0tz3AvxQPUbgFy6o6kZpnv2nqk7R5lp3MJ8it14a
         AF2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=wQTh7a3iW+fR8lVGhprFKaZ8IC1UlQ+XS8yHtG409Gc=;
        b=hR4buHGN4rHKTqwOo1oIBOUc2eM/Qj06yP7UY+8SfmIRMB6ea3amXAwS78oveh1VUu
         EZmxTBqQf5MKm+reoa8IMGLKwB/6ZtpCUmp6l0XHRvDXbh4qxt/RUg5EeO/uxmscJfad
         PTgG2fpQ81o014a/DYZmDEn3bLv4D/enfKlfmWJ4rRETgKXFdbbutMrBV7rqJUrz/zfo
         mZIa4chwLvxY5sZ/80FiV9D4tVNFyeY6BUO1IdKKkgksRizN8iIzyCFjz3Key1RJv2mb
         mq/f3hSrDdkSJ3XYfKeV8BFfdzbg+D7Qna2cO5ekYGIm/7EWfQ8S/NieoOPwOgZ5TKSp
         igRg==
X-Gm-Message-State: AGRZ1gJBLCW1LGAC1m+sI/FOdZ1LA8t5NXVsQgOv4+Va7FspY5tC+HBY
        QVgp1pcwKT5T5nSMKcYaEio=
X-Google-Smtp-Source: AJdET5fDrUZdtkMoZds7E75sX9Z3VSf5DU4QRGklHvrOKvYfXFBuCuJn+rrrO+ADuJMKz3aLmimGTg==
X-Received: by 2002:a0c:c927:: with SMTP id r36mr961884qvj.51.1540504314259;
        Thu, 25 Oct 2018 14:51:54 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm5895927qkc.96.2018.10.25.14.51.53
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Oct 2018 14:51:53 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v3 02/11] VFS copy_file_range check validity of input source offset
Date:   Thu, 25 Oct 2018 17:51:38 -0400
Message-Id: <20181025215147.36248-4-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
References: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Input source offset can't be beyond the end of the file.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/read_write.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/read_write.c b/fs/read_write.c
index fb4ffca..72b2c74 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1594,6 +1594,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 		}
 	}
 
+	if (pos_in > i_size_read(inode_in))
+		return -EINVAL;
+
 	if (file_out->f_op->copy_file_range) {
 		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
 						      pos_out, len, flags);
-- 
1.8.3.1

