Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E279CC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 15:31:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A2D7A21738
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 15:31:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Cp4cj9ju"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726244AbfBSPbv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 10:31:51 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:36322 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726110AbfBSPbv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 10:31:51 -0500
Received: by mail-it1-f196.google.com with SMTP id h6so7155096itl.1
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 07:31:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=FoBg6KUrzxP4kP14peELN9ODdd+yaUAoWRL37Q1v4Ks=;
        b=Cp4cj9jugxrhv7vWqRh+r1n8Lu5L7AS9HAcYEHoVRwk84MQOEmbxcP/9O8bG7LZGJX
         iBbeIRZ+tNkC6uHjokGSwI3OuQoDNxzKux3GxkVLoWgn/H4PeAKLGkjJU2F3NwCF7eUr
         wrWq7NqKkNmBEFXj7QKOR9Js3K45zpwBfqjfgWknJwITWYRuZ8Uq2XcaNqOmfWBOYH98
         AbCx9tucf6vGlswQ7a3JDUa7c5DqO822Ti2PogH1gob2X9c7hLczrk31CzDNIX5MD5lo
         TZJ32RZM0FBDGoaCvtFMFagh1FRkeD7muGcXjRzl+rheLqcanxZaOIwM79G0gSaT9EOW
         t13A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=FoBg6KUrzxP4kP14peELN9ODdd+yaUAoWRL37Q1v4Ks=;
        b=prYiIMqM2KAfp7C563XQEa5s6zvTNxoffTXFgcHmqhU63GOva22Z9NdO4Xdhlwkp7y
         DboqtEpuOkAKEZadXCtgDMtaQyxcimY/8AsBiR0f+TeoioIGlIk1JUKgcTfsIu9STbsi
         ZYx1lKpXg2QlQU5yOFP7/KzxwtqTLaj8a6sGKl+lW2yPtqCDsDl4S45g/NDx6q0wkl+n
         wb8/DwiiwO+BEVUM6leK2MAvaAjb0FyurDfAuhpJlyFP+F7Vz9G3Ec39/HTiMJg8ptPy
         gQe+4E1oBMObvA3Ym1ffywIPIK2P800aZTxnCQZ18qw9Qvniob3pA459/tl/ZSAxErUz
         Harg==
X-Gm-Message-State: AHQUAuYF+Fv1U1cMuyIpfMkjy97xg7lv/xHoyISTU8Kq1KZoS6/WW9C+
        XED/K9pyPaN/JfJgWHSzloziQHq9
X-Google-Smtp-Source: AHgI3IZKvt0PfQ2zekbHWrBWj5WIh8RgodvgCdklwwXdYCxjTx7nytObQM+XH94ccCarizsmMA9l6g==
X-Received: by 2002:a02:f04:: with SMTP id h4mr15224113jad.50.1550590310826;
        Tue, 19 Feb 2019 07:31:50 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id i66sm1214697ite.38.2019.02.19.07.31.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 07:31:50 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1JFVmqr024800;
        Tue, 19 Feb 2019 15:31:49 GMT
Subject: [PATCH RFC] Remove one usage of ai_canonname
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     SteveD@redhat.com
Date:   Tue, 19 Feb 2019 10:31:48 -0500
Message-ID: <20190219153100.16674.71283.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Peter Wagner <tripolar@gmx.at> reports a portability issue with
freeing ai_canonname (and subsequently replacing that pointer via
strdup(3)). The relevant standards text is:

> If nodename is not null, and if requested by the AI_CANONNAME
> flag, the ai_canonname field of the first returned addrinfo
> structure shall point to a null-terminated string containing the
> canonical name corresponding to the input nodename; if the
> canonical name is not available, then ai_canonname shall refer to
> the nodename argument or a string with the same contents.

There is no indication that this string may be freed using free(3).
Eg, the library could have allocated it as part of the addrinfo
struct itself, or it could point to static memory. The Linux man
page is equally silent on this issue.

There is only one caller to host_reliable_addrinfo() that actually
uses the string in ai->ai_canonname, and then only for debugging
messages. Change those to display the IP address instead.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 support/export/hostname.c |   25 ++++++++++---------------
 utils/mountd/auth.c       |   16 ++++++++--------
 2 files changed, 18 insertions(+), 23 deletions(-)

This patch is compile-tested only. Steve, does this patch pass your
internal tests? Are the new debugging messages sufficient IYO ?

diff --git a/support/export/hostname.c b/support/export/hostname.c
index 5c4c824..9914e0d 100644
--- a/support/export/hostname.c
+++ b/support/export/hostname.c
@@ -264,9 +264,9 @@ host_canonname(const struct sockaddr *sap)
  * Reverse and forward lookups are performed to ensure the address has
  * matching forward and reverse mappings.
  *
- * Returns addrinfo structure with just the provided address with
- * ai_canonname filled in. If there is a problem with resolution or
- * the resolved records don't match up properly then it returns NULL
+ * Returns addrinfo structure with just the provided address. If there
+ * is a problem with resolution or the resolved records don't match up
+ * properly then returns NULL.
  *
  * Caller must free the returned structure with freeaddrinfo(3).
  */
@@ -277,13 +277,15 @@ host_reliable_addrinfo(const struct sockaddr *sap)
 	struct addrinfo *ai, *a;
 	char *hostname;
 
+	ai = NULL;
 	hostname = host_canonname(sap);
 	if (hostname == NULL)
-		return NULL;
+		goto out;
 
 	ai = host_addrinfo(hostname);
+	free(hostname);
 	if (!ai)
-		goto out_free_hostname;
+		goto out;
 
 	/* make sure there's a matching address in the list */
 	for (a = ai; a; a = a->ai_next)
@@ -291,22 +293,15 @@ host_reliable_addrinfo(const struct sockaddr *sap)
 			break;
 
 	freeaddrinfo(ai);
+	ai = NULL;
 	if (!a)
-		goto out_free_hostname;
+		goto out;
 
 	/* get addrinfo with just the original address */
 	ai = host_numeric_addrinfo(sap);
-	if (!ai)
-		goto out_free_hostname;
 
-	/* and populate its ai_canonname field */
-	free(ai->ai_canonname);
-	ai->ai_canonname = hostname;
+out:
 	return ai;
-
-out_free_hostname:
-	free(hostname);
-	return NULL;
 }
 
 /**
diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 8299256..cb4848c 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -261,40 +261,40 @@ auth_authenticate(const char *what, const struct sockaddr *caller,
 		*p = '\0';
 	}
 
+	host_ntop(caller, buf, sizeof(buf));
 	switch (error) {
 	case bad_path:
 		xlog(L_WARNING, "bad path in %s request from %s: \"%s\"",
-		     what, host_ntop(caller, buf, sizeof(buf)), path);
+		     what, buf, path);
 		break;
 
 	case unknown_host:
 		xlog(L_WARNING, "refused %s request from %s for %s (%s): unmatched host",
-		     what, host_ntop(caller, buf, sizeof(buf)), path, epath);
+		     what, buf, path, epath);
 		break;
 
 	case no_entry:
 		xlog(L_WARNING, "refused %s request from %s for %s (%s): no export entry",
-		     what, ai->ai_canonname, path, epath);
+		     what, buf, path, epath);
 		break;
 
 	case not_exported:
 		xlog(L_WARNING, "refused %s request from %s for %s (%s): not exported",
-		     what, ai->ai_canonname, path, epath);
+		     what, buf, path, epath);
 		break;
 
 	case illegal_port:
 		xlog(L_WARNING, "refused %s request from %s for %s (%s): illegal port %u",
-		     what, ai->ai_canonname, path, epath, nfs_get_port(caller));
+		     what, buf, path, epath, nfs_get_port(caller));
 		break;
 
 	case success:
 		xlog(L_NOTICE, "authenticated %s request from %s:%u for %s (%s)",
-		     what, ai->ai_canonname, nfs_get_port(caller), path, epath);
+		     what, buf, nfs_get_port(caller), path, epath);
 		break;
 	default:
 		xlog(L_NOTICE, "%s request from %s:%u for %s (%s) gave %d",
-		     what, ai->ai_canonname, nfs_get_port(caller),
-			path, epath, error);
+		     what, buf, nfs_get_port(caller), path, epath, error);
 	}
 
 	freeaddrinfo(ai);

