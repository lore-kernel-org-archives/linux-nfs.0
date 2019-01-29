Return-Path: <SRS0=GD9Z=QF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D055EC169C4
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jan 2019 20:54:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 98F1A20869
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jan 2019 20:54:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SiE74dzV"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727071AbfA2Uyo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 29 Jan 2019 15:54:44 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:36651 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726982AbfA2Uyn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jan 2019 15:54:43 -0500
Received: by mail-it1-f194.google.com with SMTP id c9so6861877itj.1
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jan 2019 12:54:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=DsozCxdNnBZa+LfFa+VpRiDJgBsxqmksHn7KwVO181o=;
        b=SiE74dzVWOHKlkTQvFTzfkIyb0dXgg04fP1qDMrANuximmGTlsI8C1ktnenFNJiYxu
         VUmaHhjmfVk+ba7NwZGzv5vszUxDEIhNrTYIFzO99KgjegZvQPmvKX4Mghv2rhmzbuQn
         Kym2Xg/v7yA1dCDZX5VVOxFFDRB5KjkFZ2ebvPTbjM8Wvv2cTDIk9M9U/CkO8vnnWLog
         kboIIlOP40fmPhGbOQtODWfMACZnWvzKwcELfzjMStf//NFn3bl2ktQHCR5kWA+XpsHK
         dIiLTJBJAN1UEpoT9938RH5aFFDlzcMOFcyeV/xyDLlbuAjBaGv7gOj6hVSKnX49qX6Y
         Iafg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=DsozCxdNnBZa+LfFa+VpRiDJgBsxqmksHn7KwVO181o=;
        b=VaBuBMTap1nFBSCC+uE+87yJVDFDX3oyZaglqYNqD8DHtn3lzxsEBIjzI5KZRliHYl
         WyrKLIzNVIUYBPOvU2lsblWGdUud/HiXN12FsXuyIANII1MwYxSDpryIMdcH7s4uyBcR
         n3LTbnl+0NN0dQ6pt4Q6FsAN2bChVZ0YIv5jbUlzRblp7p2epYe1PP4nWFJD6vlC9wLf
         P1PKDKrhvfNavRfdR+5yGVIf3K3UhQ/H7+NxESeYAxH1icBFYvIIUEV5aLjqwnbwhs9I
         3/Mg1iv2M+etNGZoWgWkc21arqbf3zOsCo26JikWb/5zYVyF1YYMc4SJlLj4SCTVI4Uo
         XUfA==
X-Gm-Message-State: AJcUukdtG3ySueRlV620RT37wSFp5jpIF4y+G6BbFynkUAVNiT9+eMe6
        aFgxwREppqalQsXXaxJfsw==
X-Google-Smtp-Source: ALg8bN4HRCPurjttnTmgXBI29OQa64S1ItlcnxJ2YcvRPVyCJIQ4FS7h2zEZUi9dYnZmzy4K1xmq8A==
X-Received: by 2002:a02:b529:: with SMTP id l38mr15818321jaj.25.1548795282551;
        Tue, 29 Jan 2019 12:54:42 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id k1sm15050154iom.40.2019.01.29.12.54.41
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 12:54:41 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <anna.schumaker@netapp.com>,
        Benjamin Coddington <bcodding@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFS: Fix up return value on fatal errors in nfs_page_async_flush()
Date:   Tue, 29 Jan 2019 15:52:55 -0500
Message-Id: <20190129205255.12467-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Ensure that we return the fatal error value that caused us to exit
nfs_page_async_flush().

Fixes: c373fff7bd25 ("NFSv4: Don't special case "launder"")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: stable@vger.kernel.org # v4.12+
Reviewed-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/write.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5a0bbf917a32..f12cb31a41e5 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -621,11 +621,12 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 	nfs_set_page_writeback(page);
 	WARN_ON_ONCE(test_bit(PG_CLEAN, &req->wb_flags));
 
-	ret = 0;
+	ret = req->wb_context->error;
 	/* If there is a fatal error that covers this write, just exit */
-	if (nfs_error_is_fatal_on_server(req->wb_context->error))
+	if (nfs_error_is_fatal_on_server(ret))
 		goto out_launder;
 
+	ret = 0;
 	if (!nfs_pageio_add_request(pgio, req)) {
 		ret = pgio->pg_error;
 		/*
@@ -635,9 +636,9 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 			nfs_context_set_write_error(req->wb_context, ret);
 			if (nfs_error_is_fatal_on_server(ret))
 				goto out_launder;
-		}
+		} else
+			ret = -EAGAIN;
 		nfs_redirty_request(req);
-		ret = -EAGAIN;
 	} else
 		nfs_add_stats(page_file_mapping(page)->host,
 				NFSIOS_WRITEPAGES, 1);
-- 
2.20.1

