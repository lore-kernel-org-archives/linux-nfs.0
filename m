Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:33994 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752376AbbBTVDa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Feb 2015 16:03:30 -0500
Date: Sat, 21 Feb 2015 08:03:21 +1100
From: NeilBrown <neilb@suse.de>
To: Nix <nix@esperi.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: what on earth is going on here? paths above mountpoints turn
 into "(unreachable)"
Message-ID: <20150221080321.0b2764c0@notabene.brown>
In-Reply-To: <87h9ugqytn.fsf@spindle.srvr.nix>
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix>
	<87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
	<20150210183200.GB11226@fieldses.org>
	<87vbj4ljjn.fsf@spindle.srvr.nix>
	<20150216134628.773e3347@notabene.brown>
	<20150216145746.68809c0f@notabene.brown>
	<87h9ugqytn.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/d+V.m_+VLq+_FgcSseLfHCE"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/d+V.m_+VLq+_FgcSseLfHCE
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 20 Feb 2015 17:26:12 +0000 Nix <nix@esperi.org.uk> wrote:

> On 16 Feb 2015, NeilBrown uttered the following:
>=20
> > On Mon, 16 Feb 2015 13:46:28 +1100 NeilBrown <neilb@suse.de> wrote:
> >
> >> Anyway, please try:
> >>=20
> >> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> >> index 9b0c55cb2a2e..a460669dc395 100644
> >> --- a/fs/nfs/dir.c
> >> +++ b/fs/nfs/dir.c
> >> @@ -541,7 +541,7 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor=
_t *desc, struct nfs_entry *en
> >> =20
> >>  		count++;
> >> =20
> >> -		if (desc->plus !=3D 0)
> >> +		if (desc->plus !=3D 0 && entry->fh.size)
> >>  			nfs_prime_dcache(desc->file->f_path.dentry, entry);
> >> =20
> >>  		status =3D nfs_readdir_add_to_array(entry, page);
> >>=20
> >>=20
> >> which you might have to apply by hand.
> >
> > Make that "entry->fh->size", not "entry->fh.size" :-(
>=20
> That looks to fix it (though my first day of testing was wasted because
> I forgot nordirplus was in the mount options :/ ).
>=20

Excellent.  Thanks for testing.

NeilBrown

--Sig_/d+V.m_+VLq+_FgcSseLfHCE
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIUAwUBVOehGTnsnt1WYoG5AQK6lg/3SnShCQXQoppRPxjcGLJIycYEXp6mk2vl
KV+HrMr+jhvHNpZoZDjX4g6ZSrCdsZ2IM8M7kTRAyzVoGyCAdV9uoe5Sg+xNura8
0MHZilVdP6rnPOLTHtNsWPJHSqwh140LoYbJUX9mh7gylyufo0MohEc5MNxAFjoa
TEq4uTlfb4YpUAuL9NB1DL8U40gV+Kg1rXvZUE+2g/hAsOaHFRfsJ6N/MJUuhLAI
F+3oDPeydyp2MHFqMBo8c+LTFqa4ie5TA2OdHyRVX37gYx4qwF2QldwZIupngTy0
zaTZDDyf0tyV6/dZNJyzockpDfGvTDBPfGQXXl8RizwlI/GUh+MIxTymJx2nDY0N
sl4eHokZ1FmUJ3GGrAkHKw3jC5xL+Sue82bRLCTNrx+FXPPdBq0dl05hTm9Fwmv+
ZCIfMBRN6AbkczurycQX+wyf85Xyo1te7qQKmPtDZnHiwRvJho5tX+2tz/r2ELUR
LhyRX3mPKNgkrv+wX0QnRkQ0j8pirle2qDzvxsg48KuZ3NAwj9N3iK6V11z6HVck
rr9kPdkuJV4ij+ofsTK7D6Xb5uNnZLMnkUGw5NYV3cV5I88fJ6Q2+HUHJdYHdFsS
Z4WiDof7Zakt7M0mAIUT/Y0d6NcK0H/9xnv0TEwYfKVbh4oD6vem3TZZbF9Ssv8Q
qZwI2d8BkQ==
=qohO
-----END PGP SIGNATURE-----

--Sig_/d+V.m_+VLq+_FgcSseLfHCE--
