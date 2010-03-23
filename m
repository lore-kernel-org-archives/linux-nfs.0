From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] libexport.a: Factor SUBNETWORK checking out of
	check_client()
Date: Tue, 23 Mar 2010 12:53:05 -0400
Message-ID: <20100323165305.4368.633.stgit@localhost.localdomain>
References: <20100323165122.4368.43659.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:48378 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755118Ab0CWQxH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Mar 2010 12:53:07 -0400
Received: by mail-qy0-f179.google.com with SMTP id 9so951500qyk.1
        for <linux-nfs@vger.kernel.org>; Tue, 23 Mar 2010 09:53:07 -0700 (PDT)
In-Reply-To: <20100323165122.4368.43659.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  Factor the MCL_SUBNETWORK case out of check_client() and
client_checkaddr().  This will make it easier to add IPv6 support
eventually.

The logic in the new helper function will get a little more tangled
once IPv6 support is introduced.  Each slot in the clp address list
eventually may contain an address from either address family.

Note that the switch statement in client_checkaddr() is redundant,
since clp->cl_mtype is loop invariant.  This change makes SUBNETWORK
client checking more computationally efficient, at the cost of a few
extra lines of code.

This commit should not change code behavior in any way.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   32 ++++++++++++++++++++++----------
 1 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 833f4a9..42bf45a 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -351,6 +351,27 @@ check_fqdn(const nfs_client *clp, const struct hostent *hp)
 }
 
 /*
+ * Check each address listed in @hp against the subnetwork or
+ * host address stored in @clp.  Return 1 if an address in @hp
+ * matches the host address stored in @clp, otherwise zero.
+ */
+static int
+check_subnetwork(const nfs_client *clp, const struct hostent *hp)
+{
+	struct in_addr addr;
+	char **ap;
+
+	for (ap = hp->h_addr_list; *ap; ap++) {
+		addr = *(struct in_addr *)*ap;
+
+		if (!((clp->m_addrlist[0].s_addr ^ addr.s_addr) &
+		      clp->m_addrlist[1].s_addr))
+			return 1;
+	}
+	return 0;
+}
+
+/*
  * Match a host (given its hostent record) to a client record. This
  * is usually called from mountd.
  */
@@ -365,11 +386,7 @@ client_check(nfs_client *clp, struct hostent *hp)
 	case MCL_FQDN:
 		return check_fqdn(clp, hp);
 	case MCL_SUBNETWORK:
-		for (ap = hp->h_addr_list; *ap; ap++) {
-			if (client_checkaddr(clp, *(struct in_addr *) *ap))
-				return 1;
-		}
-		return 0;
+		return check_subnetwork(clp, hp);
 	case MCL_WILDCARD:
 		if (wildmat(hname, cname))
 			return 1;
@@ -434,11 +451,6 @@ client_check(nfs_client *clp, struct hostent *hp)
 static int
 client_checkaddr(nfs_client *clp, struct in_addr addr)
 {
-	switch (clp->m_type) {
-	case MCL_SUBNETWORK:
-		return !((clp->m_addrlist[0].s_addr ^ addr.s_addr)
-			& clp->m_addrlist[1].s_addr);
-	}
 	return 0;
 }
 

