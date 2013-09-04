Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:37146 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752537Ab3IDDZc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Sep 2013 23:25:32 -0400
Date: Wed, 4 Sep 2013 13:25:18 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC]  Don't try to recover NFS locks when they are lost.
Message-ID: <20130904132518.324edad3@notabene.brown>
In-Reply-To: <prdkh3xt7a0mituyt7v2xpmw.1378264657975@email.android.com>
References: <20130815123604.47755509@notabene.brown>
	<1378233802.6410.34.camel@leira.trondhjem.org>
	<20130904104946.1be45e52@notabene.brown>
	<prdkh3xt7a0mituyt7v2xpmw.1378264657975@email.android.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/918jdmWqIEjTKPRxMUu7v=/"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/918jdmWqIEjTKPRxMUu7v=/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 4 Sep 2013 03:17:41 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> Hi Neil,
>=20
> That looks better, but we still want to send the delegation stateid in th=
e case where we have both a lock and a delegation.

That is exactly what that code does.
First it checks for locks and aborts if a lost-lock was found.
Then it checks for delegations and returns one if found.
Then (if no delegation) it returns the lock stateid if that was found.
Then it goes on to the open stateid.

I'll combine it all into one patch and submit properly.

Thanks,
NeilBrown

>=20
> Cheers
>   Trond
>=20
> Sent from my tablet.
>=20
> NeilBrown <neilb@suse.de> wrote:
>=20
>=20
> On Tue, 3 Sep 2013 18:43:23 +0000 "Myklebust, Trond"
> <Trond.Myklebust@netapp.com> wrote:
>=20
> > On Thu, 2013-08-15 at 12:36 +1000, NeilBrown wrote:
> > >
> > > When an NFS (V4 specifically) client loses contact with the server it=
 can
> > > lose any locks that it holds.
> > > Currently when it reconnects to the server it simply tries to reclaim
> > > those locks.  This might succeed even though some other client has he=
ld and
> > > released a lock in the mean time.  So the first client might think th=
e file
> > > is unchanged, but it isn't.  This isn't good.
> > >
> > > If, when recovery happens, the locks cannot be claimed because some o=
ther
> > > client still holds the lock, then  we get a message in the kernel log=
s, but
> > > the client can still write.  So two clients can both think they have =
a lock
> > > and can both write at the same time.  This is equally not good.
> > >
> > > There was a patch a while ago
> > >   http://comments.gmane.org/gmane.linux.nfs/41917
> > >
> > > which tried to address some of this, but it didn't seem to go anywher=
e.
> > > That patch would also send a signal to the process.  That might be us=
eful
> > > but I'm really just interested in failing the writes.
> > > For NFSv4 (unlike v2/v3) there is a strong link between the lock and =
the
> > > write request so we can fairly easily fail an IO of the lock is gone.
> > >
> > > The patch below attempts to do this.  Does it make sense?
> > > Because this is a fairly big change I introduces a module parameter
> > > "recover_locks" which defaults to true (the current behaviour) but ca=
n be set
> > > to "false" to tell the client not to try to recover things that were =
lost.
> > >
> > > Comments?
> >
> > I think this patch is close to being usable. A couple of questions,
> > though:
> >
> >      1. What happens if another process' open() causes us to receive a
> >         delegation after NFS_LOCK_LOST has been set on our lock stateid,
> >         but before we call nfs4_set_rw_stateid()?
>=20
> Good point.  I think we need to check for NFS_LOCK_LOST before checking f=
or a
> delegation.  Does the incremental patch below look OK?
> It takes a spinlock in the case where we have a delegation and  hold some
> locks which it didn't have to take before.  Is that a concern?
>=20
>=20
> >      2. Shouldn't we clear NFS_LOCK_LOST at some point? It looks to me
> >         as if a process which sees the EIO, and decides to recover by
> >         calling close(), reopen()ing the file and then locking it again,
> >         might find NFS_LOCK_LOST still being set.
>=20
>=20
> NFS_LOCK_LOST is per nfs4_lock_state which should be freed by
> nfs4_fl_release_lock().
> So when the files is closed, the locks a dropped, and the structure holdi=
ng
> the NFS_LOCK_LOST flag will go away.
> Or did I miss something?
>=20
> Thanks,
> NeilBrown
>=20
>=20
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 4d103ff..bb1fd5d 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1040,10 +1040,11 @@ static int nfs4_copy_open_stateid(nfs4_stateid *d=
st, struct nfs4_state *state)
>  int nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
>                 fmode_t fmode, const struct nfs_lockowner *lockowner)
>  {
> -       int ret =3D 0;
> +       int ret =3D nfs4_copy_lock_stateid(dst, state, lockowner);
> +       if (ret =3D=3D -EIO)
> +               goto out;
>         if (nfs4_copy_delegation_stateid(dst, state->inode, fmode))
>                 goto out;
> -       ret =3D nfs4_copy_lock_stateid(dst, state, lockowner);
>         if (ret !=3D -ENOENT)
>                 goto out;
>         ret =3D nfs4_copy_open_stateid(dst, state);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/918jdmWqIEjTKPRxMUu7v=/
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUiaoHznsnt1WYoG5AQJY7xAAkPEGJbX/JlOCDMEvRtAt3ogUiSUDBKua
swbPULZG98hzsqtvednwYkps+EezZwMZDy9YEoiv/7eNkgLq9zJo3Y08hjdn8ENx
RDddWwcJmCkY6ZOxknXD9lyeYV343b3o/xXSwyneKFsrgsvD/vQ1tNkwgmxFjWDR
5uL9PbJ8tweWtMIKYOLTQ0OrF13ELu92f/WT+/hoGneuLuPOWE0Pm8VEknU5SXp7
w65kBFffkwpjbeQYrOIX4xMICaC4F+G9zs/1MYX1xCNj3VI0kBtaNr1TFT2NO9GM
2kwc+Eq/JUUA7BnvBrG5hOqYMwkqCMJxjQNlcJ3bDba+NCOhFibwgYl/smS6Ofb4
bi8ZoVu8APCedeHm3NLXCzUPqqhky6LPsAZkRXEkCUJpuX+sr3lfah5a8ujuhg/l
dHzlUCMI/o625vlp4RIBnFy1RJ4qrJR8kfv9CefONwczs07XQAo1C6xxL9Ej9Lbr
HwP4smEA8/8IJBH+YVlglH9BZmV4Py4ZqEeTBbYRgjdXFQ8hWpMLs+bajIHh++nK
OgjTJEMMRcuyefg2eveLfVJBszIt8Yyu/TpioHjxZPSKdiowvMVrs3aMtmz2Qfij
2TxGMKXTNuo1GC/FM76/AN0OoqJiKJELA9oZJWIVbrvU5xXA3Hwf8aGcIGmnE1Cj
h+2oicOgtQg=
=YwjQ
-----END PGP SIGNATURE-----

--Sig_/918jdmWqIEjTKPRxMUu7v=/--
