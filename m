From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH kNFSd 2 of 4] Minor memory leak fix.
Date: Tue, 24 Aug 2004 18:02:15 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040824220215.GA3521@fieldses.org>
References: <20040820164909.27056.patches@notabene> <E1By3FQ-000738-5m@notabene.cse.unsw.edu.au> <20040824202048.GB2057@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BzjN5-00028N-II
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 15:02:27 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BzjN2-0000oQ-OW
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 15:02:27 -0700
To: NeilBrown <neilb@cse.unsw.edu.au>
In-Reply-To: <20040824202048.GB2057@fieldses.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, Aug 24, 2004 at 04:20:48PM -0400, bfields wrote:
> On Fri, Aug 20, 2004 at 04:51:36PM +1000, NeilBrown wrote:
> > diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
> > --- ./net/sunrpc/svcauth_unix.c~current~	2004-08-20 16:38:12.000000000 +1000
> > +++ ./net/sunrpc/svcauth_unix.c	2004-08-20 16:38:19.000000000 +1000
> > @@ -104,6 +104,7 @@ void ip_map_put(struct cache_head *item,
> >  		if (test_bit(CACHE_VALID, &item->flags) &&
> >  		    !test_bit(CACHE_NEGATIVE, &item->flags))
> >  			auth_domain_put(&im->m_client->h);
> > +		kfree(im->m_class);
> >  		kfree(im);
> >  	}
> >  }
> 
> This is giving me oopses.  Fix follows.--b.
> 
> Since ip_map->m_class is now freed with kfree() when ip_map is destroyed,
> we can't assign the static string "nfsd" to it.

Oops; forgot to check return value from kmalloc, and missed the same
problem in two other spots.  Incremental patch against the previous fix.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---

 linux-2.6.9-rc1-bfields/net/sunrpc/svcauth_unix.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff -puN net/sunrpc/svcauth_unix.c~svcauth_ip_map_class_allocation2 net/sunrpc/svcauth_unix.c
--- linux-2.6.9-rc1/net/sunrpc/svcauth_unix.c~svcauth_ip_map_class_allocation2	2004-08-24 16:51:47.000000000 -0400
+++ linux-2.6.9-rc1-bfields/net/sunrpc/svcauth_unix.c	2004-08-24 16:53:17.000000000 -0400
@@ -307,6 +307,8 @@ struct auth_domain *auth_unix_lookup(str
 	struct auth_domain *rv;
 
 	key.m_class = strdup("nfsd");
+	if (!key.m_class)
+		return NULL;
 	key.m_addr = addr;
 
 	ipm = ip_map_lookup(&key, 0);
@@ -369,10 +371,13 @@ svcauth_null_accept(struct svc_rqst *rqs
 	svc_putu32(resv, RPC_AUTH_NULL);
 	svc_putu32(resv, 0);
 
-	key.m_class = rqstp->rq_server->sv_program->pg_class;
+	key.m_class = strdup(rqstp->rq_server->sv_program->pg_class);
+	if (!key.m_class)
+		return SVC_DROP;
 	key.m_addr = rqstp->rq_addr.sin_addr;
 
 	ipm = ip_map_lookup(&key, 0);
+	kfree(key.m_class);
 
 	rqstp->rq_client = NULL;
 
@@ -465,11 +470,14 @@ svcauth_unix_accept(struct svc_rqst *rqs
 	}
 
 
-	key.m_class = rqstp->rq_server->sv_program->pg_class;
+	key.m_class = strdup(rqstp->rq_server->sv_program->pg_class);
+	if (!key.m_class)
+		return SVC_DROP;
 	key.m_addr = rqstp->rq_addr.sin_addr;
 
 
 	ipm = ip_map_lookup(&key, 0);
+	kfree(key.m_class);
 
 	if (ipm)
 		switch (cache_check(&ip_map_cache, &ipm->h, &rqstp->rq_chandle)) {
_


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
