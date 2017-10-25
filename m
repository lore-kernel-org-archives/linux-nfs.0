Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43899 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751792AbdJYVTd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 25 Oct 2017 17:19:33 -0400
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>
Date: Thu, 26 Oct 2017 08:19:20 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: use supplimental groups in auth hash.
In-Reply-To: <CF1E0D4B-4EB3-4951-B152-39646ECF19DA@oracle.com>
References: <87h8upe6bp.fsf@notabene.neil.brown.name> <CF1E0D4B-4EB3-4951-B152-39646ECF19DA@oracle.com>
Message-ID: <877evjdixz.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 25 2017, Chuck Lever wrote:

>> On Oct 23, 2017, at 8:29 PM, NeilBrown <neilb@suse.com> wrote:
>>=20
>>=20
>> Some sites vary some supplimental groups a lot.
>> To avoid unduely long hash chains, include all of these
>> in the hash calculation.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>=20
>> Hi,
>> I have a customer who had thousands of auth entries with the same
>> uid and gid, so the hashtable was unbalanced and some lookups were
>> noticeably slow.  This fix helped.
>>=20
>> Relatedly, I wonder if we should set a default auth_max_cred_cachesize,
>> and nfs_access_max_cachesize - smaller than ULONG_MAX.
>>=20
>> For auth_max_cred_cachesize, a default of e.g. 256*(1<<auth_hashbits)
>> is appropriate I think.  If there are more auth entries than that,
>> you'll start to notice lookups taking a long time.
>>=20
>> For nfs_access_max_cachesize we want a similar limit as each access
>> entry pins an auth entry and so keeps a hash chain long.
>>=20
>> Or maybe we could change the auth lookup to use an rbtree (or
>> hash-table of rbtrees?) so that time scales with log of size.
>>=20
>> One option is to restore the 'jiffies' field to the access cache, and
>> discard entries older than (say) 10 minutes.
>>=20
>> Thoughts?
>
> Seems like we are always revisiting the hash function, and
> there are always workloads where long chains occur. Since
> the lookup-to-insertion ratio is very high, maybe it's time
> to consider a data structure that self-balances on insertion,
> like an rb-tree.

I'm certainly open to that possibility.

>
> Would it make sense to protect the cache with a rwlock
> instead of spin lock to allow concurrent readers?

I doubt if rwlocks are ever really useful.  If there is noticeable
contention between readers, then a lockless/RCU based approach should be
preferred.

>
> Is there any sane way to make the cred cache into a set of
> per CPU caches instead, to reduce the need for locking?

Encouraged by your outside-the-box thinking, I have another question.
Do we need the auth cache at all?  What is it actually caching?
For gss, I can easily imagine there is something worth storing in a
cache, but what value do the 'generic' and 'auth_unix' caches provide?

Does anyone know?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlnw/9oACgkQOeye3VZi
gbnzXQ//ZIhMuuhJCtpR96fwxWp29NzwSq9Da37ypqk06Kj5yI2oV3NHXcx7fFHC
sqai7Ebwsac0EW7NePMj+HW6ix4p1YMpG3MVTXu5disAK0SC5SF+frvxf1Zvnr8G
tBB/tcd+Ys68zOPdP23SGv39xHpyc1kubqMPemq8rknyZzN852o8qVp7u5N+htyk
4BCSPFGcAoqeRtO22SpMbyRTkip3t2/bPd9dVEhiNvfHfIBDapQahMr+q9aH1LQR
gOVxkuewzqTxcx99udmYkArVx4KAX9j2pv4jfN20fmVUAwnR5C2LCBW0O7cPpvAY
VBBkwAcCsqQJqJxIJ9zPTT2HKau+qoiG1n0P1TLPzKWwt3pU/Nm1bMeZdSZf+GuD
5OQuYzzdDTi12sDgEl3B+c5vH5BJp7hWeq/Ktv1HiPSQZ+nP/yETzV4wVSpCip7C
9fajA6jkaPEyjqiNGtAfNphINlE9+j2g3xkuDntQmWwWEo0LxcVJoYMWTKBFXvZo
NzWoKQYdL9Xfy3nSPR7VuNcHc//fvhx+/8YwvJDJL4XD+hH5utv8iAOqOEItKYkB
GdoiC0jeMBqn+lo9BNATvdehsr6HntzMenJcoCu/SqB/PGSuLQDzCw/l3Layj4rc
9TReX5da5jA9rSDZ49zpxi4hrtcE1MfAgyD59njviyITAvssG6A=
=8pKM
-----END PGP SIGNATURE-----
--=-=-=--
