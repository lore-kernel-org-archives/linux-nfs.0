From: Mike Waychison <Michael.Waychison@Sun.COM>
Subject: Re: [PATCH kNFSd 4 of 23] Preparation for delegation: client
 callback probe
Date: Tue, 21 Dec 2004 10:56:29 -0500
Message-ID: <41C847AD.5040408@sun.com>
References: <20041217190141.3B9D41BB8E@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NeilBrown <neilb@cse.unsw.edu.au>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CgmNK-0001K3-6d
	for nfs@lists.sourceforge.net; Tue, 21 Dec 2004 07:56:38 -0800
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CgmNG-00069I-R3
	for nfs@lists.sourceforge.net; Tue, 21 Dec 2004 07:56:38 -0800
Received: from phys-mpk-1 ([129.146.11.81])
	by brmea-mail-4.sun.com (8.12.10/8.12.9) with ESMTP id iBLFuWdx015216
	for <nfs@lists.sourceforge.net>; Tue, 21 Dec 2004 08:56:33 -0700 (MST)
Received: from conversion-daemon.mpk-mail1.sfbay.sun.com by
 mpk-mail1.sfbay.sun.com
 (iPlanet Messaging Server 5.2 HotFix 1.24 (built Dec 19 2003))
 id <0I9200C01XBHX6@mpk-mail1.sfbay.sun.com>
 (original mail from Michael.Waychison@Sun.COM) for nfs@lists.sourceforge.net;
 Tue, 21 Dec 2004 07:56:32 -0800 (PST)
In-reply-to: <20041217190141.3B9D41BB8E@citi.umich.edu>
To: "William A.(Andy) Adamson" <andros@citi.umich.edu>
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

William A.(Andy) Adamson wrote:
> the NFSv4.0 callback client and server do not use reserved ports. this makes 
> the use of delegations through firewalls or to a NAT network fail.  this is 
> fixed in the proposed NFSv4.1 minor version 'sessions' feature which allows 
> for the use of the NFSv4 reserved port 2049 for callbacks.
> 

Hmm, in that case, we might want to modify the xprt_create_proto call
somehow to reflect that we don't need a port < XPRT_MAX_RESVPORT(800),
which would limit the number of clients possible.

I'd patch something up, but I'm not sure where that stands with the
transport switch work.

> -->Andy
> 
> 
> NeilBrown wrote:
> 
>>client callback rpc to probe the callback
>>channel on setclientid with a null request.
> 
> 
> ...
> 
> 
>>+/*
>>+ * Set up the callback client and put a NFSPROC4_CB_NULL on the wire...
>>+ */
>>+void
>>+nfsd4_probe_callback(struct nfs4_client *clp)
>>+{
>>+	struct sockaddr_in	addr;
>>+	struct nfs4_callback    *cb = &clp->cl_callback;
>>+	struct rpc_timeout	timeparms;
>>+	struct rpc_xprt *	xprt;
>>+	struct rpc_program *	program = &cb->cb_program;
>>+	struct rpc_stat *	stat = &cb->cb_stat;
>>+	struct rpc_clnt *	clnt;
>>+	struct rpc_message msg = {
>>+		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
>>+		.rpc_argp       = clp,
>>+	};
>>+	char                    hostname[32];
>>+	int status;
>>+
>>+	dprintk("NFSD: probe_callback. cb_parsed %d cb_set %d\n",
>>+			cb->cb_parsed, atomic_read(&cb->cb_set));
>>+	if (!cb->cb_parsed || atomic_read(&cb->cb_set))
>>+		return;
>>+
>>+	/* Initialize address */
>>+	memset(&addr, 0, sizeof(addr));
>>+	addr.sin_family = AF_INET;
>>+	addr.sin_port = htons(cb->cb_port);
>>+	addr.sin_addr.s_addr = htonl(cb->cb_addr);
>>+
>>+	/* Initialize timeout */
>>+	timeparms.to_initval = (NFSD_LEASE_TIME/4) * HZ;
>>+	timeparms.to_retries = 5;
>>+	timeparms.to_maxval = (NFSD_LEASE_TIME/2) * HZ;
>>+	timeparms.to_exponential = 1;
>>+
>>+	/* Create RPC transport */
>>+	if (!(xprt = xprt_create_proto(IPPROTO_TCP, &addr, &timeparms))) {
>>+		dprintk("NFSD: couldn't create callback transport!\n");
>>+		goto out_err;
>>+	}
>>+
>>+	/* Initialize rpc_program */
>>+	program->name = "nfs4_cb";
>>+	program->number = cb->cb_prog;
>>+	program->nrvers = sizeof(nfs_cb_version)/sizeof(nfs_cb_version[0]);
>>+	program->version = nfs_cb_version;
>>+	program->stats = stat;
>>+
>>+	/* Initialize rpc_stat */
>>+	memset(stat, 0, sizeof(struct rpc_stat));
>>+	stat->program = program;
>>+
>>+	/* Create RPC client
>>+ 	 *
>>+	 * XXX AUTH_UNIX only - need AUTH_GSS....
>>+	 */
>>+	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(addr.sin_addr.s_addr));
>>+	if (!(clnt = rpc_create_client(xprt, hostname, program, 1, RPC_AUTH_UNIX))) {
>>+		dprintk("NFSD: couldn't create callback client\n");
>>+		goto out_xprt;
>>+	}
> 
> Out of curiosity, does this have to be a reserved port?
> 
> --
> Mike Waychison
> Sun Microsystems, Inc.
> 1 (650) 352-5299 voice
> 1 (416) 202-8336 voice
> 
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> NOTICE:  The opinions expressed in this email are held by me,
> and may not represent the views of Sun Microsystems, Inc.
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- -------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs






> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now. 
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


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

iD8DBQFByEesdQs4kOxk3/MRAsV8AJ0eCtRfyWJDnVcy4k69SUcAY9k+iACfSG8G
Yk40NgRI+AYl95FIawFi0kY=
=+6b9
-----END PGP SIGNATURE-----


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
