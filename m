From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/6] libexport.a: Refactor wildcard checking in client_check()
Date: Tue, 23 Mar 2010 12:53:48 -0400
Message-ID: <20100323165348.4368.43901.stgit@localhost.localdomain>
References: <20100323165122.4368.43659.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:51663 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab0CWQxx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Mar 2010 12:53:53 -0400
Received: by qyk9 with SMTP id 9so952529qyk.1
        for <linux-nfs@vger.kernel.org>; Tue, 23 Mar 2010 09:53:52 -0700 (PDT)
In-Reply-To: <20100323165122.4368.43659.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: refactor wildcard logic out of client_check() to make it
easier to introduce IPv6 support.

Match the style used for client_check_{fqdn,subnetwork,netgroup}.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   38 ++++++++++++++++++++++++++------------
 1 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 580012d..bf2a359 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -371,6 +371,31 @@ check_subnetwork(const nfs_client *clp, const struct hostent *hp)
 }
 
 /*
+ * Check if a wildcard nfs_client record matches the canonical name
+ * or the aliases of a host.  Return 1 if a match is found, otherwise
+ * zero.
+ */
+static int
+check_wildcard(const nfs_client *clp, const struct hostent *hp)
+{
+	char *cname = clp->m_hostname;
+	char *hname = hp->h_name;
+	char **ap;
+
+	if (wildmat(hname, cname))
+		return 1;
+
+	/* See if hname aliases listed in /etc/hosts or nis[+]
+	 * match the requested wildcard */
+	for (ap = hp->h_aliases; *ap; ap++) {
+		if (wildmat(*ap, cname))
+			return 1;
+	}
+
+	return 0;
+}
+
+/*
  * Check if @hp's hostname or aliases fall in a given netgroup.
  * Return 1 if @hp represents a host in the netgroup, otherwise zero.
  */
@@ -433,24 +458,13 @@ check_netgroup(__attribute__((unused)) const nfs_client *clp,
 int
 client_check(nfs_client *clp, struct hostent *hp)
 {
-	char	*hname = (char *) hp->h_name;
-	char	*cname = clp->m_hostname;
-	char	**ap;
-
 	switch (clp->m_type) {
 	case MCL_FQDN:
 		return check_fqdn(clp, hp);
 	case MCL_SUBNETWORK:
 		return check_subnetwork(clp, hp);
 	case MCL_WILDCARD:
-		if (wildmat(hname, cname))
-			return 1;
-		else {
-			for (ap = hp->h_aliases; *ap; ap++)
-				if (wildmat(*ap, cname))
-					return 1;
-		}
-		return 0;
+		return check_wildcard(clp, hp);
 	case MCL_NETGROUP:
 		return check_netgroup(clp, hp);
 	case MCL_ANONYMOUS:

