Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52137 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751054AbdHSAun (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Aug 2017 20:50:43 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker\@netapp.com" <anna.schumaker@netapp.com>
Date: Sat, 19 Aug 2017 10:50:31 +1000
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/8] NFSv4: don't let hanging mounts block other mounts
In-Reply-To: <1503083150.11511.4.camel@primarydata.com>
References: <150304014011.30218.1636255532744321171.stgit@noble> <150304037188.30218.6679182255685764801.stgit@noble> <1503083150.11511.4.camel@primarydata.com>
Message-ID: <87378omld4.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 18 2017, Trond Myklebust wrote:

> On Fri, 2017-08-18 at 17:12 +1000, NeilBrown wrote:
>> If you try an NFSv4 mount from an inaccessible server, it will hang
>> as
>> you would expect.
>> If you then try an NFSv4 mount from a different accessible server,
>> it will also hang.  This is not expected.
>>=20
>> The second mount is blocked in
>>   nfs4_init_client()
>>   -> nfs4_discover_server_trunking()
>>   -> nfs40_discover_server_trunking()
>>   -> nfs40_walk_client_list()
>>   -> nfs4_match_client()
>>   -> nfs_wait_client_init_complete()
>> It is waiting for the first mount to complete so that it can then
>> see if the two servers are really one and the same.
>>=20
>> It is not necessary to wait here when an nfs_client cl_cons_state is
>> NFS_CS_INITING.  Such a client will, after changing cl_cons_state,
>> call
>> nfs4_discover_server_trunking() itself.  So if the current client
>> just
>> skips those clients, trunking will still be discovered if necessary.
>>=20
>> I am unsure of situation with NFS_CS_SESSION_INITING, but I suspect
>> that the comment "Wait for CREATE_SESSION to finish" implies that
>> it is only clients in NFS_CS_SESSION_INITING that need to be waited
>> for.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  fs/nfs/nfs4client.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>=20
>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>> index e9bea90dc017..d8b9b7ff19a9 100644
>> --- a/fs/nfs/nfs4client.c
>> +++ b/fs/nfs/nfs4client.c
>> @@ -482,7 +482,7 @@ static int nfs4_match_client(struct
>> nfs_client  *pos,  struct nfs_client *new,
>>  	 * remaining fields in "pos", especially the client
>>  	 * ID and serverowner fields.  Wait for CREATE_SESSION
>>  	 * to finish. */
>> -	if (pos->cl_cons_state > NFS_CS_READY) {
>> +	if (pos->cl_cons_state =3D=3D NFS_CS_SESSION_INITING) {
>>  		atomic_inc(&pos->cl_count);
>>  		spin_unlock(&nn->nfs_client_lock);
>
> This could cause us to declare a false positive match with a client
> that is uninitialised.

Thanks for the review.

A positive match is reported by returning zero.
If cl_cons_state is not NFS_CS_READY, nfs4_match_client() will not
return zero.

So I don't see how a false positive is possible.

A false negative might be possible with an uninitialized client, but
once that client is initialised, it will call walk_client_list and find
the match.  Won't it?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmXi1kACgkQOeye3VZi
gbnW3g//ZiHdvXWYhAEE5mWBhR/h1LNWIWdniV+cmysQDUyN+fc1irAEqHkJcQYM
NUE6A/fjFrBNhe2NoGkTmi36i5dVBEDRTZtCTFN6CXUq+cdqoK84xKnjd0jqy9Q4
ppyvxlci1QzghW9BzP/iePR4s1+haCUj4k5q290pBA/YsafI531Ld5XWuYHO8yxx
Bt4hCuAji4armjBF/oYxgHK7o3F4kh3Ee0qClMOORUrkMY0fJ6czVHEVfFeShDG/
A8fqZxjkjH48foEIu8ixJbyT5WYSM+DL4expclBG9h412AFUAFeS8Q3CsGEalOwe
Zn8UDBrpxyFHlgt9o2otxeP2C0SBX8kghQXKctiC7ZnMjz1/bUWQKybR72brC5be
MisW426RHqGhrNdp6y2cpjHMtuZPj/U8STccb0lBp88lBKxzL/zepRg0RutAQUFr
esEO9X2fYBqTp3uI5s8jIcznPwCWzkHXvNH0jSw2M6fB87dgzVk7ZsPxXDtxKjRs
z7bQF/oDZFqLglrvQTHkaAioXYjEhXpjCXzeI1NHF/K1ZkrWM8schMdVYm71PS80
ek79x8hT/zSiZM4W8nRaFS9g1hwKASzEmB/f4glMMc79X9s7IKqYTaeWHqqE/ALa
G4sTCy1HSapevRqB9GVewmwG64pC6RpsjVz8PF72uYRc8+PXubY=
=dFLv
-----END PGP SIGNATURE-----
--=-=-=--
