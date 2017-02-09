Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:45110 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751540AbdBIHrr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Feb 2017 02:47:47 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 4B6B8280722
        for <linux-nfs@vger.kernel.org>; Thu,  9 Feb 2017 08:47:32 +0100 (CET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
        by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 3AE56157F
        for <linux-nfs@vger.kernel.org>; Thu,  9 Feb 2017 08:47:31 +0100 (MET)
Date: Thu, 9 Feb 2017 08:47:30 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org
Message-ID: <1845955030.39771341.1486626450894.JavaMail.zimbra@desy.de>
In-Reply-To: <1486591062.8353.2.camel@primarydata.com>
References: <ad98d031-f4a0-4713-a605-7c7f1e61a4f2@email.android.com> <1486591062.8353.2.camel@primarydata.com>
Subject: Re: [PATCH 0/4] Match TCP connection timeouts to the lease period
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Trond Myklebust" <trondmy@primarydata.com>
> To: "tigran mkrtchyan" <tigran.mkrtchyan@desy.de>
> Cc: "Anna Schumaker" <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.o=
rg
> Sent: Wednesday, February 8, 2017 10:57:44 PM
> Subject: Re: [PATCH 0/4] Match TCP connection timeouts to the lease perio=
d

> On Wed, 2017-02-08 at 22:18 +0100, Mkrtchyan, Tigran wrote:
>>=20
>>=20
>> On Feb 8, 2017 17:48, Trond Myklebust <trond.myklebust@primarydata.co
>> m> wrote:
>> With the current default TCP connection timeout being set at around
>> 3 minutes, and most server vendors setting the lease period at
>> values significantly lower than that, we can end up losing the lease
>> while waiting for the TCP layer to discover that we need to break
>> the
>> connection.
>> This patch series sets up an interface to allow the NFSv4 client to
>> adjust thsee timeout values down once it has obtained a value for
>> the lease period from the server.
>>=20
>>=20
>> Cool finally! I was waiting for that quite a bit.
>>=20
>> https://www.ietf.org/mail-archive/web/nfsv4/current/msg13758.html
>>=20
>>=20
>=20
> No. This mechanism does not excuse the server from having to process
> requests, and I am certainly not signing us up to any "gentleman's
> agreement".
>=20
> If the server has received an RPC call, then it MUST process it,
> whether or not there is a TCP connection, otherwise the lease may still
> be lost due to the server failing to live up to the requirements in
> RFC5661 Section 8.3=C2=A0(See https://tools.ietf.org/html/rfc5661#section=
-8.
> 3). Those requirements state that "If the client ID's lease has not
> expired when the server receives a SEQUENCE operation, then the server
> MUST renew the lease."
>=20
> The point of these patches are to ensure that we detect routing changes
> and things like that in a timely fashion (again, as required by
> RFC5661, Section 8.3) so that we can re-establish the connection and
> renew the lease.
>=20

Sure, I am fully agree with you. My point is that client's TCP timeout
is not a 'random number' any more and have a relation with the lease time.
However, the same can be applied to RPC timeouts as well. Our server
always to sends ERR_DELAY if request is not processed within 3sec to
avoid retries. This '3sec' is a random number, as we have no idea when
the client will lose his patience.

Tigran.


>> Tigran.
>>=20
>> Trond Myklebust (4):
>> =C2=A0 SUNRPC: Remove unused function rpc_get_timeout()
>> =C2=A0 SUNRPC: Refactor TCP socket timeout code into a helper function
>> =C2=A0 SUNRPC: Allow changing of the TCP timeout parameters on the fly
>> =C2=A0 NFSv4: Set the connection timeout to match the lease period
>>=20
>> fs/nfs/nfs4renewd.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 2 +-
>> include/linux/sunrpc/clnt.h=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 6 +--
>> include/linux/sunrpc/xprt.h=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 4 ++
>> include/linux/sunrpc/xprtsock.h |=C2=A0 3 ++
>> net/sunrpc/clnt.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 51 +++++++++++++-----------
>> net/sunrpc/xprtsock.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 | 88
>> ++++++++++++++++++++++++++++++++---------
>> 6 files changed, 107 insertions(+), 47 deletions(-)
>>=20
> --
>=20
>=20
>=09
>=09
>=20
>=20
> Trond Myklebust
> Principal System Architect
> 4300 El Camino Real | Suite 100
> Los Altos, CA=C2=A0=C2=A094022
> W: 650-422-3800
> C: 801-921-4583
> www.primarydata.com
>=20
>=20
>=20
> N=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDy=EF=BF=
=BD=EF=BF=BD=EF=BF=BDb=EF=BF=BDX=EF=BF=BD=EF=BF=BD=C7=A7v=EF=BF=BD^=EF=BF=
=BD)=DE=BA{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD{=EF=BF=BD=EF=BF=
=BD=EF=BF=BD"=EF=BF=BD=EF=BF=BD^n=EF=BF=BDr=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=
=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD&=EF=BF=BD=EF=
=BF=BD=EF=BF=BDG=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD(=EF=BF=BD=E9=9A=8E=EF=
=BF=BD=DD=A2j"=EF=BF=BD=EF=BF=BD=EF=BF=BDm=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BDz=EF=BF=BD=DE=96=EF=BF=BD=EF=BF=BD=EF=BF=BDf=EF=BF=BD=EF=BF=BD=
=EF=BF=BDh=EF=BF=BD=EF=BF=BD=EF=BF=BD~=EF=BF=BDm=EF=BF=BD
