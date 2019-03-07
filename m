Return-Path: <SRS0=nj1J=RK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D91BC4360F
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:28:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ED3DA20643
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:28:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="s/2VOl+/"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726367AbfCGP24 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 10:28:56 -0500
Received: from mail-io1-f68.google.com ([209.85.166.68]:43680 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726294AbfCGP24 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2019 10:28:56 -0500
Received: by mail-io1-f68.google.com with SMTP id y6so13821567ioq.10;
        Thu, 07 Mar 2019 07:28:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=R1lFdvXc2whZCJiw+wmrDMZyaIEAR8poJhsMRqlYVV8=;
        b=s/2VOl+/449sN6HsccRRv2hXuBzWZfVu2l8b6RXLKVDz+ssRflDM8bqiC5b+j/NdyN
         JaU4mYF+f3v2LbHc/AZtxN1zA1vhmQhb7ObUxxQvfETisfaG/JWjogZzdBjzPNC/UZrN
         R9hy9UvLtBSzLsxvciBqsWwflZXaS3QPwejNC697p9oxV4ZJvFr1V6pcJzVFpQrOP/33
         WCYPsL93+frmQW9w3u2F6IYXZKfI69b0o9MybK11ELWe+PIVZs1SV0/gsv8lpBURoaec
         56QjY8Z5Q0DHt0EYRc4QMQwwZImCbf3Pn1IKd+ql7Lsf4m9R7XMXFVpw0GDxUStLZ+ts
         j4PQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=R1lFdvXc2whZCJiw+wmrDMZyaIEAR8poJhsMRqlYVV8=;
        b=L3Vmp+LWUeP0O/xOfSOW84fKLVc2MH58sLqLWOiELdm58CGnwRt9jQ8e/h/YbkFZiN
         B+mP0XMR5bzxlxnlqnSB+litIikoMw4Eh13zifNZzsuj1UbINyHeB1SQs/GYvBlEZqVW
         JhwzSECjt4Jr9xw65T8JF7d8JKbvYfe5J3JNNX/iPugIXSC07dEn9TSDQi+i4s9ckHU7
         ALEmTTKRKqQIR+6K+YxSeoAuSkY5iKQr8Z82t0cbH7ceJnyd8E2JVLeusuyvti70LsFe
         Dzyk9WYyXMDs+x87k7IQ7v6wpYGeBIIdQ+HRR2Ko2bVeZwRzuxB1QK1nzb8mPfkOis2+
         Mujg==
X-Gm-Message-State: APjAAAVNlkjHxvAlPT003OBqH5qdiJanhwWYA7mxNNgajYbzDmxOvYtn
        u1wLpsK72y0eJ2A1aM8dVgkmQZ/x
X-Google-Smtp-Source: APXvYqznBOqNRclBBXwbWcwF7xUXhDFcEIWOD2VcTZ927mq8OFH0VSrXG/d04ZgN25Osigv2KUP8Uw==
X-Received: by 2002:a6b:6218:: with SMTP id f24mr6132691iog.229.1551972535288;
        Thu, 07 Mar 2019 07:28:55 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id z11sm2132796iog.29.2019.03.07.07.28.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 07:28:54 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x27FSssY007224;
        Thu, 7 Mar 2019 15:28:54 GMT
Subject: [PATCH v2 3/5] NFSD: Remove ima_file_check call
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org
Date:   Thu, 07 Mar 2019 10:28:54 -0500
Message-ID: <20190307152854.11306.84006.stgit@manet.1015granger.net>
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

The NFS server needs to allow NFS clients to perform their own
attestation and measurement.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/vfs.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 3c00072..524c6e5 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -802,12 +802,6 @@ static int nfsd_open_break_lease(struct inode *inode, int access)
 		goto out_nfserr;
 	}
 
-	host_err = ima_file_check(file, may_flags);
-	if (host_err) {
-		fput(file);
-		goto out_nfserr;
-	}
-
 	if (may_flags & NFSD_MAY_64BIT_COOKIE)
 		file->f_mode |= FMODE_64BITHASH;
 	else

