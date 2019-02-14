Return-Path: <SRS0=jvUk=QV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 897A8C4360F
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 20:43:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 590272192D
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 20:43:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TAkk7rvm"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2437716AbfBNUnS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Feb 2019 15:43:18 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:51260 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2391319AbfBNUnS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2019 15:43:18 -0500
Received: by mail-it1-f196.google.com with SMTP id y184so18624119itc.1;
        Thu, 14 Feb 2019 12:43:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=8t1KtvR5X3xppJF+pEb0PNGrqOzif7WWJGKp08yq2uo=;
        b=TAkk7rvmswkGeNqpsaMe9DL/C9Mk4pgCZbsFI2uo2+puN6pKKOoHvIeaGJ2h5MK6o5
         FMf75L9HmSdk5jo1gegAUvHjLSsBz96Eyz/kVuBYLaWf8h1ru7M4iLEABwBAlt7PxlAI
         L5WxzNsgLyFtrVjhA5c4SOpVKKWRChCh6uUWtO3GIiFy8piwnIn75q2NWA1WTHRbELnX
         qPR2xRbxguM6PktV8nCV0eUZ3RASW/kA6spELdySQhunZaWTDqE1CN8Zyy33GxN9LE2Z
         CFN7Dtpy6pdwu/C32EkMy6x7M4d2GcC7HhbiGOYH38k6CpNHj5yqdYDgFgNjaFGyVNOl
         Go4g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=8t1KtvR5X3xppJF+pEb0PNGrqOzif7WWJGKp08yq2uo=;
        b=Fm5/GlLRl+L6LEdR5+Ca+WM3Nv+ZBW+IPb95jgMtDSgGuyMpeRl4s5pC0q0/noLJG0
         fYQg6/1p8dNVMb0OBvLxNNDzh9wWeFtNJGRapttidg/8SFrw2qeMlK9SnNrfSKEDlOBM
         AGoZX8DrwZJvGpsyJLo+W+nzEoNoNkgyue29q1ucY7Dho3rcvNLU60+WjvXW9IAp39x8
         vaTV/pJ86xKgMHFemYBH8jjYnOlAz3do2tImWMYSJd783FJTE+BvWrANyCvG2j2Jh5CT
         uLAdzdQoMeulXKhIudAP0HUGksSbfOfRUVz9+czl9fAz1j7+R3inbsyjTKhtmGNJYDfD
         ao0w==
X-Gm-Message-State: AHQUAuYeJTsJK/IsAnVzsnTxOVQSZ6UOWCLpl3GAnkkoP/+uYtyjqpg+
        8tuzqBdPDvp94Ng9BlZfjjRU8OfV
X-Google-Smtp-Source: AHgI3IZHrMnc5NWHJ+QDNpiJpPQas3xAwSW1PAqDA9CpKpEdzO+Ic5QSj51xjf3eEfobfBhOMtvfbw==
X-Received: by 2002:a05:660c:54d:: with SMTP id w13mr3006856itk.50.1550176997407;
        Thu, 14 Feb 2019 12:43:17 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id z8sm1253343iom.88.2019.02.14.12.43.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 12:43:16 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1EKhGp0006558;
        Thu, 14 Feb 2019 20:43:16 GMT
Subject: [PATCH RFC 2/4] NFS: Rename security xattr handler
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org
Date:   Thu, 14 Feb 2019 15:43:16 -0500
Message-ID: <20190214204316.6469.41405.stgit@manet.1015granger.net>
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

Refactor: In a moment, the handler will no longer deal with only
NFSv4 security labels. Give it a more generic name.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 557a5d6..df0ee42 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7128,20 +7128,19 @@ static bool nfs4_xattr_list_nfs4_acl(struct dentry *dentry)
 
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
 
-static int nfs4_xattr_set_nfs4_label(const struct xattr_handler *handler,
-				     struct dentry *unused, struct inode *inode,
-				     const char *key, const void *buf,
-				     size_t buflen, int flags)
+static int nfs4_xattr_set_security(const struct xattr_handler *handler,
+				   struct dentry *unused, struct inode *inode,
+				   const char *key, const void *buf,
+				   size_t buflen, int flags)
 {
 	if (security_ismaclabel(key))
 		return nfs4_set_security_label(inode, buf, buflen);
-
 	return -EOPNOTSUPP;
 }
 
-static int nfs4_xattr_get_nfs4_label(const struct xattr_handler *handler,
-				     struct dentry *unused, struct inode *inode,
-				     const char *key, void *buf, size_t buflen)
+static int nfs4_xattr_get_security(const struct xattr_handler *handler,
+				   struct dentry *unused, struct inode *inode,
+				   const char *key, void *buf, size_t buflen)
 {
 	if (security_ismaclabel(key))
 		return nfs4_get_security_label(inode, buf, buflen);
@@ -7161,10 +7160,10 @@ static int nfs4_xattr_get_nfs4_label(const struct xattr_handler *handler,
 	return len;
 }
 
-static const struct xattr_handler nfs4_xattr_nfs4_label_handler = {
+static const struct xattr_handler nfs4_xattr_security_handler = {
 	.prefix = XATTR_SECURITY_PREFIX,
-	.get	= nfs4_xattr_get_nfs4_label,
-	.set	= nfs4_xattr_set_nfs4_label,
+	.get	= nfs4_xattr_get_security,
+	.set	= nfs4_xattr_set_security,
 };
 
 #else
@@ -9824,7 +9823,7 @@ static ssize_t nfs4_listxattr(struct dentry *dentry, char *list, size_t size)
 const struct xattr_handler *nfs4_xattr_handlers[] = {
 	&nfs4_xattr_nfs4_acl_handler,
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
-	&nfs4_xattr_nfs4_label_handler,
+	&nfs4_xattr_security_handler,
 #endif
 	NULL
 };

