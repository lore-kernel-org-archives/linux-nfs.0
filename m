Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:42819 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802Ab1HXPeZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Aug 2011 11:34:25 -0400
Received: by mail-ew0-f46.google.com with SMTP id 4so527255ewy.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Aug 2011 08:34:25 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] exportfs: matchhostname() doesn't handle localhost
	properly
To: linux-nfs@vger.kernel.org
Date: Wed, 24 Aug 2011 11:34:23 -0400
Message-ID: <20110824153422.3138.49458.stgit@matisse.1015granger.net>
In-Reply-To: <20110824153024.3138.63294.stgit@matisse.1015granger.net>
References: <20110824153024.3138.63294.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Same change as statd_matchhostname() is necessary for the logic in
exportfs.

Recall that these are "separate but nearly equal" because the exportfs
version requires extra expensive string checking that would be onerous
for statd.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/exportfs/exportfs.c |   34 ++++++++++++++++++++++++++++++++--
 1 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index b107c7c..12e8bf1 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -448,6 +448,36 @@ is_hostname(const char *sp)
 	return true;
 }
 
+/*
+ * Take care to perform an explicit reverse lookup on presentation
+ * addresses.  Otherwise we don't get a real canonical name or a
+ * complete list of addresses.
+ */
+static struct addrinfo *
+address_list(const char *hostname)
+{
+	struct addrinfo *ai;
+	char *cname;
+
+	ai = host_pton(hostname);
+	if (ai != NULL) {
+		/* @hostname was a presentation address */
+		cname = host_canonname(ai->ai_addr);
+		freeaddrinfo(ai);
+		if (cname != NULL)
+			goto out;
+	}
+	/* @hostname was a hostname or had no reverse mapping */
+	cname = strdup(hostname);
+	if (cname == NULL)
+		return NULL;
+
+out:
+	ai = host_addrinfo(cname);
+	free(cname);
+	return ai;
+}
+
 static int
 matchhostname(const char *hostname1, const char *hostname2)
 {
@@ -464,10 +494,10 @@ matchhostname(const char *hostname1, const char *hostname2)
 	if (!is_hostname(hostname1) || !is_hostname(hostname2))
 		return 0;
 
-	results1 = host_addrinfo(hostname1);
+	results1 = address_list(hostname1);
 	if (results1 == NULL)
 		goto out;
-	results2 = host_addrinfo(hostname2);
+	results2 = address_list(hostname2);
 	if (results2 == NULL)
 		goto out;
 

