Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48868 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732110AbeGaO7V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Jul 2018 10:59:21 -0400
Subject: Re: [Libtirpc-devel] [PATCH] rpcbind: Disable remote calls by default
To: Chuck Lever <chuck.lever@oracle.com>
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180726145436.12241-1-steved@redhat.com>
 <368D461B-E205-4FB8-98CE-06529A463C24@oracle.com>
 <ef5f7d66-a1fd-84bd-e934-046b16c35c53@RedHat.com>
 <2CAEFB0C-373A-4D83-9E19-CA6E364A6A70@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <ce869b0d-d095-2da4-15bf-badcd6d5fd1c@RedHat.com>
Date: Tue, 31 Jul 2018 09:19:02 -0400
MIME-Version: 1.0
In-Reply-To: <2CAEFB0C-373A-4D83-9E19-CA6E364A6A70@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/27/2018 03:55 PM, Chuck Lever wrote:
> 
> 
>> On Jul 27, 2018, at 3:33 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>>
>>
>>
>> On 07/26/2018 03:49 PM, Chuck Lever wrote:
>>>
>>>
>>>> On Jul 26, 2018, at 10:54 AM, Steve Dickson <steved@redhat.com> wrote:
>>>>
>>>> Added a new configuration flag --enable-rmtcalls
>>>> which will be needed to enable the remote call
>>>> functionality.
>>>>
>>>> This also stops rpcbind from opening up random
>>>> listening ports.
>>>
>>> Hi, just curious. Why a build-time and not a run-time option?
>> Cleaner and easier... with a command line option there is a lot
>> more "stuff" you have to do... (aka man pages, usage messages, etc).
>>
>> I've had customers complaining about this random listening port for 
>> years and I only know of one app (rpcinfo) that used this feature
>> so I'm fairly sure its not going to be missed...
> 
> No objection from me about making rmtcalls disappear.
> 
> But if you don't know of a valid use case for rmtcalls, it would be
> even cleaner to remove the rmtcalls feature altogether... if the
> default is "disabled" that means you are basically no longer testing
> it.
Well I was thinking it should be easily turn back on just
in case it does breaks somebody's flux capacitor... If that is
not the case we can rip it out down the road.

> 
> 2 cents.
My 4 cents! :-) 

steved.

> 
> 
>> steved.
>>>
>>>
>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>> ---
>>>> Makefile.am   | 4 ++++
>>>> configure.ac  | 4 ++++
>>>> src/rpcbind.c | 6 +++++-
>>>> 3 files changed, 13 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/Makefile.am b/Makefile.am
>>>> index c160a95..a536ffb 100644
>>>> --- a/Makefile.am
>>>> +++ b/Makefile.am
>>>> @@ -29,6 +29,10 @@ if LIBWRAP
>>>> AM_CPPFLAGS +=	-DLIBWRAP
>>>> endif
>>>>
>>>> +if RMTCALLS
>>>> +AM_CPPFLAGS +=	-DRMTCALLS
>>>> +endif
>>>> +
>>>> bin_PROGRAMS = rpcinfo
>>>> sbin_PROGRAMS = rpcbind
>>>>
>>>> diff --git a/configure.ac b/configure.ac
>>>> index 359a418..1587d4d 100644
>>>> --- a/configure.ac
>>>> +++ b/configure.ac
>>>> @@ -21,6 +21,10 @@ AC_ARG_ENABLE([warmstarts],
>>>>  AS_HELP_STRING([--enable-warmstarts], [Enables Warm Starts @<:@default=no@:>@]))
>>>> AM_CONDITIONAL(WARMSTART, test x$enable_warmstarts = xyes)
>>>>
>>>> +AC_ARG_ENABLE([rmtcalls],
>>>> +  AS_HELP_STRING([--enable-rmtcalls], [Enables Remote Calls @<:@default=no@:>@]))
>>>> +AM_CONDITIONAL(RMTCALLS, test x$enable_rmtcalls = xyes)
>>>> +
>>>> AC_ARG_WITH([statedir],
>>>>  AS_HELP_STRING([--with-statedir=ARG], [use ARG as state dir @<:@default=/var/run/rpcbind@:>@])
>>>>  ,, [with_statedir=/var/run/rpcbind])
>>>> diff --git a/src/rpcbind.c b/src/rpcbind.c
>>>> index 8db8dfc..cc848b1 100644
>>>> --- a/src/rpcbind.c
>>>> +++ b/src/rpcbind.c
>>>> @@ -794,12 +794,14 @@ got_socket:
>>>> 		}
>>>> 	}
>>>> #endif
>>>> +
>>>> +
>>>> +#ifdef RMTCALLS
>>>> 	/*
>>>> 	 * rmtcall only supported on CLTS transports for now.
>>>> 	 */
>>>> 	if (nconf->nc_semantics == NC_TPI_CLTS) {
>>>> 		status = create_rmtcall_fd(nconf);
>>>> -
>>>> #ifdef RPCBIND_DEBUG
>>>> 		if (debugging) {
>>>> 			if (status < 0) {
>>>> @@ -813,6 +815,8 @@ got_socket:
>>>> 		}
>>>> #endif
>>>> 	}
>>>> +#endif
>>>> +
>>>> 	return (0);
>>>> error:
>>>> 	close(fd);
>>>> -- 
>>>> 2.17.1
>>>>
>>>>
>>>> ------------------------------------------------------------------------------
>>>> Check out the vibrant tech community on one of the world's most
>>>> engaging tech sites, Slashdot.org! http://sdm.link/slashdot
>>>> _______________________________________________
>>>> Libtirpc-devel mailing list
>>>> Libtirpc-devel@lists.sourceforge.net
>>>> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel
>>>
>>> --
>>> Chuck Lever
>>>
>>>
>>>
> 
> --
> Chuck Lever
> 
> 
> 
