Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54039 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755948Ab3BRXcH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Feb 2013 18:32:07 -0500
Date: Tue, 19 Feb 2013 10:31:52 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        NFS <linux-nfs@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: More fun with unmounting ESTALE directories.
Message-ID: <20130219103152.46522a76@notabene.brown>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9235D18CC@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130212113813.427b8e05@notabene.brown>
	<20130214104230.013b7f71@tlielax.poochiereds.net>
	<20130218132509.0ce779de@notabene.brown>
	<20130218184609.GF4503@ZenIV.linux.org.uk>
	<20130219101031.123b1eb0@notabene.brown>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9235D18CC@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/a7R7_M9EFJcb_SZ.ow1R1iM"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/a7R7_M9EFJcb_SZ.ow1R1iM
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 18 Feb 2013 23:17:42 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-02-19 at 10:10 +1100, NeilBrown wrote:
> > On Mon, 18 Feb 2013 18:46:09 +0000 Al Viro <viro@ZenIV.linux.org.uk> wr=
ote:
> >=20
> > > On Mon, Feb 18, 2013 at 01:25:09PM +1100, NeilBrown wrote:
> > >=20
> > > > I would be really nice if sys_unmount used a LOOKUP_MOUNTPOINT flag=
 that
> > > > works a bit like LOOKUP_PARENT and LOOKUP_NOFOLLOW in that it skips=
 the very
> > > > last step and returns the mounted-on directory, not the mountpoint =
that is
> > > > mounted there - or at least makes sure not revalidate happens on th=
at final
> > > > mounted directory.
> > >=20
> > > I don't think LOOKUP_MOUNTPOINT is a good idea.  For one thing, we ha=
ve
> > > fairly few places that might want it, all of them in core VFS.  Might=
 as
> > > well provide a separate function for them, a-la path_lookupat() vs.
> > > path_openat().
> > >=20
> > > For another, we need to decide what to do with a really nasty corner =
case:
> > > 	a/b is a mountpoint, with c/d bound on it.
> > > 	c/d is a symlink to c/e
> > > 	c/e is a mountpoint
> > > What should umount("a/b", 0) do?  There are two possibilities - remov=
ing
> > > vfsmount on top of a/b or one on top of c/e...
> > >=20
> > > We have the latter semantics; _that_ is what this GETATTR is about.  =
It's
> > > a fairly obscure corner case - the question is not even whether to fo=
llow
> > > symlinks, it's whether to follow _mounts_ on the last component.  Hell
> > > knows; I'm seriously tempted to change it "don't follow mounts" and s=
ee if
> > > anyone complains.  The only case when behaviour would change would be
> > > a symlink mounted somewhere (note that this is _not_ something that c=
an easily
> > > happen; e.g. mount --bind does follow symlinks) and umount(2) given t=
he
> > > path resolving to the mountpoint of that symlink.
> >=20
> > Thinking about this some more, I now realise that my LOOKUP_MOUNTPOINT =
idea
> > was too simplistic and missed the real point.
> >=20
> > The real point is that for unmount, we want to resolve the the path wit=
hout
> > any reference to any filesystem at all - the lookup should be handled
> > entirely by the dcache.
> > Any mountpoint is pinned in the dcache, and consequently any ancestor o=
f any
> > mount point also is.  So the dcache will lead us to the dentry that we =
want.
> >=20
> > And the dentry is *all* we want.  It doesn't really matter what the ino=
de is
> > like, or whether the filesystem thinks that the inode or name still exi=
st.
> > All we need to do is find a dentry that must be  in the cache, and deta=
ch the
> > mount that is there.
> >=20
> > Whether that is achieved by a LOOKUP_ flag or a separate lookup function
> > doesn't matter much to me.
> >=20
> > I suspect we need to allow for passing a symlink to unmount, and the sy=
mlink
> > might not be in cache, so we cannot insist uniformly on only using the =
dcache.
> > However if a name is in the cache, and the cached data suggests that it=
 is a
> > directory, then we should trust that and avoid referring to the filesys=
tem.
> >=20
> > umount is really quite unique in this.  All other times we lookup a pat=
h we
> > want to use the thing we found.  With umount, we want to stop using it.
>
> > ???
>=20
> Add a umountat() syscall so that you can supply a file descriptor? :-)
>=20

If I could get that file descriptor by opening some magic file in /proc whi=
ch
led immediately to the mount point, then I'd say "yes please!".
Otherwise, I don't think it helps, and so support your ":-)".

NeilBrown

--Sig_/a7R7_M9EFJcb_SZ.ow1R1iM
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUSK56Dnsnt1WYoG5AQLadhAAokOSWpDOg2lE5wdpDBqFg1m8bu0/R7vK
r1imN1UU0xZ2CyqDrnmK0tvt5+fF9W1sNcYudhw6dd28GfRLBE/+sPPZQ5rDAep6
4+pssAh5LCV1SJCH54CLzTbAqR2mSMMQqzqn4s3X/qDomZk35wTFWe0cUPD/iD6v
kw2YLD03kzPzNJdyiWbAMQzXlWskIA95YV6pIl4w7ovTvDg/kpUvy9ONyTkxTQE/
HfkR6CDdJeH9ymceXJaS58xpjRf3cGNrWE+MDcxZ1gD14flhKVN/RWAR91bQL1vC
PSscWh11UUpH9EMGq2hXxKowPTrwUJOFFRSO834aaBmzbjaTmxBXiOPkY4YM7Ydp
NdWloA5UcY/ypMCDnWTRRuvdi2AXImFZ2f2DioJ3cc5ZXZxU90w/iwB7KGXURshG
pEAVcy5xqCp/rK9gNBi26nfIz8CPDNsndDUIADBXNB3j0yhXNPO7ujtzoCtb+orO
fAzlVQVZFczhmzug51y/scXvE09UpWRh6W8SBnznH/LL+6Y/RRZgS834WjaGnQLc
EuSDR1HUuJvLw0QOIqBqSiL9DbJ6eyW/p/d/fnsIg7rqlYVVLEIL6AQtsSbRRJDR
v5lzqKTj74ndQzS8HyacKjnaDYRS0yKS2tTZwEQvRjK4rwdGC+xB7QoC2EGYKvjd
yUuPimlvCcY=
=19lY
-----END PGP SIGNATURE-----

--Sig_/a7R7_M9EFJcb_SZ.ow1R1iM--
