Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44140 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054AbaEMAmG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 May 2014 20:42:06 -0400
Date: Tue, 13 May 2014 10:41:47 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: revalidate on open if dcache is negative.
Message-ID: <20140513104147.144ce93a@notabene.brown>
In-Reply-To: <5C29EB03-6EF6-476C-AD25-97E0A3871C26@primarydata.com>
References: <20140512135019.56e5c465@notabene.brown>
	<5C29EB03-6EF6-476C-AD25-97E0A3871C26@primarydata.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/tSbqJ+i6h_pyBbWi=shMVRh"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/tSbqJ+i6h_pyBbWi=shMVRh
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Mon, 12 May 2014 13:58:59 -0700 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

>=20
> On May 11, 2014, at 20:50, NeilBrown <neilb@suse.de> wrote:
>=20
> >=20
> >=20
> > NFS CTO semantics require that (absent a delegation) the server
> > must be contacted at each open.
> >=20
> > nfs_lookup_verify_inode() implements this when the dcache contains
> > a positive cached entry.  However it is not called when the dcache
> > contains a negative cached entry.  That path uses nfs_neg_need_reval()
> > which doesn't impose CTO semantics.
> >=20
> > So a sequence like:
> >=20
> >   rm -f testfile
> >   ls -l testfile
> >   ssh $server touch testfile
> >   cat testfile
> >=20
> > will fail:
> >=20
> >  cat: testfile: No such file or directory
> >=20
> > an 'strace' will confirm that this resulted from an 'open' system
> > call.
> >=20
> > So add code to nfs_neg_need_reval implement CTO semantics much like
> > that in nfs_lookup_verify_inode().
>=20
> Hi Neil,
>=20
> To me, close-to-open is about ensuring that the data and metadata caches =
for the file (or directory) in question are revalidated correctly on open (=
or opendir). Close-to-open semantics are enabled/disabled by the cto/nocto =
mount options (with cto being the default).
>=20
> The lookup semantics are about ensuring that the namespace cache is consi=
stent with what is on the server. They are controlled by the =E2=80=98looku=
pcache=E2=80=99 mount option, which defaults to the behaviour that you desc=
ribe above (lookupcache=3Dall). I believe that we have discussed changing t=
he default to be lookupcache=3Dpositive, which would give the semantics tha=
t your patch enforces, but I believe the consensus was to keep the current =
behaviour.
>=20

Yes - of course.  Thanks for clarifying that for me.
I had in mind that lookup-for-open is special.  It is, but not that special.

Thanks,
NeilBrown

--Sig_/tSbqJ+i6h_pyBbWi=shMVRh
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU3FqSznsnt1WYoG5AQIBLQ//fUDoSShoQ4M4cLltho+0deZM84biFUGD
Jv1hiHYpg+JsLEhSvgw3vN8hlX3T5x76f4km3Z0vgdHywvXBXVrnBwiY/3oEyeG/
jU+qhpclBXGBQK985kKFtKKsrcF3AK+tATZt+q3qJd26mBcFeOVktZfG7QxtjZMA
duMI2LH4rdvo35iYITokcGYOdMYqgehRvSP4Vjqku37fFCLbbkbePtcf9oIBnbJS
o6DGlANnKleEy7AG4mHZwvmbVKcpW4YgTwlzikAst07uAXUU0YdqXWP+eiklaDID
b/eIvw+BBxAYp55t1hjDnhXSLQDRtMXGv3JHALlTKyQCfUIYjdOlpGDsBGJRXHsJ
vO93Ew7DNodxe+pYI+7kiV50FUh5rTPBjbZxkq3wsv82UJn2W7beiIrHDr+zW+ti
3a58e2yumD7yskGEF4uRgmYLiwQJU+WOUZsB3GCaEuouD7Mt64Zu5keXQx018Dm0
N+Zx7oCnXlVJjFp2zZku5guQ3ELc4RB0zHIKQbqLiLidHZmGU+J5y5h0vEYpkr24
Bb38IAyEKQZFDMMh3W5R1sxoGavP/X+4BsY4DPcXjFbXqKWHsqequLpUZDbWidmM
ljuvewXFKxm9wzG1pOcXmW+L7yq8TVTPnW/F0dUJWxxPDfLFiIYYyftt6BpWgw8f
mW+ey2S2O5I=
=+doO
-----END PGP SIGNATURE-----

--Sig_/tSbqJ+i6h_pyBbWi=shMVRh--
