Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34217 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761538Ab3IDAt7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Sep 2013 20:49:59 -0400
Date: Wed, 4 Sep 2013 10:49:46 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Subject: Re: [PATCH/RFC]  Don't try to recover NFS locks when they are lost.
Message-ID: <20130904104946.1be45e52@notabene.brown>
In-Reply-To: <1378233802.6410.34.camel@leira.trondhjem.org>
References: <20130815123604.47755509@notabene.brown>
	<1378233802.6410.34.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/vyyQpCS=nm.cm2Ex25AAjE9"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/vyyQpCS=nm.cm2Ex25AAjE9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 3 Sep 2013 18:43:23 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-08-15 at 12:36 +1000, NeilBrown wrote:
> >=20
> > When an NFS (V4 specifically) client loses contact with the server it c=
an
> > lose any locks that it holds.
> > Currently when it reconnects to the server it simply tries to reclaim
> > those locks.  This might succeed even though some other client has held=
 and
> > released a lock in the mean time.  So the first client might think the =
file
> > is unchanged, but it isn't.  This isn't good.
> >=20
> > If, when recovery happens, the locks cannot be claimed because some oth=
er
> > client still holds the lock, then  we get a message in the kernel logs,=
 but
> > the client can still write.  So two clients can both think they have a =
lock
> > and can both write at the same time.  This is equally not good.
> >=20
> > There was a patch a while ago
> >   http://comments.gmane.org/gmane.linux.nfs/41917
> >=20
> > which tried to address some of this, but it didn't seem to go anywhere.
> > That patch would also send a signal to the process.  That might be usef=
ul
> > but I'm really just interested in failing the writes.
> > For NFSv4 (unlike v2/v3) there is a strong link between the lock and the
> > write request so we can fairly easily fail an IO of the lock is gone.
> >=20
> > The patch below attempts to do this.  Does it make sense?
> > Because this is a fairly big change I introduces a module parameter
> > "recover_locks" which defaults to true (the current behaviour) but can =
be set
> > to "false" to tell the client not to try to recover things that were lo=
st.
> >=20
> > Comments?
>=20
> I think this patch is close to being usable. A couple of questions,
> though:
>=20
>      1. What happens if another process' open() causes us to receive a
>         delegation after NFS_LOCK_LOST has been set on our lock stateid,
>         but before we call nfs4_set_rw_stateid()?

Good point.  I think we need to check for NFS_LOCK_LOST before checking for=
 a
delegation.  Does the incremental patch below look OK?
It takes a spinlock in the case where we have a delegation and  hold some
locks which it didn't have to take before.  Is that a concern?


>      2. Shouldn't we clear NFS_LOCK_LOST at some point? It looks to me
>         as if a process which sees the EIO, and decides to recover by
>         calling close(), reopen()ing the file and then locking it again,
>         might find NFS_LOCK_LOST still being set.


NFS_LOCK_LOST is per nfs4_lock_state which should be freed by
nfs4_fl_release_lock().
So when the files is closed, the locks a dropped, and the structure holding
the NFS_LOCK_LOST flag will go away.
Or did I miss something?

Thanks,
NeilBrown


diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 4d103ff..bb1fd5d 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1040,10 +1040,11 @@ static int nfs4_copy_open_stateid(nfs4_stateid *dst=
, struct nfs4_state *state)
 int nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
 		fmode_t fmode, const struct nfs_lockowner *lockowner)
 {
-	int ret =3D 0;
+	int ret =3D nfs4_copy_lock_stateid(dst, state, lockowner);
+	if (ret =3D=3D -EIO)
+		goto out;
 	if (nfs4_copy_delegation_stateid(dst, state->inode, fmode))
 		goto out;
-	ret =3D nfs4_copy_lock_stateid(dst, state, lockowner);
 	if (ret !=3D -ENOENT)
 		goto out;
 	ret =3D nfs4_copy_open_stateid(dst, state);

--Sig_/vyyQpCS=nm.cm2Ex25AAjE9
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUiaDqjnsnt1WYoG5AQI1/w//W8P50hXe5uwUxVoJ3OwxJxaCsk8F+3Zu
hAK9291abPCNUkuI9zmhPHPW4OOK/yoP5wn20sMhfGQfNeOnmUL4elxFMYzQ9zZQ
+UA8BsYeSpglCbZYAaFg2rc5CxE42oySxPZBfnsSl7lgqmZD+kjQvsY4ztRx5e8J
Qr5TRvl6k6184fdTjnqUcpnyT6sWehV7NOIfqGGduCXGXXBqOOPU1w8eeRifygCm
DGtxv+fHLekJoZu/e36HT9Izz/CcnbyYVt74F6v9Yw6oFuQ2nuhHnM74BbaM4RCR
tOgFTIqwbkdd7PNBf+XX3TwYlUgueon+M4Nn3Sy4azfwYHbBYXiKBH9K5i+rzmzW
fg4PAw9NQlIxPRPTDeJycvI35/CwvCC6TKvjvJUSSpdtpYne1m9vJlItLTCYY7Cd
p2LLoDymCh0YldDPbR4SyIHp9yZjUIZZagXPuvRMiCe+V8Doa7h+BlPpxNrxIKzL
N8KwEEVYYh+QHgITczs2bNL4hHT/VtUcraVID+Zp7A+w0PvIq/TgWZYFX8RNHjGv
FQYKjZXS2uheNkL5d3R3KjnGCdcby97yajQDSl0/8kuE9Fps58HFFouVH9Bj/zSv
tehtbmV2CZha4Tw3lWM9zqRA/XrKgFQMBlBn/3P5pLAIWh+Z0Jjlp6ix95kMpTlk
8d+GctloM0k=
=17V1
-----END PGP SIGNATURE-----

--Sig_/vyyQpCS=nm.cm2Ex25AAjE9--
