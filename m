Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:52426 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbeERTYS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2018 15:24:18 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyGDGOqPKXKD+LQq8Ub3CUosmaaAq=ir3Gp7R3LKABwtEQ@mail.gmail.com>
Date: Fri, 18 May 2018 15:23:58 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Message-Id: <DB8E23EF-80A4-48D0-B53C-AD2A4B0076E2@oracle.com>
References: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
 <CAN-5tyGDGOqPKXKD+LQq8Ub3CUosmaaAq=ir3Gp7R3LKABwtEQ@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 18, 2018, at 2:53 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> Hi Chuck,
>=20
> I'm not convinced that "srchost=3D" is necessary. I believe that
> everything that is needed is suppose to be encoded in the "target=3D"
> option.

I don't believe target=3D has what we want. For NFSv4.0 callback:

  A. The callback source principal needs to be the same as the client's
     NFS server target principal.

  B. The callback target principal needs to be the same as the client's
     NFS server source principal.

Today, for NFSv4.0 callbacks, the kernel passes to gssd:

  target=3D it uses B for this

  service=3D it always sets this to "nfs"

And gssd "makes up" the hostname part of A using gethostname(3), which
is bogus for multi-homed NFS servers.


So my patch series does the following for NFSv4.0 callbacks:

1. It acquires the actual target principal the client used to establish
   it's lease. This is A above.

2. Instead of always passing "nfs" as the service=3D value, it passes
   the non-hostname part of A. That should be "nfs" but it doesn't
   have to be.

3. Instead of letting gssd make up the hostname part of the source
   principal, it passes the hostname part of A.

That should provide the correct source principal in the multi-home
case, and it should be backwards-compatible with older gssd's.


Now here's why it's not enough to use getsockname(3) on target=3D
to predict the correct source hostname:

If the client has established the lease when mounting from one
particular hostname, and then mounts from another, it will have
to continue managing the lease using the principal it has already
established with the first hostname. NFSD knows what that is, and
can tell gssd what it needs to be. gssd, using only getsockname(3),
would probably pick something that is wrong.


> I thought target just needed to correctly identify the domain for
> which authentication is taking place.

That's what srchost=3D does. We can call it something else if that
helps.


> Then I think more changes should
> be in nfs-utils to make sure that we find credentials for that
> particular domain instead of going by the gethostbyname() results.

That's a patch to gssd that I didn't post. I will post that later if
we all agree srchost=3D is OK.

srchost=3D is optional. If it's not present in the upcall, gssd will
continue to use the result of gethostname(3) to construct the source
principal.


> On Fri, May 18, 2018 at 11:39 AM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>> I've been experimenting with this series that modifies NFSD to
>> discover and use the correct GSS service principal when constructing
>> its NFSv4.0 callback channels. I'm interested in review of this
>> approach. There are a couple of code comments marked with XXX that
>> also need some attention.
>>=20
>> The rpc.gssd change mentioned in 1/4 is unremarkable and will be
>> made available once there is consensus about the kernel changes
>> in this series. No gssproxy changes are necessary.
>>=20
>> ---
>>=20
>> Chuck Lever (4):
>>      sunrpc: Enable the kernel to specify the hostname part of =
service principals
>>      sunrpc: Extract target name into svc_cred
>>      nfsd: Use correct credential for NFSv4.0 callback with GSS
>>      nfsd: Remove callback_cred
>>=20
>>=20
>> fs/nfsd/nfs4callback.c               |   29 ++++----------
>> fs/nfsd/nfs4state.c                  |   17 +++-----
>> fs/nfsd/state.h                      |    2 -
>> include/linux/sunrpc/svcauth.h       |    3 +
>> net/sunrpc/auth_gss/auth_gss.c       |   20 ++++++++--
>> net/sunrpc/auth_gss/gss_rpc_upcall.c |   70 =
++++++++++++++++++++++------------
>> 6 files changed, 80 insertions(+), 61 deletions(-)
>>=20
>> --
>> Chuck Lever
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



