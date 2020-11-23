Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 877DBC2D0E4
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Nov 2020 20:08:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 31A9420715
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Nov 2020 20:08:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Rq8cYY4N"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728477AbgKWUIJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 23 Nov 2020 15:08:09 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42122 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728458AbgKWUIJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2020 15:08:09 -0500
Received: from mail-qk1-x742.google.com (mail-qk1-x742.google.com [IPv6:2607:f8b0:4864:20::742])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1691BC0613CF
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2020 12:08:09 -0800 (PST)
Received: by mail-qk1-x742.google.com with SMTP id h11so6664147qkl.4
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2020 12:08:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=aUWMFAxlrbl8tjXS0MpVEBHiARiBpd4h9u2zvX6IfSQ=;
        b=Rq8cYY4NZszBvQ4vCNVgCUr+Lu77KFtEW+ay76NeDITsuMzKl+BmWOUFsGYh7Ti2ng
         Y+Azgeaom/BHeEG4IzlNu0idSJvzGqeCjNQ2YNvTYczQ7JVOwOv0+v7FoPpOA+CCdDYb
         JB+Bm+b4VJ9QeiQXXmlVUiubTUxdxKGnoYIQlLMMrXctavH78X9j/Cw57jUb6KZp3xzZ
         wwn0gn+9GbAiiex3BqgAPFZk7bLPicSfIOJ7I/ty0reYiATe+mCFQJ8zXz4JGKbU+WKr
         k9KmyVUSfOzRAmU168FA834yqSSdyBSEDlwgw8/8lo62ud6WfLIfLnDjNO+FxNAu5MnQ
         +Ifw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=aUWMFAxlrbl8tjXS0MpVEBHiARiBpd4h9u2zvX6IfSQ=;
        b=gHrwLe9S+NNUtD9UwCF+lgJrhipyIP3hw7HJlRVJREU5aTik7el65wBSOkXbHYSz5r
         tqgKMH3Mpjuck4FWV1SCnZqkzpOVYdzbKzw50Ksm0qNzC6mIVQuRSngv1V9frHNEJS1w
         TdehXJMh6kaokC65uZ7LWcQZA+vJg5Ph4usBsZ+Tl2iJraJ/QBp0l7dNZgImKGC4dYQp
         7XUmqD2swlZbv87OLY4KCi82ueby+fqi/bqxIHJ0RhrFJxbbrq5WSy3X0B4a2oGYDpkQ
         xBZHmEb6tXzmDmV7PwdvxadOb1lxAo3aRsBf6W81e0P68fVAKQRyHGJhE9IzFHQbSSUE
         jGnw==
X-Gm-Message-State: AOAM530H61ofSjX9AKgB9/7LyKsaK/v6J1v5OXam1ma6KAN2OOADq5Cn
        yyFTO7cOayY8kP77l4bk0XalHeLm0AA=
X-Google-Smtp-Source: ABdhPJwobseNL8Pr84rr3J34uF6UFQn6VwvON6jrqysx/Kkas3dC8cZMiQZMMjMJhZzKUGnwqLgLPA==
X-Received: by 2002:a37:6892:: with SMTP id d140mr1198540qkc.200.1606162088060;
        Mon, 23 Nov 2020 12:08:08 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id k128sm8645640qkd.48.2020.11.23.12.08.07
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2020 12:08:07 -0800 (PST)
Sender: Chuck Lever <chucklever@gmail.com>
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id 0ANK86bR010417
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2020 20:08:06 GMT
Subject: [PATCH v3 47/85] NFSD: Replace READ* macros in nfsd4_decode_setattr()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 23 Nov 2020 15:08:06 -0500
Message-ID: <160616208635.51996.5358162552258329645.stgit@klimt.1015granger.net>
In-Reply-To: <160616177104.51996.14915419165992024951.stgit@klimt.1015granger.net>
References: <160616177104.51996.14915419165992024951.stgit@klimt.1015granger.net>
User-Agent: StGit/0.23-29-ga622f1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4xdr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 21b3b4e5a525..5a1d92290e6f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1298,7 +1298,7 @@ nfsd4_decode_setattr(struct nfsd4_compoundargs *argp, struct nfsd4_setattr *seta
 {
 	__be32 status;
 
-	status = nfsd4_decode_stateid(argp, &setattr->sa_stateid);
+	status = nfsd4_decode_stateid4(argp, &setattr->sa_stateid);
 	if (status)
 		return status;
 	return nfsd4_decode_fattr4(argp, setattr->sa_bmval,


