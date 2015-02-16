Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42518 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752541AbbBPEyi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 15 Feb 2015 23:54:38 -0500
Date: Mon, 16 Feb 2015 15:54:29 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Nix <nix@esperi.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn
 into "(unreachable)"
Message-ID: <20150216155429.46cfbab7@notabene.brown>
In-Reply-To: <CAHQdGtRZP2wYeLozY5pzrD-GALKqV8g1tjV2orotZuTcug2v3A@mail.gmail.com>
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix>
	<87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
	<20150210183200.GB11226@fieldses.org>
	<87vbj4ljjn.fsf@spindle.srvr.nix>
	<20150216134628.773e3347@notabene.brown>
	<CAHQdGtRZP2wYeLozY5pzrD-GALKqV8g1tjV2orotZuTcug2v3A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/jrb96COavIqWO+7C5sYoKBV"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/jrb96COavIqWO+7C5sYoKBV
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 15 Feb 2015 23:28:12 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Sun, Feb 15, 2015 at 9:46 PM, NeilBrown <neilb@suse.de> wrote:
> > On Sat, 14 Feb 2015 13:17:00 +0000 Nix <nix@esperi.org.uk> wrote:
> >
> >> On 10 Feb 2015, J. Bruce Fields outgrape:
> >>
> >> > It might be interesting to see output from
> >> >
> >> >     rpc.debug -m rpc -s cache
> >> >     cat /proc/net/rpc/nfsd.export/content
> >> >     cat /proc/net/rpc/nfsd.fh/content
> >> >
> >> > especially after the problem manifests.
> >>
> >> So the mount has vanished again. I couldn't make it happen with
> >> nordirplus in the mount options, so that might provide you with a clue.
> >
> > Yup.  It does.
> >
> > There is definitely something wrong in nfs_prime_dcache.  I cannot quite
> > trace through from cause to effect, but maybe I don't need to.
> >
> > Can you try the following patch and see if that makes the problem disap=
pear?
> >
> > When you perform a READDIRPLUS request on a directory that contains
> > mountpoints, the the Linux NFS server doesn't return a file-handle for
> > those names which are mountpoints (because doing so is a bit tricky).
> >
> > nfs3_decode_dirent notices and decodes as a filehandle with zero length.
> >
> > The "nfs_same_file()" check in nfs_prime_dcache() determines that isn't
> > the same as the filehandle it has, and tries to invalidate it and make =
a new
> > one.
> >
> > The invalidation should fail (probably does).
> > The creating of a new one ... might succeed.  Beyond that, it all gets =
a bit
> > hazy.
> >
> > Anyway, please try:
> >
> > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > index 9b0c55cb2a2e..a460669dc395 100644
> > --- a/fs/nfs/dir.c
> > +++ b/fs/nfs/dir.c
> > @@ -541,7 +541,7 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_=
t *desc, struct nfs_entry *en
> >
> >                 count++;
> >
> > -               if (desc->plus !=3D 0)
> > +               if (desc->plus !=3D 0 && entry->fh.size)
> >                         nfs_prime_dcache(desc->file->f_path.dentry, ent=
ry);
> >
> >                 status =3D nfs_readdir_add_to_array(entry, page);
> >
> >
> > which you might have to apply by hand.
>=20
> Doesn't that check ultimately belong in nfs_fget()? It would seem to
> apply to all filehandles, irrespective of provenance.
>=20

Maybe.  Though I think it also needs to be before nfs_prime_dcache() tries =
to
valid the dentry it found.
e.g.

 if (dentry !=3D NULL) {
    if (entry->fh->size =3D=3D 0)
       goto out;
    else if (nfs_same_file(..)) {
	....
    else {
        d_invalidate();
        ...
    }
  }

??

I'd really like to understand what is actually happening though.
d_invalidate() shouldn't effect an unmount.

Maybe the dentry that gets mounted on is the one with the all-zero fh...

NeilBrown


--Sig_/jrb96COavIqWO+7C5sYoKBV
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOF4BTnsnt1WYoG5AQIrJQ/8CkC+ebz2kgynlFBLmZKvnmL2lt2t54kM
L+4REuQSXuce/afAv+ZZqh93WO3rwHWkh238uHTwZGtCy4JEdeDROgI/8fPibsed
u7CKaIO6SBUURwhIYZHrplEf37HiJI+gSv4UP5zRAvbMl6JTxWmynhKNM/sDzivI
S4VWtCFhwKCOc2luol6mQscJToSOqvhMOpRG1i1wVo6mWp8JV3oFXb/GUvttV64m
4NXgBGi7shz7mJqOWoWsmTG7ZMcmuy7xs80nohoHDdEzThBCfYWDwclvqqTMshck
deRDg1/lBNoeVuWIfSMrHeLOT3A06RPqu7GNQ9uNfc9Uw/IKS1ROpTaazCzMJZbv
db1Lf6kBBfETyEy3JjUCP/H1I7dGzaB65qt5lW+fqqyTR2VaF0maDcKUK9nYtSTd
W/DneEfM5Kzmi3dcloTOHj76Ou/fdrgclyT2Y62ReTuqyzuzYfLQseXJSDS95EUI
IxaoBxlreNBUeigmMX/BFTyJAhFJVgYcgHW1A3thIQQ3vy7h7A2gVEO6GEwJ4CC8
y8FOETIeJrgeRapjEJdMixilmRvlSBWsqBylI71sq0SDWG3m1jD+YoBLtZ1255ak
NE1fKwMrFxUgzjRcC3trxwvF1hO+QUMRMlAVCyAFj+DDZabXpG6enmGOkoDEBGTt
CB62fjDQkcs=
=wRSx
-----END PGP SIGNATURE-----

--Sig_/jrb96COavIqWO+7C5sYoKBV--
