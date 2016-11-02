Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Benjamin Coddington <bcodding@redhat.com>
Date: Thu, 03 Nov 2016 10:34:56 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/6] NFSv4: change nfs4_do_setattr to take an open_context instead of a nfs4_state.
In-Reply-To: <0773ADA2-C1DE-4D01-8B3C-5883A6A62C2E@redhat.com>
References: <147633263771.766.17853370901003798934.stgit@noble> <147633280745.766.9047567139865023402.stgit@noble> <0773ADA2-C1DE-4D01-8B3C-5883A6A62C2E@redhat.com>
Message-ID: <877f8lqwv3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 03 2016, Benjamin Coddington wrote:

> On 13 Oct 2016, at 0:26, NeilBrown wrote:

>> @@ -3694,20 +3695,17 @@ nfs4_proc_setattr(struct dentry *dentry,=20
>> struct nfs_fattr *fattr,
>>
>>  	/* Search for an existing open(O_WRITE) file */
>>  	if (sattr->ia_valid & ATTR_FILE) {
>> -		struct nfs_open_context *ctx;
>>
>>  		ctx =3D nfs_file_open_context(sattr->ia_file);
>> -		if (ctx) {
>> +		if (ctx)
>>  			cred =3D ctx->cred;
>> -			state =3D ctx->state;
>> -		}
>>  	}
>
>
> Does this need a get_nfs_open_context() there to make sure the open=20
> context
> doesn't drop away?

I can't see why you would.  The ia_file must hold a reference to the
ctx, and this code doesn't keep any reference to the ctx after
nfs4_proc_setattr completes - does it?



>     I'm getting this on generic/089:
>
> [  651.855291] run fstests generic/089 at 2016-11-01 11:15:57
> [  652.645828] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [  653.166259] NFSD: client ::1 testing state ID with incorrect client=20
> ID
> [  653.167218] BUG: unable to handle kernel NULL pointer dereference at=20
> 0000000000000018

I think this BUG is happening in nfs41_check_expired_locks.
This:
	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
walks off the end of a list, finding a NULL on a list which should never
have a NULL pointer.  That does suggest a use-after-free of an
nfs4_lock_state, or possibly of an nfs4_state.

I can't see it in the code yet though.

>
> Something else is also wrong there.. wrapping that with
> get_nfs_open_context() makes the crash go away, but there are still=20
> several
> "NFS: nfs4_reclaim_open_state: Lock reclaim failed!" in the log.   Why=20
> would
> we be doing reclaim at all?  I'll look at a network capture next.

The
> [  653.166259] NFSD: client ::1 testing state ID with incorrect client ID

errors suggests that the client is sending a stateid that doesn't match
the client id, so the server reports and error and the client enters
state recovery.
Maybe one thread is dropping a flock lock while another thread is using
it for some IO and they race?  I think there are refcounts in place to
protect that but something might be missing.

I look forward to seeing the network capture.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYGnggAAoJEDnsnt1WYoG5I8cQALxeE0REU2vvGdoF9IGQf/sA
gkjIKVKpbSJfBN+xUuxsQsLndab4jS4iXOEnF2zvut6v8KtKwU+SeysyXrO7Jpu1
fqo0l4rGsAHidb/ZW1+ns+rEo6kSnAr919jW7nWMtkpM1dhfM8cTJ3v4b3x+gVqm
DgghT7JAuncPg8tabVCOkho41J5ZQ88OzNobi9G1xBb+0aqccrnwu0kQTgQizOAv
QHkKDxZUavtqANKoMEAQ3maU0Dty6vx17Efy0xJV3G1Szc7FATwms/3ibBVZlds8
vD8S1wUkgsqHmVzjivWyiVHVPs1hpR+KiR+UvgoGCXkxFHEIGJ0CuMwAnxNwpf+g
t+va8CP24R61FZavn8GZb4db5QbChJ4SuCJgRxwA8+u7yXix+BxzsR/IEMz3AUB6
j/zwzTldnJxdZ7jdiBVTuDBWkKzPXoEuaVC4fbg3tWYVVbHZVErqdIfAI+NKx6eV
UhzK4hHICsK5fb++e4OLhyppSSXSLDByhKqlNaPcHYDEPZG2WUs6bUYbDihJRuYJ
4DyKmCR351EITMO8PhLyCCr2gMETVFDkHDTMgN51qT0O7GPAcFbROm/kMpTty91+
WSkJOBCPNjrJkxDgf2h6YPlSOYyusqoPWjaXe9N5BTLR0BUhXlvuh91NfEccIJeO
DgVdLpz5ymODjFV8w25D
=APDV
-----END PGP SIGNATURE-----
--=-=-=--
