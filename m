Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:19807 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763031Ab3ECT0R convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 May 2013 15:26:17 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: long delay when mounting due to SETCLIENTID AUTH_GSS attempts
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130503151727.09d684f4@tlielax.poochiereds.net>
Date: Fri, 3 May 2013 15:26:09 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <EB1CC0C3-1E31-4A3F-90E7-A79098161D1B@oracle.com>
References: <20130503132557.2fdf794d@tlielax.poochiereds.net> <AE700845-4032-4BEC-817C-97EB08A831E8@oracle.com> <20130503142421.19fb3ca6@tlielax.poochiereds.net> <1367606034.3556.25.camel@leira.trondhjem.org> <20130503144437.3a47e476@tlielax.poochiereds.net> <A2E5B3F1-A8F1-4731-A66C-548B9C8FD429@oracle.com> <20130503151727.09d684f4@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 3, 2013, at 3:17 PM, Jeff Layton <jlayton@redhat.com> wrote:

> On Fri, 3 May 2013 14:48:59 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On May 3, 2013, at 2:44 PM, Jeff Layton <jlayton@redhat.com> wrote:
>> 
>>> On Fri, 3 May 2013 18:33:54 +0000
>>> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>>> 
>>>> On Fri, 2013-05-03 at 14:24 -0400, Jeff Layton wrote:
>>>>> On Fri, 3 May 2013 13:56:13 -0400
>>>>> Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>> 
>>>>>> 
>>>>>> On May 3, 2013, at 1:25 PM, Jeff Layton <jlayton@redhat.com> wrote:
>>>>>> 
>>>>>>> I've noticed that when running a 3.10-pre kernel that if I try to mount
>>>>>>> up a NFSv4 filesystem that it now takes ~15s for the mount to complete.
>>>>>>> 
>>>>>>> Here's a little rpcdebug output:
>>>>>>> 
>>>>>>> [ 3056.385078] svc: server ffff8800368fc000 waiting for data (to = 9223372036854775807)
>>>>>>> [ 3056.392056] RPC:       new task initialized, procpid 2471
>>>>>>> [ 3056.392758] RPC:       allocated task ffff88010cd90100
>>>>>>> [ 3056.393303] RPC:    42 __rpc_execute flags=0x1280
>>>>>>> [ 3056.393630] RPC:    42 call_start nfs4 proc SETCLIENTID (sync)
>>>>>>> [ 3056.394056] RPC:    42 call_reserve (status 0)
>>>>>>> [ 3056.394368] RPC:    42 reserved req ffff8801019f9600 xid 21ad6c40
>>>>>>> [ 3056.394783] RPC:       wake_up_first(ffff88010a989990 "xprt_sending")
>>>>>>> [ 3056.395252] RPC:    42 call_reserveresult (status 0)
>>>>>>> [ 3056.395595] RPC:    42 call_refresh (status 0)
>>>>>>> [ 3056.395901] RPC:       gss_create_cred for uid 0, flavor 390004
>>>>>>> [ 3056.396361] RPC:       gss_create_upcall for uid 0
>>>>>>> [ 3071.396134] RPC: AUTH_GSS upcall timed out.
>>>>>>> Please check user daemon is running.
>>>>>>> [ 3071.397374] RPC:       gss_create_upcall for uid 0 result -13
>>>>>>> [ 3071.398192] RPC:    42 call_refreshresult (status -13)
>>>>>>> [ 3071.398873] RPC:    42 call_refreshresult: refresh creds failed with error -13
>>>>>>> [ 3071.399881] RPC:    42 return 0, status -13
>>>>>>> 
>>>>>>> The problem is that we're now trying to upcall for GSS creds to do the
>>>>>>> SETCLIENTID call, but this host isn't running rpc.gssd. Not running
>>>>>>> rpc.gssd is pretty common for people not using kerberized NFS. I think
>>>>>>> we'll see a lot of complaints about this.
>>>>>>> 
>>>>>>> Is this expected?
>>>>>> 
>>>>>> Yes.
>>>>>> 
>>>>>> There are operations like SETCLIENTID and GETATTR(fs_locations) which should always use an integrity-checking security flavor, even if particular mount points use sec=sys.
>>>>>> 
>>>>>> There are cases where GSS is not available, and we fall back to using AUTH_SYS.  That should happen as quickly as possible, I agree.
>>>>>> 
>>>>>>> If so, what's the proposed remedy?
>>>>>>> Simply have everyone run rpc.gssd even if they're not using kerberized NFS?
>>>>>> 
>>>>>> 
>>>>>> That's one possibility.  Or we could shorten the upcall timeout.  Or, add a mechanism by which rpc.gssd can provide a positive indication to the kernel that it is running.
>>>>>> 
>>>>>> It doesn't seem like an intractable problem.
>>>>>> 
>>>>> 
>>>>> Nope, it's not intractable at all...
>>>>> 
>>>>> Currently, the gssd upcall uses the RPC_PIPE_WAIT_FOR_OPEN flag to
>>>>> allow you to queue upcalls to be processed when the daemon isn't up
>>>>> yet. When the daemon starts, it processes that queue. The caller gives
>>>>> up after 15s (which is what's happening here), and the upcall
>>>>> eventually gets scraped out of the queue after 30s.
>>>>> 
>>>>> We could stop using that flag on this rpc_pipe and simply require that
>>>>> the daemon be up and running before attempting any sort of AUTH_GSS
>>>>> rpc. That might be a little less friendly in the face of boot-time
>>>>> ordering problems, but it should presumably make this problem go away.
>>>> 
>>>> You probably don't want to do that... The main reason for the
>>>> RPC_PIPE_WAIT_FOR_OPEN is that even if the gssd daemon is running, it
>>>> takes it a moment or two to notice that a new client directory has been
>>>> created, and that there is a new 'krb' pipe to attach to.
>>>> 
>>> 
>>> Ok yeah, good point...
>>> 
>>> Shortening the timeout will also suck -- that'll just reduce the pain
>>> somewhat but will still be a performance regression. It looks like even
>>> specifying '-o sec=sys' doesn't disable this behavior. Should it?
>> 
>> Nope.
>> 
>> We should always use krb5i if a GSS context can be established with our machine cred.  As I said before, SETCLIENTID and GETATTR(fs_locations) really should use an integrity-protecting security flavor no matter what flavor is in effect on the mount points themselves.
>> 
>>> Instead of using AUTH_GSS for SETCLIENTID by default, would it make
>>> sense to add a switch (module parm?) that turns it on so that it can be
>>> an opt-in thing rather than doing this by default?
>> 
>> Why add another tunable when we really should just fix the delay?
>> 
> 
> Because just shortening the delay will still leave you with a delay.
> Less people might notice and complain if it's shorter, but it'll still
> be there. It'll be particularly annoying with autofs...
> 
> You also run the risk of hitting the problem Trond mentioned if you
> shorten it too much (timing out the upcall before gssd's duty cycle has
> a chance to get to it).

So what about taking one of the other approaches I mentioned?

> 
>> Besides, if gssd is running and no keytab exists, then the fallback to AUTH_SYS should be fast. Is that not an effective workaround until we address the delay problem?
>> 
> 
> Yep, no problem if gssd is running. I'm concerned about the common case
> where it isn't. The expectation in the past has always been that if you
> weren't running kerberized NFS that you didn't need to run gssd. That
> has now changed and if you don't want to suffer a delay when mounting
> (however short it eventually is) then you need to run it.

Why are you assuming this is a permanent change?

> Might it make sense to introduce this change more gradually? Somehow
> warn people who aren't running gssd that they ought to start turning it
> on before we do this by default?

I don't expect this issue to last for release after release.  A moment ago you agreed that this shouldn't be intractable, so I fail to see the need to start wiring up long-term workarounds.

Can't we just agree on a fix, and then get that into 3.10 as a regression fix?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




