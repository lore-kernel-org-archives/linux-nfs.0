From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH kNFSd 2 of 4] Minor memory leak fix.
Date: Thu, 26 Aug 2004 18:28:40 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040826222840.GA26003@fieldses.org>
References: <20040820164909.27056.patches@notabene> <E1By3FQ-000738-5m@notabene.cse.unsw.edu.au> <20040824202048.GB2057@fieldses.org> <20040824220215.GA3521@fieldses.org> <16683.61807.372405.848939@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0Sjg-0003RO-6B
	for nfs@lists.sourceforge.net; Thu, 26 Aug 2004 15:28:48 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C0Sjf-0008BV-Gr
	for nfs@lists.sourceforge.net; Thu, 26 Aug 2004 15:28:48 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16683.61807.372405.848939@cse.unsw.edu.au>
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

On Wed, Aug 25, 2004 at 11:54:55AM +1000, Neil Brown wrote:
> How about we just decide that fixed-length string buffers are OK (as
> the reality is that any value other than "nfsd" is extremely
> unlikely), and use the following instead.

Sure.

> This is against 2.6.8.1-mm4 without Bruce's patch, but is not an
> official submission yet as I have actually tested it yet. (should do
> soon).

OK, I've now reviewed and tested it.

I get oopses on 2.6.9-rc1 within half an hour of mounting (I'm surprised
noone else is complaining; am I doing something unusual?), so I think we
should apply this sooner rather than later.

Though Trond is right that, this out of the way, we need to stop doing
the ip mapping on every rpc request.

--Bruce Fields

How about we just decide that fixed-length string buffers are OK (as
the reality is that any value other than "nfsd" is extremely
unlikely), and use the following instead.

>From Neil Brown <neilb@cse.unsw.edu.au>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2004-08-25 11:34:08.000000000 +1000
+++ ./net/sunrpc/svcauth_unix.c	2004-08-25 11:37:30.000000000 +1000
@@ -90,7 +90,7 @@ static void svcauth_unix_domain_release(
 
 struct ip_map {
 	struct cache_head	h;
-	char			*m_class; /* e.g. "nfsd" */
+	char			m_class[8]; /* e.g. "nfsd" */
 	struct in_addr		m_addr;
 	struct unix_domain	*m_client;
 	int			m_add_change;
@@ -104,7 +104,6 @@ void ip_map_put(struct cache_head *item,
 		if (test_bit(CACHE_VALID, &item->flags) &&
 		    !test_bit(CACHE_NEGATIVE, &item->flags))
 			auth_domain_put(&im->m_client->h);
-		kfree(im->m_class);
 		kfree(im);
 	}
 }
@@ -121,8 +120,7 @@ static inline int ip_map_match(struct ip
 }
 static inline void ip_map_init(struct ip_map *new, struct ip_map *item)
 {
-	new->m_class = item->m_class;
-	item->m_class = NULL;
+	strcpy(new->m_class, item->m_class);
 	new->m_addr.s_addr = item->m_addr.s_addr;
 }
 static inline void ip_map_update(struct ip_map *new, struct ip_map *item)
@@ -171,6 +169,8 @@ static int ip_map_parse(struct cache_det
 	/* class */
 	len = qword_get(&mesg, class, 50);
 	if (len <= 0) return -EINVAL;
+	if (len >= sizeof(ipm.m_class))
+		return -EINVAL;
 
 	/* ip address */
 	len = qword_get(&mesg, buf, 50);
@@ -194,9 +194,7 @@ static int ip_map_parse(struct cache_det
 	} else
 		dom = NULL;
 
-	ipm.m_class = strdup(class);
-	if (ipm.m_class == NULL)
-		return -ENOMEM;
+	strcpy(ipm.m_class, class);
 	ipm.m_addr.s_addr =
 		htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
 	ipm.h.flags = 0;
@@ -212,7 +210,6 @@ static int ip_map_parse(struct cache_det
 		ip_map_put(&ipmp->h, &ip_map_cache);
 	if (dom)
 		auth_domain_put(dom);
-	if (ipm.m_class) kfree(ipm.m_class);
 	if (!ipmp)
 		return -ENOMEM;
 	cache_flush();
@@ -272,9 +269,7 @@ int auth_unix_add_addr(struct in_addr ad
 	if (dom->flavour != RPC_AUTH_UNIX)
 		return -EINVAL;
 	udom = container_of(dom, struct unix_domain, h);
-	ip.m_class = strdup("nfsd");
-	if (!ip.m_class)
-		return -ENOMEM;
+	strcpy(ip.m_class, "nfsd");
 	ip.m_addr = addr;
 	ip.m_client = udom;
 	ip.m_add_change = udom->addr_changes+1;
@@ -282,7 +277,7 @@ int auth_unix_add_addr(struct in_addr ad
 	ip.h.expiry_time = NEVER;
 	
 	ipmp = ip_map_lookup(&ip, 1);
-	if (ip.m_class) kfree(ip.m_class);
+
 	if (ipmp) {
 		ip_map_put(&ipmp->h, &ip_map_cache);
 		return 0;
@@ -306,7 +301,7 @@ struct auth_domain *auth_unix_lookup(str
 	struct ip_map key, *ipm;
 	struct auth_domain *rv;
 
-	key.m_class = "nfsd";
+	strcpy(key.m_class, "nfsd");
 	key.m_addr = addr;
 
 	ipm = ip_map_lookup(&key, 0);
@@ -368,7 +363,7 @@ svcauth_null_accept(struct svc_rqst *rqs
 	svc_putu32(resv, RPC_AUTH_NULL);
 	svc_putu32(resv, 0);
 
-	key.m_class = rqstp->rq_server->sv_program->pg_class;
+	strcpy(key.m_class, rqstp->rq_server->sv_program->pg_class);
 	key.m_addr = rqstp->rq_addr.sin_addr;
 
 	ipm = ip_map_lookup(&key, 0);
@@ -464,7 +459,7 @@ svcauth_unix_accept(struct svc_rqst *rqs
 	}
 
 
-	key.m_class = rqstp->rq_server->sv_program->pg_class;
+	strcpy(key.m_class, rqstp->rq_server->sv_program->pg_class);
 	key.m_addr = rqstp->rq_addr.sin_addr;
 
 


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
