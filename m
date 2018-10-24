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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EBA1ECDE46
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:59:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 22A9520832
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:59:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GmgxpqlT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22A9520832
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727531AbeJYE2Z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 00:28:25 -0400
Received: from mail-qt1-f195.google.com ([209.85.160.195]:41734 "EHLO
        mail-qt1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727502AbeJYE2Z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 00:28:25 -0400
Received: by mail-qt1-f195.google.com with SMTP id l41-v6so7089227qtl.8;
        Wed, 24 Oct 2018 12:58:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=K7MFHrnWE4fWFYme7dBc6bdrP0/8P/CPMn5um30ZDY4=;
        b=GmgxpqlTCSH4sxnhjDmk1b3zz7z6tY7NM4ZTpwBEqBX9xRywdGfWsgiWTJFBzSQUq+
         1Gkxmc9MR8Bigwn1+6gjuqChU54aqehj114aEkSSLt88NYRKX5dsEGMrxTp7/zBd/JiX
         B9Zb/EmjQo3pg1aRR028rpVpFNlAkJP7PrDCqjfCnZUcnNELtgLE3m6rWOCOuZrYFUpK
         zPwha3L7HO9J9OnevBCuHByj2EZLWYXsKlDS8IIiwQpbKcpglzUNIw7i+FpQiuNqHpca
         sqNSZKyJjnf4FvG2034Plv+NLZIYhmbDmp1qPd0JmN0LFmYxaXYMq0T91JjRhHpKyQJh
         VOWg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=K7MFHrnWE4fWFYme7dBc6bdrP0/8P/CPMn5um30ZDY4=;
        b=rkz3s3k9gFaBBaP6K7Ni7SR4rQAvYBiMozfuPGiA1BLUEKLuh+9/BN0Dnmz7EfNX55
         3oao+e967ZDBVWMVD7fqdTQeGLjtfhrBmrs+758RnSLxEcodIVllXv77qttkUXKY6qjv
         sTb959Vv+N00inYndYW1bwfMPilGupMTCZui+KbQWo72/Y3uxxGWTod5WzVPTvOXIxxl
         n/H8vjvGo66GDEoYThmbrnZZsQNLYbDGRQsiUN4gcjQWBBF9WRowT/OBnnm45FAOJUM9
         jAFc5c5VQAcgqwjvf8n8XrLCsaB5T1Z4H4s6gGQFQDX3oiSB+Ia5r1aPG81M+IoUDEsx
         UbGg==
X-Gm-Message-State: AGRZ1gKzHk5pmgjX+caHRsld4gMQiT7YgaAyNbsljo3ub8VXQXIFr2mE
        IuoJarRHzwTr5qXZ3d9c3ak=
X-Google-Smtp-Source: AJdET5epiUQnbmNbY7amS4LFXFehvCJgpEOl75o8b04n8rMWdi3/d9IqFeDtf7eUeZE51OJqiOLQQw==
X-Received: by 2002:ac8:38bd:: with SMTP id f58-v6mr3675217qtc.337.1540411138393;
        Wed, 24 Oct 2018 12:58:58 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id d124-v6sm3872380qkf.85.2018.10.24.12.58.57
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Oct 2018 12:58:57 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v2 12/13] NFS for "inter" copy treat ESTALE as ENOTSUPP
Date:   Wed, 24 Oct 2018 15:58:36 -0400
Message-Id: <20181024195837.35532-14-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

If the client sends an "inter" copy to the destination server but
it only supports "intra" copy, it can return ESTALE (since it
doesn't know anything about the file handle from the other server
and does not recognize the special case of "inter" copy). Translate
this error as ENOTSUPP and also send OFFLOAD_CANCEL to teh source
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

