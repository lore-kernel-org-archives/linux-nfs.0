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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8734DC6786F
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 474A020820
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WgjdqWRZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 474A020820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726700AbeKBBtZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 21:49:25 -0400
Received: from mail-ot1-f68.google.com ([209.85.210.68]:39716 "EHLO
        mail-ot1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726580AbeKBBtY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 21:49:24 -0400
Received: by mail-ot1-f68.google.com with SMTP id g27so5448469oth.6;
        Thu, 01 Nov 2018 09:45:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=7UYm6KwHepkUcFRejYDPg8EOERI1MmALOURzx0oOqU8=;
        b=WgjdqWRZSBCk+y5XNGR0Oxbe9YV13LTKQ1xpaqzswAD4/Y3/ffLJHwVDUjjngUKOGy
         e1Rdno1U9cCxOqgcTjMQ4qOS68CblAF0t4zqMk+a3n801BKXGq5iI94o5EeyLJ0co3JZ
         nPC44N5V0hDoDrs5K1Io1F+oBCPfmvqiTrEdOfCHwHr40qKcFGPDeLts5y3UDTGc8DiV
         WLF5K9itYHe/LcdhtjYRUSuSG8Hoda9e41Die3jrcbXvfvCzJ3SZS9Il7DLhs4HuqK6n
         HGIs5/IKrzbw1zqRRu3SJpvu8o0MkRqalTztr5V8ReQTrFiv1N95Yq3iGCuqiQgO8IGI
         +ixA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=7UYm6KwHepkUcFRejYDPg8EOERI1MmALOURzx0oOqU8=;
        b=RD/zMhdITBznT48KXJrEhHW0zJuM0b2StVzJxUuvd6x15NMN2Z0uM3A3vpI37ZNhzf
         tiEjWDv1kWqbZpyZURTHgsgfNxdSQRUP7v6MOa7uK/5X9ZQKt5MxzXH7AFHDqSZtsgbb
         aKcd610HjY8/CRCoftuwZQJ4zs96DIJfDYWaY8O2G0sLwE2E555QwKTdXyFb2Bx6V368
         YgLBdWx/b2kzKHe+AVxYYOLY5dE1nQBuoWlkWY3oJwyRiE4mfJRrUWz7NYjtPLB5QA3r
         2btw2u5T5uXd9lS4u61Da6nviiA2MR2TrGhIRZRPFtV6lyCQjDjZUAr7GUxlAeLFqto0
         9UcA==
X-Gm-Message-State: AGRZ1gKKn1BhQnOPfebVy7B3OOHtVddQXwV4C3+pF9bFvpCoNUFFzfWM
        1j1xc8oTyexB9qvVq6n09Nc=
X-Google-Smtp-Source: AJdET5eI5m7Br4MHgBECKZMotd5GHotg+IJd2r7J3teZ1Qshkz8UYwxDnva7SXXf+QcpHEK1F4u2Vw==
X-Received: by 2002:a9d:17e9:: with SMTP id j96mr5323937otj.34.1541090739670;
        Thu, 01 Nov 2018 09:45:39 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id r62-v6sm1834301oig.14.2018.11.01.09.45.38
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Nov 2018 09:45:39 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org
Subject: [PATCH v8 09/11] NFS: for "inter" copy treat ESTALE as ENOTSUPP
Date:   Thu,  1 Nov 2018 12:45:21 -0400
Message-Id: <20181101164523.41812-10-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
References: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

If the client sends an "inter" copy to the destination server but
it only supports "intra" copy, it can return ESTALE (since it
doesn't know anything about the file handle from the other server
and does not recognize the special case of "inter" copy). Translate
this error as ENOTSUPP and also send OFFLOAD_CANCEL to the source
server so that it can clean up state.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 98fe00b..00809b3 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -395,6 +395,11 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 			args.sync = true;
 			dst_exception.retry = 1;
 			continue;
+		} else if (err == -ESTALE &&
+				!nfs42_files_from_same_server(src, dst)) {
+			nfs42_do_offload_cancel_async(src, &args.src_stateid);
+			err = -EOPNOTSUPP;
+			break;
 		}
 
 		err2 = nfs4_handle_exception(server, err, &src_exception);
-- 
1.8.3.1

