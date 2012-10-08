Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:37667 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773Ab2JHGDA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Oct 2012 02:03:00 -0400
Date: Mon, 8 Oct 2012 17:03:04 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistency when mounting a directory that 'world' cannot
 access.
Message-ID: <20121008170304.37dc6ae9@notabene.brown>
In-Reply-To: <20121004160739.GA4693@fieldses.org>
References: <20120918112329.7d88ed9e@notabene.brown>
	<20121001154309.GD18400@fieldses.org>
	<20121002123810.15bd1ee2@notabene.brown>
	<20121002143334.GA1435@fieldses.org>
	<20121003134629.72557522@notabene.brown>
	<20121003151349.GD14313@fieldses.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA909001D77@SACEXCMBX04-PRD.hq.netapp.com>
	<20121003162728.GE14313@fieldses.org>
	<20121004084659.38632320@notabene.brown>
	<20121004160739.GA4693@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/U1trZW3gspds3xWk=yAK66F"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/U1trZW3gspds3xWk=yAK66F
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 4 Oct 2012 12:07:39 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Thu, Oct 04, 2012 at 08:46:59AM +1000, NeilBrown wrote:
> > On Wed, 3 Oct 2012 12:27:28 -0400 "J. Bruce Fields" <bfields@fieldses.o=
rg>
> > wrote:
> >=20
> > > On Wed, Oct 03, 2012 at 03:48:43PM +0000, Myklebust, Trond wrote:
> > > > On Wed, 2012-10-03 at 11:13 -0400, J. Bruce Fields wrote:
> > > > > On Wed, Oct 03, 2012 at 01:46:29PM +1000, NeilBrown wrote:
> > > > > > On Tue, 2 Oct 2012 10:33:34 -0400 "J. Bruce Fields" <bfields@fi=
eldses.org>
> > > > > > wrote:
> > > > > >=20
> > > > > > > I guess you're right.  So it starts to sound more like: "you =
have a
> > > > > > > confusing setup.  Your export configuration says one thing, a=
nd your
> > > > > > > filesystem permissions say another.  Under NFSv3 the confusio=
n didn't
> > > > > > > matter, but now it does--time to fix it."
> > > > > > >=20
> > > > > >=20
> > > > > > That's the best I could come to - I'm glad to have it confirmed=
.  Thanks!
> > > > > >=20
> > > > > > It is unfortunate that Linux NFS uses an anon credential to mou=
nt when krb5
> > > > > > is in use, and uses 'root' when auth_sys is used (which might b=
e anon if
> > > > > > "root_squash" is active, but might not).
> > > > > > I wonder if it would work to use auth_none for the mount-time l=
ookup, just
> > > > > > for consistency..
> > > > > >=20
> > > > > > Is the following appropriate?  Is there somewhere better to put=
 this caveat?
> > > > >=20
> > > > > Unfortunately, it's more complicated than this, as it depends on =
client
> > > > > implementation and configuration details.
> > > > >=20
> > > > > Something like this would be more accurate but possibly too long:
> > > > >=20
> > > > > 	Note that under NFSv2 and NFSv3, the mount path is traversed by
> > > > > 	mountd acting as root, but under NFSv4 the mount path is looked
> > > > > 	up using the client's credentials.  This means that, for
> > > > > 	example, if a client mounts using a krb5 credential that the
> > > > > 	server maps to an "anonmyous" user, then the mount will only
> > > > > 	succeed if that directory and all its parents allow eXecute
> > > > > 	permissions.
> > > >=20
> > > > So you're listing this as a "feature" rather than a bug? There shou=
ld be
> > > > no reason to constrain the pseudofs to use the permission checks fr=
om
> > > > the underlying filesystem.
> > >=20
> > > I'd be fine with that.
> > >=20
> > > (That still leaves some subtle v3/v4 difference in the case of mount
> > > paths underneath an export?
> > >=20
> > > What *is* the existing mountd behavior there, exactly?  I'm inclined =
to
> > > think allowing mounts of arbitrary subdirectories is a bug, but maybe
> > > there's some historical reason for it or maybe someone already depends
> > > on it.)
> > >=20
> > > --b.
> >=20
> > The behaviour is simple that you mount a filehandle (typically belongin=
g to a
> > directory) and that filehandle can be anything inside any exported file=
system.
>=20
> It's not the nfsd behavior that bothers me--there's nothing we can do
> about the fact that access by filehandle can bypass directory
> permissions.
>=20
> What bothers is that mountd will apparently allow anyone to do a lookup
> anywhere in an exported filesystem.

Not anyone - it requires a privileged source port from a known host.
So it is only "anyone who can get 'root'".

>=20
> I don't know--maybe I shouldn't be so concerned about the possibility a
> rogue user could figure out that my "Music" directory includes an
> unreasonable number of Miles Davis titles.
>=20
> > Yes, please do depend on being able to mount filehandles that aren't to=
 root
