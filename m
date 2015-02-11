Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42977 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751914AbbBKDHY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Feb 2015 22:07:24 -0500
Date: Wed, 11 Feb 2015 14:07:14 +1100
From: NeilBrown <neilb@suse.de>
To: Nix <nix@esperi.org.uk>
Cc: bfields@fieldses.org (J. Bruce Fields),
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn
 into "(unreachable)"
Message-ID: <20150211140714.4da42a5b@notabene.brown>
In-Reply-To: <87zj8l7j3z.fsf@spindle.srvr.nix>
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix>
	<87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/g.Y09H+IuqKUXSkdD6MaQSu"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/g.Y09H+IuqKUXSkdD6MaQSu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 10 Feb 2015 17:48:48 +0000 Nix <nix@esperi.org.uk> wrote:

> On 5 Feb 2015, NeilBrown spake thusly:
>=20
> > On Wed, 04 Feb 2015 23:28:17 +0000 Nix <nix@esperi.org.uk> wrote:
> >> It doesn't. It still recurs.
> >
> > Is /usr/archive still exported to mutilate with crossmnt?
> > If it is, can you change to not do that (it is quite possible to have
> > different export options for different clients).
>=20
> OK. Adjusted.
>=20
> > I think that if crossmnt is enabled on the server, then explicitly
> > mounting /usr/archive/series will have the same net effect as not doing=
 so
> > (though I'm not 100% certain).
> >
> > Also, can you try changing
> >    /proc/sys/fs/nfs/nfs_mountpoint_timeout
> >
> > It defaults to 500 (seconds - time for light from Sun to reach Earth).
> > If you make it smaller and the problem gets worse, or make it much bigg=
er
> > and the problem goes away, that would be interesting.
> > If it makes no difference, that also would be interesting.
>=20
> Seems to make no difference, which is distinctly surprising. If
> anything, it happens more often at the default value than at either the
> high or low values. It's very erratic: it happened ten times in one day,
> then three days passed and it didn't happen at all... system under
> very similar load the whole time.
>=20
> >From other prompts, what I'm seeing now -- but wasn't then, before I
> took the crossmnt out -- is an epidemic of spontaneous unmounting: i.e.,
> /usr/archive/series suddenly vanishes until remounted.
>=20
> I might just reboot all systems involved in this mess and hope it goes
> away. I have no *clue* what's going on, I've never seen it before, maybe
> it'll stop if I no longer believe in it.
>=20

This all sounds remarkably similar to a problem that a customer reported
recently.
In that case the server was a NetApp and v4 was in use and the server seemed
to suggest that it was using volatile file handles.
If a filehandle for a mounted-on directory changes, then (I think) a new
inode will be allocated and the mountpoint will effectively disappear
(though I think it should remain in /proc/mounts).

However your have a Linux server and v3, so if it is the same problem, then=
 I
completely mis-diagnosed it.

I wonder if something is going wrong in nfs_prime_dcache().  The code looks
right, but it is a little complex...

You could rule that out by disabling READDIRPLUS by using the nordirplus
mount option.  If that makes the proble go away, it would be very
interesting...

A more intrusive debugging approach would be to get d_drop() to scream if t=
he
dentry being dropped had DCACHE_MOUNTED set.

Are you able to try either of those?

NeilBrown

--Sig_/g.Y09H+IuqKUXSkdD6MaQSu
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVNrHYjnsnt1WYoG5AQLFXQ//TqXfEPJeLUQe0XOWmRr9bwAF8x2womXK
8ae5yXqZBNfDbJSzTrJSpWL7R5bcKma3+JtkdMOzuCpZ9nOf2W1umSY/ccOXjfFr
KsXIRSKLzv0ieZKhoUBYBpDXigEMF9PI92RaT91iNRwmrSJuhwWThPcOE8oMzjML
Hi01YACEug9B6aEvDrlXkhB+gSoC1V4vMr00Asnx3zpnMyYKMRTNAPTW+h//PWP3
NnCak2PNcUGgzZ3kF5pNUMrHSQeep+CaYr8m4Pkiou0AfQa3eYi18js5OnpwPgi5
7ba9xsKaYU0d9duxmaS7EdOzLRU6ME/3oJPC8q/wg5WsgtxpIfNj/iLZtX5HiJ+q
7OblGtIiXc6z3sWEsEfmwV3++uUz49ChP6sLY9uMc/XzXVewXjx+6ZdgMAH67cWw
EXPw5+wYThUgd6/ptSRgbr2ciZmpUiVPinpz3NvRSE+Nr1tjunE+GgMRalUBNKeW
N3CbgTCC9q3cmTOZQtNdEuuHnoZD+UeRopFMGILbMY8gNLPbWA7GFF0w1+fMuyY0
eDKwylilSwdmcqN/E+k4f20y3ji84mZV/v+o6dlitbt0yfUmKbFmBJ8TsAJqIYhl
ZVxC8mz1q+MqEugXSYZ5RdMwAxkNn9URFU6q1Or9YgI+2NuFOe7lPChfQH6Tz2rt
9nzhrrDzlcU=
=MZw1
-----END PGP SIGNATURE-----

--Sig_/g.Y09H+IuqKUXSkdD6MaQSu--
