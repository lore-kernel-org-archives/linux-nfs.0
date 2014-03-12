Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38321 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752268AbaCLFiN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2014 01:38:13 -0400
Date: Wed, 12 Mar 2014 16:38:03 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Carsten Ziepke <kieltux@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH - v2] mount.nfs: Fix fallback from tcp to udp
Message-ID: <20140312163803.0e911784@notabene.brown>
In-Reply-To: <531F2334.2030203@RedHat.com>
References: <20140224142349.784345f9@notabene.brown>
	<531E2E3F.2020805@RedHat.com>
	<20140311090124.05409b1b@notabene.brown>
	<531F2334.2030203@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/EBp=1nBCXtgQuJNzRyX.iBk"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/EBp=1nBCXtgQuJNzRyX.iBk
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 11 Mar 2014 10:52:36 -0400 Steve Dickson <SteveD@redhat.com> wrote:

> On 03/10/2014 06:01 PM, NeilBrown wrote:
> >=20
> > With  a 3.11.10 client talking to a 3.2.0 server I run
> >   rpc.nfsd 0
> >   rpc.nfsd -T -N4
> > on the server, then
> >   rpcinfo -p SERVER | grep nfs
> > shows
> >     100003    2   udp   2049  nfs
> >     100003    3   udp   2049  nfs
> >     100227    2   udp   2049  nfs_acl
> >     100227    3   udp   2049  nfs_acl
> >=20
> > On client I run
> >     mount -v SERVER:/PATH /mnt
> > and I get
> > mount.nfs: trying text-based options 'vers=3D4,addr=3D192.168.1.3,clien=
taddr=3D192.168.1.2'
> > mount.nfs: mount(2): Connection refused
> >=20
> > repeating ever 10 seconds or so.  It eventually times out after 2 minut=
es.
> >=20
> > Same client to a 3.10 server I get the same behaviour.
> > 3.2.0 client and 3.10 server, same behaviour again.
> >=20
> > I have noticed that sometimes when I stop the NFS server the registrati=
on
> > with rpcbind doesn't go away.  Not often, but sometimes.  I wonder if t=
hat
> > could be confusing something?  Can you check that nfsv4 has been
> > de-registered from rpcbind?
> >=20
> > I note you are getting the error:
> >=20
> >> mount.nfs: portmap query failed: RPC: Remote system error - Connection=
 refused
> >=20
> > This seems to suggest that rpcbind isn't running.  Yet when I kill rpcb=
ind
> > and try a v3 mount I get
> >=20
> >   mount.nfs: portmap query failed: RPC: Unable to receive - Connection =
refused
> >=20
> > which is slightly different, so presumably there is a different cause i=
n your
> > case.
> >=20
> > Maybe you could turn on some rpcdebug tracing to see what is happening?
> Ok... I had to dial back my client to an older kernel (3.12)
> to start seeing what you were seeing...=20
>=20
> I would make one change and one comment... The change I would
> like to make (I'll re-post it) is to ping the server to see
> if v4 came up instead of asking rpcbind if its registered.=20
> Code wise I think it cleaner and quicker plus I'm not sure
> its a good idea to tie v4 and rpcbind together...=20

My logic was that if rpcbind was running at all, then any v4 server should
register with it.  It would seem odd for rpcbind to report "v2 or v3" but f=
or
v4 to be running anyway.
However I don't object in principle to your approach.
I'll have a look at the code.


>=20
> My comment is this... This code become obsolete with the 3.13
> kernel because the kernel never returns the timeout or the
> ECONNREFUSED... The mount just spins in the kernel until
> interrupted.=20

This sounds like a regression to me.  For a systemcall that used to fail to
now hang sounds like an API change, and we usually discourage those.

Can it be fixed?  Trond?

NeilBrown


>=20
> steved.


--Sig_/EBp=1nBCXtgQuJNzRyX.iBk
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUx/yuznsnt1WYoG5AQLemRAAq/WtQ9oMBjAm9B9XL5A90purYrw/7GpN
L5+QYRkTs2WV/PHnEqvJXN8AL9zZv3DnUPegLTNDecF6mGox1wptxuBPUW0NIL37
z9lAno1s8dPIKCeK6La28noQNN5kertdSgivth1+d99QwVdZ02s69lWmgqYl3fvJ
N2poRs0YNpFM9prxSeKxpIHKYkAEkJTrq/kQiVnb6y+iMrsO/NIEBbjOTwkBewbs
dh4ITspB+RFYrRJ9mXGSDEDhk/6c0AJ8FRu7NyuOjCk/WqY/C9FBImMcM8NnRFzt
3+cX7xxHNuKV9Xmhqb8ODg1MJrKW0l4FKEl/olrUHxOEB4omJGo4kF/guYM0zoZ8
flg0pjoeouF7XYo5iOiU849nAiSREh2yiiGHNiAg34QDUTwNGEoiFNN3v75ugasM
QyTphslYcVqLmF2SgU4PPd6JB3lhDtG/lcTInOsBHziBPSqHVC6zmhMzonObVRar
ckAXc5JAFWCC/fmkBM33fz6N+8bm37ncJCh9Swovm2E2sd4R9+2J931cJSGc9L/u
DM7Q+vkYWhUlFrRnCsv1VzfHzeWWJBZ2SK6zacuslvH0AVED01daR+E7Qk4npG3x
QSQuRsQAckTen/xcNuMtptQ5oXfAVmW45GxeYRrECyNJcr9rzEwoWTgljze6A1xV
x96ybI6dXSA=
=CrmY
-----END PGP SIGNATURE-----

--Sig_/EBp=1nBCXtgQuJNzRyX.iBk--
