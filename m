Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:42216 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752700AbeDKOJm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Apr 2018 10:09:42 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [Libtirpc-devel] [PATCH 1/2] Restore using reserve ports for
 client connections
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <44316a1b-82ff-261c-b691-31b5621fb4e7@RedHat.com>
Date: Wed, 11 Apr 2018 08:09:14 -0600
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2B22DB71-6F0A-4A5A-A92D-976B5D0E6A22@oracle.com>
References: <20180410213043.5545-1-steved@redhat.com>
 <1E130010-3BB3-4BB8-9521-1B6096BC615B@oracle.com>
 <44316a1b-82ff-261c-b691-31b5621fb4e7@RedHat.com>
To: Steve Dickson <SteveD@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Apr 11, 2018, at 6:34 AM, Steve Dickson <SteveD@RedHat.com> wrote:
>=20
>=20
> Hey,
>=20
> On 04/10/2018 06:17 PM, Chuck Lever wrote:
>>=20
>>=20
>>> On Apr 10, 2018, at 3:30 PM, Steve Dickson <steved@redhat.com> =
wrote:
>>>=20
>>> Commit 46e04a73 changed both clnt_com_create()
>>> and clnt_tli_create() to avoid using reserve ports when
>>> creating connection to the server.
>>>=20
>>> For certain legacy apps, the client has to used
>>> reserve port to be able to communicate with its
>>> server so using of reserve ports is restored.
>>=20
>> Hi Steve-
>>=20
>> Which legacy apps use clnt_tli_create and require this behavior?
> yphelper, yppush and ypxfr via the clnt_create() call. At least
> that's all I have found so far.

clnt_create(3) unfortunately appears to be in glibc. So
fair enough, but your patch description really does need
to provide these details and examples, please.


>> There is no backwards compatibility requirement for this API.
> Well unlike the server side, the client will not be squatting
> on these port for an absorbent amount time. 99% of the time they
> are UDP connection so the ports are immediately reusable,
> unlike TCP connection that get stuck in TIME_WAIT and
> there is a requirement for reserve port be used to talk
> to the server.

I do not agree that this is a harmless default.

There is no guarantee that the RPC consumer is going to
release the client immediately. That's the problem with
continuing to use bindresvport(3) here: many callers might
free the CLNT immediately, but some don't.

We have examples of callers -- in our own administrative
tools -- that start up as root on purpose so they can
create a long-lived client.

Some of them don't need to do that, and thus can consume a
reserved port for no good reason.

And we know that a few applications do use TCP, even for
short-lived clients, and that has a bad side-effect.

Look at mount.nfs, for example. It runs as root. If it uses
TCP to contact the server's rpcbind and mountd, and uses
these basic library client APIs, that leaves two reserved
ports in TIME_WAIT for two minutes. A storm of NFS mount
operations can easily consume all the reserved ports for a
few minutes.

Maybe mount.nfs doesn't do that, but some other applications
might. There's nothing in libtirpc to prevent it.


> So I'm feeling pretty strong that there is no problem at
> all with the client using reserve ports for their short
> lived connection.

There is no guarantee the client will be short-lived, and
in the common case a reserved port is an unneeded use of
a scarce system resource. This is bad default behavior.


> Not using them would cause more problems
> as we have already seen.

This is not "causing problems." These legacy apps are using
an undocumented behavior. I will note that we are basically
fixing libtirpc to address an application where patches are
available for this to be done correctly.

The best that can be done for the moment is try to reduce
the likelihood that bindresvport(3) will land on a well-known
port, without reducing the reliability of success. I will
look into it.


> steved.
>=20
>>=20
>>=20
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>> src/clnt_generic.c | 3 +--
>>> src/rpc_soc.c      | 3 +--
>>> 2 files changed, 2 insertions(+), 4 deletions(-)
>>>=20
>>> diff --git a/src/clnt_generic.c b/src/clnt_generic.c
>>> index e5a314f..774292b 100644
>>> --- a/src/clnt_generic.c
>>> +++ b/src/clnt_generic.c
>>> @@ -341,8 +341,7 @@ clnt_tli_create(int fd, const struct netconfig =
*nconf,
>>> 		servtype =3D nconf->nc_semantics;
>>> 		if (!__rpc_fd2sockinfo(fd, &si))
>>> 			goto err;
>>> -		if (__binddynport(fd) =3D=3D -1)
>>> -			goto err;
>>> +		bindresvport(fd, NULL);
>>> 	} else {
>>> 		if (!__rpc_fd2sockinfo(fd, &si))
>>> 			goto err;
>>> diff --git a/src/rpc_soc.c b/src/rpc_soc.c
>>> index af6c482..f32a27c 100644
>>> --- a/src/rpc_soc.c
>>> +++ b/src/rpc_soc.c
>>> @@ -147,8 +147,7 @@ clnt_com_create(raddr, prog, vers, sockp, =
sendsz, recvsz, tp, flags)
>>> 	bindaddr.maxlen =3D bindaddr.len =3D  sizeof (struct =
sockaddr_in);
>>> 	bindaddr.buf =3D raddr;
>>>=20
>>> -	if (__binddynport(fd) =3D=3D -1)
>>> -		goto err;
>>> +	bindresvport(fd, NULL);
>>> 	cl =3D clnt_tli_create(fd, nconf, &bindaddr, prog, vers,
>>> 				sendsz, recvsz);
>>> 	if (cl) {
>>> --=20
>>> 2.14.3
>>>=20
>>>=20
>>> =
--------------------------------------------------------------------------=
----
>>> Check out the vibrant tech community on one of the world's most
>>> engaging tech sites, Slashdot.org! http://sdm.link/slashdot
>>> _______________________________________________
>>> Libtirpc-devel mailing list
>>> Libtirpc-devel@lists.sourceforge.net
>>> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel
>>=20
>> --
>> Chuck Lever
>>=20
>>=20
>>=20

--
Chuck Lever



