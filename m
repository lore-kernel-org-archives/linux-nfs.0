Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34236 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752100Ab2JBCiN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 22:38:13 -0400
Date: Tue, 2 Oct 2012 12:38:10 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistency when mounting a directory that 'world' cannot
 access.
Message-ID: <20121002123810.15bd1ee2@notabene.brown>
In-Reply-To: <20121001154309.GD18400@fieldses.org>
References: <20120918112329.7d88ed9e@notabene.brown>
	<20121001154309.GD18400@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/qEOsg=mVVjOfvKqku3K8W.u"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/qEOsg=mVVjOfvKqku3K8W.u
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 1 Oct 2012 11:43:10 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, Sep 18, 2012 at 11:23:29AM +1000, NeilBrown wrote:
> >=20
> > Suppose that on an NFS server I have a directory
> >    /foo/bar/baz
> >=20
> > which I export, and that /foo/bar does not have world access.  e.g.
> > permissions are '750' and everyone who owns files in there is a member =
of the
> > group which owns /foo/bar.
> >=20
> > Then with NFSv3 I can
> >   mount server:/foo/bar/baz  /somewhere
> > because the lookup of /foo/bar/baz happens as root on the server in mou=
ntd.
> >=20
> > With NFSv4 using 'sec=3Dsys' I can only do this if I export with
> > "no_root_squash", as the lookup happens on the client as root, and if r=
oot
> > were squashed, it wouldn't have access beyond /foo/bar.
> >=20
> > But if I use NFSv4 using 'sec=3Dkrb5', the lookup happens on the client=
 using a
> > machine credential which gets mapped to 'nobody/nogroup' (or whatever a=
nonuid
> > and anongid are set to for the export).  So I cannot perform the mount =
at all.
> >=20
> > This is - at best - inconsistent and can cause confusion (hey - I was
> > confused for a while there).
> >=20
> > Should something be done?  Can anything be done?
>=20
> I think nfsd_lookup_dentry() would need a special exception for the
> NFSEXP_V4ROOT case.

I don't think that would help in general.
If I export /foo and want to mount /foo/bar/baz, then for the last lookup at
least, NFSEXP_V4ROOT isn't set anywhere near.

An exception would need to be made for every 'nfs4_lookup_dentry', provided
it found a directory, or nothing (or a symlink...).  Possibly this could on=
ly
be done for anonymous credentials (as are used by the nfs4 mount operation).

It would be nice if we could clearly differentiate a mount-time lookup from=
 a
regular lookup, but I don't think the protocol allows for that.

Thanks,
NeilBrown


>=20
> Looks like the directory permission check is actually done in
> lookup_one_len(), so we'd need to either call something else or
> temporarily swap credentials?
>=20
> --b.
>=20
> >=20
> > I lean towards thinking that the most restrictive behaviour is most cor=
rect
> > (though I have a customer who feels that it is too restrictive).
> >=20
> > Should the NFSv4 client always use an anon credential when performing t=
he
> > 'mount'?  Is that even possible for auth_sys?
> > Should rpc.mountd use set_fsuid before doing the path lookup to ensure =
that
> > everyone has access to the exported directory?
> >=20
> > Or is there some way 'mount' lookups for krb5 could be treated as being
> > performed by root?
> >=20
> > Any ideas?


--Sig_/qEOsg=mVVjOfvKqku3K8W.u
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUGpTkjnsnt1WYoG5AQLHShAAm5SgofAhIFPztX55So4AvxSLfGLMNIJe
mjcttgc60dYCuGMtKZxbQeeT13GtMvxiKmYs1csNtotr0MSDuFgtZGLPHimugoaT
XcKFfsmrJF+rg5lGDfFCsNeviyl3mHyOiSuIiY7c61y2Nn7tcEKAmlZCejtVnu9p
lu4nFFSBcuw3r8Gylcz9PEb9ncEvmDn85wyAv5511jM0gbk0g4wS22Gk/yCu5Y/n
kvRJtjvszkVMkhZXYo8oIDS7G+FUI3fYVH47chVbKCKdtr3XHdQU06OHpWV7h9Ac
KGBVxdzVOQRa4FxPTlvo3rWGP2YSKu0442TKci1MuZAYgh3Bj4xvC+x3BAYhp2Lq
YdwbASsmvgL6YvUM4X+dsjLmk1tsCybP3GIzw9Sqpwd7IBIvSzQg81ZQAfQn7P7h
nzL262GBPAU5I8FDQtedSEgPdWUgHlr8xxRSsqwAcTEAnnS8BUgC/14yJ9ljSMD4
uo+QGqhvEkDd7znkUCCUcq0o9o0s/uV8WaLVLrPa7B3NCPCwqXF8/YEVtZaITew8
fz46PfdTVrQiiCqt0mz0hzv9WtzceYnCFjhR55ljhtHp/JIFjsn5mbb8FDvFy0tA
hd6skBa8BtM9pNMXUy+NKo6OhnNmO/J+HfSLfsIi3YiTR171B+Z62lXQDb4BQye0
5MSvtmprQBI=
=r9+g
-----END PGP SIGNATURE-----

--Sig_/qEOsg=mVVjOfvKqku3K8W.u--
