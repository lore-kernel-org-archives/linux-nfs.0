Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:57914 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2389371AbeG0VTX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Jul 2018 17:19:23 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [Libtirpc-devel] [PATCH] rpcbind: Disable remote calls by default
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <ef5f7d66-a1fd-84bd-e934-046b16c35c53@RedHat.com>
Date: Fri, 27 Jul 2018 15:55:29 -0400
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2CAEFB0C-373A-4D83-9E19-CA6E364A6A70@oracle.com>
References: <20180726145436.12241-1-steved@redhat.com>
 <368D461B-E205-4FB8-98CE-06529A463C24@oracle.com>
 <ef5f7d66-a1fd-84bd-e934-046b16c35c53@RedHat.com>
To: Steve Dickson <SteveD@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jul 27, 2018, at 3:33 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>=20
>=20
>=20
> On 07/26/2018 03:49 PM, Chuck Lever wrote:
>>=20
>>=20
>>> On Jul 26, 2018, at 10:54 AM, Steve Dickson <steved@redhat.com> =
wrote:
>>>=20
>>> Added a new configuration flag --enable-rmtcalls
>>> which will be needed to enable the remote call
>>> functionality.
>>>=20
>>> This also stops rpcbind from opening up random
>>> listening ports.
>>=20
>> Hi, just curious. Why a build-time and not a run-time option?
> Cleaner and easier... with a command line option there is a lot
> more "stuff" you have to do... (aka man pages, usage messages, etc).
>=20
> I've had customers complaining about this random listening port for=20
> years and I only know of one app (rpcinfo) that used this feature
> so I'm fairly sure its not going to be missed...

No objection from me about making rmtcalls disappear.

But if you don't know of a valid use case for rmtcalls, it would be
even cleaner to remove the rmtcalls feature altogether... if the
default is "disabled" that means you are basically no longer testing
it.

2 cents.


> steved.
>>=20
>>=20
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>> Makefile.am   | 4 ++++
>>> configure.ac  | 4 ++++
>>> src/rpcbind.c | 6 +++++-
>>> 3 files changed, 13 insertions(+), 1 deletion(-)
>>>=20
>>> diff --git a/Makefile.am b/Makefile.am
>>> index c160a95..a536ffb 100644
>>> --- a/Makefile.am
>>> +++ b/Makefile.am
>>> @@ -29,6 +29,10 @@ if LIBWRAP
>>> AM_CPPFLAGS +=3D	-DLIBWRAP
>>> endif
>>>=20
>>> +if RMTCALLS
>>> +AM_CPPFLAGS +=3D	-DRMTCALLS
>>> +endif
>>> +
>>> bin_PROGRAMS =3D rpcinfo
>>> sbin_PROGRAMS =3D rpcbind
>>>=20
>>> diff --git a/configure.ac b/configure.ac
>>> index 359a418..1587d4d 100644
>>> --- a/configure.ac
>>> +++ b/configure.ac
>>> @@ -21,6 +21,10 @@ AC_ARG_ENABLE([warmstarts],
>>>  AS_HELP_STRING([--enable-warmstarts], [Enables Warm Starts =
@<:@default=3Dno@:>@]))
>>> AM_CONDITIONAL(WARMSTART, test x$enable_warmstarts =3D xyes)
>>>=20
>>> +AC_ARG_ENABLE([rmtcalls],
>>> +  AS_HELP_STRING([--enable-rmtcalls], [Enables Remote Calls =
@<:@default=3Dno@:>@]))
>>> +AM_CONDITIONAL(RMTCALLS, test x$enable_rmtcalls =3D xyes)
>>> +
>>> AC_ARG_WITH([statedir],
>>>  AS_HELP_STRING([--with-statedir=3DARG], [use ARG as state dir =
@<:@default=3D/var/run/rpcbind@:>@])
>>>  ,, [with_statedir=3D/var/run/rpcbind])
>>> diff --git a/src/rpcbind.c b/src/rpcbind.c
>>> index 8db8dfc..cc848b1 100644
>>> --- a/src/rpcbind.c
>>> +++ b/src/rpcbind.c
>>> @@ -794,12 +794,14 @@ got_socket:
>>> 		}
>>> 	}
>>> #endif
>>> +
>>> +
>>> +#ifdef RMTCALLS
>>> 	/*
>>> 	 * rmtcall only supported on CLTS transports for now.
>>> 	 */
>>> 	if (nconf->nc_semantics =3D=3D NC_TPI_CLTS) {
>>> 		status =3D create_rmtcall_fd(nconf);
>>> -
>>> #ifdef RPCBIND_DEBUG
>>> 		if (debugging) {
>>> 			if (status < 0) {
>>> @@ -813,6 +815,8 @@ got_socket:
>>> 		}
>>> #endif
>>> 	}
>>> +#endif
>>> +
>>> 	return (0);
>>> error:
>>> 	close(fd);
>>> --=20
>>> 2.17.1
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



