From: Mike Waychison <Michael.Waychison@Sun.COM>
Subject: Re: [PATCH kNFSd 4 of 23] Preparation for delegation: client
 callback probe
Date: Fri, 17 Dec 2004 01:45:01 -0500
Message-ID: <41C2806D.5050408@sun.com>
References: <20041217162128.9968.patches@notabene>
 <E1CfAap-0002dc-GG@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfBrn-00026b-Hn
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 22:45:31 -0800
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CfBrm-0005Fu-HF
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 22:45:31 -0800
Received: from phys-mpk-1 ([129.146.11.81])
	by brmea-mail-4.sun.com (8.12.10/8.12.9) with ESMTP id iBH6jSdv009355
	for <nfs@lists.sourceforge.net>; Thu, 16 Dec 2004 23:45:28 -0700 (MST)
Received: from conversion-daemon.mpk-mail1.sfbay.sun.com by
 mpk-mail1.sfbay.sun.com
 (iPlanet Messaging Server 5.2 HotFix 1.24 (built Dec 19 2003))
 id <0I8U00601SWBJ8@mpk-mail1.sfbay.sun.com>
 (original mail from Michael.Waychison@Sun.COM) for nfs@lists.sourceforge.net;
 Thu, 16 Dec 2004 22:45:28 -0800 (PST)
In-reply-to: <E1CfAap-0002dc-GG@notabene.cse.unsw.edu.au>
To: NeilBrown <neilb@cse.unsw.edu.au>
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

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

NeilBrown wrote:
> client callback rpc to probe the callback
> channel on setclientid with a null request.
> 
...

> +/*
> + * Set up the callback client and put a NFSPROC4_CB_NULL on the wire...
> + */
> +void
> +nfsd4_probe_callback(struct nfs4_client *clp)
> +{
> +	struct sockaddr_in	addr;
> +	struct nfs4_callback    *cb = &clp->cl_callback;
> +	struct rpc_timeout	timeparms;
> +	struct rpc_xprt *	xprt;
> +	struct rpc_program *	program = &cb->cb_program;
> +	struct rpc_stat *	stat = &cb->cb_stat;
> +	struct rpc_clnt *	clnt;
> +	struct rpc_message msg = {
> +		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
> +		.rpc_argp       = clp,
> +	};
> +	char                    hostname[32];
> +	int status;
> +
> +	dprintk("NFSD: probe_callback. cb_parsed %d cb_set %d\n",
> +			cb->cb_parsed, atomic_read(&cb->cb_set));
> +	if (!cb->cb_parsed || atomic_read(&cb->cb_set))
> +		return;
> +
> +	/* Initialize address */
> +	memset(&addr, 0, sizeof(addr));
> +	addr.sin_family = AF_INET;
> +	addr.sin_port = htons(cb->cb_port);
> +	addr.sin_addr.s_addr = htonl(cb->cb_addr);
> +
> +	/* Initialize timeout */
> +	timeparms.to_initval = (NFSD_LEASE_TIME/4) * HZ;
> +	timeparms.to_retries = 5;
> +	timeparms.to_maxval = (NFSD_LEASE_TIME/2) * HZ;
> +	timeparms.to_exponential = 1;
> +
> +	/* Create RPC transport */
> +	if (!(xprt = xprt_create_proto(IPPROTO_TCP, &addr, &timeparms))) {
> +		dprintk("NFSD: couldn't create callback transport!\n");
> +		goto out_err;
> +	}
> +
> +	/* Initialize rpc_program */
> +	program->name = "nfs4_cb";
> +	program->number = cb->cb_prog;
> +	program->nrvers = sizeof(nfs_cb_version)/sizeof(nfs_cb_version[0]);
> +	program->version = nfs_cb_version;
> +	program->stats = stat;
> +
> +	/* Initialize rpc_stat */
> +	memset(stat, 0, sizeof(struct rpc_stat));
> +	stat->program = program;
> +
> +	/* Create RPC client
> + 	 *
> +	 * XXX AUTH_UNIX only - need AUTH_GSS....
> +	 */
> +	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(addr.sin_addr.s_addr));
> +	if (!(clnt = rpc_create_client(xprt, hostname, program, 1, RPC_AUTH_UNIX))) {
> +		dprintk("NFSD: couldn't create callback client\n");
> +		goto out_xprt;
> +	}

Out of curiosity, does this have to be a reserved port?

- --
Mike Waychison
Sun Microsystems, Inc.
1 (650) 352-5299 voice
1 (416) 202-8336 voice

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
NOTICE:  The opinions expressed in this email are held by me,
and may not represent the views of Sun Microsystems, Inc.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBwoBsdQs4kOxk3/MRAgHCAJ4xgWFHL+6IlrslbifbQoCR1RDlQQCeLw8p
VsUf2XAdv0ihP2qfBOTlp40=
=1WbB
-----END PGP SIGNATURE-----


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
