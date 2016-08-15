Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47328 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbcHOSdV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 14:33:21 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] libnfsidmap: Query DNS for the the NFSv4 domain
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <0950c4ed-e4a9-4b6c-010d-b1c5f75b8dd8@RedHat.com>
Date: Mon, 15 Aug 2016 14:33:15 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7454EDBA-6557-4C6E-856B-5BB5243B9502@oracle.com>
References: <1470950774-3649-1-git-send-email-steved@redhat.com> <CBF9A3DE-7B43-4838-BA27-9B9E60AB54FB@oracle.com> <910b6aed-a955-5fd1-982f-b5d4541f107e@RedHat.com> <7B86C63A-EB63-42EF-A0A6-34CFFAC10B96@oracle.com> <0950c4ed-e4a9-4b6c-010d-b1c5f75b8dd8@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 15, 2016, at 1:00 PM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> 
> 
> On 08/15/2016 11:16 AM, Chuck Lever wrote:
>> 
>>> On Aug 15, 2016, at 10:57 AM, Steve Dickson <SteveD@redhat.com> wrote:
>>> 
>>> 
>>> 
>>> On 08/14/2016 02:59 PM, Chuck Lever wrote:
>>>> Hey Steve-
>>>> 
>>>> Sorry for the delay, and thanks for putting this together!
>>>> 
>>>> 
>>>>> On Aug 11, 2016, at 5:26 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>>>> 
>>>>> In domain_from_dns(), when at the hostname is a FQHN
>>>>> query the DNS server for the _nfsv4idmapdomain TXT
>>>>> record. If the record exists, use that as the
>>>>> NFSv4 domain.
>>>>> 
>>>>> Note, this query will only happen if the domain name
>>>>> is not set in the /etc/idmapd.conf
>>>> 
>>>> Is there a man page update that goes with this? The order in
>>>> which the library searches for the domain name should be
>>>> documented. idmapd.conf(5), maybe.
>>> Yes... I should have made this an RFC patch since I just
>>> wanted to get core out there for for comments... 
>>> The man page needs to updated as well as the configure.ac.
>> 
>> To enable this feature IMO a better choice is to use a command
>> line option on nfsidmap and rpc.idmapd.
> With Solaris, is this on by default or off? If needed.. (a big if)
> I think I would rather have a way to disable it.

In Solaris I don't know if there's even a way to turn it off,
but specifying the domain name locally seems like it would be
an effective way to prevent the TXT query. So, maybe there's
no need for any command line control?

I was just guessing at what you had in mind for configure.ac.


>>>> Also, some indication of when a change to the TXT record can
>>>> be observed by users could be mentioned.
>>> I'm not sure what you are asking here... There is the TTL time
>>> for TXT that is returned in the query but that is completely
>>> controlled by the admin...
>> 
>> Mostly this is about what might go into a man page update.
>> 
>> After the TXT record is changed, how long before the client
>> moves a mapped user ID from the old domain to the new one? 
> From a DNS standpoint all depends on the TTL on the TXT record
> From an NFS standpoint the next call to DNS.

Point is, it's not immediate: from questions I've gotten from
Solaris testers about Linux idmapping, I expect to see one or
two about "how long does it take before it's effective". Having
some docs to point to would be nice.


>> How long before all the mapped user IDs are converted to the new
>> domain? (I think I know the answer, but what should the man
>> page say about it).
> The keys all have timeouts on them... so when they timeout... 
> I guess maybe the key chain can be invalidate when a
> change is noticed? That would be easy with a daemon not
> so easy with a command.
> 
>> 
>> For instance, the kernel's cache of keys delays the effect of
>> changing the result of that TXT query. Should the man page
>> recommend a flush of that cache on clients?
> Hmm... adding a second step.. it probably should be automatic.

That would be nice, but seems like it would be difficult
when using TXT, unless the host stored the previous query
result somewhere so it could be compared with the latest
one.


--
Chuck Lever



