From: "William A.(Andy) Adamson" <andros@citi.umich.edu>
Subject: Re: [PATCH kNFSd 4 of 23] Preparation for delegation: client
 callback probe
Date: Fri, 17 Dec 2004 14:01:41 -0500
Message-ID: <20041217190141.3B9D41BB8E@citi.umich.edu>
References: <41C2806D.5050408@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NeilBrown <neilb@cse.unsw.edu.au>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net, andros@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfNMH-0004WP-R8
	for nfs@lists.sourceforge.net; Fri, 17 Dec 2004 11:01:45 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CfNMF-0000XO-P4
	for nfs@lists.sourceforge.net; Fri, 17 Dec 2004 11:01:44 -0800
To: Mike Waychison <Michael.Waychison@Sun.COM>
In-reply-to: Your message of "Fri, 17 Dec 2004 01:45:01 EST."
             <41C2806D.5050408@sun.com>
Sender: nfs-admin@lists.sourceforge.net
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

the NFSv4.0 callback client and server do not use reserved ports. this makes 
the use of delegations through firewalls or to a NAT network fail.  this is 
fixed in the proposed NFSv4.1 minor version 'sessions' feature which allows 
for the use of the NFSv4 reserved port 2049 for callbacks.

-->Andy

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> NeilBrown wrote:
> > client callback rpc to probe the callback
> > channel on setclientid with a null request.
> > 
> ...
> 
> > +/*
> > + * Set up the callback client and put a NFSPROC4_CB_NULL on the wire...
> > + */
> > +void
> > +nfsd4_probe_callback(struct nfs4_client *clp)
> > +{
> > +	struct sockaddr_in	addr;
> > +	struct nfs4_callback    *cb = &clp->cl_callback;
> > +	struct rpc_timeout	timeparms;
> > +	struct rpc_xprt *	xprt;
> > +	struct rpc_program *	program = &cb->cb_program;
> > +	struct rpc_stat *	stat = &cb->cb_stat;
> > +	struct rpc_clnt *	clnt;
> > +	struct rpc_message msg = {
> > +		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
> > +		.rpc_argp       = clp,
> > +	};
> > +	char                    hostname[32];
> > +	int status;
> > +
> > +	dprintk("NFSD: probe_callback. cb_parsed %d cb_set %d\n",
> > +			cb->cb_parsed, atomic_read(&cb->cb_set));
> > +	if (!cb->cb_parsed || atomic_read(&cb->cb_set))
> > +		return;
> > +
> > +	/* Initialize address */
> > +	memset(&addr, 0, sizeof(addr));
> > +	addr.sin_family = AF_INET;
> > +	addr.sin_port = htons(cb->cb_port);
> > +	addr.sin_addr.s_addr = htonl(cb->cb_addr);
> > +
> > +	/* Initialize timeout */
> > +	timeparms.to_initval = (NFSD_LEASE_TIME/4) * HZ;
> > +	timeparms.to_retries = 5;
> > +	timeparms.to_maxval = (NFSD_LEASE_TIME/2) * HZ;
> > +	timeparms.to_exponential = 1;
> > +
> > +	/* Create RPC transport */
> > +	if (!(xprt = xprt_create_proto(IPPROTO_TCP, &addr, &timeparms))) {
> > +		dprintk("NFSD: couldn't create callback transport!\n");
> > +		goto out_err;
> > +	}
> > +
> > +	/* Initialize rpc_program */
> > +	program->name = "nfs4_cb";
> > +	program->number = cb->cb_prog;
> > +	program->nrvers = sizeof(nfs_cb_version)/sizeof(nfs_cb_version[0]);
> > +	program->version = nfs_cb_version;
> > +	program->stats = stat;
> > +
> > +	/* Initialize rpc_stat */
> > +	memset(stat, 0, sizeof(struct rpc_stat));
> > +	stat->program = program;
> > +
> > +	/* Create RPC client
> > + 	 *
> > +	 * XXX AUTH_UNIX only - need AUTH_GSS....
> > +	 */
> > +	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(addr.sin_addr.s_addr));
> > +	if (!(clnt = rpc_create_client(xprt, hostname, program, 1, RPC_AUTH_UNIX))) {
> > +		dprintk("NFSD: couldn't create callback client\n");
> > +		goto out_xprt;
> > +	}
> 
> Out of curiosity, does this have to be a reserved port?
> 
> - --
> Mike Waychison
> Sun Microsystems, Inc.
> 1 (650) 352-5299 voice
> 1 (416) 202-8336 voice
> 
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> NOTICE:  The opinions expressed in this email are held by me,
> and may not represent the views of Sun Microsystems, Inc.
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.2.5 (GNU/Linux)
> Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org
> 
> iD8DBQFBwoBsdQs4kOxk3/MRAgHCAJ4xgWFHL+6IlrslbifbQoCR1RDlQQCeLw8p
> VsUf2XAdv0ihP2qfBOTlp40=
> =1WbB
> -----END PGP SIGNATURE-----
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now. 
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
