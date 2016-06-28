Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36442 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbcF1STe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2016 14:19:34 -0400
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 1/1 v2] systemd: Only start the gssd daemons when they are enabled
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <bb272a90-ba16-de0b-d96b-e19390bc66a9@RedHat.com>
Date: Tue, 28 Jun 2016 14:19:25 -0400
Cc: Weston Andros Adamson <dros@monkey.org>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <396FBF54-ABFC-46AB-889C-CD95DD5B85F9@oracle.com>
References: <1466520807-4340-1-git-send-email-steved@redhat.com> <09ECB137-8EC4-4713-B5F4-44D0405B2700@oracle.com> <c21d7a5d-853f-1722-53b4-99f66f263d74@RedHat.com> <AA20A3F4-82FB-4118-B0F2-012890D24042@oracle.com> <a82a0e31-a0e0-409a-8310-bd62cf0436b5@RedHat.com> <1D39CEF6-AC29-4166-95DF-ADBD2C0286B3@oracle.com> <e3735233-446f-ff18-6127-41ed956e6f91@RedHat.com> <73CFA6F9-C983-47D7-972C-9DF782731F3C@oracle.com> <2085406d-1e41-46b2-6791-2a3208f5497b@RedHat.com> <DE6D6AB1-4C56-43B2-8E11-778A29CF472C@oracle.com> <5940600C-CF7E-46EA-804C-A67A6F9D52E3@monkey.org> <bb272a90-ba16-de0b-d96b-e19390bc66a9@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 28, 2016, at 2:12 PM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> 
> 
>> On 06/28/2016 01:23 PM, Weston Andros Adamson wrote:
>> 
>>>> On Jun 28, 2016, at 12:27 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>> 
>>>> 
>>>> On Jun 28, 2016, at 10:27 AM, Steve Dickson <SteveD@redhat.com> wrote:
>>>> 
>>>> Again, sorry for the delay... That darn flux capacitor broke... again!!! :-)
>>>> 
>>>>> On 06/23/2016 09:30 PM, Chuck Lever wrote:
>>>>> 
>>>>>> On Jun 23, 2016, at 11:57 AM, Steve Dickson <SteveD@redhat.com> wrote:
>>>> 
>>>> [snip]
>>>> 
>>>>>> the key tab does have a nfs/hosname@REALM entry. So the 
>>>>>> call to the KDC is probably failing... which 
>>>>>> could be construed as a misconfiguration, but
>>>>>> that misconfiguration should not even come into 
>>>>>> play with sec=sys mounts... IMHO...
>>>>> 
>>>>> I disagree, of course. sec=sys means the client is not going
>>>>> to use Kerberos to authenticate individual user requests,
>>>>> and users don't need a Kerberos ticket to access their files.
>>>>> That's still the case.
>>>>> 
>>>>> I'm not aware of any promise that sec=sys means there is
>>>>> no Kerberos within 50 miles of that mount.
>>>> I think that's is the assumption... No Kerberos will be
>>>> needed for sec=sys mounts. Its not when Kerberos is 
>>>> not configured.
>>> 
>>> NFSv3 sec=sys happens to mean that no Kerberos is needed.
>>> This hasn't changed either.
>>> 
>>> NFSv4 sec=sys is different. Just like NFSv4 ACLs, and
>>> NFSv4 ID mapping, and NFSv4 locking, and so on.
>>> 
>>> Note though that Kerberos isn't needed for NFSv4 sec=sys
>>> even when there is a keytab. The client negotiates and
>>> operates without it.
>>> 
>>> 
>>>>> If there are valid keytabs on both systems, they need to
>>>>> be set up correctly. If there's a misconfiguration, then
>>>>> gssd needs to report it precisely instead of time out.
>>>>> And it's just as easy to add a service principal to a keytab
>>>>> as it is to disable a systemd service in that case.
>>>> I think its more straightforward to disable a service
>>>> that is not needed than to have to add a principal to a 
>>>> keytab for a service that's not being used or needed.
>>> 
>>> IMO automating NFS setup so that it chooses the most
>>> secure possible settings without intervention is the
>>> best possible solution.
>>> 
>>> 
>>>>>>> Is gssd waiting for syslog or something?
>>>>>> No... its just failing to get the machine creds for root
>>>>> 
>>>>> Clearly more is going on than that, and so far we have only
>>>>> some speculation. Can you provide an strace of rpc.gssd or
>>>>> a network capture so we can confirm what's going on?
>>>> Yes... Yes... and Yes.. I added you to the bz...
>>> 
>>> Thanks! I'll have a look at it.
>>> 
>>> 
>>>>>> [snip]
>>>>>> 
>>>>>>>> Which does work and will still work... but I'm thinking it is
>>>>>>>> much similar to disable the service via systemd command
>>>>>>>> systemctl disable rpc-gssd
>>>>>>>> 
>>>>>>>> than creating and editing those .conf files.
>>>>>>> 
>>>>>>> This should all be automatic, IMO.
>>>>>>> 
>>>>>>> On Solaris, drop in a keytab and a krb5.conf, and add sec=krb5
>>>>>>> to your mounts. No reboot, nothing to restart. Linux should be
>>>>>>> that simple.
>>>>>> The only extra step with Linux is to 'sysctmctl start rpc-gssd'
>>>>>> I don't there is much would can do about that....
>>>>> 
>>>>> Sure there is. Leave gssd running, and make sure it can respond
>>>>> quickly in every reasonable case. :-p
>>>>> 
>>>>> 
>>>>>> But of
>>>>>> course... Patches are always welcomed!! 8-)
>>>>>> 
>>>>>> TBL... When kerberos is configured correctly for NFS everything
>>>>>> works just fine. When kerberos is configured, but not for NFS,
>>>>>> causes delays on all NFS mounts.
>>>>> 
>>>>> This convinces me even more that there is a gssd issue here.
>>>>> 
>>>>> 
>>>>>> Today, there is a method to stop rpc-gssd from blindly starting
>>>>>> when kerberos is configured to eliminate that delay.
>>>>> 
>>>>> I can fix my broken TV by not turning it on, and I don't
>>>>> notice the problem. But the problem is still there any
>>>>> time I want to watch TV.
>>>>> 
>>>>> The problem is not fixed by disabling gssd, it's just
>>>>> hidden in some cases.
>>>> I agree this %100... All I'm saying there should be a 
>>>> way to disable it when the daemon is not needed or used.
>>> 
>>> NFSv4 sec=sys *does* use Kerberos, when it is available.
>>> It has for years.
>>> 
>>> Documentation should be updated to state that if Kerberos
>>> is configured on clients, they will attempt to use it to
>>> manage some operations that are common to all NFSv4 mount
>>> points on that client, even when a mount point uses sec=sys.
>>> 
>>> Kerberos will be used for user authentication only if the
>>> client administrator has not specified a sec= setting, but
>>> the server export allows the use of Kerberos; or if the
>>> client administrator has specified a sec=krb5, sec=krb5i,
>>> or sec=krb5p setting.
>>> 
>>> The reason for using Kerberos for common operations is
>>> that a client may have just one lease management principal.
>>> If the client uses sec=sys and sec=krb5 mounts, and the
>>> sec=sys mount is done first, then lease management would use
>>> sys as well. The client cannot change this principal after
>>> it has established a lease and files are open.
>>> 
>>> A subsequent sec=krb5 mount will also use sec=sys for
>>> lease management. This will be surprising and insecure
>>> behavior. Therefore, all mounts from this client attempt
>>> to set up a krb5 lease management transport.
>> 
>> Chuck,
>> 
>> Thanks for explaining this so well! This definitely should make
>> it’s way into documentation - we should have added something
>> like this a long time ago.
> I agree... where should it go? the mount.nfs man page??

nfs(5) is where this kind of thing typically goes.


