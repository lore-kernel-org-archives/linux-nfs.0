Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45487 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752275AbcBBEKw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Feb 2016 23:10:52 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Tue, 02 Feb 2016 15:10:43 +1100
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Dave Chinner <dchinner@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC] VFS: Improve fairness when locking the per-superblock s_anon list
In-Reply-To: <20160201212601.GE5499@fieldses.org>
References: <87fuxh1bo8.fsf@notabene.neil.brown.name> <20160201212601.GE5499@fieldses.org>
Message-ID: <87vb67bvlo.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 02 2016, J. Bruce Fields wrote:

> On Fri, Jan 29, 2016 at 11:17:43AM +1100, NeilBrown wrote:
>> bit-spin-locks, as used for dcache hash chains, are not fair.
>> This is not a problem for the dcache hash table as different CPUs are
>> likely to access different entries in the hash table so high contention
>> is not expected.
>> However anonymous dentryies (created by NFSD) all live on a single hash
>> chain "s_anon" and the bitlock on this can be highly contended, resulting
>> in soft-lockup warnings.
>
> Just out of curiosity, because I can't recall seeing complaints about
> warnings, when do you see it happen?  Server reboot, maybe?

Soft-lockup warnings.  Possibly some client might notice delays longer
than they should be, but the only actual complaints have been about the war=
nings.

>
> It should be hitting that __d_obtain_alias() case only when a filehandle
> lookup finds a file without a cached dentry, which is an important case
> to handle, but not normally what I'd expect to be the common case.  Am I
> forgetting something?

I don't think you are missing anything significant.  I too was somewhat
surprised that there would be enough contention to cause problems, but
the evidence was fairly conclusive (at two separate sites), and the
proposed fix made the symptoms disappear.

Maybe there are a great many different files being accessed and a lot of
memory pressure on the server keeps pushing them out of cache.  I find
that customers often have loads that have quite different from what I
might expect...

Thanks,
NeilBrown


>
> --b.
>
>>=20
>> So introduce a global (fair) spinlock and take it before grabing the
>> bitlock on s_anon.  This provides fairness and makes the warnings go awa=
y.
>>=20
>> We could alternately use s_inode_list_lock, or add another spinlock
>> to struct super_block.  Suggestions?
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>=20
>> Dave: I'd guess you would be against using the new s_inode_list_lock
>> for this because it is already highly contended - yes?
>> Is it worth adding another spinlock to 'struct super_block' ?
>>=20
>> Thanks,
>> NeilBrown
>>=20
>>=20
>>  fs/dcache.c | 8 ++++++++
>>  1 file changed, 8 insertions(+)
>>=20
>> diff --git a/fs/dcache.c b/fs/dcache.c
>> index 92d5140de851..e83f1ac1540c 100644
>> --- a/fs/dcache.c
>> +++ b/fs/dcache.c
>> @@ -104,6 +104,8 @@ static unsigned int d_hash_shift __read_mostly;
>>=20=20
>>  static struct hlist_bl_head *dentry_hashtable __read_mostly;
>>=20=20
>> +static DEFINE_SPINLOCK(s_anon_lock);
>> +
>>  static inline struct hlist_bl_head *d_hash(const struct dentry *parent,
>>  					unsigned int hash)
>>  {
>> @@ -490,10 +492,14 @@ void __d_drop(struct dentry *dentry)
>>  		else
>>  			b =3D d_hash(dentry->d_parent, dentry->d_name.hash);
>>=20=20
>> +		if (b =3D=3D &dentry->d_sb->s_anon)
>> +			spin_lock(&s_anon_lock);
>>  		hlist_bl_lock(b);
>>  		__hlist_bl_del(&dentry->d_hash);
>>  		dentry->d_hash.pprev =3D NULL;
>>  		hlist_bl_unlock(b);
>> +		if (b =3D=3D &dentry->d_sb->s_anon)
>> +			spin_unlock(&s_anon_lock);
>>  		dentry_rcuwalk_invalidate(dentry);
>>  	}
>>  }
>> @@ -1978,9 +1984,11 @@ static struct dentry *__d_obtain_alias(struct ino=
de *inode, int disconnected)
>>  	spin_lock(&tmp->d_lock);
>>  	__d_set_inode_and_type(tmp, inode, add_flags);
>>  	hlist_add_head(&tmp->d_u.d_alias, &inode->i_dentry);
>> +	spin_lock(&s_anon_lock);
>>  	hlist_bl_lock(&tmp->d_sb->s_anon);
>>  	hlist_bl_add_head(&tmp->d_hash, &tmp->d_sb->s_anon);
>>  	hlist_bl_unlock(&tmp->d_sb->s_anon);
>> +	spin_unlock(&s_anon_lock);
>>  	spin_unlock(&tmp->d_lock);
>>  	spin_unlock(&inode->i_lock);
>>  	security_d_instantiate(tmp, inode);
>> --=20
>> 2.7.0
>>=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWsCxDAAoJEDnsnt1WYoG5XIYP/2f9VDZOQOBbFvpZ6QaiQtq7
1kyv66HWIq0GhjlWoVWw4dijr2q4CLhBQYocj8VPqxf2ySRK3B638iI/K8U7MlyG
3BtaY6o0D+4XhqSUbzNWqV0o5bKTxGDcfgT7R1vckMXB3Duhks1ox0JU8EyXbivN
dYB0nkuJkCVP0UNdsu2W7w8gnYRqxKwhuwNyQzu5R3R2HQRba9hILHlEIOg7T2lC
Yf2lP2LLI0vrv5KTrd48ZsffvmNer1YyAND+cItPCw2o4chmu8fyr0nfesn8cVx/
jE4OTBfgcM0vVKbbZv5pN+cuhRZxIlmTQO719/eltiLqPgHVY7JnRe8h1J30bgS0
nLXMTi4APJ2ARiDomL9hTgRNuW0XMHHtpGk3ioZR2UomXYIeefikqB5bDSCx1Ayz
LoLFPYG1NRETvMC5Zldeh8cAmczl9cbvvLH63C010J8ntmiXxP37JwPSZRlexXRk
VgG6yB/Z7o77wIr9UseR7sW5KL6WlEPt/OUtWomtccAdqNwNCUuKnianaENXMfUX
J05df4/o+gZmoh8EsMDRr8I94sT5nXvveNZujH2zSw9HYnyUBVTJ3ir4xGmf5l0d
5FFO28GzevZc4Z4InwGNVi6M4icCcjpT592wYrxTKmFlVrz2pLm+lFm+mnTxp517
wOg2l0qQfbfGf3dQFzlr
=8FMu
-----END PGP SIGNATURE-----
--=-=-=--
