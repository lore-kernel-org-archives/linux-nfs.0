From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] libexport.a: Factor FQDN checking out of check_client()
Date: Tue, 23 Mar 2010 12:52:50 -0400
Message-ID: <20100323165249.4368.2047.stgit@localhost.localdomain>
References: <20100323165122.4368.43659.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:6920 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837Ab0CWQxA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Mar 2010 12:53:00 -0400
Received: by qw-out-2122.google.com with SMTP id 8so1597140qwh.37
        for <linux-nfs@vger.kernel.org>; Tue, 23 Mar 2010 09:52:59 -0700 (PDT)
In-Reply-To: <20100323165122.4368.43659.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  Factor the MCL_FQDN case out of check_client() and
client_checkaddr().  This will make it easier to add IPv6 support
eventually.

The logic in the new helper function will get a little more tangled
once IPv6 support is introduced.  Each slot in the clp address list
eventually may contain an address from either address family.

Note that the switch statement in client_checkaddr() is redundant,
since clp->cl_mtype is loop invariant.  This change makes FQDN client
checking more computationally efficient, at the cost of a few extra
lines of code.

This commit should not change code behavior in any way.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   31 +++++++++++++++++++++++--------
 1 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 5e937b0..833f4a9 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -329,6 +329,28 @@ add_name(char *old, const char *add)
 }
 
 /*
+ * Check each address listed in @hp against each address
+ * stored in @clp.  Return 1 if a match is found, otherwise
+ * zero.
+ */
+static int
+check_fqdn(const nfs_client *clp, const struct hostent *hp)
+{
+	struct in_addr addr;
+	char **ap;
+	int i;
+
+	for (ap = hp->h_addr_list; *ap; ap++) {
+		addr = *(struct in_addr *)*ap;
+
+		for (i = 0; i < clp->m_naddr; i++)
+			if (clp->m_addrlist[i].s_addr == addr.s_addr)
+				return 1;
+	}
+	return 0;
+}
+
+/*
  * Match a host (given its hostent record) to a client record. This
  * is usually called from mountd.
  */
@@ -341,6 +363,7 @@ client_check(nfs_client *clp, struct hostent *hp)
 
 	switch (clp->m_type) {
 	case MCL_FQDN:
+		return check_fqdn(clp, hp);
 	case MCL_SUBNETWORK:
 		for (ap = hp->h_addr_list; *ap; ap++) {
 			if (client_checkaddr(clp, *(struct in_addr *) *ap))
@@ -411,15 +434,7 @@ client_check(nfs_client *clp, struct hostent *hp)
 static int
 client_checkaddr(nfs_client *clp, struct in_addr addr)
 {
-	int	i;
-
 	switch (clp->m_type) {
-	case MCL_FQDN:
-		for (i = 0; i < clp->m_naddr; i++) {
-			if (clp->m_addrlist[i].s_addr == addr.s_addr)
-				return 1;
-		}
-		return 0;
 	case MCL_SUBNETWORK:
 		return !((clp->m_addrlist[0].s_addr ^ addr.s_addr)
 			& clp->m_addrlist[1].s_addr);

