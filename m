Return-Path: <SRS0=j1eS=ND=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31873C46475
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 15:35:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D3C152075D
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 15:35:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3C152075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727359AbeJWX6z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 19:58:55 -0400
Received: from mail-io1-f68.google.com ([209.85.166.68]:46580 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726277AbeJWX6z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2018 19:58:55 -0400
Received: by mail-io1-f68.google.com with SMTP id y22-v6so1128228ioj.13
        for <linux-nfs@vger.kernel.org>; Tue, 23 Oct 2018 08:35:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:to:from:subject:message-id:date:user-agent
         :mime-version:content-language:content-transfer-encoding;
        bh=3/02nhonb/oks7I8v50KFdHCwoBtpIpLUFuodLP+v0I=;
        b=Qwi8RSSW7FBmRkgpBtfwcd7Xy1FGzKSCma8/UbPFHgTqJUpTBEWaCKA/rUd9L9bbGU
         nrmMeFpS0IxaGFQBPjcEdcFsJCdXTwIqeVpMBHnkEOPDQ57dNvEd/VTxbGb+lzUT6FY0
         maEcTJm/MuubNe2O2hZky3DwUuDrVn0KhjjtLRYzu2dOdEP74KEbirfpdN4tKBn/wjXn
         q6pnqu0x99JuN9u5tK4JmEAq/G7e93IMxnqAHzRNZnlwZ1QoXIjcg0OYK31ILZTrT7Tg
         r42CuYOcIIAOIB906I06E1qc57aNpYJ8pDtW5oNABQny5tROjlmsK+sQs1JN4mXRfcKz
         64UQ==
X-Gm-Message-State: AGRZ1gLH3Qy9qsVssJFo1vcun0mgIlLMdnFpwnMG7Hx74HwOEp2C13Oq
        NPZpZWtsQ+7H+c1hGhur453nCg==
X-Google-Smtp-Source: AJdET5e3ZcAowHoAu95n9Q4aGM8uM7dKjcdmQ2O4KhJcPh7e8fYvWOSCHUZf1eqv2UL7nADCQv9Eqw==
X-Received: by 2002:a6b:c389:: with SMTP id t131-v6mr12094120iof.157.1540308901313;
        Tue, 23 Oct 2018 08:35:01 -0700 (PDT)
Received: from hut.sorensonfamily.com (198-0-247-150-static.hfc.comcastbusiness.net. [198.0.247.150])
        by smtp.gmail.com with ESMTPSA id s10-v6sm863727itb.38.2018.10.23.08.34.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 08:34:58 -0700 (PDT)
To:     linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
From:   Frank Sorenson <sorenson@redhat.com>
Subject: [PATCH] NFS: change sign of nfs_fh length
Message-ID: <85517ec3-e3d4-1bf3-8eea-cb274face1a7@redhat.com>
Date:   Tue, 23 Oct 2018 10:34:57 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


The filehandle has a length which is defined as a 32-bit
"unsigned integer".  Change sign of the length appropriately.

Signed-off-by: Frank Sorenson <sorenson@redhat.com>
---
 fs/nfs/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b7bde12d8cd5..2fc8f6fa25e4 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3516,7 +3516,7 @@ static int decode_attr_exclcreat_supported(struct
xdr_stream *xdr,
 static int decode_attr_filehandle(struct xdr_stream *xdr, uint32_t
*bitmap, struct nfs_fh *fh)
 {
 	__be32 *p;
-	int len;
+	u32 len;

 	if (fh != NULL)
 		memset(fh, 0, sizeof(*fh));
-- 
2.13.6

