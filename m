Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx6-phx2.redhat.com ([209.132.183.39]:57377 "EHLO
	mx6-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932273AbbLNWPi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Dec 2015 17:15:38 -0500
Date: Mon, 14 Dec 2015 17:15:37 -0500 (EST)
From: Frank Sorenson <sorenson@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Steve Dickson <steved@redhat.com>
Message-ID: <371875408.30231785.1450131337790.JavaMail.zimbra@redhat.com>
In-Reply-To: <1054854128.30230518.1450131093639.JavaMail.zimbra@redhat.com>
Subject: fix mountd netgroup lookup for short hostnames
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Commit 9a92ef6f194926904b1289e0ce1daecb42bd5e8b to add netgroup
lookup of resolvable IP addresses inadvertently broke the
netgroup check for short hostnames by clobbering the 'hname'
variable.
    
This patch fixes that breakage by changing the IP address
lookup to use a separate variable.  The 'hname' variable
used in the short hostname lookup is now untouched in
the IP lookup code.



Author: Frank Sorenson <sorenson@redhat.com>
Date:   Mon Dec 14 15:50:30 2015 -0600

    mountd: fix netgroup lookup for short hostnames
    
    Commit 9a92ef6f194926904b1289e0ce1daecb42bd5e8b to add netgroup
    lookup of resolvable IP addresses inadvertently broke the
    netgroup check for short hostnames.
    
    This patch fixes that breakage by changing the IP address
    lookup to use a separate variable.
    
    Signed-off-by: Frank Sorenson <sorenson@redhat.com>

diff --git a/support/export/client.c b/support/export/client.c
index af9e6bb..2346f99 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -639,7 +639,7 @@ check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
 	const char *netgroup = clp->m_hostname + 1;
 	struct addrinfo *tmp = NULL;
 	struct hostent *hp;
-	char *dot, *hname;
+	char *dot, *hname, *ip;
 	int i, match;
 
 	match = 0;
@@ -687,19 +687,16 @@ check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
 	}
 
 	/* check whether the IP itself is in the netgroup */
-	for (tmp = (struct addrinfo *)ai ; tmp != NULL ; tmp = tmp->ai_next) {
-		free(hname);
-		hname = calloc(INET6_ADDRSTRLEN, 1);
-
-		if (inet_ntop(tmp->ai_family, &(((struct sockaddr_in *)tmp->ai_addr)->sin_addr), hname, INET6_ADDRSTRLEN) != hname) {
-			xlog(D_GENERAL, "  %s: unable to inet_ntop addrinfo %p: %m", __func__, tmp, errno);
-			goto out;
-		}
-		if (innetgr(netgroup, hname, NULL, NULL)) {
+	ip = calloc(INET6_ADDRSTRLEN, 1);
+	if (inet_ntop(ai->ai_family, &(((struct sockaddr_in *)ai->ai_addr)->sin_addr), ip, INET6_ADDRSTRLEN) == ip) {
+		if (innetgr(netgroup, ip, NULL, NULL)) {
+			free(hname);
+			hname = ip;
 			match = 1;
 			goto out;
 		}
 	}
+	free(ip);
 
 	/* Okay, strip off the domain (if we have one) */
 	dot = strchr(hname, '.');
