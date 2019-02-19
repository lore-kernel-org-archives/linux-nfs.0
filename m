Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9ED7C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 15:52:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 905CB21738
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 15:52:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="O6XQiOkR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725885AbfBSPwk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 10:52:40 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:36184 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725820AbfBSPwk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 10:52:40 -0500
Received: by mail-it1-f193.google.com with SMTP id h6so7335098itl.1
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 07:52:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=92AUFlWLzcIhYEh9m1l+sTVsTKU77ANWigCwJrxVsUI=;
        b=O6XQiOkRtYBcz+KyG7B8XiEgwKTfbNdZMwKw9cWzqVEhSSo/atOoUhhfLRmBvNovv3
         h5rNIXlWYbDJtYWjHcAJhFZWSRC8b/PjyOd7Kkcqu0SDxmiH3ZyNz+xesFYxg+jzl2Uu
         RQLzAW32eDVqr1dZKIx+XuEHJLqOaNbJ4vLyF11X5dpRYgSHXpqndJW5jKfh4HrgFpT5
         FS7ijS+CAkwpfrMRl7vroxGA+iICl7i6RVw+Ob1Q2YDP9TO3dHTKZhGxIPpSHVJ0DwJI
         xbN0qpK34Uw4CCTAM2qxSDBivw4+tew7P736vW1OWAS48B4W2rsdBKHqvAE4mrE61c5B
         StyQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=92AUFlWLzcIhYEh9m1l+sTVsTKU77ANWigCwJrxVsUI=;
        b=Az4ZBAauXCga2rr0jkUZG2GoZvI/Kfvc0fYlWxmAv1CcGh0MMz0lBp+B1+X5ozejgP
         Lzvi7Dl2iZAdHP8Z3HdRSUirh1qM2n9yhV+SarbHxVlCD+xRpyHpmISYvPCbveFsXHtW
         cfrEKnbyMN7yHRwy7fd76dBVmXccqBwjWzxxIPedpIzi2I5gDRGT7//LW7Ie+KvZ1iFA
         6zRYimE7Pm3fna/hf+94dU+CKmmU2LxW9f8SJcSJV89mTK6xFhff1odta8cUo6Cf/MZ9
         oEPHF3T3mGNbTsisNNbdgwGXyOg1ezLR6EebH+OaHuHQY3L46YnwIld+pXGFD9i9ZQxN
         TfYQ==
X-Gm-Message-State: AHQUAuaGFz8/UJUxFVw2ND3p/12CiE2cH6cc1whmHPLLk0FtVJGdwIfk
        S5d6519Mo8DwdeUf/53TnEmGNJSA
X-Google-Smtp-Source: AHgI3IYmrJrjkjt2RSbzljfu6sjVBrg1KZtPuMR5YgNVX2gBz7xns6njmnhSTgjQHIjwGkfY1f0Q5Q==
X-Received: by 2002:a24:3512:: with SMTP id k18mr2396861ita.83.1550591559327;
        Tue, 19 Feb 2019 07:52:39 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id r65sm1333943itb.19.2019.02.19.07.52.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 07:52:38 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1JFqaGo024832;
        Tue, 19 Feb 2019 15:52:37 GMT
Subject: [PATCH v2] Remove abuse of ai_canonname
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     SteveD@redhat.com, tripolar@gmx.at
Date:   Tue, 19 Feb 2019 10:52:36 -0500
Message-ID: <20190219155220.17240.31293.stgit@manet.1015granger.net>
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
 support/export/hostname.c |   58 +++++++++------------------------------------
 utils/mountd/auth.c       |   16 ++++++------
 2 files changed, 20 insertions(+), 54 deletions(-)


Compile-tested only.


diff --git a/support/export/hostname.c b/support/export/hostname.c
index 5c4c824..96c5449 100644
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
@@ -323,7 +318,6 @@ host_numeric_addrinfo(const struct sockaddr *sap)
 {
 	socklen_t salen = nfs_sockaddr_length(sap);
 	char buf[INET6_ADDRSTRLEN];
-	struct addrinfo *ai;
 	int error;
 
 	if (salen == 0) {
@@ -348,21 +342,7 @@ host_numeric_addrinfo(const struct sockaddr *sap)
 		return NULL;
 	}
 
-	ai = host_pton(buf);
-
-	/*
-	 * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
-	 */
-	if (ai != NULL) {
-		free(ai->ai_canonname);		/* just in case */
-		ai->ai_canonname = strdup(buf);
-		if (ai->ai_canonname == NULL) {
-			freeaddrinfo(ai);
-			ai = NULL;
-		}
-	}
-
-	return ai;
+	return host_pton(buf);
 }
 #else	/* !HAVE_GETNAMEINFO */
 __attribute__((__malloc__))
@@ -372,7 +352,6 @@ host_numeric_addrinfo(const struct sockaddr *sap)
 	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
 	const struct in_addr *addr = &sin->sin_addr;
 	char buf[INET_ADDRSTRLEN];
-	struct addrinfo *ai;
 
 	if (sap->sa_family != AF_INET)
 		return NULL;
@@ -382,19 +361,6 @@ host_numeric_addrinfo(const struct sockaddr *sap)
 					(socklen_t)sizeof(buf)) == NULL)
 		return NULL;
 
-	ai = host_pton(buf);
-
-	/*
-	 * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
-	 */
-	if (ai != NULL) {
-		ai->ai_canonname = strdup(buf);
-		if (ai->ai_canonname == NULL) {
-			freeaddrinfo(ai);
-			ai = NULL;
-		}
-	}
-
-	return ai;
+	return host_pton(buf);
 }
 #endif	/* !HAVE_GETNAMEINFO */
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

