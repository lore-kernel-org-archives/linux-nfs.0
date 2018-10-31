Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1EC5C0044C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 20:02:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9BE2720657
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 20:02:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="G5KCFUdP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BE2720657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727537AbeKAFB7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 01:01:59 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:52510 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726187AbeKAFB7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 01:01:59 -0400
Received: by mail-it1-f194.google.com with SMTP id r5-v6so18137090ith.2
        for <linux-nfs@vger.kernel.org>; Wed, 31 Oct 2018 13:02:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=yPEZ+pW29dVQbHYdHJQxAhFswwsUoe69MLHepyA0wjU=;
        b=G5KCFUdPgc4KISYYrUnXsu9hGrgP5LNnF5ieeEU7cj7l61KAH75oGFCfTCUwb12xAL
         Co75CX3SEy2NRwD9tdjmDo09YuN8YFdOypRHh/V98Q6o+Sxz6h5W8pMph+CscDMfEJGK
         Du+HF+r6uIQuC9TvqURoilEFbq/7VibTztmeDI/rU/C5y3aCOup4cfEfEn9s9x3bpoO4
         YCoRQG1ZPm4IGfijV/9GB+jxyF5xtAHDpeKSXDuZ/sv67stfoVfA7dQXZ9hiTMh5+Rjj
         j99PKkJxHCROJjkbXvgxxyUrIV0AG2zjJgJ/TUSyIw+HYr61dDDkVigH1gH31BDmdy5Y
         hvSA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=yPEZ+pW29dVQbHYdHJQxAhFswwsUoe69MLHepyA0wjU=;
        b=L9ChGXvmSkHJ9xfy+DCCeI2vlsAQEM4NJ/jW2VYdC+ivmt6iflbjs7ZfDw1A0jzQEK
         1LTuqaHwMhU0XetCzu12OKBUbiZwjwpqyxevnZvKXAXHDYlOVkdJn+xnE0KaMXVs/VH8
         HCDfQS509tqtMeWYi5ty/OfqKwj3YxeN9iieUpZfqXRz17dDE/xKPtIr23bHJEcwx2HJ
         sNDlJ1hocTTt7eulfkF8MdNKMur+eyakgvO8DcERZHXJr937IyJRzW9dYg0ycFw3Se70
         FE5tPA+XPPy5gQTcpagqNSiYLrLA7Mq4+JuMGpb5gMchv3peekPY9/gu+lhsv6JUaPJg
         HPDQ==
X-Gm-Message-State: AGRZ1gJIGASprMsacOp+Ivsq++B0IeIZ8pwpx3sAwAkazF6cc1/YukIx
        D42k27vLsghw1dv/kHK3Jf8=
X-Google-Smtp-Source: AJdET5enWPzuTV0kPHyHYDqkxVwdyhnMitmuc2NKXsQYM5iUd5/4Xio2k7agqzwiZ+gXYzKTsHFx2g==
X-Received: by 2002:a02:3ece:: with SMTP id s197-v6mr3490432jas.102.1541016145652;
        Wed, 31 Oct 2018 13:02:25 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id g73-v6sm11150636itg.37.2018.10.31.13.02.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 13:02:25 -0700 (PDT)
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id w9VK2O2S021313;
        Wed, 31 Oct 2018 20:02:24 GMT
Subject: [PATCH v1 2/3] Harden configure.ac checks for libxml2
From:   Chuck Lever <chuck.lever@oracle.com>
To:     steved@redhat.com
Cc:     linux-nfs@vger.kernel.org
Date:   Wed, 31 Oct 2018 16:02:24 -0400
Message-ID: <20181031200224.7507.51989.stgit@klimt.1015granger.net>
In-Reply-To: <20181031200218.7507.15214.stgit@klimt.1015granger.net>
References: <20181031200218.7507.15214.stgit@klimt.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Modernize the libxml2 script to use PKG_PROG_PKG_CONFIG instead of
an ad hoc macro. This automates the population of AM_CPPFLAGS with
"-I/usr/include/libxml2" when it is needed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 aclocal/libxml2.m4           |   20 +++++++++++---------
 support/junction/Makefile.am |    2 --
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/aclocal/libxml2.m4 b/aclocal/libxml2.m4
index 5c399b2..8231553 100644
--- a/aclocal/libxml2.m4
+++ b/aclocal/libxml2.m4
@@ -1,15 +1,17 @@
 dnl Checks for libxml2.so
 AC_DEFUN([AC_LIBXML2], [
 
-  if test "$enable_junction" = yes; then
+  PKG_PROG_PKG_CONFIG([0.9.0])
+  AS_IF(
+    [test "$enable_junction" = "yes"],
+    [PKG_CHECK_MODULES([XML2], [libxml-2.0 >= 2.4],
+                       [LIBXML2="${XML2_LIBS}"
+                        AM_CPPFLAGS="${AM_CPPFLAGS} ${XML2_CFLAGS}"
+                        AC_DEFINE([HAVE_LIBXML2], [1],
+                                  [Define to 1 if you have and wish to use libxml2.])],
+                       [AC_MSG_ERROR([libxml2 not found.])])])
 
-    dnl look for the library; do not add to LIBS if found
-    AC_CHECK_LIB([xml2], [xmlParseFile], [LIBXML2=-lxml2],
-                 [AC_MSG_ERROR([libxml2 not found.])])
-    AC_SUBST(LIBXML2)
-
-    dnl XXX should also check for presence of xml headers
-
-  fi
+  AC_SUBST([AM_CPPFLAGS])
+  AC_SUBST(LIBXML2)
 
 ])dnl
diff --git a/support/junction/Makefile.am b/support/junction/Makefile.am
index 97e7426..be6958b 100644
--- a/support/junction/Makefile.am
+++ b/support/junction/Makefile.am
@@ -30,5 +30,3 @@ libjunction_la_SOURCES	= display.c export-cache.c junction.c \
 			  locations.c nfs.c path.c xml.c
 
 MAINTAINERCLEANFILES	= Makefile.in
-
-AM_CPPFLAGS		= -I. -I../include -I/usr/include/libxml2

