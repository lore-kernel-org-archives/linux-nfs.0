Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:42819 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044Ab1HXPef (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Aug 2011 11:34:35 -0400
Received: by mail-ew0-f46.google.com with SMTP id 4so527255ewy.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Aug 2011 08:34:35 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] sm-notify: sm-notify doesn't handle localhost properly
To: linux-nfs@vger.kernel.org
Date: Wed, 24 Aug 2011 11:34:32 -0400
Message-ID: <20110824153432.3138.94316.stgit@matisse.1015granger.net>
In-Reply-To: <20110824153024.3138.63294.stgit@matisse.1015granger.net>
References: <20110824153024.3138.63294.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

It looks like the existing algorithm for verifying the passed-in bind
address is as broken as statd_matchhostname() used to be: for IP
addresses, AI_CANONNAME is useless.  We need to have getnameinfo(3) or
equivalent in there.

Clean up: extract the logic that verifies the command line bind
address into its own function, and make it handle canonical name
lookup correctly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |  127 ++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 102 insertions(+), 25 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index f05eadf..2421f8b 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -93,6 +93,101 @@ smn_lookup(const char *name)
 	return ai;
 }
 
+#ifdef HAVE_GETNAMEINFO
+static char *
+smn_get_hostname(const struct sockaddr *sap, const socklen_t salen,
+		const char *name)
+{
+	char buf[NI_MAXHOST];
+	int error;
+
+	error = getnameinfo(sap, salen, buf, sizeof(buf), NULL, 0, NI_NAMEREQD);
+	if (error != 0) {
+		xlog(L_ERROR, "my_name '%s' is unusable: %s",
+			name, gai_strerror(error));
+		return NULL;
+	}
+	return strdup(buf);
+}
+#else	/* !HAVE_GETNAMEINFO */
+static char *
+smn_get_hostname(const struct sockaddr *sap,
+		__attribute__ ((unused)) const socklen_t salen,
+		const char *name)
+{
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)(char *)sap;
+	const struct in_addr *addr = &sin->sin_addr;
+	struct hostent *hp;
+
+	if (sap->sa_family != AF_INET) {
+		xlog(L_ERROR, "my_name '%s' is unusable: Bad address family",
+			name);
+		return NULL;
+	}
+
+	hp = gethostbyaddr(addr, (socklen_t)sizeof(addr), AF_INET);
+	if (hp == NULL) {
+		xlog(L_ERROR, "my_name '%s' is unusable: %s",
+			name, hstrerror(h_errno));
+		return NULL;
+	}
+	return strdup(hp->h_name);
+}
+#endif	/* !HAVE_GETNAMEINFO */
+
+/*
+ * Presentation addresses are converted to their canonical hostnames.
+ * If the IP address does not map to a hostname, it is an error:
+ * we never send a presentation address as the argument of SM_NOTIFY.
+ *
+ * If "name" is not a presentation address, it is left alone.  This
+ * allows the administrator some flexibility if DNS isn't configured
+ * exactly how sm-notify prefers it.
+ *
+ * Returns NUL-terminated C string containing the result, or NULL
+ * if the canonical name doesn't exist or cannot be determined.
+ * The caller must free the result with free(3).
+ */
+__attribute_malloc__
+static char *
+smn_verify_my_name(const char *name)
+{
+	struct addrinfo *ai = NULL;
+	struct addrinfo hint = {
+#ifdef IPV6_SUPPORTED
+		.ai_family	= AF_UNSPEC,
+#else	/* !IPV6_SUPPORTED */
+		.ai_family	= AF_INET,
+#endif	/* !IPV6_SUPPORTED */
+		.ai_flags	= AI_NUMERICHOST,
+	};
+	char *retval;
+	int error;
+
+	error = getaddrinfo(name, NULL, &hint, &ai);
+	switch (error) {
+	case 0:
+		/* @name was a presentation address */
+		retval = smn_get_hostname(ai->ai_addr, ai->ai_addrlen, name);
+		freeaddrinfo(ai);
+		if (retval == NULL)
+			return NULL;
+		break;
+	case EAI_NONAME:
+		/* @name was not a presentation address */
+		retval = strdup(name);
+		break;
+	default:
+		xlog(L_ERROR, "my_name '%s' is unusable: %s",
+			name, gai_strerror(error));
+		return NULL;
+	}
+
+	xlog(D_GENERAL, "Canonical name for my_name '%s': %s",
+			name, retval);
+	return retval;
+}
+
 __attribute_malloc__
 static struct nsm_host *
 smn_alloc_host(const char *hostname, const char *mon_name,
@@ -416,32 +511,14 @@ usage:		fprintf(stderr,
 	}
 
 	if (opt_srcaddr != NULL) {
-		struct addrinfo *ai = NULL;
-		struct addrinfo hint = {
-			.ai_family	= AF_UNSPEC,
-			.ai_flags	= AI_NUMERICHOST,
-		};
-
-		if (getaddrinfo(opt_srcaddr, NULL, &hint, &ai))
-			/* not a presentation address - use it */
-			strncpy(nsm_hostname, opt_srcaddr, sizeof(nsm_hostname));
-		else {
-			/* was a presentation address - look it up in
-			 * /etc/hosts, so it can be used for my_name */
-			int error;
+		char *name;
 
-			freeaddrinfo(ai);
-			hint.ai_flags = AI_CANONNAME;
-			error = getaddrinfo(opt_srcaddr, NULL, &hint, &ai);
-			if (error != 0) {
-				xlog(L_ERROR, "Bind address %s is unusable: %s",
-						opt_srcaddr, gai_strerror(error));
-				exit(1);
-			}
-			strncpy(nsm_hostname, ai->ai_canonname,
-							sizeof(nsm_hostname));
-			freeaddrinfo(ai);
-		}
+		name = smn_verify_my_name(opt_srcaddr);
+		if (name == NULL)
+			exit(1);
+
+		strncpy(nsm_hostname, name, sizeof(nsm_hostname));
+		free(name);
 	}
 
 	(void)nsm_retire_monitored_hosts();

