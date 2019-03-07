Return-Path: <SRS0=nj1J=RK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 546B5C10F03
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:29:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1AC9D20851
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:29:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="B/F/BJLe"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726425AbfCGP3C (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 10:29:02 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:34950 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726415AbfCGP3C (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2019 10:29:02 -0500
Received: by mail-it1-f196.google.com with SMTP id 188so16405959itb.0;
        Thu, 07 Mar 2019 07:29:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=8t1KtvR5X3xppJF+pEb0PNGrqOzif7WWJGKp08yq2uo=;
        b=B/F/BJLeY/dm/Y4+c2pjOIK3CM5U0PIoQQTPW25otqGEzAQHP9t8KygwBrlO6VZXDe
         fO7IwvRug/+Qng1CR7WRYRXW1DYoN3TVi3kRHOoQopn38kCBf4LeRZFnxx0eg0XBeGvO
         bBEfVHrW4iDElO0hU8svGMLEg7BjIu2Y93G/eNWjtZaDnKIueO6JUFzEQqOLfoN6fHnn
         QY3sGkjJuG/rLYP/GmmcX2PBk+IB75RO29P9p3JqrAq37Qt9+/4roK6xokV26V6ZyDKF
         cwC8ErhUZV4Uhtv45HLy8HvER/6BY9iwGal0qbJhmfz5VaFL7JUu+jklN18k3oNn3n9W
         atMQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=8t1KtvR5X3xppJF+pEb0PNGrqOzif7WWJGKp08yq2uo=;
        b=qml4cKIIYoEVdcTpV7OThRtmbOKn8j7cntizPcD+L8t506uVPzveoFfYQMbMVBOU47
         pt6G6cCVYjRmeh6wPeu0M7UFYUlSPPE55jlet6ZxIh1LeXcw3dOdU8nOR8VSMLxeUave
         EWLA7fx8+xzw+jVc2RLL89JPfZaHQgHVplgNi5egCNQFHeP9Q6i6DtaiqNlFw7dc87fn
         xa4+EPF/sHf/fPAKDf1OmGwYZeVTPom/WdX1sVX3G8c69YpNJUC1gtr0wZWh9L//+haZ
         OcSbPo+Q71Et0WKZ/402Io4u6BoJ1pibulCMI4lxB5whgN0oPHsfUgzO5okzGhQpl8Me
         0Gbg==
X-Gm-Message-State: APjAAAUDGBXaiZu2ABiedA/Z8tFUtOfo+lsnQ8o89Zqr9L8+W9LjI60M
        NZzliTUSVwhHTjrXJRyHVrKk1WvN
X-Google-Smtp-Source: APXvYqxrTVFXU3BxthdA2pfaqYN6sivPARIl8qw3iO4EfbHY9G8rozuKMcv9BV6v1YOcv/38axBOyQ==
X-Received: by 2002:a24:360d:: with SMTP id l13mr5309948itl.83.1551972540716;
        Thu, 07 Mar 2019 07:29:00 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id c13sm1977059iod.69.2019.03.07.07.29.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 07:29:00 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x27FSxcU007227;
        Thu, 7 Mar 2019 15:28:59 GMT
Subject: [PATCH v2 4/5] NFS: Rename security xattr handler
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org
Date:   Thu, 07 Mar 2019 10:28:59 -0500
Message-ID: <20190307152859.11306.63507.stgit@manet.1015granger.net>
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

