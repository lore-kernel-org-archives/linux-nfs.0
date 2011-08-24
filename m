Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:49169 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649Ab1HXPeR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Aug 2011 11:34:17 -0400
Received: by eyx24 with SMTP id 24so878813eyx.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Aug 2011 08:34:15 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] statd: statd_matchhostname() doesn't handle localhost
	properly
To: linux-nfs@vger.kernel.org
Date: Wed, 24 Aug 2011 11:34:13 -0400
Message-ID: <20110824153413.3138.44194.stgit@matisse.1015granger.net>
In-Reply-To: <20110824153024.3138.63294.stgit@matisse.1015granger.net>
References: <20110824153024.3138.63294.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The job of statd_matchhostname() is to work hard at matching two
hostnames or presentation IP addresses that may refer to the same
host.

statd_matchhostname() turns the hostname of the local system into a
list of addresses containing only the loopback address.  The actual
DNS registered address of the system does not appear in that list.

Presentation IP addresses, on the other hand, are soundly ignored by
the AI_CANONNAME option of getaddrinfo(3).  The ai_canonname string
that is returned is just the same presentation IP address.  And the
resulting list of addresses contains just that IP address.

So if the DNS registered IP address of the local host is passed in as
one argument, and the local hostname is passed as the other argument,
statd_matchhostname() whiffs and believes there is no match.  To fix
this, the logic needs to be smarter about deriving a hostname from an
IP address.

This appears to cause no end of trouble: monitor records pile up in
/var/lib/nfs/sm and sm.bak, notifications are missed, and so on.  This
has likely been around since commit cbd3a131 "statd: Introduce statd
version of matchhostname()" (Jan 14, 2010).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/hostname.c |   55 +++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 47 insertions(+), 8 deletions(-)

diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
index 616a3cb..746ecc7 100644
--- a/utils/statd/hostname.c
+++ b/utils/statd/hostname.c
@@ -225,6 +225,49 @@ statd_canonical_name(const char *hostname)
 	return strdup(buf);
 }
 
+/*
+ * Take care to perform an explicit reverse lookup on presentation
+ * addresses.  Otherwise we don't get a real canonical name or a
+ * complete list of addresses.
+ *
+ * Returns an addrinfo list that has ai_canonname filled in, or
+ * NULL if some error occurs.  Caller must free the returned
+ * list with freeaddrinfo(3).
+ */
+__attribute_malloc__
+static struct addrinfo *
+statd_canonical_list(const char *hostname)
+{
+	struct addrinfo hint = {
+#ifdef IPV6_SUPPORTED
+		.ai_family	= AF_UNSPEC,
+#else	/* !IPV6_SUPPORTED */
+		.ai_family	= AF_INET,
+#endif	/* !IPV6_SUPPORTED */
+		.ai_flags	= AI_NUMERICHOST,
+		.ai_protocol	= (int)IPPROTO_UDP,
+	};
+	char buf[NI_MAXHOST];
+	struct addrinfo *ai;
+
+	ai = get_addrinfo(hostname, &hint);
+	if (ai != NULL) {
+		/* @hostname was a presentation address */
+		_Bool result;
+		result = get_nameinfo(ai->ai_addr, ai->ai_addrlen,
+					buf, (socklen_t)sizeof(buf));
+		freeaddrinfo(ai);
+		if (result)
+			goto out;
+	}
+	/* @hostname was a hostname or had no reverse mapping */
+	strcpy(buf, hostname);
+
+out:
+	hint.ai_flags = AI_CANONNAME;
+	return get_addrinfo(buf, &hint);
+}
+
 /**
  * statd_matchhostname - check if two hostnames are equivalent
  * @hostname1: C string containing hostname
@@ -241,11 +284,6 @@ _Bool
 statd_matchhostname(const char *hostname1, const char *hostname2)
 {
 	struct addrinfo *ai1, *ai2, *results1 = NULL, *results2 = NULL;
-	struct addrinfo hint = {
-		.ai_family	= AF_UNSPEC,
-		.ai_flags	= AI_CANONNAME,
-		.ai_protocol	= (int)IPPROTO_UDP,
-	};
 	_Bool result = false;
 
 	if (strcasecmp(hostname1, hostname2) == 0) {
@@ -253,10 +291,10 @@ statd_matchhostname(const char *hostname1, const char *hostname2)
 		goto out;
 	}
 
-	results1 = get_addrinfo(hostname1, &hint);
+	results1 = statd_canonical_list(hostname1);
 	if (results1 == NULL)
 		goto out;
-	results2 = get_addrinfo(hostname2, &hint);
+	results2 = statd_canonical_list(hostname2);
 	if (results2 == NULL)
 		goto out;
 
@@ -276,7 +314,8 @@ out:
 	freeaddrinfo(results2);
 	freeaddrinfo(results1);
 
-	xlog(D_CALL, "%s: hostnames %s", __func__,
+	xlog(D_CALL, "%s: hostnames %s and %s %s", __func__,
+			hostname1, hostname2,
 			(result ? "matched" : "did not match"));
 	return result;
 }