> > of a filesystem.
> >=20
> > The case the brought this issue to my attention involved the server hav=
ing
> > a directory containing hundreds of home directories.  This directory is
> > exported.
> >=20
> > If they mount that top level directory they get horrible performance.  =
If
> > they use an automounter to just mount the homes that are accessed it wo=
rks
> > better.  They weren't able to explain why but my guess is that some too=
ls
> > (GUI filesystem browser) would occasionally do the equivalent of "ls  -=
l" of
> > the top level directory which would hammer nfs-idmapd and probably ldap=
....
> > though you would think that would get cached and not be a problem for l=
ong.
> > So maybe it is more subtle than that.
>=20
> Getting all the id->name mappings for a 100-entry directory is going to
> require a 100 serialized upcalls to idmapd (and then possibly ldap), and
> by default it looks like the idmapd cache will go cold after 10
> minutes....  Not hard to imagine that could be a problem.
>=20
> Running multiple idmapd process would be easy and might help?  Though
> not if the client's just giving us the getattrs one at a time.
>=20
> Or maybe the problem's somewhere else entirely, but that's a real bug if
> we aren't giving good performance on /home.

I did some experimenting..
On both 'client' and 'server':
  for i in `seq 2000 3000`; do echo u$i:x:$i:1000::/nohome:/bin/false; done
>> /etc/passwd

On server in suitable directory

  for i in `seq 2000 3000`; do mkdir $i ; chown u$i $i ; done

Mount that directory onto the client with NFSv3 and "time ls -l" takes a
little under 4 seconds.
Mount with NFSv4 and it takes about the same.  However:

.....
drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2974
drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2975
drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2976
drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2977
drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2978
drwxr-xr-x 2 u2979      root 4096 Oct  8 16:19 2979
drwxr-xr-x 2 u2980      root 4096 Oct  8 16:19 2980
drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2981
drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2982
drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2983
drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2984
drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2985
drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2986
....


tcpdump shows the server is returning the write stuff, but something if goi=
ng
wrong on the client.  I've tried unmounting/remounting and killing/restarti=
ng
rpc.idmapd.
I had some config problems previously .. is there any chance that these
unknown entries are in a cache?  Any easy way to view or flush the cache?

Of course this is with text-file password lookup.  LDAP might be slower but
I'd be surprised if it was much slower.

NeilBrown



>=20
> --b.
>=20
> > I've built similar setups before.  There is something attractive about
> > everyone's home directory being /home/$USERNAME even though they are on
> > different servers and different filesystems.
> >=20
> > In the particular problem scenario, local policy requires that the 'sta=
ff'
> > directory on the server to not be world-accessible, but they still want=
 to
> > mount the individual home directories from there onto client machines as
> > required.
> > I cannot easily justify that policy, but the point is that it works with
> > NFSv3 and with AUTH_SYS/no_root_squash, but not with NFSv4/kerb5.  I do=
n't
> > think we can fix this inconsistency but maybe we can explain it.
> >=20
> > I think your text is more accurate than mine, but also a little more va=
gue so
> > the important may not be immediately obvious.  That might be a price we=
 have
> > to pay for accuracy.


--Sig_/U1trZW3gspds3xWk=yAK66F
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUHJsmDnsnt1WYoG5AQLmUQ/+LY0fkjYzJiPCYWNDMedlE5ixdt5W1CXA
3QJUwgc3nH17wY8AtYLPXWLtH37mQB+8Cm8SOQGOWam8yH4U3NRXWpB5pkHXwkGN
Gtm5hD5q61Xw+i+mV58wceWAzWfXug95KrM+c1rSbEwzovmadlWR7hA+bKdX4j54
e14o4TOpOZc8Lj6Dg9l1hI9otP5c5xo7uAXdKwP+9J9vBwjA0OsIbpspN+vsbH9K
LYRmf/qvZPhh6noPtkLP6chmHXWDQ53mYgzfJVhxgMC6vaYTf0ZsGGQOlUXROLUq
zdOTaFJQjLdF8JM7ccEqidxMKQYnUs1bIymdPidkcgiR2VirsGFdJkRpbxPDY48m
aNT3tZe900f9kOqohQ/pbLZL5Zs2qziLskHTAgy0kTDcMltCJ7U4/WRgfFXeG87f
7ohxzNt3ydHuACQHPHwosjOL1GWYaGI8WpPNZr2pwciMHrKJNaj9FfCRbiZYCBlO
8GEqwHqZaXHZPEMh2krwxc5XI9H03c93lwmLDnVWGEsooGssypdUrFjRUNJGLy2h
WucyRFstxUEUOAezUuW4CvwoE6D00SVXxVLF1hh9Vwy0zPOzjiRSvKtFV7qSE1wk
DVkwPjeHW+CEa9pI+I/IP/s0QBj+zpIPF1rWJtf8r6g405/4X0iAyyQnsiJfoo8e
DZt0COClm+U=
=bHPv
-----END PGP SIGNATURE-----

--Sig_/U1trZW3gspds3xWk=yAK66F--
