From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH kNFSd 4 of 23] Preparation for delegation: client callback probe
Date: Tue, 21 Dec 2004 08:12:35 -0800
Message-ID: <482A3FA0050D21419C269D13989C611307CF4BA1@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "NeilBrown" <neilb@cse.unsw.edu.au>,
	"Andrew Morton" <akpm@osdl.org>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cgmcu-0002U4-RW
	for nfs@lists.sourceforge.net; Tue, 21 Dec 2004 08:12:44 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cgmcs-0000AA-0U
	for nfs@lists.sourceforge.net; Tue, 21 Dec 2004 08:12:44 -0800
To: "Mike Waychison" <Michael.Waychison@Sun.COM>,
	"William A.(Andy) Adamson" <andros@citi.umich.edu>
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

mike-

the latest client side transport switch patches are here:

  http://troy.citi.umich.edu/~cel/linux-2.6/2.6.9-a/release-notes.html

for your review.  i don't think these are going in any time soon.

we need some time to consider the port number issues.  can the patch
with the borg designation 4 of 23 go in without the port number change
you suggested?


> -----Original Message-----
> From: Mike Waychison [mailto:Michael.Waychison@Sun.COM]=20
> Sent: Tuesday, December 21, 2004 10:56 AM
> To: William A.(Andy) Adamson
> Cc: NeilBrown; Andrew Morton; nfs@lists.sourceforge.net
> Subject: Re: [NFS] [PATCH kNFSd 4 of 23] Preparation for=20
> delegation: client callback probe
>=20
>=20
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> William A.(Andy) Adamson wrote:
> > the NFSv4.0 callback client and server do not use reserved=20
> ports. this=20
> > makes
> > the use of delegations through firewalls or to a NAT=20
> network fail.  this is=20
> > fixed in the proposed NFSv4.1 minor version 'sessions'=20
> feature which allows=20
> > for the use of the NFSv4 reserved port 2049 for callbacks.
> >=20
>=20
> Hmm, in that case, we might want to modify the=20
> xprt_create_proto call somehow to reflect that we don't need=20
> a port < XPRT_MAX_RESVPORT(800), which would limit the number=20
> of clients possible.
>=20
> I'd patch something up, but I'm not sure where that stands=20
> with the transport switch work.
>=20
> > -->Andy
> >=20
> >=20
> > NeilBrown wrote:
> >=20
> >>client callback rpc to probe the callback
> >>channel on setclientid with a null request.
> >=20
> >=20
> > ...
> >=20
> >=20
> >>+/*
> >>+ * Set up the callback client and put a NFSPROC4_CB_NULL on the=20
> >>+wire...  */ void
> >>+nfsd4_probe_callback(struct nfs4_client *clp)
> >>+{
> >>+	struct sockaddr_in	addr;
> >>+	struct nfs4_callback    *cb =3D &clp->cl_callback;
> >>+	struct rpc_timeout	timeparms;
> >>+	struct rpc_xprt *	xprt;
> >>+	struct rpc_program *	program =3D &cb->cb_program;
> >>+	struct rpc_stat *	stat =3D &cb->cb_stat;
> >>+	struct rpc_clnt *	clnt;
> >>+	struct rpc_message msg =3D {
> >>+		.rpc_proc       =3D=20
> &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
> >>+		.rpc_argp       =3D clp,
> >>+	};
> >>+	char                    hostname[32];
> >>+	int status;
> >>+
> >>+	dprintk("NFSD: probe_callback. cb_parsed %d cb_set %d\n",
> >>+			cb->cb_parsed, atomic_read(&cb->cb_set));
> >>+	if (!cb->cb_parsed || atomic_read(&cb->cb_set))
> >>+		return;
> >>+
> >>+	/* Initialize address */
> >>+	memset(&addr, 0, sizeof(addr));
> >>+	addr.sin_family =3D AF_INET;
> >>+	addr.sin_port =3D htons(cb->cb_port);
> >>+	addr.sin_addr.s_addr =3D htonl(cb->cb_addr);
> >>+
> >>+	/* Initialize timeout */
> >>+	timeparms.to_initval =3D (NFSD_LEASE_TIME/4) * HZ;
> >>+	timeparms.to_retries =3D 5;
> >>+	timeparms.to_maxval =3D (NFSD_LEASE_TIME/2) * HZ;
> >>+	timeparms.to_exponential =3D 1;
> >>+
> >>+	/* Create RPC transport */
> >>+	if (!(xprt =3D xprt_create_proto(IPPROTO_TCP, &addr,=20
> &timeparms))) {
> >>+		dprintk("NFSD: couldn't create callback transport!\n");
> >>+		goto out_err;
> >>+	}
> >>+
> >>+	/* Initialize rpc_program */
> >>+	program->name =3D "nfs4_cb";
> >>+	program->number =3D cb->cb_prog;
> >>+	program->nrvers =3D=20
> sizeof(nfs_cb_version)/sizeof(nfs_cb_version[0]);
> >>+	program->version =3D nfs_cb_version;
> >>+	program->stats =3D stat;
> >>+
> >>+	/* Initialize rpc_stat */
> >>+	memset(stat, 0, sizeof(struct rpc_stat));
> >>+	stat->program =3D program;
> >>+
> >>+	/* Create RPC client
> >>+ 	 *
> >>+	 * XXX AUTH_UNIX only - need AUTH_GSS....
> >>+	 */
> >>+	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(addr.sin_addr.s_addr));
> >>+	if (!(clnt =3D rpc_create_client(xprt, hostname, program,=20
> 1, RPC_AUTH_UNIX))) {
> >>+		dprintk("NFSD: couldn't create callback client\n");
> >>+		goto out_xprt;
> >>+	}
> >=20
> > Out of curiosity, does this have to be a reserved port?
> >=20
> > --
> > Mike Waychison
> > Sun Microsystems, Inc.
> > 1 (650) 352-5299 voice
> > 1 (416) 202-8336 voice
> >=20
> > ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > NOTICE:  The opinions expressed in this email are held by=20
> me, and may=20
> > not represent the views of Sun Microsystems, Inc.=20
> > ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>=20
> - -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from=20
> real users. Discover which products truly live up to the=20
> hype. Start reading now. http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net=20
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20
>=20
>=20
>=20
>=20
>=20
> > -------------------------------------------------------
> > SF email is sponsored by - The IT Product Guide
> > Read honest & candid reviews on hundreds of IT Products from real=20
> > users. Discover which products truly live up to the hype. Start=20
> > reading now. http://productguide.itmanagersjournal.com/
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net=20
> > https://lists.sourceforge.net/lists/listinfo/nfs
>=20
>=20
> - --
> Mike Waychison
> Sun Microsystems, Inc.
> 1 (650) 352-5299 voice
> 1 (416) 202-8336 voice
>=20
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> NOTICE:  The opinions expressed in this email are held by me,=20
> and may not represent the views of Sun Microsystems, Inc.=20
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.2.5 (GNU/Linux)
> Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org
>=20
> iD8DBQFByEesdQs4kOxk3/MRAsV8AJ0eCtRfyWJDnVcy4k69SUcAY9k+iACfSG8G
> Yk40NgRI+AYl95FIawFi0kY=3D
> =3D+6b9
> -----END PGP SIGNATURE-----
>=20
>=20
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from=20
> real users. Discover which products truly live up to the=20
> hype. Start reading now.=20
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net=20
> https://lists.sourceforge.net/lists/listinfo/n> fs
>=20


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
