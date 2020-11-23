Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8952C2D0E4
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Nov 2020 20:07:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4FB0320717
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Nov 2020 20:07:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WLjwlzlb"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728198AbgKWUHs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 23 Nov 2020 15:07:48 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42056 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728018AbgKWUHs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2020 15:07:48 -0500
Received: from mail-qt1-x841.google.com (mail-qt1-x841.google.com [IPv6:2607:f8b0:4864:20::841])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4D93BC0613CF
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2020 12:07:48 -0800 (PST)
Received: by mail-qt1-x841.google.com with SMTP id 7so14381064qtp.1
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2020 12:07:48 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=2ytE20CH0KubMBhhh6jnCi52bsotB+3AGzaIYGMI3TU=;
        b=WLjwlzlb0nFQ28UB26B53BMJsXa2zm4kjQ+gEQCvgmlKXi5tYuT96X6pD7Dpg8s/GF
         s93mCh+ZmUcfzCMRcNuWXqLRCHVSVd6c4e9gyayAv7WA6Dy1OwDPik9GtI1ml5H0cw6+
         HBOQxiC9B6KnUkFpUHYZ/I8Sx4WTrjo/1gGaH28wk6m7ztnmk4eLHKrz3mSrKibnlYt7
         AHraT7fXwpFl4by81p4OcBbs1JwM8Cl7mAC2yfEOwwNx3PzG29fNGQq1aOeaPFlgJHPW
         kGJAjsyhyb7TKYEnu7ieSb7um685kv5leHzEi3d/naMgoIJl1t/BLZDqb9LnSUzxRLeN
         AAtg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=2ytE20CH0KubMBhhh6jnCi52bsotB+3AGzaIYGMI3TU=;
        b=DdTWM9OS3QzIWsVB8BbAM88RXJO3qerQe/ozrDVRbHH8vdf5w94vmjrsPomby5N57g
         nVI/O5oGp5/dmXsTmbKbVT+4nWsTmXN3Z8LMOWY0GCO1XhqLBz4MVG4P0+YE3o367Gmw
         3Eo7/8Zo4JrfresCnF2pV8PZLZ6avevzOMOl4cu+VPLGFLKpj7ckA/K75R1hkzwX257D
         8hFFV4ncKe4fY885RsUDcN//IIhkYKBxtkZMXy+mCvo36SghZ5/82NulHl4vYqErrzsb
         V57TvvtQZtxgTpD+IhF43iop3zslBS8w6fjmmi4fwynYKIi+NXvxwcbnssHuH3TSneZ8
         bsAA==
X-Gm-Message-State: AOAM531uYl4a8afrBfMv4u7GYamRwmybJ4WJOL4vckhbSwqLybznL+8b
        xqAO1nUlk75/LpNx8fhSHDPmDOs19ko=
X-Google-Smtp-Source: ABdhPJzQVF5k4A/CCqVrta19+bhDJ89avu3ujZ8lyrJa+CpwuCSIzXNQFwAzUk7qs1tnmyC7KZTFXg==
X-Received: by 2002:ac8:4612:: with SMTP id p18mr869648qtn.31.1606162067275;
        Mon, 23 Nov 2020 12:07:47 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id n21sm10739326qke.21.2020.11.23.12.07.46
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2020 12:07:46 -0800 (PST)
Sender: Chuck Lever <chucklever@gmail.com>
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id 0ANK7jh0010397
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2020 20:07:45 GMT
Subject: [PATCH v3 43/85] NFSD: Replace READ* macros in nfsd4_decode_remove()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 23 Nov 2020 15:07:45 -0500
Message-ID: <160616206564.51996.379395383887167228.stgit@klimt.1015granger.net>
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
 fs/nfsd/nfs4xdr.c |   11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6f10692452cf..cdec94ae81fc 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1255,16 +1255,7 @@ nfsd4_decode_readdir(struct nfsd4_compoundargs *argp, struct nfsd4_readdir *read
 static __be32
 nfsd4_decode_remove(struct nfsd4_compoundargs *argp, struct nfsd4_remove *remove)
 {
-	DECODE_HEAD;
-
-	READ_BUF(4);
-	remove->rm_namelen = be32_to_cpup(p++);
-	READ_BUF(remove->rm_namelen);
-	SAVEMEM(remove->rm_name, remove->rm_namelen);
-	if ((status = check_filename(remove->rm_name, remove->rm_namelen)))
-		return status;
-
-	DECODE_TAIL;
+	return nfsd4_decode_component4(argp, &remove->rm_name, &remove->rm_namelen);
 }
 
 static __be32


