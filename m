Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60300 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752856AbcHORA5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2016 13:00:57 -0400
Subject: Re: [PATCH] libnfsidmap: Query DNS for the the NFSv4 domain
To: Chuck Lever <chuck.lever@oracle.com>
References: <1470950774-3649-1-git-send-email-steved@redhat.com>
 <CBF9A3DE-7B43-4838-BA27-9B9E60AB54FB@oracle.com>
 <910b6aed-a955-5fd1-982f-b5d4541f107e@RedHat.com>
 <7B86C63A-EB63-42EF-A0A6-34CFFAC10B96@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <0950c4ed-e4a9-4b6c-010d-b1c5f75b8dd8@RedHat.com>
Date: Mon, 15 Aug 2016 13:00:55 -0400
MIME-Version: 1.0
In-Reply-To: <7B86C63A-EB63-42EF-A0A6-34CFFAC10B96@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/15/2016 11:16 AM, Chuck Lever wrote:
> 
>> On Aug 15, 2016, at 10:57 AM, Steve Dickson <SteveD@redhat.com> wrote:
>>
>>
>>
>> On 08/14/2016 02:59 PM, Chuck Lever wrote:
>>> Hey Steve-
>>>
>>> Sorry for the delay, and thanks for putting this together!
>>>
>>>
>>>> On Aug 11, 2016, at 5:26 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>>>
>>>> In domain_from_dns(), when at the hostname is a FQHN
>>>> query the DNS server for the _nfsv4idmapdomain TXT
>>>> record. If the record exists, use that as the
>>>> NFSv4 domain.
>>>>
>>>> Note, this query will only happen if the domain name
>>>> is not set in the /etc/idmapd.conf
>>>
>>> Is there a man page update that goes with this? The order in
>>> which the library searches for the domain name should be
>>> documented. idmapd.conf(5), maybe.
>> Yes... I should have made this an RFC patch since I just
>> wanted to get core out there for for comments... 
>> The man page needs to updated as well as the configure.ac.
> 
> To enable this feature IMO a better choice is to use a command
> line option on nfsidmap and rpc.idmapd.
With Solaris, is this on by default or off? If needed.. (a big if)
I think I would rather have a way to disable it.
 
> 
> 
>>> Also, some indication of when a change to the TXT record can
>>> be observed by users could be mentioned.
>> I'm not sure what you are asking here... There is the TTL time
>> for TXT that is returned in the query but that is completely
>> controlled by the admin...
> 
> Mostly this is about what might go into a man page update.
> 
> After the TXT record is changed, how long before the client
> moves a mapped user ID from the old domain to the new one? 
