From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Makes nfs mount warning less frequent and more
	valuable
Date: Mon, 21 Mar 2005 12:43:38 -0500
Message-ID: <1111427018.10508.24.camel@lade.trondhjem.org>
References: <4237178A.5030003@dgreaves.com>
	 <Pine.LNX.4.61.0503151439250.22235@guppy.limebrokerage.com>
	 <42384B59.3060408@dgreaves.com>
	 <1111075232.13215.14.camel@lade.trondhjem.org>
	 <Pine.LNX.4.61.0503211051110.5958@guppy.limebrokerage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Greaves <david@dgreaves.com>,
	Neil Brown <neilb@cse.unsw.edu.au>, Erez Zadok <ezk@cs.sunysb.edu>,
	am-utils@fsl.cs.sunysb.edu, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDQwg-0004Es-7v
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 09:44:06 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDQwd-0002jv-H1
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 09:44:06 -0800
To: Ion Badulescu <ionut@badula.org>
In-Reply-To: <Pine.LNX.4.61.0503211051110.5958@guppy.limebrokerage.com>
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

m=E5 den 21.03.2005 Klokka 11:18 (-0500) skreiv Ion Badulescu:
> On Thu, 17 Mar 2005, Trond Myklebust wrote:
>=20
> > I started rethinking this subject last night in between cleanups of the
> > ACL code. Attached is the resulting patch proposal. It goes a lot
> > further that what you do, but should hopefully provide better error
> > reporting in "mount" and clean up some of that code.
> >
> > In particular, note that it attempts to add an error code that tells yo=
u
> > whether or not NFSv3 is actually supported by the kernel: I used
> > EPROTONOSUPPORT, since that gives the correct error message with
> > perror() (although strictly, EPROTONOSUPPORT appears to be a socket
> > error). If anyone has a better suggestion for an error that makes more
> > sense, then I'm all ears...
>=20
> ENOSYS might be an alternative, though personally I have no problem with=20
> EPROTONOSUPPORT. ENOSYS is worse because it's then hard to differentiate=20
> between no NFS support at all and no support for that particular version.

Right. The problem is that ENOSYS is supposed to mean "function not
implemented", but is usually interpreted in userland to mean "syscall
not implemented".

The thing that scared me away from ENOSYS was that "umount" is actually
using it in order to figure out whether or not it can use sys_umount2().

> This is actually very good news for amd, because we've been struggling fo=
r=20
> years to detect (and work around) the case when the kernel version (and=20
> headers) indicate that v3 support would be available on the client side,=20
> but the user doesn't have it compiled in.
>=20
> I think the patch looks good. Just a small problem with one error path:
>=20
> +       s =3D ERR_PTR(-ENOMEM);
>          server =3D kmalloc(sizeof(struct nfs_server), GFP_KERNEL);
>          if (!server)
> -               return ERR_PTR(-ENOMEM);
> +               goto out_err;
> [...]
> +out_err:
> +       kfree(server);
> +       return s;
>=20
> This will call kfree(NULL) if the kmalloc fails. Which may well be fine--=
I=20
> haven't looked at kfree to see if handles that case.

It is safe. kfree() automatically detects NULL pointers.

Cheers,
 Trond
--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
