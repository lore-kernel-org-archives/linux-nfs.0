Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33301 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755045AbcHSVhW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 17:37:22 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Sat, 20 Aug 2016 07:37:14 +1000
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
Subject: Re: [PATCH 2/2] mount: RPC_PROGNOTREGISTERED should not be a permanent error
In-Reply-To: <20160819205953.GO32329@fieldses.org>
References: <147157095612.26568.14161646901346011334.stgit@noble> <147157115640.26568.2934329194247787636.stgit@noble> <20160819205953.GO32329@fieldses.org>
Message-ID: <87lgzsh245.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, Aug 20 2016, J. Bruce Fields wrote:

> Just one more thought about this one....
>
> If you mistakenly attempt to mount a server that's using rpc for some
> service other than nfs, then this will result in a hang where we
> previously got a useful error, right?

That is the one problem case - yes.
I prefer to think that it will result in a timeout, rather than a
hang.... but I'm a half-full kind-a-guy.

>
> Maybe that's a rare enough case not to worry about these days.

Trying to NFS mount a filesystem from a machine that doesn't serve NFS
should always be a rare case.
The most likely credible situation that I can come up with is a typo in
the server name.

If a site uses NIS there could very likely be servers that run rpcbind
but not nfsd, so the typo scenario certainly could happen (maybe file
servers are named after composers, while NIS servers are named after dog
noises) .  I think (hope?) that an unexpected delay it nearly as good as
an error message to say "you did something wrong" and that should be
enough for the typo to be noticed.

Thanks,
NeilBrown

>
> --b.
>
> On Fri, Aug 19, 2016 at 11:45:56AM +1000, NeilBrown wrote:
>> Commit: bf66c9facb8e ("mounts.nfs: v2 and v3 background mounts should re=
try when server is down.")
>>=20
>> changed the behaviour of "bg" mounts so that RPC_PROGNOTREGISTERED,
>> which maps to EOPNOTSUPP, is not a permanent error.
>> This useful because when an NFS server starts up there is a small window=
 between
>> the moment that rpcbind (or portmap) starts responding to lookup request=
s,
>> and the moment when nfsd registers with rpcbind.  During that window
>> rpcbind will reply with RPC_PROGNOTREGISTERED, but mount should not give=
 up.
>>=20
>> This same reasoning applies to foreground mounts.  They don't wait for
>> as long, but could still hit the window and fail prematurely.
>>=20
>> So revert the above patch and instead add EOPNOTSUPP to the list of
>> temporary errors known to nfs_is_permanent_error.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  utils/mount/stropts.c |    7 +++----
>>  1 file changed, 3 insertions(+), 4 deletions(-)
>>=20
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index 9de6794c6177..d5dfb5e4a669 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -948,6 +948,7 @@ static int nfs_is_permanent_error(int error)
>>  	case ETIMEDOUT:
>>  	case ECONNREFUSED:
>>  	case EHOSTUNREACH:
>> +	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
>>  	case EAGAIN:
>>  		return 0;	/* temporary */
>>  	default:
>> @@ -1019,8 +1020,7 @@ static int nfsmount_parent(struct nfsmount_info *m=
i)
>>  	if (nfs_try_mount(mi))
>>  		return EX_SUCCESS;
>>=20=20
>> -	/* retry background mounts when the server is not up */
>> -	if (nfs_is_permanent_error(errno) && errno !=3D EOPNOTSUPP) {
>> +	if (nfs_is_permanent_error(errno)) {
>>  		mount_error(mi->spec, mi->node, errno);
>>  		return EX_FAIL;
>>  	}
>> @@ -1055,8 +1055,7 @@ static int nfsmount_child(struct nfsmount_info *mi)
>>  		if (nfs_try_mount(mi))
>>  			return EX_SUCCESS;
>>=20=20
>> -		/* retry background mounts when the server is not up */
>> -		if (nfs_is_permanent_error(errno) && errno !=3D EOPNOTSUPP)
>> +		if (nfs_is_permanent_error(errno))
>>  			break;
>>=20=20
>>  		if (time(NULL) > timeout)
>>=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXt3wKAAoJEDnsnt1WYoG5TZsQAI0pdoSYcpsg+LUcGjQweAeu
hnTm/OO12pIDshs+p+pvwym2IP9r8FEmrf5g1fFLbuQeE9in9PkUuAvHr9FKQYR/
YXzQvZJqKhRf1v6rBudPVuB0xW3SQo9NgqFgYvXb60q2AjxotNkidSRxN02k1SMq
qs8YWCgL4KhLJ35M0J9a1mb9Ht0qMlA5oT8Vv7bv5SSSzwfwEWjczm10T8ca22dE
ucNofv42oWzY+IKbCyiKaKhZ2blP3JFO0qPLQdtXdpjKDK6Qcb3tRr12qyAv+y0U
kqM34JcvnNHmOEM+3IMhFzJCEwN3HyCncEZYJvQ0KpIioi8rvhwt5NBu4RNwxXaU
W2jc15+APkJZRdBfcRUBO7ow13LIUIpkH+1eVpPRoCgoGGkbqRrl2y6j5Ru0ONyE
sWq8+7/Xfnbb9SBG42WdDgCi6bNhlYr3QwqmLoLyjtCMbJTOWZlmBz6R7grsJKTd
66bG3i1PL+Vl/QAvXrFK/47IRSF8rNyaWVO7ParEKfnA/3FsGsKraWt1X9aEOcHW
Jj5nOrUss4AVxHpEPQsubZy323CZDJ0DddxVIOcuaT6lvByXoCX8/keDUP5gYDLp
1BzVwsBT/4x4r0fGGAsVlinqLZ5N6PKhFZvhWGGQFxiqOPMHAgybKBPvGDKPPQfE
r55E1VailYCZ1/f3sOpb
=ibDU
-----END PGP SIGNATURE-----
--=-=-=--
