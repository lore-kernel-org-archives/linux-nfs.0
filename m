Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34749 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272AbbBPCqi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 15 Feb 2015 21:46:38 -0500
Date: Mon, 16 Feb 2015 13:46:28 +1100
From: NeilBrown <neilb@suse.de>
To: Nix <nix@esperi.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: what on earth is going on here? paths above mountpoints turn
 into "(unreachable)"
Message-ID: <20150216134628.773e3347@notabene.brown>
In-Reply-To: <87vbj4ljjn.fsf@spindle.srvr.nix>
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix>
	<87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
	<20150210183200.GB11226@fieldses.org>
	<87vbj4ljjn.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/TaVIF_1=e1EG+1JIJP54K/3"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/TaVIF_1=e1EG+1JIJP54K/3
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 14 Feb 2015 13:17:00 +0000 Nix <nix@esperi.org.uk> wrote:

> On 10 Feb 2015, J. Bruce Fields outgrape:
>=20
> > It might be interesting to see output from
> >
> > 	rpc.debug -m rpc -s cache
> > 	cat /proc/net/rpc/nfsd.export/content
> > 	cat /proc/net/rpc/nfsd.fh/content
> >
> > especially after the problem manifests.
>=20
> So the mount has vanished again. I couldn't make it happen with
> nordirplus in the mount options, so that might provide you with a clue.

Yup.  It does.

There is definitely something wrong in nfs_prime_dcache.  I cannot quite
trace through from cause to effect, but maybe I don't need to.

Can you try the following patch and see if that makes the problem disappear?

When you perform a READDIRPLUS request on a directory that contains
mountpoints, the the Linux NFS server doesn't return a file-handle for
those names which are mountpoints (because doing so is a bit tricky).

nfs3_decode_dirent notices and decodes as a filehandle with zero length.

The "nfs_same_file()" check in nfs_prime_dcache() determines that isn't
the same as the filehandle it has, and tries to invalidate it and make a new
one.

The invalidation should fail (probably does).
The creating of a new one ... might succeed.  Beyond that, it all gets a bit
hazy.

Anyway, please try:

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 9b0c55cb2a2e..a460669dc395 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -541,7 +541,7 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *d=
esc, struct nfs_entry *en
=20
 		count++;
=20
-		if (desc->plus !=3D 0)
+		if (desc->plus !=3D 0 && entry->fh.size)
 			nfs_prime_dcache(desc->file->f_path.dentry, entry);
=20
 		status =3D nfs_readdir_add_to_array(entry, page);


which you might have to apply by hand.

Thanks,
NeilBrown

--Sig_/TaVIF_1=e1EG+1JIJP54K/3
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOFaBDnsnt1WYoG5AQIVUhAAgX+TFYwiKk0o84W6G11CBjfYO+8P/sAT
v0amf3+4cRPPFHiKl0ISBWWoFKdkI45m8jxD85ipRjoT7SRNgGgnYCiIHoFeKcV7
QEy3tw+UbZ7Ll64vIfZrIfqmYlgsG7ZwYyrTY27LQGNTmh9nQg26cGggEBEHySRI
1YLedkCSx7T27b9z1VOgj+Kgd7yNE1EbHNMciGu3Q6/zZwUcG7P1MLj+iLC+2m4W
6OxSys+a2k3eXLww4NC2lG2kUV9l7A0YhzmCEHRFYg9LUYtfI52sraQ8Esu8tENC
ubY5BOv7xozsGHKoTrlRltRAGQ4JWFSO1HF4bQpXoTQJTA2LJvrKeHkSwrQ0dcJV
zFGaruxoslv/8sSzhBMmVrxqUfAu+DWXKsXG7cKq0AaaN9w3KMG0zlJ9pQ/h4/ip
Ttd24DpX4WkpejcFjoy+jjRlg08HhKpyKBg3uoKJ5q4y1klPV2ZV2ZWXhLnyKc13
Jkl+tQ1HFlu91xY2hfx5E9SfLIa7Az7YT5r5xs5n5x5lNjCAAq8bjCrMxs5GvpgP
1nnFcfPOMg7UhvoNcLsehW4rNY/INZup0KrLOPptQpXa4AyiKKIY1CZ7jpDzcXDc
v0vCJ8nCqPboj2izSLszN/aPa6s04dfIwkn39FYT25h+yuaKA7nVRoh8otPtZBb+
86U7fV+ZvPg=
=tc8d
-----END PGP SIGNATURE-----

--Sig_/TaVIF_1=e1EG+1JIJP54K/3--
