From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3 of 6] svcrpc: move export table checks to a
 per-program pg_add_client method
Date: Thu, 16 Sep 2004 21:18:39 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095383919.10216.142.camel@lade.trondhjem.org>
References: <1095375544.839c1c96.3@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C87P6-0004hh-Gu
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 18:19:12 -0700
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C87P5-00024V-6O
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 18:19:12 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <1095375544.839c1c96.3@fieldses.org>
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

P=E5 to , 16/09/2004 klokka 19:16, skreiv J. Bruce Fields:

> diff -puN net/sunrpc/svcauth_unix.c~svcrpc_unix_ip_mapping_method net/sun=
rpc/svcauth_unix.c
> --- linux-2.6.9-rc2/net/sunrpc/svcauth_unix.c~svcrpc_unix_ip_mapping_meth=
od	2004-09-16 16:40:53.000000000 -0400
> +++ linux-2.6.9-rc2-bfields/net/sunrpc/svcauth_unix.c	2004-09-16 16:40:53=
.000000000 -0400
> @@ -334,10 +334,6 @@ svcauth_unix_set_client(struct svc_rqst=20
>  {
>  	struct ip_map key, *ipm;
> =20
> -	rqstp->rq_client =3D NULL;
> -	if (rqstp->rq_proc =3D=3D 0)
> -		return SVC_OK;
> -
>  	strcpy(key.m_class, rqstp->rq_server->sv_program->pg_class);
>  	key.m_addr =3D rqstp->rq_addr.sin_addr;
> =20
> @@ -395,7 +391,7 @@ svcauth_null_accept(struct svc_rqst *rqs
>  	if (cred->cr_group_info =3D=3D NULL)
>  		return SVC_DROP; /* kmalloc failure - client must retry */
> =20
> -	rv =3D svcauth_unix_set_client(rqstp);
> +	rv =3D rqstp->rq_server->sv_program->pg_set_client(rqstp);
>  	if (rv =3D=3D SVC_DENIED)
>  		goto badcred;
> =20
> @@ -473,7 +469,7 @@ svcauth_unix_accept(struct svc_rqst *rqs
>  		return SVC_DENIED;
>  	}
> =20
> -	rv =3D svcauth_unix_set_client(rqstp);
> +	rv =3D rqstp->rq_server->sv_program->pg_set_client(rqstp);
>  	if (rv =3D=3D SVC_DENIED)
>  		goto badcred;
> =20

This is rather unclean...

You are making a special method that is really very specific to
svcauth_unix and svcauth_null, yet the pg_set_client() appears as a
generic method in the generic svc_program object.

Firstly, I'd strongly suggest that we call this callback pg_set_domain
so that there is no confusion about what it does.

Secondly, please explain why we're leaving RPCSEC_GSS as a special case
here? Isn't the current implementation also calling up to "rpc.mountd"
in order to check "/etc/exports"? Ideally, all the *_accept() methods
should be calling the same function to set the domain (or not to set it
as the case may be). Better still: could we defer calling
pg_set_domain() until after the call to svc_authenticate?

Finally, please could we move the domain_release() method out of struct
auth_ops and into struct auth_domain itself?

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
