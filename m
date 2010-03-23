From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] libexport.a: Refactor netgroup checking in client_check()
Date: Tue, 23 Mar 2010 12:53:23 -0400
Message-ID: <20100323165323.4368.22761.stgit@localhost.localdomain>
References: <20100323165122.4368.43659.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:63792 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab0CWQxo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Mar 2010 12:53:44 -0400
Received: by qw-out-2122.google.com with SMTP id 8so1597330qwh.37
        for <linux-nfs@vger.kernel.org>; Tue, 23 Mar 2010 09:53:43 -0700 (PDT)
In-Reply-To: <20100323165122.4368.43659.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: refactor netgroup logic out of client_check() to make it
easier to introduce IPv6 support.

 +  Use preferred style of keeping #ifdef out of the middle of
    function definitions.  Squelch compiler warnings for "#ifndef
    HAVE_INNETGR" by using __attribute__((unused)).

 +  Use preferred style of not using curly braces around switch cases.

 +  Match style used for check_{fqdn,subnetwork}.

 +  Clarify comment documenting use of h_aliases

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   97 ++++++++++++++++++++++++++++-------------------
 1 files changed, 57 insertions(+), 40 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 419a4a7..580012d 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -371,6 +371,62 @@ check_subnetwork(const nfs_client *clp, const struct hostent *hp)
 }
 
 /*
+ * Check if @hp's hostname or aliases fall in a given netgroup.
+ * Return 1 if @hp represents a host in the netgroup, otherwise zero.
+ */
+#ifdef HAVE_INNETGR
+static int
+check_netgroup(const nfs_client *clp, const struct hostent *hp)
+{
+	const char *netgroup = clp->m_hostname + 1;
+	const char *hname = hp->h_name;
+	struct hostent *nhp = NULL;
+	struct sockaddr_in addr;
+	int match, i;
+	char *dot;
+
+	/* First, try to match the hostname without
+	 * splitting off the domain */
+	if (innetgr(netgroup, hname, NULL, NULL))
+		return 1;
+
+	/* See if hname aliases listed in /etc/hosts or nis[+]
+	 * match the requested netgroup */
+	for (i = 0; hp->h_aliases[i]; i++) {
+		if (innetgr(netgroup, hp->h_aliases[i], NULL, NULL))
+			return 1;
+	}
+
+	/* If hname is ip address convert to FQDN */
+	if (inet_aton(hname, &addr.sin_addr) &&
+	   (nhp = gethostbyaddr((const char *)&(addr.sin_addr),
+	    sizeof(addr.sin_addr), AF_INET))) {
+		hname = nhp->h_name;
+		if (innetgr(netgroup, hname, NULL, NULL))
+			return 1;
+	}
+
+	/* Okay, strip off the domain (if we have one) */
+	dot = strchr(hname, '.');
+	if (dot == NULL)
+		return 0;
+
+	*dot = '\0';
+	match = innetgr(netgroup, hname, NULL, NULL);
+	*dot = '.';
+
+	return match;
+}
+#else	/* !HAVE_INNETGR */
+static int
+check_netgroup(__attribute__((unused)) const nfs_client *clp,
+		__attribute__((unused)) const struct hostent *hp)
+{
+	return 0;
+}
+#endif	/* !HAVE_INNETGR */
+
+/*
  * Match a host (given its hostent record) to a client record. This
  * is usually called from mountd.
  */
@@ -396,46 +452,7 @@ client_check(nfs_client *clp, struct hostent *hp)
 		}
 		return 0;
 	case MCL_NETGROUP:
-#ifdef HAVE_INNETGR
-		{
-			char	*dot;
-			int	match, i;
-			struct hostent *nhp = NULL;
-			struct sockaddr_in addr;
-
-			/* First, try to match the hostname without
-			 * splitting off the domain */
-			if (innetgr(cname+1, hname, NULL, NULL))
-				return 1;
-
-			/* try the aliases as well */
-			for (i = 0; hp->h_aliases[i]; i++) {
-				if (innetgr(cname+1, hp->h_aliases[i], NULL, NULL))
-					return 1;
-			}
-
-			/* If hname is ip address convert to FQDN */
-			if (inet_aton(hname, &addr.sin_addr) &&
-			   (nhp = gethostbyaddr((const char *)&(addr.sin_addr),
-			    sizeof(addr.sin_addr), AF_INET))) {
-				hname = (char *)nhp->h_name;
-				if (innetgr(cname+1, hname, NULL, NULL))
-					return 1;
-			}
-
-			/* Okay, strip off the domain (if we have one) */
-			if ((dot = strchr(hname, '.')) == NULL)
-				return 0;
-
-			*dot = '\0';
-			match = innetgr(cname+1, hname, NULL, NULL);
-			*dot = '.';
-
-			return match;
-		}
-#else
-		return 0;
-#endif
+		return check_netgroup(clp, hp);
 	case MCL_ANONYMOUS:
 		return 1;
 	case MCL_GSS:

