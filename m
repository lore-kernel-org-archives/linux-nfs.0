Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53122 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249AbaCEF7s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2014 00:59:48 -0500
Date: Wed, 5 Mar 2014 16:59:33 +1100
From: NeilBrown <neilb@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/8] NFS: prepare for RCU-walk support but pushing tests
 later in code.
Message-ID: <20140305165933.09ca9d84@notabene.brown>
In-Reply-To: <20140305053441.GX18016@ZenIV.linux.org.uk>
References: <20140305025813.27421.23871.stgit@notabene.brown>
	<20140305030028.27421.92032.stgit@notabene.brown>
	<20140305053441.GX18016@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Dw=F0Q9zvHqQhC.OzIyNF8O"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Dw=F0Q9zvHqQhC.OzIyNF8O
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 5 Mar 2014 05:34:41 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Wed, Mar 05, 2014 at 02:00:28PM +1100, NeilBrown wrote:
> > -	parent =3D dget_parent(dentry);
> > +		parent =3D rcu_dereference(dentry->d_parent);
> > +	else
> > +		parent =3D dget_parent(dentry);
> >  	dir =3D parent->d_inode;
> >  	nfs_inc_stats(dir, NFSIOS_DENTRYREVALIDATE);
>=20

Hi Al,
 thanks for the review.

> ... and in RCU mode there's nothing to stop parent from
> 	a) not being dentry->d_parent anymore

Does that matter?  Surely dentry->d_parent exists, is still a dentry, and w=
as
recently the parent to dentry (i.e. since the last grace period).  If it has
changed (which it must if it is no longer our parent), then the cache
validity checks are bound to fail and we will fall back to refcnt-walk as we
should.

> 	b) having already become negative.

I didn't think dentries ever became negative.  When a file is deleted the o=
ld
positive dentry is unlinked and a new negative dentry is created in it's
place.
Or has that changed since last I looked?

If they can become negative, then I could
   dir =3D ACCESS_ONCE(parent->d_inode);
   if (!dir)
        return -ECHILD;

Do you think that would be safe?

Thanks,
NeilBrown


>=20
> NAK.


--Sig_/Dw=F0Q9zvHqQhC.OzIyNF8O
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxa9RTnsnt1WYoG5AQJX5Q//b2CL+39Z3jmbL9nb2JEVSpNRpVrqBt+s
y6GPQBOpis64QMGGwoEqdyYutSMfnNqIEqB7yOqKqHeTjX/PI/9XZxe/mJmGFRBd
c5yEXkCWlvc5SqU1TyJpJRUvYGFx3M63k31lC2/dp6aPH78KcsfdNwJ3e0jkM4al
bBWe1rU7WqCjsrEHwkZ94tTsDcTe0XigZYelrDLBw2x3o6cNV9jZz5NXrBxz4cdT
H+fwqtwKYqJKs+Egap9E+Tk0huZOvzQRqDfbt7PeR6xPUgbHnWxyPm//KSRWXy8J
uy+L4r8zCPcDJGrrvttAYorJ5G5g4bvSngWJ2vKeSC29aJYTy/S5O/P3LjLOqFwW
JqDtf5/a37o7L5yu1T97+IJRhMCLHSR4HuwS4l6lJ20sgkYIb/YjhRVq2/kZNxFB
LLps4GwOFPctZRI64brH8fZrhzZT9xWb7BiyZRTGTH/zATr159A7Gjs8g9KKumSn
Ikvkh7l7y26WPZ4Ka8lvjy4B89P+AZjtHJohE51rN/P6hu35YNs83vivMosL2VkL
bNP4LziyqIs7tiIBAqXY+9BPeCZcpLQjdB8E/Lyrkx5XyFA+0/iNd22ARDUtAN6Q
C61AFKH01iCj2ZG7gQquTcECsYoijwWJ9UbjcSsYdrj/+mCNZt6gX1JHxRSzrXD2
sTXmJfI2s3E=
=/tkY
-----END PGP SIGNATURE-----

--Sig_/Dw=F0Q9zvHqQhC.OzIyNF8O--
