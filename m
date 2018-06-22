Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:52897 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754537AbeFVVth (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jun 2018 17:49:37 -0400
Received: by mail-it0-f67.google.com with SMTP id m194-v6so4812112itg.2
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jun 2018 14:49:37 -0700 (PDT)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [PATCH 2/2] nfsd: return ENOSPC if unable to allocate a session
 slot
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20180622175416.GA7119@fieldses.org>
Date: Fri, 22 Jun 2018 17:49:34 -0400
Cc: Manjunath Patil <manjunath.b.patil@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <148E65CF-D3D4-4E43-A190-822C5F7824B9@gmail.com>
References: <1529598933-16506-1-git-send-email-manjunath.b.patil@oracle.com>
 <1529598933-16506-2-git-send-email-manjunath.b.patil@oracle.com>
 <20180622175416.GA7119@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-


> On Jun 22, 2018, at 1:54 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Thu, Jun 21, 2018 at 04:35:33PM +0000, Manjunath Patil wrote:
>> Presently nfserr_jukebox is being returned by nfsd for create_session
>> request if server is unable to allocate a session slot. This may be
>> treated as NFS4ERR_DELAY by the clients and which may continue to =
re-try
>> create_session in loop leading NFSv4.1+ mounts in hung state. nfsd
>> should return nfserr_nospc in this case as per =
rfc5661(section-18.36.4
>> subpoint 4. Session creation).
>=20
> I don't think the spec actually gives us an error that we can use to =
say
> a CREATE_SESSION failed permanently for lack of resources.

The current situation is that the server replies NFS4ERR_DELAY,
and the client retries indefinitely. The goal is to let the
client choose whether it wants to try the CREATE_SESSION again,
try a different NFS version, or fail the mount request.

Bill and I both looked at this section of RFC 5661. It seems to
us that the use of NFS4ERR_NOSPC is appropriate and unambiguous
in this situation, and it is an allowed status for the
CREATE_SESSION operation. NFS4ERR_DELAY OTOH is not helpful.


> Better would be to avoid the need to fail at all.

That would be good too.


>  Possibilities:
>=20
> 	- revive Trond's patches some time back to do dynamic slot size
> 	  renegotiation
> 	- make sure the systems you're testing on already have
> 	  de766e570413 and 44d8660d3bb0 applied.
> 	- further liberalise the limits here: do we need them at all, or
> 	  should we just wait till a kmalloc fails?  Or maybe take a
> 	  hybrid approach?: e.g. allow an arbitrary number of clients
> 	  and only limit slots & slotsizes.

> --b.
>=20
>>=20
>> Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
>> ---
>> fs/nfsd/nfs4state.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>=20
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 8571414..3734e08 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -2716,7 +2716,7 @@ static __be32 check_forechannel_attrs(struct =
nfsd4_channel_attrs *ca, struct nfs
>> 	 */
>> 	ca->maxreqs =3D nfsd4_get_drc_mem(ca);
>> 	if (!ca->maxreqs)
>> -		return nfserr_jukebox;
>> +		return nfserr_nospc;
>>=20
>> 	return nfs_ok;
>> }
>> --=20
>> 1.8.3.1
>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chucklever@gmail.com



