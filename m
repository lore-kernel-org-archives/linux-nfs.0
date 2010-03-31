From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: don't try to map gid's in generic rpc code
Date: Wed, 31 Mar 2010 15:47:41 -0400
Message-ID: <20100331194741.GA5355@fieldses.org>
References: <20100306175212.GB22650@fieldses.org> <20100324142414.GE12057@fieldses.org> <20100329182443.GC3778@kroah.com> <20100330144054.GD11545@fieldses.org> <20100330200320.GB1693@kroah.com> <20100331193029.GC4937@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, linux-nfs@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38073 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756585Ab0CaTpd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Mar 2010 15:45:33 -0400
In-Reply-To: <20100331193029.GC4937@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

For nfsd we provide users the option of mapping uid's to server-side
supplementary group lists.  That makes sense for nfsd, but not
necessarily for other rpc users (such as the callback client).

So move that lookup to svcauth_unix_set_client, which is a
program-specific method.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/svcauth_unix.c |   53 +++++++++++++++++++++++++-------------------
 1 files changed, 30 insertions(+), 23 deletions(-)

On Wed, Mar 31, 2010 at 03:30:29PM -0400, J. Bruce Fields wrote:
> In any case, I'll follow up with patches generated against 2.6.32.10.

Also, while testing those patches on 2.6.32, I noticed that 2.6.32.y
doesn't include the following (unrelated) patch.  Could you apply it as
well?  Thanks!

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 117f68a..97cc3de 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -655,23 +655,25 @@ static struct unix_gid *unix_gid_lookup(uid_t uid)
 		return NULL;
 }
 
-static int unix_gid_find(uid_t uid, struct group_info **gip,
-			 struct svc_rqst *rqstp)
+static struct group_info *unix_gid_find(uid_t uid, struct svc_rqst *rqstp)
 {
-	struct unix_gid *ug = unix_gid_lookup(uid);
+	struct unix_gid *ug;
+	struct group_info *gi;
+	int ret;
+
+	ug = unix_gid_lookup(uid);
 	if (!ug)
-		return -EAGAIN;
-	switch (cache_check(&unix_gid_cache, &ug->h, &rqstp->rq_chandle)) {
+		return ERR_PTR(-EAGAIN);
+	ret = cache_check(&unix_gid_cache, &ug->h, &rqstp->rq_chandle);
+	switch (ret) {
 	case -ENOENT:
-		*gip = NULL;
-		return 0;
+		return ERR_PTR(-ENOENT);
 	case 0:
-		*gip = ug->gi;
-		get_group_info(*gip);
+		gi = get_group_info(ug->gi);
 		cache_put(&ug->h, &unix_gid_cache);
-		return 0;
+		return gi;
 	default:
-		return -EAGAIN;
+		return ERR_PTR(-EAGAIN);
 	}
 }
 
@@ -681,6 +683,8 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 	struct sockaddr_in *sin;
 	struct sockaddr_in6 *sin6, sin6_storage;
 	struct ip_map *ipm;
+	struct group_info *gi;
+	struct svc_cred *cred = &rqstp->rq_cred;
 
 	switch (rqstp->rq_addr.ss_family) {
 	case AF_INET:
@@ -722,6 +726,17 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 			ip_map_cached_put(rqstp, ipm);
 			break;
 	}
+
+	gi = unix_gid_find(cred->cr_uid, rqstp);
+	switch (PTR_ERR(gi)) {
+	case -EAGAIN:
+		return SVC_DROP;
+	case -ENOENT:
+		break;
+	default:
+		put_group_info(cred->cr_group_info);
+		cred->cr_group_info = gi;
+	}
 	return SVC_OK;
 }
 
@@ -818,19 +833,11 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 	slen = svc_getnl(argv);			/* gids length */
 	if (slen > 16 || (len -= (slen + 2)*4) < 0)
 		goto badcred;
-	if (unix_gid_find(cred->cr_uid, &cred->cr_group_info, rqstp)
-	    == -EAGAIN)
+	cred->cr_group_info = groups_alloc(slen);
+	if (cred->cr_group_info == NULL)
 		return SVC_DROP;
-	if (cred->cr_group_info == NULL) {
-		cred->cr_group_info = groups_alloc(slen);
-		if (cred->cr_group_info == NULL)
-			return SVC_DROP;
-		for (i = 0; i < slen; i++)
-			GROUP_AT(cred->cr_group_info, i) = svc_getnl(argv);
-	} else {
-		for (i = 0; i < slen ; i++)
-			svc_getnl(argv);
-	}
+	for (i = 0; i < slen; i++)
+		GROUP_AT(cred->cr_group_info, i) = svc_getnl(argv);
 	if (svc_getu32(argv) != htonl(RPC_AUTH_NULL) || svc_getu32(argv) != 0) {
 		*authp = rpc_autherr_badverf;
 		return SVC_DENIED;
-- 
1.6.3.3

