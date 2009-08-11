From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/4] nfsd: make nfs4_client->cl_addr a struct
	sockaddr_storage
Date: Tue, 11 Aug 2009 07:02:20 -0400
Message-ID: <20090811070220.207dde6d@tlielax.poochiereds.net>
References: <1249942157-12613-1-git-send-email-jlayton@redhat.com>
	<1249942157-12613-3-git-send-email-jlayton@redhat.com>
	<D56220C9-E887-4EA6-95E8-31B7C3B5B1DA@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <D56220C9-E887-4EA6-95E8-31B7C3B5B1DA@oracle.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 10 Aug 2009 18:53:56 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> On Aug 10, 2009, at 6:09 PM, Jeff Layton wrote:
> > It's currently a __be32, which isn't big enough to hold an IPv6  
> > address.
> > While we're at it, add some new routines for comparing and copying
> > cl_addr's.
> >
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > fs/nfsd/nfs4state.c        |   70 ++++++++++++++++++++++++++++++++++ 
> > +--------
> > include/linux/nfsd/state.h |    2 +-
> > 2 files changed, 58 insertions(+), 14 deletions(-)
> >
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 95e2185..cbc1a05 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -1216,6 +1216,45 @@ nfsd4_set_ex_flags(struct nfs4_client *new,  
> > struct nfsd4_exchange_id *clid)
> > 	clid->flags = new->cl_exchange_flags;
> > }
> >
> > +/* Returns true if addresses are equal (ignoring port, scope, etc) */
> > +static bool
> > +cl_addr_equal(struct sockaddr *a, struct sockaddr *b)
> > +{
> > +	struct sockaddr_in *a4, *b4;
> > +
> > +	if (a->sa_family != b->sa_family)
> > +		return false;
> > +
> > +	switch (a->sa_family) {
> > +	case AF_INET:
> > +		a4 = (struct sockaddr_in *) a;
> > +		b4 = (struct sockaddr_in *) b;
> > +		return (a4->sin_addr.s_addr == b4->sin_addr.s_addr);
> > +	}
> > +
> > +	/* not sure how to compare, so just return false */
> > +	return false;
> > +}
> 
> lockd has a similar requirement, iirc.  I wonder if it makes sense to  
> add this functionality instead as a generic routine in include/linux/ 
> sunrpc/clnt.h alongside rpc_{get,set}_port.
> 
> Also, I wonder if we need to compile out the IPv6-related code  
> throughout if CONFIG_IPV6 is not set...?  Glancing around, I don't see  
> any strong dependency on CONFIG_IPV6, but we may want to reduce the  
> resulting object size in that case.  Did you happen to try a kernel  
> build test with CONFIG_IPV6 disabled?
> 

Yeah lockd does have similar routines for this. I'll see about adding a
common set of routines, probably more closely based on the lockd ones
since they wrap the IPv6 parts in CONFIG_IPV6, and convert lockd to use
those too.

