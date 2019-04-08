Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 695F4C10F14
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 20:00:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 35B8620880
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 20:00:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UB2/h5v+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726523AbfDHUAe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 16:00:34 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:42429 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726220AbfDHUAe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Apr 2019 16:00:34 -0400
Received: by mail-io1-f67.google.com with SMTP id c4so12154577ioh.9
        for <linux-nfs@vger.kernel.org>; Mon, 08 Apr 2019 13:00:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=SLPiNUK9YXOo6JDOo5+fg1lpErdlRYRmJskzrwKo4Vs=;
        b=UB2/h5v+h5hCQEC9/6khlgk3VHzyEgV8JXJ2cz3Oh5PJWM2W2mlkMFQ8tYTL5h4eXT
         0A4g8IilmwdiakigVA5cygoJz+WpIkXV2DsFK8wJ/n/hqtZc3T/E2QxUFlREnYrmRhPw
         13UCcgV34aihpoiWz3SI3PoTaeWPdpI5az4o6b9SZS4rfNfKvifFn5b6+M+Da3KcDYpi
         +y+nv4+YcNnRu9WsStiGHkXiQSghbrQOq43i/RFADchNMLk34fzdnqVaiYYVrrafBszm
         bRQY0lHVyCyL+dyGfhvqml/sf1xtPIgwJsNtBxHjr1B8tvqhh3a+zkYoxN+Desru7coi
         ekSA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=SLPiNUK9YXOo6JDOo5+fg1lpErdlRYRmJskzrwKo4Vs=;
        b=ZUzM95/a2W326iJpCEIo6o56pUdahWhmtnTqc1zFM+uW47UO1TlFbSCM6O2H9wSWhp
         quOX1AYN59kbqku7zGJ2Ql+p316UoaznvKv1I5bsLkszULSTW5gptDnu3utDXXLlsuiC
         AZ1ev0nPE7I2hsD2nkUAd44BA5dRqbUGRZtRSx7KcXPTCYY+qsLmt9sTLycs5LRug9V/
         uGdNxyCdo9fZ4s9xr2qhEccq7Xt5B74nBNGh+Aes5a6xNdyNURQabWP9Dbo4Ks+CFQb9
         8+6xXP6vpH3XwjafBDDn10DehBfeJFJQVPkdPur38y/E9TQ+0rcJ4Z4xHmdOi7iZ0fy+
         7CZg==
X-Gm-Message-State: APjAAAW5rMFIYyV7FClloGmQ/k7ZaD2NH8cKY9PHnhv9d+7UsrTW7HpZ
        QZXxXoeJlL/OJ591Lra2wRogJ8vo
X-Google-Smtp-Source: APXvYqwgesG2wJmdZDdJlKhmatMjHhNeanS61Ll093aNVg6zTNNB+cAKgv8B8UMIVRsJEHxuq0BysA==
X-Received: by 2002:a5e:d618:: with SMTP id w24mr22196107iom.164.1554753633007;
        Mon, 08 Apr 2019 13:00:33 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id e27sm13268210ioc.14.2019.04.08.13.00.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 13:00:32 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x38K0UMc031202;
        Mon, 8 Apr 2019 20:00:30 GMT
Subject: [PATCH v1] NFS: Fix handling of reply page vector
From:   Chuck Lever <chuck.lever@oracle.com>
To:     kolga@netapp.com
Cc:     linux-nfs@vger.kernel.org
Date:   Mon, 08 Apr 2019 16:00:30 -0400
Message-ID: <20190408200030.16366.22026.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

NFSv4 GETACL and FS_LOCATIONS requests stopped working in v5.1-rc.

These two need the extra padding to be added directly to the reply
length.

Reported-by: Olga Kornievskaia <aglo@umich.edu>
Fixes: 02ef04e432ba ("NFS: Account for XDR pad of buf->pages")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4xdr.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index cfcabc3..6024461 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2589,7 +2589,7 @@ static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
 			ARRAY_SIZE(nfs4_acl_bitmap), &hdr);
 
 	rpc_prepare_reply_pages(req, args->acl_pages, 0,
-				args->acl_len, replen);
+				args->acl_len, replen + 1);
 	encode_nops(&hdr);
 }
 
@@ -2811,7 +2811,7 @@ static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
 	}
 
 	rpc_prepare_reply_pages(req, (struct page **)&args->page, 0,
-				PAGE_SIZE, replen);
+				PAGE_SIZE, replen + 1);
 	encode_nops(&hdr);
 }
 

