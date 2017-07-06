Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33287 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752582AbdGFSqJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Jul 2017 14:46:09 -0400
Received: by mail-pg0-f52.google.com with SMTP id k14so5137376pgr.0
        for <linux-nfs@vger.kernel.org>; Thu, 06 Jul 2017 11:46:09 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v3 14/14] SUNRPC: add AF_VSOCK support to auth.unix.ip
From: Abbas Naderi <abiusx@google.com>
In-Reply-To: <20170630132352.32133-15-stefanha@redhat.com>
Date: Thu, 6 Jul 2017 11:46:05 -0700
Cc: linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>
Message-Id: <19D7C0EF-17AB-43AD-ADFF-19D1DBC73F37@google.com>
References: <20170630132352.32133-1-stefanha@redhat.com>
 <20170630132352.32133-15-stefanha@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Without CONFIG_SUNRPC_BACKCHANNEL, many things such as =
=E2=80=9Csvc_vsock_bc_class=E2=80=9D are undefined, and then used =
throughout the code.
Most of the =E2=80=9CCONFIG_SUNRPC_XPRT_VSOCK=E2=80=9D guards in =
sunrpc/svcsock.c should also be guarded by CONFIG_SUNRPC_BACKCHANNEL.

-A

> On Jun 30, 2017, at 6:23 AM, Stefan Hajnoczi <stefanha@redhat.com> =
wrote:
>=20
> The ip_map currently supports AF_INET and AF_INET6.  It actually
> converts IPv4 to IPv6 addresses.  We can't do that for AF_VSOCK but a
> union will allow both IPv6 and vsock sockaddr structs to be used.
>=20
> The cache userspace interface now supports 'vsock:CID' syntax for
> AF_VSOCK addresses.
>=20
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
> net/sunrpc/svcauth_unix.c | 146 =
++++++++++++++++++++++++++++++++++++----------
> 1 file changed, 115 insertions(+), 31 deletions(-)
>=20
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index f81eaa8..b33ea0b 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -89,7 +89,15 @@ EXPORT_SYMBOL_GPL(unix_domain_find);
> struct ip_map {
> 	struct cache_head	h;
> 	char			m_class[8]; /* e.g. "nfsd" */
> -	struct in6_addr		m_addr;
> +	union {
> +		struct sockaddr		m_sa;
> +
> +		/* For AF_INET6 and AF_INET (we map to IPv6) */
> +		struct sockaddr_in6	m_sin6;
> +
> +		/* For AF_VSOCK */
> +		struct sockaddr_vm	m_svm;
> +	};
> 	struct unix_domain	*m_client;
> };
>=20
> @@ -112,8 +120,22 @@ static int ip_map_match(struct cache_head *corig, =
struct cache_head *cnew)
> {
> 	struct ip_map *orig =3D container_of(corig, struct ip_map, h);
> 	struct ip_map *new =3D container_of(cnew, struct ip_map, h);
> -	return strcmp(orig->m_class, new->m_class) =3D=3D 0 &&
> -	       ipv6_addr_equal(&orig->m_addr, &new->m_addr);
> +
> +	if (strcmp(orig->m_class, new->m_class) !=3D 0)
> +		return 0;
> +
> +	if (orig->m_sa.sa_family !=3D new->m_sa.sa_family)
> +		return 0;
> +
> +	switch (orig->m_sa.sa_family) {
> +	case AF_INET6:
> +		return ipv6_addr_equal(&orig->m_sin6.sin6_addr,
> +				       &new->m_sin6.sin6_addr);
> +
> +	case AF_VSOCK:
> +		return orig->m_svm.svm_cid =3D=3D new->m_svm.svm_cid;
> +	}
> +	return 0;
> }
> static void ip_map_init(struct cache_head *cnew, struct cache_head =
*citem)
> {
> @@ -121,7 +143,14 @@ static void ip_map_init(struct cache_head *cnew, =
struct cache_head *citem)
> 	struct ip_map *item =3D container_of(citem, struct ip_map, h);
>=20
> 	strcpy(new->m_class, item->m_class);
> -	new->m_addr =3D item->m_addr;
> +	switch (item->m_sa.sa_family) {
> +	case AF_INET6:
> +		new->m_sin6 =3D item->m_sin6;
> +		break;
> +	case AF_VSOCK:
> +		new->m_svm =3D item->m_svm;
> +		break;
> +	}
> }
> static void update(struct cache_head *cnew, struct cache_head *citem)
> {
> @@ -145,19 +174,30 @@ static void ip_map_request(struct cache_detail =
*cd,
> 				  char **bpp, int *blen)
> {
> 	char text_addr[40];
> +	struct in6_addr *addr;
> 	struct ip_map *im =3D container_of(h, struct ip_map, h);
>=20
> -	if (ipv6_addr_v4mapped(&(im->m_addr))) {
> -		snprintf(text_addr, 20, "%pI4", =
&im->m_addr.s6_addr32[3]);
> -	} else {
> -		snprintf(text_addr, 40, "%pI6", &im->m_addr);
> +	switch (im->m_sa.sa_family) {
> +	case AF_INET6:
> +		addr =3D &im->m_sin6.sin6_addr;
> +		if (ipv6_addr_v4mapped(addr)) {
> +			snprintf(text_addr, 20, "%pI4", =
&addr->s6_addr32[3]);
> +		} else {
> +			snprintf(text_addr, 40, "%pI6", addr);
> +		}
> +		break;
> +
> +	case AF_VSOCK:
> +		snprintf(text_addr, 10, "vsock:%u", im->m_svm.svm_cid);
> +		break;
> 	}
> +
> 	qword_add(bpp, blen, im->m_class);
> 	qword_add(bpp, blen, text_addr);
> 	(*bpp)[-1] =3D '\n';
> }
>=20
> -static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char =
*class, struct in6_addr *addr);
> +static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char =
*class, struct sockaddr *sap);
> static int __ip_map_update(struct cache_detail *cd, struct ip_map =
*ipm, struct unix_domain *udom, time_t expiry);
>=20
> static int ip_map_parse(struct cache_detail *cd,
> @@ -173,6 +213,7 @@ static int ip_map_parse(struct cache_detail *cd,
> 		struct sockaddr		sa;
> 		struct sockaddr_in	s4;
> 		struct sockaddr_in6	s6;
> +		struct sockaddr_vm	svm;
> 	} address;
> 	struct sockaddr_in6 sin6;
> 	int err;
> @@ -201,11 +242,15 @@ static int ip_map_parse(struct cache_detail *cd,
> 		sin6.sin6_family =3D AF_INET6;
> 		ipv6_addr_set_v4mapped(address.s4.sin_addr.s_addr,
> 				&sin6.sin6_addr);
> +		address.s6 =3D sin6;
> 		break;
> #if IS_ENABLED(CONFIG_IPV6)
> 	case AF_INET6:
> -		memcpy(&sin6, &address.s6, sizeof(sin6));
> -		break;
> +		break; /* Do nothing */
> +#endif
> +#ifdef CONFIG_SUNRPC_XPRT_VSOCK
> +	case AF_VSOCK:
> +		break; /* Do nothing */
> #endif
> 	default:
> 		return -EINVAL;
> @@ -227,7 +272,7 @@ static int ip_map_parse(struct cache_detail *cd,
> 		dom =3D NULL;
>=20
> 	/* IPv6 scope IDs are ignored for now */
> -	ipmp =3D __ip_map_lookup(cd, class, &sin6.sin6_addr);
> +	ipmp =3D __ip_map_lookup(cd, class, &address.sa);
> 	if (ipmp) {
> 		err =3D __ip_map_update(cd, ipmp,
> 			     container_of(dom, struct unix_domain, h),
> @@ -247,7 +292,7 @@ static int ip_map_show(struct seq_file *m,
> 		       struct cache_head *h)
> {
> 	struct ip_map *im;
> -	struct in6_addr addr;
> +	struct in6_addr *addr;
> 	char *dom =3D "-no-domain-";
>=20
> 	if (h =3D=3D NULL) {
> @@ -256,33 +301,67 @@ static int ip_map_show(struct seq_file *m,
> 	}
> 	im =3D container_of(h, struct ip_map, h);
> 	/* class addr domain */
> -	addr =3D im->m_addr;
> -
> +	addr =3D &im->m_sin6.sin6_addr;
> 	if (test_bit(CACHE_VALID, &h->flags) &&
> 	    !test_bit(CACHE_NEGATIVE, &h->flags))
> 		dom =3D im->m_client->h.name;
>=20
> -	if (ipv6_addr_v4mapped(&addr)) {
> -		seq_printf(m, "%s %pI4 %s\n",
> -			im->m_class, &addr.s6_addr32[3], dom);
> -	} else {
> -		seq_printf(m, "%s %pI6 %s\n", im->m_class, &addr, dom);
> +	switch (im->m_sa.sa_family) {
> +	case AF_INET6:
> +		if (ipv6_addr_v4mapped(addr)) {
> +			seq_printf(m, "%s %pI4 %s\n",
> +				im->m_class,
> +				&addr->s6_addr32[3],
> +				dom);
> +		} else {
> +			seq_printf(m, "%s %pI6 %s\n", im->m_class, addr, =
dom);
> +		}
> +		break;
> +
> +	case AF_VSOCK:
> +		seq_printf(m, "%s %u %s\n",
> +			im->m_class, im->m_svm.svm_cid, dom);
> +		break;
> 	}
> 	return 0;
> }
>=20
> +static int __ip_map_hash(struct ip_map *ipm)
> +{
> +	int hash;
> +
> +	switch (ipm->m_sa.sa_family) {
> +	case AF_INET6:
> +		hash =3D hash_ip6(&ipm->m_sin6.sin6_addr);
> +		break;
> +	case AF_VSOCK:
> +		hash =3D hash_32(ipm->m_svm.svm_cid, IP_HASHBITS);
> +		break;
> +	default:
> +		BUG();
> +	}
> +
> +	return hash_str(ipm->m_class, IP_HASHBITS) ^ hash;
> +}
>=20
> static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char =
*class,
> -		struct in6_addr *addr)
> +		struct sockaddr *sap)
> {
> 	struct ip_map ip;
> 	struct cache_head *ch;
>=20
> 	strcpy(ip.m_class, class);
> -	ip.m_addr =3D *addr;
> -	ch =3D sunrpc_cache_lookup(cd, &ip.h,
> -				 hash_str(class, IP_HASHBITS) ^
> -				 hash_ip6(addr));
> +	switch (sap->sa_family) {
> +	case AF_INET6:
> +		ip.m_sin6 =3D *(struct sockaddr_in6 *)sap;
> +		break;
> +	case AF_VSOCK:
> +		ip.m_svm =3D *(struct sockaddr_vm *)sap;
> +		break;
> +	default:
> +		return NULL;
> +	}
> +	ch =3D sunrpc_cache_lookup(cd, &ip.h, __ip_map_hash(&ip));
>=20
> 	if (ch)
> 		return container_of(ch, struct ip_map, h);
> @@ -291,12 +370,12 @@ static struct ip_map *__ip_map_lookup(struct =
cache_detail *cd, char *class,
> }
>=20
> static inline struct ip_map *ip_map_lookup(struct net *net, char =
*class,
> -		struct in6_addr *addr)
> +		struct sockaddr *sap)
> {
> 	struct sunrpc_net *sn;
>=20
> 	sn =3D net_generic(net, sunrpc_net_id);
> -	return __ip_map_lookup(sn->ip_map_cache, class, addr);
> +	return __ip_map_lookup(sn->ip_map_cache, class, sap);
> }
>=20
> static int __ip_map_update(struct cache_detail *cd, struct ip_map =
*ipm,
> @@ -311,8 +390,7 @@ static int __ip_map_update(struct cache_detail =
*cd, struct ip_map *ipm,
> 		set_bit(CACHE_NEGATIVE, &ip.h.flags);
> 	ip.h.expiry_time =3D expiry;
> 	ch =3D sunrpc_cache_update(cd, &ip.h, &ipm->h,
> -				 hash_str(ipm->m_class, IP_HASHBITS) ^
> -				 hash_ip6(&ipm->m_addr));
> +				 __ip_map_hash(ipm));
> 	if (!ch)
> 		return -ENOMEM;
> 	cache_put(ch, cd);
> @@ -654,6 +732,7 @@ static struct group_info *unix_gid_find(kuid_t =
uid, struct svc_rqst *rqstp)
> int
> svcauth_unix_set_client(struct svc_rqst *rqstp)
> {
> +	struct sockaddr *sap;
> 	struct sockaddr_in *sin;
> 	struct sockaddr_in6 *sin6, sin6_storage;
> 	struct ip_map *ipm;
> @@ -667,10 +746,15 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
> 	case AF_INET:
> 		sin =3D svc_addr_in(rqstp);
> 		sin6 =3D &sin6_storage;
> +		sin6->sin6_family =3D AF_INET6;
> 		ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, =
&sin6->sin6_addr);
> +		sap =3D (struct sockaddr *)sin6;
> 		break;
> 	case AF_INET6:
> -		sin6 =3D svc_addr_in6(rqstp);
> +		sap =3D svc_addr(rqstp);
> +		break;
> +	case AF_VSOCK:
> +		sap =3D svc_addr(rqstp);
> 		break;
> 	default:
> 		BUG();
> @@ -683,7 +767,7 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
> 	ipm =3D ip_map_cached_get(xprt);
> 	if (ipm =3D=3D NULL)
> 		ipm =3D __ip_map_lookup(sn->ip_map_cache, =
rqstp->rq_server->sv_program->pg_class,
> -				    &sin6->sin6_addr);
> +				    sap);
>=20
> 	if (ipm =3D=3D NULL)
> 		return SVC_DENIED;
> --=20
> 2.9.4
>=20

