From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] make capabilities support optional
Date: Mon, 26 Apr 2010 11:24:03 -0400
Message-ID: <4BD5B013.9060705@oracle.com>
References: <1271753213-17374-1-git-send-email-vapier@gentoo.org> <4BD1CADD.4050200@RedHat.com> <4BD1D8AA.4030708@oracle.com> <4BD1E55B.2090703@RedHat.com> <4BD1F121.1060001@oracle.com> <4BD21DA1.4000001@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:41449 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676Ab0DZPYc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Apr 2010 11:24:32 -0400
In-Reply-To: <4BD21DA1.4000001-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/23/2010 06:22 PM, Steve Dickson wrote:
>
>
> On 04/23/2010 03:12 PM, Chuck Lever wrote:
>> Hi Steve-
>>
>> On 04/23/2010 02:22 PM, Steve Dickson wrote:
>>> On 04/23/2010 01:28 PM, Chuck Lever wrote:
>>>> On 04/23/2010 12:29 PM, Steve Dickson wrote:
>>>>> On 04/20/2010 04:46 AM, Mike Frysinger wrote:
>>>>>> The new code using libcap is quite minor, so rather than always
>>>>>> reqiure
>>>>>> libcap support, make it a normal --enable type flag.  Current default
>>>>>> behavior is retained -- if libcap is found, it is enabled, else it is
>>>>>> disabled like every nfs-utils version in the past.
>>>>>>
>>>>>> Signed-off-by: Mike Frysinger<vapier@gentoo.org>
>>>>>>
>>>>> Committed...
>>>>
>>>> I somehow missed this one.  Why are we disabling libcap?  And why are we
>>>> adding another --enable flag when everyone has agreed that we should
>>>> avoid that if at all possible?
>>> The justification I was used was it made nfs-utils more portable on
>>> systems/distros that may not have the libcap support.
>>
>> As an aside, the patch description is where we should be documenting the
>> thinking behind these decisions in an audit-able and transparent manner.
>>   The description for this patch doesn't have a strong justification
>> IMHO.  It would be hard for any of us to come back to this patch a year
>> from now and figure out exactly why this change was made.  (I say this
>> having spent the last year doing just that for a long history of patches
>> to statd and mount).
> True, the patch description could have been a bit more verbose, but I
> feel I understood the reason for the patch and that reason the made
> sense to me...

The problem is that this patch was never posted publicly, so you were 
the only reviewer.  The rest of us have no idea what this is about.

> I feel backwards compatibility is important..

Sure, but this isn't necessarily the way to go about it, in this case. 
It's hard to know though, since the patch description was vague, and the 
patch itself was never publicly posted.

I'm all for choice, but let's make sure it's _informed_ choice where 
ever possible.

>> Back on topic: I get it that, in general, we want to allow older distros
>> to build the latest nfs-utils.  However I don't think we can blithely
>> rip this libcap support out, even just for old configurations.
>>
>> If we really do need to drop libcap for some configurations, then such a
>> change should be thoroughly tested in those environments.  Some features
>> won't always work without libcap, and appropriate warnings should be
>> added to man pages and/or should be displayed by statd.
> Well dropping libcap is not the default and I don't see us (i.e. upstream)
> ever making it the default... If people want set that config flag, its up to
> them to document the ramifications, IMHO...

Er, I think it _is_ up to us chickens to document the ramifications.  If 
some new --enable flag just shows up on ./configure, how am I going to 
know whether I should set it or not?  I certainly couldn't tell why 
another --enable flag was needed just for libcap until Mike spelled it out.

>>>> It is especially on older systems that nfs-utils will break without
>>>> libcap support.  Without CAP_NET_BIND, pmap_unregister() will fail when
>>>> statd is shut down, leaving NSM registered with the portmapper, but with
>>>> no active listeners.  When statd is started up again, it won't be able
>>>> to register the new NSM listener ports.
>>> Hmm... I agree the unregister() would fail on exit, but that's the reason
>>> an unregister() (and then an register) is done on start up before the
>>> privileges are drop... Actually this how it worked for a very long time,
>>> well before the capabilities support added...
>>
>> When I was working on it, subsequent attempts to register would always
>> fail if an NSM service was already registered.  In other words, this was
>> broken when I found it.
>>
>> Commits e2446fda and 7dd13420 explain why CAP_NET_BIND was introduced,
>> and what bugs are addressed.  Without CAP_NET_BIND, we can't guarantee
>> that the NSM service can be unregistered, and neither can we guarantee
>> that a privileged port, when requested, can be used for listening.
>>
>> The problem is that statd drops its root privileges, so any subsequent
>> attempts to acquire a privileged port (such as to do a
>> pmap_unregister()) will fail, and leave the NSM service registered.
>>
>> Since rpcbind registration is done via AF_UNIX, it can work without
>> CAP_NET_BIND.  But it requires that the registering UID be the same as
>> the UID used to unregister it.  Thus both registration and
>> unregistration must be root, or both must be done as "rpcuser."  Since
>> statd drops its privileges just after start-up, I chose the latter.
>>
>> However, using lower privileges means a pmap_unregister() will always
>> fail in common cases.  So CAP_NET_BIND is retained for this purpose.
>>
>> We also have to worry about mount.nfs these days, as it pings the statd
>> service when mounting with "lock".  If NSM is registered, but no statd
>> is listening (as would be the case if statd couldn't unregister itself
>> on its way down), then most subsequent NFSv2/v3 mounts would hang.  This
>> is why even "unregister/register" at start-up isn't always adequate.
>>
> I can't disagree with any of the above... but the above assumes that
> the --disable libcap will some how become the default... that is
> not the case...
>
> All that config flag allows is backwards compatibility,  which I know
> we both think is a good thing...

Now that we've answered the question of "why are we doing this," the 
question in my mind is how we want statd to behave if libcap isn't 
available.

At the very least, I think the man page should mention this bug somehow, 
and maybe a warning should be generated during the build.  Since this is 
mostly for embedded systems, according to Mike, I doubt an actual 
generated run-time warning would be visible to anyone.

-- 
chuck[dot]lever[at]oracle[dot]com
