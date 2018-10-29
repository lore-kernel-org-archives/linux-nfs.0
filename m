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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E944C0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CB7F42082D
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="abKsq1Ar"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB7F42082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729494AbeJ3DyT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 23:54:19 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:33347 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725969AbeJ3DyT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 23:54:19 -0400
Received: by mail-qt1-f196.google.com with SMTP id i15-v6so10613777qtr.0;
        Mon, 29 Oct 2018 12:04:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=7UYm6KwHepkUcFRejYDPg8EOERI1MmALOURzx0oOqU8=;
        b=abKsq1ArtZCaHIBtn77+V+0S2MNJjLsjaZpiGdjotXMAeXcQ6ygvFxE/11zdkO//fP
         iRc7DSuftrfH48BLMD3yvxS7yrdsZpygVk3BiMShWDmqljswokasjhpMTYk9QME6Y0LH
         h8IiT10YB+AKHHzpbUhDFVX0RugTQo5F/pnHFN6010pO29FaZJ/3LjFUGe8AQrayrVnz
         lUw0Z8vQNpFTNkiJfq9xyf2TFZAi2iwhYOXXMkCaXVwhp/zDYVgnFY8SrNlZuFelXsnR
         sZD+AH+jw2K2Ec2z0qG552jJRdOSQooFHH199o5QhyGxuOYW6sLwXGKwVS1UYHpq2zhP
         awjA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=7UYm6KwHepkUcFRejYDPg8EOERI1MmALOURzx0oOqU8=;
        b=nn/9IDAWDB9QK5ZtUEbH7/wAIVP/phPt4sztGD9PM7TY5G4lzgaEb70J8tkI5ou03f
         d4iAxcOQy4F0bESx8FNIfg7NmA21yupfY0wasQDwTNedbZkutJIIWejo9AWglXjaPfuK
         V2tRKWg2lrKjjjnkI2v/sApgmJGF6H37nBqEu3I/buGKR6SK9EpnNfQc3qFMLqIoONU6
         E8QNdp79aqhH5btccJrLBLXnwjB85vga8KGSTN+akPbN4AbYGKcrQKOxwcL/r9X15cgl
         vKIUCSa8fVe06A8/VOCPAYUkB1afC/eSlM8TsNSi2tsBaYYLnqzW2nKugvWkQvRyQk58
         vqyA==
X-Gm-Message-State: AGRZ1gKucnCHSLXisU3ru7RN4fszEcGi5yZ4EUu1eljyMB+wNiSmruXk
        nOii99sqd3soQAkAjFT04fQ=
X-Google-Smtp-Source: AJdET5dXLgBITk9np6eoDTc5LoG8de/M6uDqWv+oQFl9JeVheNEtPpBwC5bVdcHp1ZaXQQqr3PBBSg==
X-Received: by 2002:aed:39a9:: with SMTP id m38-v6mr14379423qte.222.1540839860593;
        Mon, 29 Oct 2018 12:04:20 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id c5-v6sm2714373qtj.55.2018.10.29.12.04.19
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 12:04:19 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v6 10/12] NFS: for "inter" copy treat ESTALE as ENOTSUPP
Date:   Mon, 29 Oct 2018 15:03:55 -0400
Message-Id: <20181029190357.38439-12-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
References: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
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

