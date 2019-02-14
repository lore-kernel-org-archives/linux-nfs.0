Return-Path: <SRS0=jvUk=QV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCE84C4360F
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 20:43:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8B9992192B
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 20:43:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i0rn4qxw"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389444AbfBNUnN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Feb 2019 15:43:13 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:50722 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388630AbfBNUnN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2019 15:43:13 -0500
Received: by mail-it1-f194.google.com with SMTP id z7so18662114iti.0;
        Thu, 14 Feb 2019 12:43:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=vxHkntpfIAx6Jkx57Y4/1HXD+768KWbcgw5EDCyfM6U=;
        b=i0rn4qxwt2eEiOQ6OsyKsXlob/oPeRvYLVpDEqR+pPTeShJPSTZ44oPwsRh1EQV/fs
         oaGwDLskWf33wxPb0GIjZOUE9Bt5EQ/usPkmShuTjaJPB7Znk5mPZShof3A8wqSFk2zd
         eq1JRprgjk3DZBnMRck8b+34xLZI3AEvm/3fuVFDBXfWgYlxqI7pFqA/g+qCN7faOAA4
         f4Bv+ZB8AiR0mGdUhnaQvMJg+nOpHjKnk1fyCxtyS2nda3HTrya9r0iHDFjebTjcE82r
         s/KB+euaoh31bdaMWcN3SLRkMeUvSmSDM7CTMZgJRSfc5yeq/ei6GYHqXhkcgS1gEvjK
         0arQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=vxHkntpfIAx6Jkx57Y4/1HXD+768KWbcgw5EDCyfM6U=;
        b=JD3i8CoWoLJYZhqNlSdoLlL5hG/r7gqcp7Usas4Hj7BKgS5gTZUSORVqTU9LFDcgum
         gwQpCtxGROiFPLTAKQrNycLNsF1Z57wYoxSYGJguJo9w0oMfOTLY5yW7iZtW17ieaNRX
         gPJe8aRQ8gj2TXVyKEcIwx658wTdm6qeH2h6J2xcJnsOebOd9OD7Sms5faC++Qg4jBc/
         YarN15MIn48Wu6j7x+ZuyH2VPUQssL29pslZg/GdexKKLKMPPUbL3pdlpBhhIsGVgQ75
         aC9mLDAaEEQNaJiL7pPEIr07v21rm/26GXWUVjCRK7eYPSh8wbvV4CWjCmpVHGMTKalu
         RpYA==
X-Gm-Message-State: AHQUAuYuo3WDo3F4qoejBnKn/Rhen7fDRIfbzvgkhiqbCXTKZ+vx1jzQ
        EnOcdnj67Larn8PrVk+Q6IPrznYe
X-Google-Smtp-Source: AHgI3IYx3vfq1CsxblzqQpHtix6D34Z7XWNyKgW13ZblsjPj3ccEolXoqbyYS1Bj/Z2n08G0EV+JVA==
X-Received: by 2002:a6b:b214:: with SMTP id b20mr3409232iof.130.1550176992022;
        Thu, 14 Feb 2019 12:43:12 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 125sm1590540itk.28.2019.02.14.12.43.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 12:43:11 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1EKhALB006555;
        Thu, 14 Feb 2019 20:43:10 GMT
Subject: [PATCH RFC 1/4] NFS: Define common IMA-related protocol elements
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org
Date:   Thu, 14 Feb 2019 15:43:10 -0500
Message-ID: <20190214204310.6469.44847.stgit@manet.1015granger.net>
In-Reply-To: <20190214203336.6469.34750.stgit@manet.1015granger.net>
References: <20190214203336.6469.34750.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Common protocol definitions used by the server and client
implementations. A separate patch also makes it easier to see what
code needs to be change when the flag name and value is eventually
standardized.

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

