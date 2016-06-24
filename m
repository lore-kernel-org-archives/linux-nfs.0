Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34883 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbcFXBaa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2016 21:30:30 -0400
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 1/1 v2] systemd: Only start the gssd daemons when they are enabled
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <e3735233-446f-ff18-6127-41ed956e6f91@RedHat.com>
Date: Thu, 23 Jun 2016 21:30:23 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <73CFA6F9-C983-47D7-972C-9DF782731F3C@oracle.com>
References: <1466520807-4340-1-git-send-email-steved@redhat.com> <09ECB137-8EC4-4713-B5F4-44D0405B2700@oracle.com> <c21d7a5d-853f-1722-53b4-99f66f263d74@RedHat.com> <AA20A3F4-82FB-4118-B0F2-012890D24042@oracle.com> <a82a0e31-a0e0-409a-8310-bd62cf0436b5@RedHat.com> <1D39CEF6-AC29-4166-95DF-ADBD2C0286B3@oracle.com> <e3735233-446f-ff18-6127-41ed956e6f91@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 23, 2016, at 11:57 AM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> Sorry for the delayed response... PTO yesterday.
> 
>> On 06/21/2016 01:57 PM, Chuck Lever wrote:
>> 
>>> On Jun 21, 2016, at 1:20 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>> 
>>> Hey,
>>> 
>>> On 06/21/2016 11:47 AM, Chuck Lever wrote:
>>>>>>>> When you say "the upcall fails" do you mean there is
>>>>>>>> no reply, or that there is a negative reply after a
>>>>>>>> delay, or there is an immediate negative reply?
>>>>>> Good point.. the upcalls did not fail, they
>>>>>> just received negative replies.
>>>> I would say that the upcalls themselves are not the
>>>> root cause of the delay if they all return immediately.
>>> Well when rpc.gssd is not running (aka no upcalls)
>>> the delays stop happening.
>> 
>> Well let me say it a different way: the mechanism of
>> performing an upcall should be fast. The stuff that gssd
>> is doing as a result of the upcall request may be taking
>> longer than expected, though.
> I'm pretty sure its not the actual mechanism causing the
> delay...  Its the act of failing (read keytabs maybe even
> ping the KDC) is what taking the time at least that's
> what the sys logs show.
> 
>> 
>> If gssd is up, and has nothing to do (which I think is
>> the case here?) then IMO that upcall should be unnoticeable.
> Well its not... It is causing a delay.
> 
>> I don't expect there to be any difference between the kernel
>> squelching an upcall, and an upcall completing immediately.
> There kernel will always make the upcall when rpc.gssd 
> is running... I don't see how the kernel can squelch the upcall
> with rpc.gssd running. Not starting rpc.gssd is the only
> way to squelch the upcall.
> 
>> 
>> 
>>>> Are you saying that each negative reply takes a moment?
>>> Yes. Even on sec=sys mounts. Which is the issue.
>> 
>> Yep, I get that. I've seen that behavior on occasion,
>> and agree it should be addressed somehow.
>> 
>> 
>>>> If that's the case, is there something that gssd should
>>>> do to reply more quickly when there's no host or nfs
>>>> service principal in the keytab?
>>> I don't think so... unless we start caching negative
>>> negative response or something like which is way 
>>> overkill especially since the problem is solved
>>> by not starting rpc.gssd.
>> 
>> I'd like to understand why this upcall, which should be
>> equivalent to a no-op, is not returning an immediate
>> answer. Three of these in a row shouldn't take more than
>> a dozen milliseconds.
> It looks like, from the systlog timestamps, each upcall 
> is taking a ~1 sec.
> 
>> 
>> How long does the upcall take when there is a service
>> principal versus how long it takes when there isn't one?
>> Try running gssd under strace to get some timings.
> the key tab does have a nfs/hosname@REALM entry. So the 
> call to the KDC is probably failing... which 
> could be construed as a misconfiguration, but
> that misconfiguration should not even come into 
> play with sec=sys mounts... IMHO...

I disagree, of course. sec=sys means the client is not going
to use Kerberos to authenticate individual user requests,
and users don't need a Kerberos ticket to access their files.
That's still the case.

I'm not aware of any promise that sec=sys means there is
no Kerberos within 50 miles of that mount.

If there are valid keytabs on both systems, they need to
be set up correctly. If there's a misconfiguration, then
gssd needs to report it precisely instead of time out.
And it's just as easy to add a service principal to a keytab
as it is to disable a systemd service in that case.


>> Is gssd waiting for syslog or something?
> No... its just failing to get the machine creds for root

Clearly more is going on than that, and so far we have only
some speculation. Can you provide an strace of rpc.gssd or
a network capture so we can confirm what's going on?


> [snip]
> 
>>> Which does work and will still work... but I'm thinking it is
>>> much similar to disable the service via systemd command
>>>  systemctl disable rpc-gssd
>>> 
>>> than creating and editing those .conf files.
>> 
>> This should all be automatic, IMO.
>> 
>> On Solaris, drop in a keytab and a krb5.conf, and add sec=krb5
>> to your mounts. No reboot, nothing to restart. Linux should be
>> that simple.
> The only extra step with Linux is to 'sysctmctl start rpc-gssd'
> I don't there is much would can do about that....

Sure there is. Leave gssd running, and make sure it can respond
quickly in every reasonable case. :-p


> But of
> course... Patches are always welcomed!! 8-)
> 
> TBL... When kerberos is configured correctly for NFS everything
> works just fine. When kerberos is configured, but not for NFS,
> causes delays on all NFS mounts.

This convinces me even more that there is a gssd issue here.


> Today, there is a method to stop rpc-gssd from blindly starting
> when kerberos is configured to eliminate that delay.

I can fix my broken TV by not turning it on, and I don't
notice the problem. But the problem is still there any
time I want to watch TV.

The problem is not fixed by disabling gssd, it's just
hidden in some cases.


> This patch just tweaking that method to make things easier.

It makes one thing easier, and other things more difficult.
As a community, I thought our goal was to make Kerberos
easier to use, not easier to turn off.


> To address your concern about covering up a bug. I just don't
> see it... The code is doing exactly what its asked to do.
> By default the kernel asks krb5i context (when rpc.gssd
> is run). rpc.gssd looking for a principle in the key tab, 
> when found the KDC is called... 
> 
> Everything is working just like it should and it is
> failing just like it should. I'm just trying to 
> eliminate all this process when not needed, in 
> an easier way..

I'm not even sure now what the use case is. The client has
proper principals, but the server doesn't? The server
should refuse the init sec context immediately. Is gssd
even running on the server?

Suppose there are a thousand clients and one broken
server. An administrator would fix that one server by
adding an extra service principal, rather than log
into a thousand clients to change a setting on each.

Suppose your client wants both sys and krb5 mounts of
a group of servers, and some are "misconfigured."
You have to enable gssd on the client but there are still
delays on the sec=sys mounts.

In fact, I think that's going to be pretty common. Why add
an NFS service principal on a client if you don't expect
to use sec=krb5 some of the time?


