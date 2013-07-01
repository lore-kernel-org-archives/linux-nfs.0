Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49175 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755393Ab3GAWY1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 18:24:27 -0400
Date: Tue, 2 Jul 2013 08:24:13 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [patch/rfc] allow exported (and *not* exported) filesystems to
 be unmounted.
Message-ID: <20130702082413.34dac92e@notabene.brown>
In-Reply-To: <20130701191238.GD19945@fieldses.org>
References: <20130605130541.5968d5c2@notabene.brown>
	<20130605034115.GD13110@ZenIV.linux.org.uk>
	<20130605161934.59ab6804@notabene.brown>
	<20130605133658.GE24193@fieldses.org>
	<20130606100512.1c701a64@notabene.brown>
	<20130701191238.GD19945@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/TFe/.00C2MN8U+xNoJUm42s"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/TFe/.00C2MN8U+xNoJUm42s
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 1 Jul 2013 15:12:38 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Thu, Jun 06, 2013 at 10:05:12AM +1000, NeilBrown wrote:
> > On Wed, 5 Jun 2013 09:36:58 -0400 "J. Bruce Fields" <bfields@fieldses.o=
rg>
> > wrote:
> >=20
> > > On Wed, Jun 05, 2013 at 04:19:34PM +1000, NeilBrown wrote:
> > > > On Wed, 5 Jun 2013 04:41:15 +0100 Al Viro <viro@ZenIV.linux.org.uk>=
 wrote:
> > > >=20
> > > > > On Wed, Jun 05, 2013 at 01:05:41PM +1000, NeilBrown wrote:
> > > > > >=20
> > > > > > Hi Bruce,
> > > > > >  this is a little issue that seems to keep coming up so I thoug=
ht it might be
> > > > > >  time to fix it.
> > > > > >=20
> > > > > >  As you know, a filesystem that is exported cannot be unmounted=
 as the export
> > > > > >  cache holds a reference to it.  Though if it hasn't been acces=
sed for a
> > > > > >  while then it can.
> > > > > >=20
> > > > > >  As I hadn't realised before sometimes *non* exported filesyste=
ms can be
> > > > > >  pinned to.  A negative entry in the cache can pin a filesystem=
 just as
> > > > > >  easily as a positive entry.
> > > > > >  An amusing, if somewhat contrived, example is that if you expo=
rt '/' with
> > > > > >  crossmnt and:
> > > > > >=20
> > > > > >     mount localhost:/ /mnt
> > > > > >     ls -l /
> > > > > >     umount /mnt
> > > > > >=20
> > > > > >  the umount might fail.  This is because the "ls -l" tried to e=
xport every
> > > > > >  filesystem found mounted in '/'.  The export of "/mnt" failed =
of course
> > > > > >  because you cannot re-export an NFS filesystem.  But it is sti=
ll in the
> > > > > >  cache.
> > > > > >  An 'exportfs -f' fixes this, but shouldn't be necessary.
> > >=20
> > > Yeah, ugh.  As a less contrived example, can the default v4 root expo=
rt
> > > lead to arbitrary filesystems being pinned just because a client tried
> > > to mount the wrong path?
> >=20
> > I think it can only pin filesystems that are exported, either explicitl=
y or
> > via a parent being exported with 'crossmnt'.
>=20
> But see utils/mountd/v4root.c, and:
>=20
> 	[root@server ~]# exportfs -v
> 	/export <world>(rw,...)
> 	[root@server ~]# mount /mnt
>=20
> 		[root@pip4 ~]# mount pip4:/ /mnt/
> 		[root@pip4 ~]# ls -l /mnt/
> 		total 4
> 		drwxrwxrwt 3 root root 4096 Jun  7 10:34 export
> 		[root@pip4 ~]#=20
>=20
> 	[root@server ~]# umount /mnt/
> 	umount: /mnt: target is busy.
> 	...
> 	[root@server ~]# grep /mnt /proc/net/rpc/nfsd.export/content=20
> 	# /mnt	*()

You make a good point.  I didn't think that would happen, and I think I cou=
ld
argue that it is a bug.  I have no idea how easy it would be to "fix" witho=
ut
pouring over the code for a while though.  Or whether it is worth "fixing".

>=20
> > > Could the export cache be indexed on a path string instead of a struct
> > > path?
> >=20
> > Yes.  It would mean lots of extra pathname lookups and possibly lots of
> > "d_path()" calls.
>=20
> Right.  Ugh.  Still, struct path seems wrong as it's not something gssd
> knows about, and there's not really a 1-1 mapping between the two (see
> e.g. the recent complaint about the case where the struct path
> represents a lazy-unmounted export
> http://mid.gmane.org/<20130625191008.GA20277@us.ibm.com> ).

I noticed that but haven't really followed it (though I just checked and
there isn't much to follow...)

What do we *want* to happen in this case?  I would argue that when the
filesystem is detached the export should immediately become invalid.

We could possibly put a check in exp_find_key() to see if ek->ek_path
was still attached (not sure how to do that) and if it is: invalidate the ek
before calling cache_check().  If the "is path detach" test is cheap, we
should probably do this.

Or - we could flush relevant entries from the cache whenever there is a
change in the mount table.  That is certainly the preferred option if the "=
is
path detached" test is at all expensive.  But it seems it isn't completely
clear how that flushing should be triggered...

NeilBrown


--Sig_/TFe/.00C2MN8U+xNoJUm42s
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUdIBjTnsnt1WYoG5AQKcfg//cFSk/ahASB+NNUfuku0TDMZ9RgTyK5iT
SQHonlupwtoyPNGdb3hNWEZi86cO6ebAAar50tChIzzUsKzU42cum3OuBNFLB97r
76qfEObG42ycVvxIf03KIafL/rYIwnanvEtL08ggawFqvp6/WhAQL4QocOJthZZ5
dVKQ+OPXqiDAjubjPxUIr1qwoY7aSkSPSJjiuG7TUQWV1PFfX/6yBnHh6JHVjpti
bdq9+vnoPzE9Dz47ibilI+iRBvdWixcssxMDL+94hMzV7DhuZ06LnqXjzyPpUc3H
Z3q90OUfRExwrmt5WKZ8Lg4vjAA5NjizGE6oNBk2cWauJZruVnyO3NFs4M2MKK/j
vPMPP+qTYicGntTap7sS0DtClPVA7wEb0SwKYCMuSXIqhEP/1GwYxq/r5C1VZ23b
d+feKL2CBOp2yzFONdk01Dd4oNKMNYTTIRnxpomEl92mrKdKi+jQmQUVAMsw54OY
hh+wQfvIhJAaOchWRKlj8ChJV0CrAWYbYspuhrz/a2ST4aL2LOsElFAuXSqn15oB
VHE2RfRyJc7HpUK+62yeLdXWrULQTgxX4VDMEcvWW3tUpb4nK/AltQWYsWhREcgv
/e9bS6tShlr20g8aYfPPAv2LyhBXskBF2jHys4xZyFfIZHyjhcXRxOeodmzb5Lxv
Ei1/zPMfQyA=
=klRU
-----END PGP SIGNATURE-----

--Sig_/TFe/.00C2MN8U+xNoJUm42s--