> > +
> > +/* Given a sockaddr, fill in the cl_addr -- ignore port, scope, etc  
> > */
> 
> It's probably worth mentioning somewhere (patch description and/or  
> block comment) that this IPv6 support does not include link local  
> support.  It's obvious to those of us who work closely with this code,  
> but others may assume IPv6 support means link local works too.
> 
> Otherwise, I'm pretty sure you can just copy the scope ID of the  
> destination address (the server's receiving address) for the  
> SETCLIENTID RPC in order to get the right scope ID for callbacks, in  
> which case no extra comment is needed.
> 

Yeah, that's doable. I'll add that to the next respin.

> > +static void
> > +cl_addr_copy(struct sockaddr *dst, struct sockaddr *src)
> > +{
> > +	struct sockaddr_in *s4, *d4;
> > +
> > +	dst->sa_family = src->sa_family;
> > +
> > +	switch (dst->sa_family) {
> > +	case AF_INET:
> > +		s4 = (struct sockaddr_in *) src;
> > +		d4 = (struct sockaddr_in *) dst;
> > +		d4->sin_addr.s_addr = s4->sin_addr.s_addr;
> > +		return;
> > +	default:
> > +		dst->sa_family = AF_UNSPEC;
> > +	}
> > +}
> 
> This is probably also useful functionality to make generic.  I seem to  
> recall both lockd and the client need this kind of address copy  
> function.
> 

Ok, I'll look into that too.

> > +
> > __be32
> > nfsd4_exchange_id(struct svc_rqst *rqstp,
> > 		  struct nfsd4_compound_state *cstate,
> > @@ -1225,13 +1264,15 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
> > 	int status;
> > 	unsigned int		strhashval;
> > 	char			dname[HEXDIR_LEN];
> > +	char			addr_str[INET_ADDRSTRLEN];
> > 	nfs4_verifier		verf = exid->verifier;
> > -	u32			ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
> > +	struct sockaddr		*sa = svc_addr(rqstp);
> >
> > +	rpc_ntop(sa, addr_str, sizeof(addr_str));
> > 	dprintk("%s rqstp=%p exid=%p clname.len=%u clname.data=%p "
> > -		" ip_addr=%u flags %x, spa_how %d\n",
> > +		"ip_addr=%s flags %x, spa_how %d\n",
> > 		__func__, rqstp, exid, exid->clname.len, exid->clname.data,
> > -		ip_addr, exid->flags, exid->spa_how);
> > +		addr_str, exid->flags, exid->spa_how);
> >
> > 	if (!check_name(exid->clname) || (exid->flags &  
> > ~EXCHGID4_FLAG_MASK_A))
> > 		return nfserr_inval;
> > @@ -1320,7 +1361,7 @@ out_new:
> >
> > 	copy_verf(new, &verf);
> > 	copy_cred(&new->cl_cred, &rqstp->rq_cred);
> > -	new->cl_addr = ip_addr;
> > +	cl_addr_copy((struct sockaddr *) &new->cl_addr, sa);
> > 	gen_clid(new);
> > 	gen_confirm(new);
> > 	add_to_unconfirmed(new, strhashval);
> > @@ -1394,7 +1435,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
> > 		     struct nfsd4_compound_state *cstate,
> > 		     struct nfsd4_create_session *cr_ses)
> > {
> > -	u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
> > +	struct sockaddr *sa = svc_addr(rqstp);
> > 	struct nfs4_client *conf, *unconf;
> > 	struct nfsd4_clid_slot *cs_slot = NULL;
> > 	int status = 0;
> > @@ -1422,7 +1463,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
> > 		cs_slot->sl_seqid++;
> > 	} else if (unconf) {
> > 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
> > -		    (ip_addr != unconf->cl_addr)) {
> > +		    !cl_addr_equal(sa, (struct sockaddr *) &unconf->cl_addr)) {
> > 			status = nfserr_clid_inuse;
> > 			goto out;
> > 		}
> > @@ -1569,7 +1610,7 @@ __be32
> > nfsd4_setclientid(struct svc_rqst *rqstp, struct  
> > nfsd4_compound_state *cstate,
> > 		  struct nfsd4_setclientid *setclid)
> > {
> > -	struct sockaddr_in	*sin = svc_addr_in(rqstp);
> > +	struct sockaddr		*sa = svc_addr(rqstp);
> > 	struct xdr_netobj 	clname = {
> > 		.len = setclid->se_namelen,
> > 		.data = setclid->se_name,
> > @@ -1601,8 +1642,11 @@ nfsd4_setclientid(struct svc_rqst *rqstp,  
> > struct nfsd4_compound_state *cstate,
> > 		/* RFC 3530 14.2.33 CASE 0: */
> > 		status = nfserr_clid_inuse;
> > 		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)) {
> > -			dprintk("NFSD: setclientid: string in use by client"
> > -				" at %pI4\n", &conf->cl_addr);
> > +			char addr_str[INET_ADDRSTRLEN];
> 
> Nit:  It's kind of odd that you are taking pains to switch from  
> svc_addr_in() to svc_addr() and use sockaddr_storage and so on, but  
> then right here you add a buffer that is only big enough for an IPv4  
> address.  I know you bump its size in a subsequent patch, but it might  
> be more consistent if you made this buffer larger right when you  
> introduce it.
> 

Simple enough to change. Maybe I'll even make the size switchable based
on CONFIG_IPV6 setting...

> > +			rpc_ntop((struct sockaddr *) &conf->cl_addr, addr_str,
> > +				 sizeof(addr_str));
> > +			dprintk("NFSD: setclientid: string in use by client "
> > +				"at %s\n", addr_str);
> > 			goto out;
> > 		}
> > 	}
> > @@ -1664,7 +1708,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp,  
> > struct nfsd4_compound_state *cstate,
> > 		gen_clid(new);
> > 	}
> > 	copy_verf(new, &clverifier);
> > -	new->cl_addr = sin->sin_addr.s_addr;
> > +	cl_addr_copy((struct sockaddr *) &new->cl_addr, sa);
> > 	new->cl_flavor = rqstp->rq_flavor;
> > 	princ = svc_gss_principal(rqstp);
> > 	if (princ) {
> > @@ -1698,7 +1742,7 @@ nfsd4_setclientid_confirm(struct svc_rqst  
> > *rqstp,
> > 			 struct nfsd4_compound_state *cstate,
> > 			 struct nfsd4_setclientid_confirm *setclientid_confirm)
> > {
> > -	struct sockaddr_in *sin = svc_addr_in(rqstp);
> > +	struct sockaddr *sa = svc_addr(rqstp);
> > 	struct nfs4_client *conf, *unconf;
> > 	nfs4_verifier confirm = setclientid_confirm->sc_confirm;
> > 	clientid_t * clid = &setclientid_confirm->sc_clientid;
> > @@ -1717,9 +1761,9 @@ nfsd4_setclientid_confirm(struct svc_rqst  
> > *rqstp,
> > 	unconf = find_unconfirmed_client(clid);
> >
> > 	status = nfserr_clid_inuse;
> > -	if (conf && conf->cl_addr != sin->sin_addr.s_addr)
> > +	if (conf && !cl_addr_equal((struct sockaddr *) &conf->cl_addr, sa))
> > 		goto out;
> > -	if (unconf && unconf->cl_addr != sin->sin_addr.s_addr)
> > +	if (unconf && !cl_addr_equal((struct sockaddr *) &unconf->cl_addr,  
> > sa))
> > 		goto out;
> >
> > 	/*
> > diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> > index d866368..fb0c404 100644
> > --- a/include/linux/nfsd/state.h
> > +++ b/include/linux/nfsd/state.h
> > @@ -200,7 +200,7 @@ struct nfs4_client {
> > 	char                    cl_recdir[HEXDIR_LEN]; /* recovery dir */
> > 	nfs4_verifier		cl_verifier; 	/* generated by client */
> > 	time_t                  cl_time;        /* time of last lease  
> > renewal */
> > -	__be32			cl_addr; 	/* client ipaddress */
> > +	struct sockaddr_storage	cl_addr; 	/* client ipaddress */
> > 	u32			cl_flavor;	/* setclientid pseudoflavor */
> > 	char			*cl_principal;	/* setclientid principal name */
> > 	struct svc_cred		cl_cred; 	/* setclientid principal */
> 

Thanks for the comments so far!

-- 
Jeff Layton <jlayton@redhat.com>
