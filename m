Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:43703 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755449AbcHXTF1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Aug 2016 15:05:27 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Lever Chuck <chuck.lever@oracle.com>
CC: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: READ during state recovery uses zero stateid
Date: Wed, 24 Aug 2016 19:05:20 +0000
Message-ID: <832771A7-EF94-475C-871E-EE9499EC75B3@primarydata.com>
References: <AB29A5B8-1564-4C31-A843-F0C5CC4C91F1@oracle.com>
 <87A94B50-A9D5-44FF-9F78-F916C98E6767@primarydata.com>
 <182FCDA3-1BD7-436F-88A3-B29AAD7E6BAE@oracle.com>
In-Reply-To: <182FCDA3-1BD7-436F-88A3-B29AAD7E6BAE@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 24, 2016, at 14:47, Chuck Lever <chuck.lever@oracle.com> wrote:
>=20
>=20
>> On Aug 24, 2016, at 2:23 PM, Trond Myklebust <trondmy@primarydata.com> w=
rote:
>>=20
>>>=20
>>> On Aug 24, 2016, at 14:10, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>=20
>>> Hi-
>>>=20
>>> I have a wire capture that shows this race while a simple I/O workload =
is
>>> running:
>>>=20
>>> 0. The client reconnects after a network partition
>>> 1. The client sends a couple of READ requests
>>> 2. The client independently discovers its lease has expired
>>> 3. The client establishes a fresh lease
>>> 4. The client destroys open, lock, and delegation stateids for the file
>>> that was open under the previous lease
>>> 5. The client issues a new OPEN to recover state for that file
>>> 6. The server replies to the READs in step 1. with NFS4ERR_EXPIRED
>>> 7. The client turns the READs around immediately using the current open
>>> stateid for that file, which is the zero stateid
>>> 8. The server replies NFS4_OK to the OPEN from step 5
>>>=20
>>> If I understand the code correctly, if the server happened to send thos=
e
>>> READ replies after its OPEN reply (rather than before), the client woul=
d
>>> have used the recovered open stateid instead of the zero stateid when
>>> resending the READ requests.
>>>=20
>>> Would it be better if the client recognized there is state recovery in
>>> progress, and then waited for recovery to complete, before retrying the
>>> READs?
>>>=20
>>=20
>> Why isn=92t the session draining taking care of ensuring the READs don=
=92t happen until after recovery is done?
>=20
> This is NFSv4.0. (Apologies, I recalled NFS4ERR_EXPIRED had been removed
> from NFSv4.1, but I see that I was mistaken).
>=20
> Here's step 1 and 2, exactly. After the partition heals, the client sends=
:
>=20
> C READ
> C GETATTR
> C READ
> C RENEW
>=20
> The server responds to the RENEW first with GSS_CTXPROBLEM. The client's
> gssd connects and establishes a fresh GSS context. The client sends the
> RENEW again with the fresh context, and the server responds NFS4ERR_EXPIR=
ED.
> This triggers step 3.
>=20
> The replies for those READ calls are in step 6., after state recovery
> has started.

This is what I=92m confused about: Normally, I=92d expect the NFSv4.0 code =
to drain, due to the checks in nfs40_setup_sequence().

IOW: there should be 2 steps

   2.5) Call nfs4_drain_slot_tbl() and wait for operations to complete
   2.6) Process the NFS4ERR_EXPIRED errors returned by the READ requests se=
nt in (1).

before we get to recovering the lease in (3)...

