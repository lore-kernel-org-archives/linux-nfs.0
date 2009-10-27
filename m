From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 4.1 NULL dereference in 2.6.32-rc3
Date: Tue, 27 Oct 2009 19:17:49 -0400
Message-ID: <20091027231749.GB14471@fieldses.org>
References: <20091005230736.GB31874@fieldses.org> <20091009002020.GC26954@fieldses.org> <20091009170218.GF9436@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43675 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755442AbZJ0XQ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Oct 2009 19:16:27 -0400
In-Reply-To: <20091009170218.GF9436@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 09, 2009 at 01:02:19PM -0400, J. Bruce Fields wrote:
> On Thu, Oct 08, 2009 at 08:20:20PM -0400, J. Bruce Fields wrote:
> > On Mon, Oct 05, 2009 at 07:07:36PM -0400, J. Bruce Fields wrote:
> > > After mounting and unmounting a 4.1 partition with client and server
> > > both 2.6.32-rc3, I see the following NULL dereference on the client.
> > > 
> > > I think the only cache lookup there is in unix_gid_find().  Hm.
> > > Maybe it's trying to defer a request without a defer method set?
> > 
> > Confirmed.  And I don't see where the client sets any defer method.  (It
> > shouldn't really have to.)
> > 
> > Anyway, I'll think of some way to bypass this upcall.
> 
> Actually, it seems sort of wrong to have what's really nfs
> server-specific credential mapping in generic rpc cred parsing code.
> Maybe we should move that unix_gid_find() into pg_authenticate()
> (so svcauth_unix_set_client() in this case).

Something like this?

It's a little annoying that we then allocate a struct group_info * to
hold the on-the-wire auth_unix groups, even when we'll later discard
them.

But I doubt that's a big deal, and I'd prefer the cleaner nfsd/rpc
separation.

--b.

commit db5566449a9991110e51486cd680dc07772cb728
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Oct 20 18:51:34 2009 -0400

    nfsd4: don't try to map gid's in generic rpc code
    
    For nfsd we provide users the option of mapping uid's to server-side
    supplementary group lists.  That makes sense for nfsd, but not
    necessarily for other rpc users (such as the callback client).
    
    So move that lookup to svcauth_unix_set_client, which is a
    program-specific method.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

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
