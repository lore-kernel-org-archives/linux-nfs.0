Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F092DC0044C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 20:02:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A877420657
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 20:02:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BDLlJKTu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A877420657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726187AbeKAFCF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 01:02:05 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:50832 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729344AbeKAFCE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 01:02:04 -0400
Received: by mail-it1-f194.google.com with SMTP id k206-v6so20128305ite.0
        for <linux-nfs@vger.kernel.org>; Wed, 31 Oct 2018 13:02:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=8GcZpjudktPl/dQtOP+F1fCvlHpCGOnuydFmVoM5yyM=;
        b=BDLlJKTueUc3h9OD2RSwQROlM0wWHb+Qpi/34idTB55Qgf1u1Vw+aDqfUVdGe/jzF1
         NmKBEfWR1dt3d5OT1dw6RFyZ/yDD1hi8pEAAZV+JpSV4ST8EsAuB20qVmXUS2L3cRcu0
         d4Xq+aXfiuoEwCyM4pXBzS1KNApflYHYBjSKAqF9AbrWq6G9Dj3+nV24EK04ixyPv21V
         H6n5KbxSa8iwF6RK0JWhtIkWT61yzVZnWTaKJ3OOuvKzqqrvzIGb8sHG3OCsLDOPiSYF
         McVvkkAWhn7N0LM4CRzKZRerBoZ/kLNhjR6kgemVXXinz+P9cFa5WN2Z+0C/R4cpeFn6
         RoTQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=8GcZpjudktPl/dQtOP+F1fCvlHpCGOnuydFmVoM5yyM=;
        b=eqvJwzJJmfGLsFHVKrqK5fZjgOGo/v9N0bp1uv4LBbWGVlqgvzHebqHnXCQhQnqybk
         K1MWJlwwMmaW6/ppqopBO3PXVMaD2+fDKw3jqnBAo2AdkcbhEhvyK8gxvzzCLP9wK+DS
         uiJFQTe7ST+iPuqMIXJ4pOXHn09FzOWlPKKtssZYhyzA1AjfUYTiriXpHxcdKfvyrU22
         xYbH3zHlPX+FvuzENvrPOfRhkmjbWz9iCtnv5h+OMadDnjAHJUCLkRYH0xBmMrTDFoY+
         k8I5HH+navq49eu2wPQ09UjhYYnB4IcI5NR66D6Q6HvcWxnkErUgocByxiFb54QHEfKR
         1rtg==
X-Gm-Message-State: AGRZ1gJr8IWaq9b/6yUiZc0xB5iy4xEAHOeB6nhilSxTCqeSBam+LlhG
        P1Spsl5tgjf47rhRz00aMjC24C+G
X-Google-Smtp-Source: AJdET5eOJyy3y31psfgrt5bcXNwDzq2pfLk25GQk1lq7R8j7sVuBx+P5nDGBW/UFH+FH549NemrNEQ==
X-Received: by 2002:a24:7bd6:: with SMTP id q205-v6mr2894070itc.154.1541016150904;
        Wed, 31 Oct 2018 13:02:30 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id o134-v6sm9473616iod.17.2018.10.31.13.02.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 13:02:30 -0700 (PDT)
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id w9VK2T3V021316;
        Wed, 31 Oct 2018 20:02:29 GMT
Subject: [PATCH v1 3/3] Finish port of junction support to nfs-utils
From:   Chuck Lever <chuck.lever@oracle.com>
To:     steved@redhat.com
Cc:     linux-nfs@vger.kernel.org
Date:   Wed, 31 Oct 2018 16:02:29 -0400
Message-ID: <20181031200229.7507.26189.stgit@klimt.1015granger.net>
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

CONFIG_JUNCTION was defined for use in Makefiles, but that does not
provide a -DCONFIG_JUNCTION on the compiler command line. Add logic
to configure.ac to get the compiler flags right.

Now that mountd junction support is getting built, a few last minute
porting bugs popped out. Fix those up.

