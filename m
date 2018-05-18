Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:51282 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750763AbeERU4m (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2018 16:56:42 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyFs4nxAwVynpr=Q5d_t+N5s9sa=2+1mj4-pZ-m1Xe3ZRA@mail.gmail.com>
Date: Fri, 18 May 2018 16:56:22 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Message-Id: <EDBF0CF4-3E94-44EF-8541-9445409F0B9B@oracle.com>
References: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
 <CAN-5tyGDGOqPKXKD+LQq8Ub3CUosmaaAq=ir3Gp7R3LKABwtEQ@mail.gmail.com>
 <DB8E23EF-80A4-48D0-B53C-AD2A4B0076E2@oracle.com>
 <CAN-5tyFs4nxAwVynpr=Q5d_t+N5s9sa=2+1mj4-pZ-m1Xe3ZRA@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 18, 2018, at 4:11 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> On Fri, May 18, 2018 at 3:23 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>>=20
>>> On May 18, 2018, at 2:53 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>=20
>>> Hi Chuck,
>>>=20
>>> I'm not convinced that "srchost=3D" is necessary. I believe that
>>> everything that is needed is suppose to be encoded in the "target=3D"
>>> option.
>>=20
>> I don't believe target=3D has what we want. For NFSv4.0 callback:
>>=20
>>  A. The callback source principal needs to be the same as the =
client's
>>     NFS server target principal.
>=20
> Correct and by specifying "nfs" and "*" I think that signals to the
> gssd to pick the NFS server principal (which is what the client would
> used as the target for the client to server authentication).
>=20
>>  B. The callback target principal needs to be the same as the =
client's
>>     NFS server source principal.
>>=20
>> Today, for NFSv4.0 callbacks, the kernel passes to gssd:
>>=20
>>  target=3D it uses B for this
>>=20
>>  service=3D it always sets this to "nfs"
>>=20
>> And gssd "makes up" the hostname part of A using gethostname(3), =
which
>> is bogus for multi-homed NFS servers.
>=20
> I agree that's bogus. Instead we should grab the domain from the
> "target=3D" string.
>=20
>=20
>> So my patch series does the following for NFSv4.0 callbacks:
>>=20
>> 1. It acquires the actual target principal the client used to =
establish
>>   it's lease. This is A above.
>>=20
>> 2. Instead of always passing "nfs" as the service=3D value, it passes
>>   the non-hostname part of A. That should be "nfs" but it doesn't
>>   have to be.
>=20
> Ok so yes it has historically have always been "nfs" (even thought
> it's only RECOMMENDED by the spec) and I don't think this is the case
> to add complexity to change a well established behavior?
>=20
>> 3. Instead of letting gssd make up the hostname part of the source
>>   principal, it passes the hostname part of A.
>=20
> I'm arguing that hostname part of A should have been a part of the =
"target=3D"

For a callback credential upcall:

  target name=3D client's principal @ client's hostname
  source name=3D server's principal @ server's hostname

I don't see how gssd on a multi-homed server could derive "server's
hostname" correctly from "client's hostname" in every case. As I
explained below, the kernel retains the correct "server's hostname"
string in clp->cl_cred even if the client should connect from another
hostname within the lease expiry period.

Example:

Given a client manet that has

- an interface named manet.domain
- an interface named manet.other.domain
- one key in its keytab: host/manet.domain@REALM

And given a server klimt that has

- an interface named klimt.domain
- an interface named klimt.other.domain
- a key in its keytab: nfs/klimt.domain@REALM
- a key in its keytab: nfs/klimt.other.domain@REAM

Now suppose the client manet mounts klimt.other with NFSv4.0 and
sec=3Dkrb5. The client establishes a GSS context using:

   source=3Dhost/manet.domain@REALM
   target=3Dnfs/klimt.other.domain@REALM

and we want the server to establish a GSS context for the callback
channel that looks like:

   source=3Dnfs/klimt.other.domain@REALM
   target=3Dhost/manet.domain@REALM

How does gssd construct the correct source principal given the
target host/manet.domain@REALM ? Today it picks
nfs/klimt.domain@REALM , which is incorrect.

Further, if the client then connects via klimt.domain but continues
to use the original GSS context and lease, how does gssd know it
needs to use source=3Dnfs/klimt.other.domain@REALM if it needs to
re-establish the callback context for some reason?

The only way gssd can know these things for certain is if the
kernel explicitly requests "nfs/klimt.other.domain@REALM" as the
source principal for this GSS context. srchost=3D enables the
kernel to request a specific hostname for the source principal.

Currently our upcall does not specify a REALM for either principal,
but that should be straightforward to add.

I'm in favor of not having magic in gssd that figures this stuff
out based on a heuristic, but rather I'd like the kernel ask for
precisely what it needs every time.


>> That should provide the correct source principal in the multi-home
>> case, and it should be backwards-compatible with older gssd's.
>>=20
>>=20
>> Now here's why it's not enough to use getsockname(3) on target=3D
>> to predict the correct source hostname:
>>=20
>> If the client has established the lease when mounting from one
>> particular hostname, and then mounts from another, it will have
>> to continue managing the lease using the principal it has already
>> established with the first hostname. NFSD knows what that is, and
>> can tell gssd what it needs to be. gssd, using only getsockname(3),
>> would probably pick something that is wrong.
>>=20
>>=20
>>> I thought target just needed to correctly identify the domain for
>>> which authentication is taking place.
>>=20
>> That's what srchost=3D does. We can call it something else if that
>> helps.
>>=20
>>=20
>>> Then I think more changes should
>>> be in nfs-utils to make sure that we find credentials for that
>>> particular domain instead of going by the gethostbyname() results.
>>=20
>> That's a patch to gssd that I didn't post. I will post that later if
>> we all agree srchost=3D is OK.
>>=20
>> srchost=3D is optional. If it's not present in the upcall, gssd will
>> continue to use the result of gethostname(3) to construct the source
>> principal.
>>=20
>>=20
>>> On Fri, May 18, 2018 at 11:39 AM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>> I've been experimenting with this series that modifies NFSD to
>>>> discover and use the correct GSS service principal when =
constructing
>>>> its NFSv4.0 callback channels. I'm interested in review of this
>>>> approach. There are a couple of code comments marked with XXX that
>>>> also need some attention.
>>>>=20
>>>> The rpc.gssd change mentioned in 1/4 is unremarkable and will be
>>>> made available once there is consensus about the kernel changes
>>>> in this series. No gssproxy changes are necessary.
>>>>=20
>>>> ---
>>>>=20
>>>> Chuck Lever (4):
>>>>     sunrpc: Enable the kernel to specify the hostname part of =
service principals
>>>>     sunrpc: Extract target name into svc_cred
>>>>     nfsd: Use correct credential for NFSv4.0 callback with GSS
>>>>     nfsd: Remove callback_cred
>>>>=20
>>>>=20
>>>> fs/nfsd/nfs4callback.c               |   29 ++++----------
>>>> fs/nfsd/nfs4state.c                  |   17 +++-----
>>>> fs/nfsd/state.h                      |    2 -
>>>> include/linux/sunrpc/svcauth.h       |    3 +
>>>> net/sunrpc/auth_gss/auth_gss.c       |   20 ++++++++--
>>>> net/sunrpc/auth_gss/gss_rpc_upcall.c |   70 =
++++++++++++++++++++++------------
>>>> 6 files changed, 80 insertions(+), 61 deletions(-)
>>>>=20
>>>> --
>>>> Chuck Lever
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe =
linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
>> --
>> Chuck Lever

--
Chuck Lever



