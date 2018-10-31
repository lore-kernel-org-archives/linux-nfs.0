Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D5C4C0044C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 20:02:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 37F1920657
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 20:02:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mCgU9vUY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37F1920657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727841AbeKAFBz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 01:01:55 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:51955 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726187AbeKAFBy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 01:01:54 -0400
Received: by mail-it1-f193.google.com with SMTP id h13so7278000itl.1
        for <linux-nfs@vger.kernel.org>; Wed, 31 Oct 2018 13:02:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=okoF8dCRvRydSkNyYTp54CK8N8jHhP7rmuq4MGABCto=;
        b=mCgU9vUY2GQ0/gJlc+0zJDZtiqtOg0YP/kw+HrbLv4fTUkDXerPh8/OA8EMVUGmZ2m
         9Y2fO6dbG7WFBJ33TbalnT44KxQJkYyCCy7FPb/c35g8dNDOkx9ROpn+vsUCJfZDROK9
         eDtb9mWTW6OyO8bdPB7k1CT27KJrit2n6tpR1g3MAAdI7GV4n5sMMoxhPDbLVA1myppg
         aNeYIM2+WHXHqMTwNhJY91AfSsx1u7trDnsznjCkD43vapF0F1BPKKnuMZv63MdqqXzg
         fIWIr/XYT7f3PWDIyFZXWzYcEaB5wDqDN7Jnqp3JE1IAeskqp4p8pNqCNGKRZI54j0iz
         JRPA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=okoF8dCRvRydSkNyYTp54CK8N8jHhP7rmuq4MGABCto=;
        b=N7UFcf/TO3snEdseBTKqjSk+K9atyNII6SoBuCgdGwPzv2FfgMsbZmaKyCUNOcoVWe
         +gV9H81REofHlUvJI54Ct7ckUGn3TIf755ZWma63FaNS+tcMX9xCBr07GNIS++zQ2qYP
         jApqTgnPzoiiLTselk07OPATsPpI4Ak5gcKJE1t6g58kInKXgtHIFGW2yeQxLyuYeu0/
         VOOhpsmg9bs3remX/5tiin86GqyH0TYmTxoPUDOaCmzaeRawOooGx25eNrMmjrh5dV3V
         r704r8nRwJ/9F7lxVFLlT2uhoTKMpxQ0OQxc7VCuCjm+ADEURWzLaHsf1JQEytMC4vKx
         /qhQ==
X-Gm-Message-State: AGRZ1gJMYrxp6tSARZJT/Sh6BDTj7xfo7l5WIPAeOiW3inRCJYTph5FF
        h2Bhevb2cUtmApjXNAYcnZg=
X-Google-Smtp-Source: AJdET5eFbDdPPj26/LeWmOWBef5oohZ4ruEDGRZfJZrluS754rrKomrJYqfPk/0Us+w3Zsp3xEme4g==
X-Received: by 2002:a24:76d0:: with SMTP id z199-v6mr2952373itb.82.1541016141360;
        Wed, 31 Oct 2018 13:02:21 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id c71-v6sm9479725itd.18.2018.10.31.13.02.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 13:02:20 -0700 (PDT)
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id w9VK2ICB021310;
        Wed, 31 Oct 2018 20:02:19 GMT
Subject: [PATCH v1 1/3] Fix quoting in configure.ac
From:   Chuck Lever <chuck.lever@oracle.com>
To:     steved@redhat.com
Cc:     linux-nfs@vger.kernel.org
Date:   Wed, 31 Oct 2018 16:02:18 -0400
Message-ID: <20181031200218.7507.15214.stgit@klimt.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Replace an unmatched single quote to help syntax coloring editors.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 configure.ac |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index cf1c4b9..16eae06 100644
--- a/configure.ac
+++ b/configure.ac
@@ -165,7 +165,7 @@ AC_ARG_ENABLE(uuid,
 	choose_blkid=default)
 AC_ARG_ENABLE(mount,
 	[AC_HELP_STRING([--disable-mount],
-		[Don't build mount.nfs and do use the util-linux mount(8) functionality. @<:@default=no@:>@])],
+		[Do not build mount.nfs and do use the util-linux mount(8) functionality. @<:@default=no@:>@])],
 	enable_mount=$enableval,
 	enable_mount=yes)
 	AM_CONDITIONAL(CONFIG_MOUNT, [test "$enable_mount" = "yes"])

