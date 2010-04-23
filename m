From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] make capabilities support optional
Date: Fri, 23 Apr 2010 18:22:25 -0400
Message-ID: <4BD21DA1.4000001@RedHat.com>
References: <1271753213-17374-1-git-send-email-vapier@gentoo.org> <4BD1CADD.4050200@RedHat.com> <4BD1D8AA.4030708@oracle.com> <4BD1E55B.2090703@RedHat.com> <4BD1F121.1060001@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46724 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751494Ab0DWWWe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Apr 2010 18:22:34 -0400
In-Reply-To: <4BD1F121.1060001@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/23/2010 03:12 PM, Chuck Lever wrote:
> Hi Steve-
> 
> On 04/23/2010 02:22 PM, Steve Dickson wrote:
>> On 04/23/2010 01:28 PM, Chuck Lever wrote:
>>> On 04/23/2010 12:29 PM, Steve Dickson wrote:
>>>> On 04/20/2010 04:46 AM, Mike Frysinger wrote:
>>>>> The new code using libcap is quite minor, so rather than always
>>>>> reqiure
>>>>> libcap support, make it a normal --enable type flag.  Current default
>>>>> behavior is retained -- if libcap is found, it is enabled, else it is
>>>>> disabled like every nfs-utils version in the past.
>>>>>
>>>>> Signed-off-by: Mike Frysinger<vapier@gentoo.org>
>>>>>
>>>> Committed...
>>>
>>> I somehow missed this one.  Why are we disabling libcap?  And why are we
>>> adding another --enable flag when everyone has agreed that we should
>>> avoid that if at all possible?
>> The justification I was used was it made nfs-utils more portable on
>> systems/distros that may not have the libcap support.
> 
> As an aside, the patch description is where we should be documenting the
> thinking behind these decisions in an audit-able and transparent manner.
>  The description for this patch doesn't have a strong justification
> IMHO.  It would be hard for any of us to come back to this patch a year
> from now and figure out exactly why this change was made.  (I say this
> having spent the last year doing just that for a long history of patches
> to statd and mount).
True, the patch description could have been a bit more verbose, but I 
feel I understood the reason for the patch and that reason the made
sense to me... I feel backwards compatibility is important..  

> 
> Back on topic: I get it that, in general, we want to allow older distros
> to build the latest nfs-utils.  However I don't think we can blithely
> rip this libcap support out, even just for old configurations.
> 
> If we really do need to drop libcap for some configurations, then such a
> change should be thoroughly tested in those environments.  Some features
> won't always work without libcap, and appropriate warnings should be
> added to man pages and/or should be displayed by statd.
Well dropping libcap is not the default and I don't see us (i.e. upstream) 
ever making it the default... If people want set that config flag, its up to 
them to document the ramifications, IMHO...

> 
>>> It is especially on older systems that nfs-utils will break without
>>> libcap support.  Without CAP_NET_BIND, pmap_unregister() will fail when
>>> statd is shut down, leaving NSM registered with the portmapper, but with
>>> no active listeners.  When statd is started up again, it won't be able
>>> to register the new NSM listener ports.
>> Hmm... I agree the unregister() would fail on exit, but that's the reason
>> an unregister() (and then an register) is done on start up before the
>> privileges are drop... Actually this how it worked for a very long time,
>> well before the capabilities support added...
> 
> When I was working on it, subsequent attempts to register would always
> fail if an NSM service was already registered.  In other words, this was
> broken when I found it.
> 
> Commits e2446fda and 7dd13420 explain why CAP_NET_BIND was introduced,
> and what bugs are addressed.  Without CAP_NET_BIND, we can't guarantee
> that the NSM service can be unregistered, and neither can we guarantee
> that a privileged port, when requested, can be used for listening.
> 
> The problem is that statd drops its root privileges, so any subsequent
> attempts to acquire a privileged port (such as to do a
> pmap_unregister()) will fail, and leave the NSM service registered.
> 
> Since rpcbind registration is done via AF_UNIX, it can work without
> CAP_NET_BIND.  But it requires that the registering UID be the same as
> the UID used to unregister it.  Thus both registration and
> unregistration must be root, or both must be done as "rpcuser."  Since
> statd drops its privileges just after start-up, I chose the latter.
> 
> However, using lower privileges means a pmap_unregister() will always
> fail in common cases.  So CAP_NET_BIND is retained for this purpose.
> 
> We also have to worry about mount.nfs these days, as it pings the statd
> service when mounting with "lock".  If NSM is registered, but no statd
> is listening (as would be the case if statd couldn't unregister itself
> on its way down), then most subsequent NFSv2/v3 mounts would hang.  This
> is why even "unregister/register" at start-up isn't always adequate.
> 
I can't disagree with any of the above... but the above assumes that
the --disable libcap will some how become the default... that is 
not the case... 

All that config flag allows is backwards compatibility,  which I know 
we both think is a good thing... 

steved.


