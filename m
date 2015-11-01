Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.lysator.liu.se ([130.236.254.3]:40033 "EHLO
	mail.lysator.liu.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672AbbKAVxS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Nov 2015 16:53:18 -0500
Message-ID: <563689C9.5040800@lysator.liu.se>
Date: Sun, 01 Nov 2015 22:53:13 +0100
From: Peter Rosin <peda@lysator.liu.se>
MIME-Version: 1.0
To: Chuck Lever <chucklever@gmail.com>
CC: Andreas Radke <a.radke@arcor.de>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>
Subject: Re: [Libtirpc-devel] ANNOUNCE: libtirpc-1.0.1 released.
References: <56351BDA.1090500@RedHat.com> <20151101115106.54815c74@workstation64.home> <56365281.4070005@lysator.liu.se> <83C2DFA0-A11D-4EBA-8786-E247393812F3@gmail.com>
In-Reply-To: <83C2DFA0-A11D-4EBA-8786-E247393812F3@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 2015-11-01 20:26, Chuck Lever wrote:
>> On Nov 1, 2015, at 12:57 PM, Peter Rosin <peda@lysator.liu.se> wrote:
>>
>>
>> On 2015-11-01 11:51, Andreas Radke wrote:
>>> Am Sat, 31 Oct 2015 15:51:54 -0400
>>> schrieb Steve Dickson <SteveD@redhat.com>:
>>>
>>>> Hello,
>>>>
>>>> The 1.0.1 version of libtirpc has just been release.
>>>>
>>>> In this release the SONAME has been changed to 3.0.0 to
>>>> reflect a number of changes in the API. Those changes
>>>> were needed to make the Linux version of libtirpc
>>>> more compatible with other implementations
>>> This break rpcbind recompilation:
>>>
>>> src/rpcb_svc_com.c: In function 'handle_reply':
>>> src/rpcb_svc_com.c:1298:6: error: 'SVCXPRT {aka struct __rpc_svcxprt}'
>>> has no member named 'xp_auth' xprt->xp_auth = &svc_auth_none;
>>>       ^
>>> In file included from /usr/include/tirpc/rpc/rpc.h:62:0,
>>>                  from src/rpcb_svc_com.c:48:
>>> src/rpcb_svc_com.c:1300:22: error: 'SVCXPRT {aka struct __rpc_svcxprt}'
>>> has no member named 'xp_auth' SVCAUTH_DESTROY(xprt->xp_auth);
>>>                       ^
>>> /usr/include/tirpc/rpc/svc_auth.h:63:7: note: in definition of macro
>>> 'SVCAUTH_DESTROY' ((*((auth)->svc_ah_ops->svc_ah_destroy))(auth))
>>>        ^
>>> src/rpcb_svc_com.c:1300:22: error: 'SVCXPRT {aka struct __rpc_svcxprt}'
>>> has no member named 'xp_auth' SVCAUTH_DESTROY(xprt->xp_auth);
>>>                       ^
>>> /usr/include/tirpc/rpc/svc_auth.h:63:43: note: in definition of macro
>>> 'SVCAUTH_DESTROY' ((*((auth)->svc_ah_ops->svc_ah_destroy))(auth))
>>>                                            ^
>>> src/rpcb_svc_com.c:1301:6: error: 'SVCXPRT {aka struct __rpc_svcxprt}'
>>> has no member named 'xp_auth' xprt->xp_auth = NULL;
>>>       ^
>>> Makefile:481: recipe for target 'src/rpcb_svc_com.o' failed
>>> make: *** [src/rpcb_svc_com.o] Error 1
>>> make: *** Waiting for unfinished jobs....
>>> ==> ERROR: A failure occurred in build().
>>>
>>> Do you have a fix?
>>>
>> Should be as simple as (not even compile-tested):
>>
>> diff --git a/src/rpcb_svc_com.c b/src/rpcb_svc_com.c
>> index 4ae93f1..38f163f 100644
>> --- a/src/rpcb_svc_com.c
>> +++ b/src/rpcb_svc_com.c
>> @@ -1295,10 +1295,8 @@ handle_reply(int fd, SVCXPRT *xprt)
>>      a.rmt_localvers = fi->versnum;
>>
>>      xprt_set_caller(xprt, fi);
>> -    xprt->xp_auth = &svc_auth_none;
>> +    SVC_XP_AUTH(xprt) = svc_auth_none;
>>      svc_sendreply(xprt, (xdrproc_t) xdr_rmtcall_result, (char *) &a);
>> -    SVCAUTH_DESTROY(xprt->xp_auth);
>> -    xprt->xp_auth = NULL;
>>  done:
>>      if (buffer)
>>          free(buffer);
>>
>> But that breaks compatibility with earlier libtirpc of course…
>>
> #if defined(SVC_XP_AUTH)
> SVC_XP_AUTH(xprt) = svc_auth_none;
> #else
>
>  . . .
>
> #endif
>
> But I wonder if that’s even necessary now. See rpcbind
> commit 86036582c001.
>
Yes, it is fishy to clobber the server auth stuff, so it is probably best to just zap
the svc_auth_none assignment altogether. However, the core initializes the
server auth to svc_auth_none at the beginning of handling each separate call,
so if you somehow use a xprt to send replies before it has taken a call (is that
even possible?), there will be no server auth. In that very dubious case, the
assignment is essential.

I have not looked at the rpcbind code in any depth whatsoever and don't know
anything about the semantics of this "handle_reply" function. But, since it is
a "reply", there will presumably have been a preceding "call", presumably on
the same transport, in which case the server auth have been initialized. So, it
is safe to drop the svc_auth_none assignment.           Presumably. :-)

Cheers,
Peter
