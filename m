Return-Path: <SRS0=nj1J=RK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D392DC10F03
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:28:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A323520851
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:28:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JN8t3riG"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726344AbfCGP2q (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 10:28:46 -0500
Received: from mail-io1-f68.google.com ([209.85.166.68]:44889 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726294AbfCGP2p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2019 10:28:45 -0500
Received: by mail-io1-f68.google.com with SMTP id u12so201767iop.11;
        Thu, 07 Mar 2019 07:28:45 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=FbTFeZnMS1eDOaZUmhKgi0QsjZTtKp9+5TuH/5Ggj34=;
        b=JN8t3riGrCR7vYF7WMukqmvKhc7RqCMF1MxYzxO0vI8yF785JSOQ77+mw7dmuo1l+w
         V36+XAVn7a3yY/2stRo/S9aKE7XshBgMyWC4OCcv2+bca8DAhH7cP00pD3Olp7c7ex8P
         oSlJgl7x1byufZA6cwFNXccvtNAhKYtkZNwq2mmrajMlXDerRU+HBS/IYCWsQWsgDfXJ
         xvwO6vLWILq6ptAZB2eS37AOb7i525R6KYbCGtvwgHYKo8TTeOVW+3W0sKDEkz9wqsUB
         bDDO3NwyUiQixAP9N1eVx+hF7N1pNwr+a+03W+xhf5iclAAybuCx2zVGReyCCCnKhV5e
         qHlA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=FbTFeZnMS1eDOaZUmhKgi0QsjZTtKp9+5TuH/5Ggj34=;
        b=YAgB+N7IKYctUZ4jKTJe5PkFSGZZI/t7vy4Rzq0mHtwO8ZoaWOkluMWtro6iX8c7GJ
         htBYNKpxM+3Y7YucUyWx0mo+hWSvdOiVc3A6ZuW1KLSSLB3kjGCbJYd4c4TZdUE1+py4
         Ua1L4KCVBrq8yrnSjslvVedRNVtNnl8iuSz8VrkIOXG+YOWya9GhcFyT0xMcqV1YFgWh
         ZZ1n64rJOhHyfs0lzN03FdIKxxWIucmcv+mUZwfrJwktESHBxruZexYdctoDEK186AaR
         8U/Is4H9IZ+Kocmqgj1ikTU2IzNJqwmAsRfMqod5WRZ2VFh+vRX/tzT/i8/d9RQTfVBt
         AKnw==
X-Gm-Message-State: APjAAAUwlec8drFugSVJ1rpJrzpotW9uUYN3hxWyVMYhdwY2VeTa3U9s
        TSticv+CQGdZ9ayYolw2Sces9GYC
X-Google-Smtp-Source: APXvYqwYvPvB9Y25dti22r+X3XGMlFbzLPQdj4KfaKZmHbjbysZ3+CQGdYp7Cc7NbxNtFyavltDEHQ==
X-Received: by 2002:a5e:d803:: with SMTP id l3mr5644272iok.144.1551972525007;
        Thu, 07 Mar 2019 07:28:45 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id o9sm2589549itb.23.2019.03.07.07.28.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 07:28:44 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x27FShmH007218;
        Thu, 7 Mar 2019 15:28:43 GMT
Subject: [PATCH v2 1/5] NFS: Define common IMA-related protocol elements
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org
Date:   Thu, 07 Mar 2019 10:28:43 -0500
Message-ID: <20190307152843.11306.73138.stgit@manet.1015granger.net>
In-Reply-To: <20190307151838.11306.94183.stgit@manet.1015granger.net>
References: <20190307151838.11306.94183.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Common protocol definitions used by the server and client
implementations. A separate patch also makes it easier to identify
the code that needs to change when the flag name and value is
eventually standardized.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/nfs4.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 1b06f0b..ca3adb1 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -41,6 +41,7 @@ struct nfs4_acl {
 };
 
 #define NFS4_MAXLABELLEN	2048
+#define NFS4_MAXIMALEN		(4096)
 
 struct nfs4_label {
 	uint32_t	lfs;
@@ -451,6 +452,7 @@ enum change_attr_type4 {
 #define FATTR4_WORD2_CHANGE_ATTR_TYPE	(1UL << 15)
 #define FATTR4_WORD2_SECURITY_LABEL     (1UL << 16)
 #define FATTR4_WORD2_MODE_UMASK		(1UL << 17)
+#define FATTR4_WORD2_LINUX_IMA		(1UL << 18)
 
 /* MDS threshold bitmap bits */
 #define THRESHOLD_RD                    (1UL << 0)

