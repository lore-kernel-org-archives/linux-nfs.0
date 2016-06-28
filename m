Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52479 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752054AbcF1O15 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jun 2016 10:27:57 -0400
Subject: Re: [PATCH 1/1 v2] systemd: Only start the gssd daemons when they are
 enabled
To: Chuck Lever <chuck.lever@oracle.com>
References: <1466520807-4340-1-git-send-email-steved@redhat.com>
 <09ECB137-8EC4-4713-B5F4-44D0405B2700@oracle.com>
 <c21d7a5d-853f-1722-53b4-99f66f263d74@RedHat.com>
 <AA20A3F4-82FB-4118-B0F2-012890D24042@oracle.com>
 <a82a0e31-a0e0-409a-8310-bd62cf0436b5@RedHat.com>
 <1D39CEF6-AC29-4166-95DF-ADBD2C0286B3@oracle.com>
 <e3735233-446f-ff18-6127-41ed956e6f91@RedHat.com>
 <73CFA6F9-C983-47D7-972C-9DF782731F3C@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <2085406d-1e41-46b2-6791-2a3208f5497b@RedHat.com>
Date: Tue, 28 Jun 2016 10:27:55 -0400
MIME-Version: 1.0
In-Reply-To: <73CFA6F9-C983-47D7-972C-9DF782731F3C@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Again, sorry for the delay... That darn flux capacitor broke... again!!! :-)

On 06/23/2016 09:30 PM, Chuck Lever wrote:
> 
>> On Jun 23, 2016, at 11:57 AM, Steve Dickson <SteveD@redhat.com> wrote:

[snip]

>> the key tab does have a nfs/hosname@REALM entry. So the 
>> call to the KDC is probably failing... which 
>> could be construed as a misconfiguration, but
>> that misconfiguration should not even come into 
>> play with sec=sys mounts... IMHO...
> 
> I disagree, of course. sec=sys means the client is not going
> to use Kerberos to authenticate individual user requests,
> and users don't need a Kerberos ticket to access their files.
> That's still the case.
> 
> I'm not aware of any promise that sec=sys means there is
> no Kerberos within 50 miles of that mount.
I think that's is the assumption... No Kerberos will be
needed for sec=sys mounts. Its not when Kerberos is 
not configured. 
 
> 
> If there are valid keytabs on both systems, they need to
> be set up correctly. If there's a misconfiguration, then
> gssd needs to report it precisely instead of time out.
> And it's just as easy to add a service principal to a keytab
> as it is to disable a systemd service in that case.
I think its more straightforward to disable a service
that is not needed than to have to add a principal to a 
keytab for a service that's not being used or needed.

> 
> 
>>> Is gssd waiting for syslog or something?
>> No... its just failing to get the machine creds for root
> 
> Clearly more is going on than that, and so far we have only
> some speculation. Can you provide an strace of rpc.gssd or
> a network capture so we can confirm what's going on?
Yes... Yes... and Yes.. I added you to the bz... 

> 
> 
>> [snip]
>>
>>>> Which does work and will still work... but I'm thinking it is
>>>> much similar to disable the service via systemd command
>>>>  systemctl disable rpc-gssd
>>>>
>>>> than creating and editing those .conf files.
>>>
>>> This should all be automatic, IMO.
>>>
>>> On Solaris, drop in a keytab and a krb5.conf, and add sec=krb5
>>> to your mounts. No reboot, nothing to restart. Linux should be
>>> that simple.
>> The only extra step with Linux is to 'sysctmctl start rpc-gssd'
>> I don't there is much would can do about that....
> 
> Sure there is. Leave gssd running, and make sure it can respond
> quickly in every reasonable case. :-p
> 
> 
>> But of
>> course... Patches are always welcomed!! 8-)
>>
>> TBL... When kerberos is configured correctly for NFS everything
>> works just fine. When kerberos is configured, but not for NFS,
>> causes delays on all NFS mounts.
> 
> This convinces me even more that there is a gssd issue here.
> 
> 
>> Today, there is a method to stop rpc-gssd from blindly starting
>> when kerberos is configured to eliminate that delay.
> 
> I can fix my broken TV by not turning it on, and I don't
> notice the problem. But the problem is still there any
> time I want to watch TV.
> 
> The problem is not fixed by disabling gssd, it's just
> hidden in some cases.
I agree this %100... All I'm saying there should be a 
way to disable it when the daemon is not needed or used.

Having it automatically started just because there is a 
keytab, at first, I thought was a good idea, now
it turns not people really don't what miscellaneous 
daemons running. Case in point gssproxy... Automatically
comes but there is a way to disable it. With rpc.gssd
there is not (easily). 
 
> 
> 
>> This patch just tweaking that method to make things easier.
> 
> It makes one thing easier, and other things more difficult.
> As a community, I thought our goal was to make Kerberos
> easier to use, not easier to turn off.
Again I can't agree with you more! But this is the case 
were Kerberos is *not* being used for NFS... we should
make that case work as well... 

> 
> 
>> To address your concern about covering up a bug. I just don't
>> see it... The code is doing exactly what its asked to do.
>> By default the kernel asks krb5i context (when rpc.gssd
>> is run). rpc.gssd looking for a principle in the key tab, 
>> when found the KDC is called... 
>>
>> Everything is working just like it should and it is
>> failing just like it should. I'm just trying to 
>> eliminate all this process when not needed, in 
>> an easier way..
> 
> I'm not even sure now what the use case is. The client has
> proper principals, but the server doesn't? The server
> should refuse the init sec context immediately. Is gssd
> even running on the server?
No they don't because they are not using Kerberos for NFS...

So I guess this is what we are saying:
 
If you what to used Kerberos for anything at all,
they must configure it for NFS for their clients
to work properly... I'm not sure we really want to
say this. 

> 
> Suppose there are a thousand clients and one broken
> server. An administrator would fix that one server by
> adding an extra service principal, rather than log
> into a thousand clients to change a setting on each.
> 
> Suppose your client wants both sys and krb5 mounts of
> a group of servers, and some are "misconfigured."
> You have to enable gssd on the client but there are still
> delays on the sec=sys mounts.
In both these cases you are assuming Kerberos mounts 
are being used and so Kerberos should be configured 
for NFS. That is just not the case. 

> 
> In fact, I think that's going to be pretty common. Why add
> an NFS service principal on a client if you don't expect
> to use sec=krb5 some of the time?
In that case adding the principal does make sense. But...

Why *must* you add a principal when you know only sec=sys 
mounts will be used?

steved.
