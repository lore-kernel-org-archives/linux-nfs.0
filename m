Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 14 Oct 2016 11:22:01 +1100
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/6] NFSv4: enhance nfs4_copy_lock_stateid to use a flock stateid if there is one
In-Reply-To: <1476372136.12134.12.camel@redhat.com>
References: <147633263771.766.17853370901003798934.stgit@noble> <147633280755.766.16463067741350482818.stgit@noble> <1476372136.12134.12.camel@redhat.com>
Message-ID: <87shrzzsnq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 14 2016, Jeff Layton wrote:

> On Thu, 2016-10-13 at 15:26 +1100, NeilBrown wrote:
>> A process can have two possible lock owner for a given open file:
>> a per-process Posix lock owner and a per-open-file flock owner
>> Use both of these when searching for a suitable stateid to use.
>>=20
>> With this patch, READ/WRITE requests will use the correct stateid
>> if a flock lock is active.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  fs/nfs/nfs4state.c |   14 +++++++++-----
>>  1 file changed, 9 insertions(+), 5 deletions(-)
>>=20
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index f25eee8202bf..ed39ee164f5f 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -800,11 +800,13 @@ void nfs4_close_sync(struct nfs4_state *state, fmo=
de_t fmode)
>>   * that is compatible with current->files
>>   */
>>  static struct nfs4_lock_state *
>> -__nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
>> +__nfs4_find_lock_state(struct nfs4_state *state,
>> +		       fl_owner_t fl_owner, fl_owner_t fl_owner2)
>>  {
>>  	struct nfs4_lock_state *pos;
>>  	list_for_each_entry(pos, &state->lock_states, ls_locks) {
>> -		if (pos->ls_owner !=3D fl_owner)
>> +		if (pos->ls_owner !=3D fl_owner &&
>> +		    pos->ls_owner !=3D fl_owner2)
>>  			continue;
>>  		atomic_inc(&pos->ls_count);
>>  		return pos;
>
> Ok, so we end up getting whatever is first on the list here. That's
> certainly fine when there are either flock/OFD locks or traditional
> POSIX locks in use.
>
> When there are both in use though, then things may be less predictable.
> That said, mixing flock/OFD and POSIX locks on the same fds from the
> same process is not a great idea in general, and I have a hard time
> coming up with a valid use-case there.

Using two types of locks in the one application would be ... unusual.
I wouldn't want to spend much of addressing any issues, but not being
predictable isn't good.  Intermittent problems are so hard to debug.

We should probably make sure it consistently chooses on or the other.
As flock locks are always whole-file, it is always safe to choose the
flock lock over the posix lock as you can be sure the IO is covered by
the lock. OFD locks make that a little be less of a clear choice.

On the other hand, NFS locks were originally only Posix locks and flock
locks were only supported much later.  So for historical consistency we
should probably choose the Posix stateid preferentially.

I find the second argument more convincing.   Here is the updated patch.

Thanks,
NeilBrown

From: NeilBrown <neilb@suse.com>
Subject: [PATCH] NFSv4: enhance nfs4_copy_lock_stateid to use a flock state=
id
 if there is one

A process can have two possible lock owner for a given open file:
a per-process Posix lock owner and a per-open-file flock owner
Use both of these when searching for a suitable stateid to use.

With this patch, READ/WRITE requests will use the correct stateid
if a flock lock is active.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/nfs4state.c | 38 +++++++++++++++++++++++++++-----------
 1 file changed, 27 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index f25eee8202bf..bd29d4360660 100644
=2D-- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -797,19 +797,33 @@ void nfs4_close_sync(struct nfs4_state *state, fmode_=
t fmode)
=20
 /*
  * Search the state->lock_states for an existing lock_owner
=2D * that is compatible with current->files
+ * that is compatible with either of the given owners.
+ * If the second is non-zero, then the first refers to a Posix-lock
+ * owner (current->files) and the second refers to a flock/OFD
+ * owner (struct file*).  In that case, prefer a match for the first
+ * owner.
+ * If both sorts of locks are held on the one file we cannot know
+ * which stateid was intended to be used, so a "correct" choice cannot
+ * be made.  Failing that, a "consistent" choice is preferable.  The
+ * consistent choice we make is to prefer the first owner, that of a
+ * Posix lock.
  */
 static struct nfs4_lock_state *
=2D__nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
+__nfs4_find_lock_state(struct nfs4_state *state,
+		       fl_owner_t fl_owner, fl_owner_t fl_owner2)
 {
=2D	struct nfs4_lock_state *pos;
+	struct nfs4_lock_state *pos, *ret =3D NULL;
 	list_for_each_entry(pos, &state->lock_states, ls_locks) {
=2D		if (pos->ls_owner !=3D fl_owner)
=2D			continue;
=2D		atomic_inc(&pos->ls_count);
=2D		return pos;
+		if (pos->ls_owner =3D=3D fl_owner) {
+			ret =3D pos;
+			break;
+		}
+		if (pos->ls_owner =3D=3D fl_owner2)
+			ret =3D pos;
 	}
=2D	return NULL;
+	if (ret)
+		atomic_inc(&ret->ls_count);
+	return ret;
 }
=20
 /*
@@ -857,7 +871,7 @@ static struct nfs4_lock_state *nfs4_get_lock_state(stru=
ct nfs4_state *state, fl_
=20=09
 	for(;;) {
 		spin_lock(&state->state_lock);
=2D		lsp =3D __nfs4_find_lock_state(state, owner);
+		lsp =3D __nfs4_find_lock_state(state, owner, 0);
 		if (lsp !=3D NULL)
 			break;
 		if (new !=3D NULL) {
@@ -942,7 +956,7 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 		const struct nfs_lock_context *l_ctx)
 {
 	struct nfs4_lock_state *lsp;
=2D	fl_owner_t fl_owner;
+	fl_owner_t fl_owner, fl_flock_owner;
 	int ret =3D -ENOENT;
=20
 	if (l_ctx =3D=3D NULL)
@@ -952,8 +966,10 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 		goto out;
=20
 	fl_owner =3D l_ctx->lockowner.l_owner;
+	fl_flock_owner =3D l_ctx->open_context->flock_owner;
+
 	spin_lock(&state->state_lock);
=2D	lsp =3D __nfs4_find_lock_state(state, fl_owner);
+	lsp =3D __nfs4_find_lock_state(state, fl_owner, fl_flock_owner);
 	if (lsp && test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
 		ret =3D -EIO;
 	else if (lsp !=3D NULL && test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) =
!=3D 0) {
=2D-=20
2.10.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYACUpAAoJEDnsnt1WYoG51rgQAI5eC/VKnDZVbJHrFC0YI/Uv
juhYMg2z8NghVvaC5ACWoTTUxudGfudBk1wuVcxXiaEoskVYO75VUYTt/ZNQCNr0
zmDDNwO4GqDCANTgm/ErsBiGfXCFUdYmOrtRCBFpyINLxdCal8pmkC/vz1RpefRh
sssgeLtEHedoBd7t8xO5azm0heQiReyAxyk56k/BAfOb9Q1hb9uGvHXhdtpLIbr+
cXLEtA9t9fhh8BnvGnpozGqN/JjcjYygoBCmGiGeFPpwNgs1+t/QSTYHbwtlh+Rd
bq+7AAB5PUvYS5v/o9MqNT+HF9EZqIfzvJFasd1ZTIZf65bLCEtuvnm7UuyFSZKN
EZZnaR27OkKPH1363QtAx6HxV7ispH44G/mhJFfTldfl3ywsLqolgC/sszlJTc5h
Fcw1ZkDnVOfwUEXHwT2HLkPoCQTw4xup0Wgcv1IHwXxiYovWeGny1ObHePEB6Yv6
vdijje6WXFCy+UDD2R/d4zLlI2Eub0MLqB6xK34mZ48J8nM0dbMTY8XHW1l33oxZ
tIdKeTXWUOOerbz/5sq/vJ4L7n3nMRamTUZuRW4kbBYWrk8aDhUQNUH0jjGEjZv3
NH78moNMQT4arVMVomqIwQOM5QikgWGErrEj5YcK7pPaJau+AngJTmMch5PYjkHq
OIHHDQH5lvz4VClTypKV
=1Ubf
-----END PGP SIGNATURE-----
--=-=-=--
