From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3 of 6] svcrpc: move export table checks to a
 per-program pg_add_client method
Date: Thu, 16 Sep 2004 19:38:51 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095377931.10216.43.camel@lade.trondhjem.org>
References: <1095375544.839c1c96.3@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C85qO-0005TE-0d
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:39:16 -0700
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C85qN-0000uR-Dj
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:39:15 -0700
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

> diff -L fs/nsfd/nfssvc.c -puN /dev/null /dev/null
> diff -puN fs/lockd/svc.c~svcrpc_unix_ip_mapping_method fs/lockd/svc.c
> --- linux-2.6.9-rc2/fs/lockd/svc.c~svcrpc_unix_ip_mapping_method	2004-09-=
16 16:40:53.000000000 -0400
> +++ linux-2.6.9-rc2-bfields/fs/lockd/svc.c	2004-09-16 16:40:53.000000000 =
-0400
> @@ -398,6 +398,16 @@ static int param_set_##name(const char *
>  	return 0;							\
>  }
> =20
> +static int lockd_set_client(struct svc_rqst *rqstp)
> +{
> +	rqstp->rq_client =3D NULL;
> +	if (rqstp->rq_proc =3D=3D 0) /* XXX not quite right. */
> +		return SVC_OK;
> +	else
> +		return svcauth_unix_set_client(rqstp);
> +}
> +

Is svcauth_unix_set_client() actually exported anywhere?

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
