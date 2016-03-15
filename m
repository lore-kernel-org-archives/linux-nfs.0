Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60004 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932924AbcCOWcT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2016 18:32:19 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 16 Mar 2016 09:32:10 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH - nfsv4-acl-tools] nfs4_ace_from_string: ignore inheritance ACEs on non-directories.
In-Reply-To: <20160314210659.GB22276@fieldses.org>
References: <8760xen4ph.fsf@notabene.neil.brown.name> <20160314210659.GB22276@fieldses.org>
Message-ID: <8737rrgyol.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 15 2016, J. Bruce Fields wrote:

> On Wed, Feb 24, 2016 at 02:54:18PM +1100, NeilBrown wrote:
>>=20
>> If you try to use
>>      nfs4_setfacl -R -a A:d:........   directory
>>=20
>> to recursively set an inheritance ACE on all directories in a tree, it
>> will fail on the first non-directory as setting an inheritance ACE
>> there is not permitted (and as it aborts on the first sign of an error).
>>=20
>> So use the is_dir flag to avoid doing that, just as is done with the
>> DELETE_CHILD permission.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>=20
>> Hi Bruce,
>>  are you still maintaining nfsv4-acl-tools?  Last commit was over
>>  a year ago!! I guess that means it is nearly perfect :-)
>
> Alas, it could probably use some love.  I'm hoping richacls take over,
> though.  Eventually.
>
>>  A customer came across this problem and it seems simple to fix,
>>  but if I'm missing something important, please let me know.
>
> I didn't trace carefully through the callers, but I suspect this'll also
> mean that nfs4_setfacl also silently discards inheritable ACEs in some
> cases where the user could know better, instead of erroring out?

I guess so.  If you give a file on the command line then you still want
the error.  If you give a directory and "-R" you don't.  I wonder how
much work that would be....

>
> But, honestly, I'm not necessarily even sure which is the better
> behavior, and -R needs to work, so, applying.

Thanks.

>
> Futher patches, or volunteers for maintenance, welcome....

:-)  Patches, maybe.  The rest - not me!!

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW6I1qAAoJEDnsnt1WYoG5kZYQALkSEaAU6V1hPkfCNkdfDTGZ
mtiLQGpi19LyFbNSPoyjCQVClKy2Jhwzn2W7pPscg2X5p49zJ9co6F79kwVW6sv6
RfDQ9VcQf9Yj6HC24en3c1oFF/HI7t6Y3mihhtX2C5J+ETJV+JCokAb29U2M2ZKQ
15GMeTg6jfmUUJZSK5ncqWHwzJqeGcEyGJqzG/cfYt/XlW7yE156RLghYmLL6eF1
LWrzsz8Xh2CCEhNt02kKoRl1O0/T84UGAo6gSs8Qt24wbannYubA4HnDipOemy1T
2f2CcDy3JlgSNjaWlSCwLMzOZ7mqY7aXzyTXKqzO3gHRBk1myfgJjwJNHBaDyHD8
3EKADYraOLnzH5ihIwPkmqpLMqqLz5IAnF0d/CTBrebAPNZ+uRzHS/a05pi0UuBr
j8rKAX3mNFfUiog9SuP1Z0f4ehfsrToqhqQwRub7GJb/alIQ4WAC8cDYnAoCV2HN
WWnKHLV22dlJQiJfgAS2ufutd6FT6LXB91oX7MvF1HYkG9g3t/EFsn+GjY9ExMTq
qNNYhPjunMzRjSwv7kRfO7QRsX4nnnFm+qd3VLqKplty/1+scranWTiT7jDm87eS
Zq0a1XOIfW/iF6LQjwSd0WM3lCuZAN62A7VOXHBd2c/0b8XUXyqAoo/gHuUzku2s
ZpgMJuvvBndQFVOhVIT9
=sAxx
-----END PGP SIGNATURE-----
--=-=-=--
