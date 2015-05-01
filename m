Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52355 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753181AbbEADIg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Apr 2015 23:08:36 -0400
Date: Fri, 1 May 2015 13:08:26 +1000
From: NeilBrown <neilb@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under
 pseudo root
Message-ID: <20150501130826.40721dd0@notabene.brown>
In-Reply-To: <20150501022939.GQ889@ZenIV.linux.org.uk>
References: <5538EB18.7080802@gmail.com>
	<20150424130045.6bbdb2f9@notabene.brown>
	<553E2784.6020906@gmail.com>
	<20150429125728.69ddfc6c@notabene.brown>
	<20150429191934.GA23980@fieldses.org>
	<20150430075225.21a71056@notabene.brown>
	<20150430213602.GB9509@fieldses.org>
	<20150501115326.51f5613a@notabene.brown>
	<20150501020324.GP889@ZenIV.linux.org.uk>
	<20150501122333.1476c999@notabene.brown>
	<20150501022939.GQ889@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/vPfjl91D3qc6EMQKLWTptpU"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/vPfjl91D3qc6EMQKLWTptpU
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 1 May 2015 03:29:40 +0100 Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Fri, May 01, 2015 at 12:23:33PM +1000, NeilBrown wrote:
> > > What kind of consistency warranties do callers expect, BTW?  You do r=
ealize
> > > that between iterate_dir() and callbacks an entry might have been rem=
oved
> > > and/or replaced?
> >=20
> > For READDIR_PLUS, lookup_one_len is called on each name and it requires
> > i_mutex, so the code currently holds i_mutex over the whole sequence.
> > This is triggering a deadlock.
>=20
> Yes, I've seen the context.  However, you are _not_ holding it between
> actual iterate_dir() and those callbacks, which opens a window when
> directory might have been changed.
>=20
> Again, what kind of consistency is expected by callers?  Are they ready to
> cope with "there's no such entry anymore" or "inumber is nothing like
> what we'd put in ->ino, since it's no the same object" or "->d_type is
> completely unrelated to what we'd found, since the damn thing had been
> removed and created from scratch"?

Ah, sorry.

Yes, the callers are prepared for "there's no such entry anymore".
They don't use d_type, so don't care if it might be meaningless.
NFSv4 doesn't use ino either, but NFSv3 does and isn't properly cautious
about ino changing.

In nfs3xdr, we should probably pass 'ino' to encode_entryplus_baggage() and
thence to compose_entry_fh() and it should report failure if
dchild->d_inode->i_ino doesn't match.
Simply not returning the extra attributes is perfectly acceptable in NFSv3.

So it looks like we are mostly OK here - we don't really need i_mutex to be
held for very long.

NeilBrown


--Sig_/vPfjl91D3qc6EMQKLWTptpU
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVULuKjnsnt1WYoG5AQJ72w//U3CdmoifokvB0oSuY8i2J6IzDOULRfnu
SP2ilHAQtbho5GLaqplLSO7XpwdJqb+t0fvLNCz5scFZ+ld//9OMaTbBF23qOewd
C9uSu8vyzwM9oVO5oyB0xmeL7qRZ0oDkJf6dIrfsB22/q2Wac02KfnAx42k1d+tP
QYgXaMV2FmWZaUgGU9/b3d6ozGTdR9uAdg/bfbMhRGAd5T/LHvt2xB6dRr/T/o+6
px17fsVm6IpDO7QMZmVacHHaBOAeifkccpgE9RB5K9W+3II3z5/xxtkgpFPloah6
stoGb3EmQdbnapNTAFedGyrR+hB6e3kXmr0hetNAWbthjE4mfXmEeWMj/gdC5uQJ
C4orwrktlUhFzHMpqyuF5azwqlwnU1L6MUZlP1gsDu8ca2fVB0rWganarKGi1b5W
GoyGZhYKSP4DIcMPin9PaUf/Sbn+doXVouhDvGv5Kzalp6ijlS+2qaenGCqW3814
ngBRvnsu3jQrnxi1KBOYUkmKyj+7qFZxSuLj/uZWeG7J0/dpfOizIEIPZGVX3kfv
8+SDF9qPho1UuY0iV2JmJq8I91u85bCEfTwSdvabtzZ/R39ur6t8ENn4cA5kv4pg
1PW8FbzDGr1Y2haUPOSuyA0bWPGmB/REeeMQ22xI1tODkMQWXix4H6I4ADSg4hN5
/r2amQA1Vgo=
=ihXW
-----END PGP SIGNATURE-----

--Sig_/vPfjl91D3qc6EMQKLWTptpU--