Reported-by: Yongcheng Yang <yoyang@redhat.com>
BugLink: https://bugzilla.redhat.com/show_bug.cgi?id=1543126
Fixes: 79978ed34973 ("mountd: Solder in support for NFS basic ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 configure.ac         |    8 +++++++-
 utils/mountd/cache.c |   18 +++++++++---------
 2 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/configure.ac b/configure.ac
index 16eae06..b458891 100644
--- a/configure.ac
+++ b/configure.ac
@@ -185,7 +185,13 @@ AC_ARG_ENABLE(junction,
 			[enable support for NFS junctions @<:@default=no@:>@])],
 	enable_junction=$enableval,
 	enable_junction=no)
-AM_CONDITIONAL(CONFIG_JUNCTION, [test "$enable_junction" = "yes" ])
+	if test "$enable_junction" = yes; then
+		AC_DEFINE(HAVE_JUNCTION_SUPPORT, 1,
+                          [Define this if you want junction support compiled in])
+	else
+		enable_junction=
+	fi
+	AM_CONDITIONAL(CONFIG_JUNCTION, [test "$enable_junction" = "yes" ])
 
 AC_ARG_ENABLE(tirpc,
 	[AC_HELP_STRING([--disable-tirpc],
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 6f42512..7e8d403 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -976,8 +976,9 @@ lookup_export(char *dom, char *path, struct addrinfo *ai)
 	return found;
 }
 
-#ifdef CONFIG_JUNCTION
+#ifdef HAVE_JUNCTION_SUPPORT
 
+#include <libxml/parser.h>
 #include "junction.h"
 
 struct nfs_fsloc_set {
@@ -1084,8 +1085,7 @@ static bool locations_to_fslocdata(struct nfs_fsloc_set *locations,
 	*ttl = 0;
 
 	for (;;) {
-		enum jp_status status;
-		int len;
+		int len, status;
 
 		status = get_next_location(locations, &server,
 							&rootpath, ttl);
@@ -1219,7 +1219,7 @@ nfs_get_basic_junction(const char *junct_path, struct nfs_fsloc_set **locset)
 		return EINVAL;
 	}
 
-	locset->ns_current = locset->ns_list;
+	new->ns_current = new->ns_list;
 	new->ns_ttl = 300;
 	*locset = new;
 	return 0;
@@ -1242,7 +1242,7 @@ static struct exportent *lookup_junction(char *dom, const char *pathname,
 	status = nfs_get_basic_junction(pathname, &locations);
 	switch (status) {
 		xlog(L_WARNING, "Dangling junction %s: %s",
-			pathname, strerro(status));
+			pathname, strerror(status));
 		goto out;
 	}
 
@@ -1252,8 +1252,8 @@ static struct exportent *lookup_junction(char *dom, const char *pathname,
 
 	exp = locations_to_export(locations, pathname, parent);
 
-	nfs_free_locations(locset->ns_list);
-	free(locset);
+	nfs_free_locations(locations->ns_list);
+	free(locations);
 
 out:
 	xmlCleanupParser();
@@ -1273,7 +1273,7 @@ static void lookup_nonexport(int f, char *buf, int buflen, char *dom, char *path
 	free(eep);
 }
 
-#else	/* !CONFIG_JUNCTION */
+#else	/* !HAVE_JUNCTION_SUPPORT */
 
 static void lookup_nonexport(int f, char *buf, int buflen, char *dom, char *path,
 		struct addrinfo *UNUSED(ai))
@@ -1281,7 +1281,7 @@ static void lookup_nonexport(int f, char *buf, int buflen, char *dom, char *path
 	dump_to_cache(f, buf, buflen, dom, path, NULL, 0);
 }
 
-#endif	/* !CONFIG_JUNCTION */
+#endif	/* !HAVE_JUNCTION_SUPPORT */
 
 static void nfsd_export(int f)
 {

