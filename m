Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:19511 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752848AbcHSFAy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2016 01:00:54 -0400
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
        by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u7IGsksW000414
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 18 Aug 2016 16:54:46 GMT
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] libnfsidmap: Query DNS for the the NFSv4 domain
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <a452c0af-1c23-73a5-0fe7-a4d622099a6b@RedHat.com>
Date: Thu, 18 Aug 2016 12:54:36 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1557E393-F99D-44E3-B2E1-A7C7660A949F@oracle.com>
References: <1470950774-3649-1-git-send-email-steved@redhat.com> <CBF9A3DE-7B43-4838-BA27-9B9E60AB54FB@oracle.com> <910b6aed-a955-5fd1-982f-b5d4541f107e@RedHat.com> <7B86C63A-EB63-42EF-A0A6-34CFFAC10B96@oracle.com> <a452c0af-1c23-73a5-0fe7-a4d622099a6b@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey bud-

> On Aug 18, 2016, at 12:40 PM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> 
> 
> On 08/15/2016 11:16 AM, Chuck Lever wrote:
>>>>> On Aug 11, 2016, at 5:26 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>>>>>>> 
>>>>>>>> In domain_from_dns(), when at the hostname is a FQHN
>>>>>>>> query the DNS server for the _nfsv4idmapdomain TXT
>>>>>>>> record. If the record exists, use that as the
>>>>>>>> NFSv4 domain.
>>>>>>>> 
>>>>>>>> Note, this query will only happen if the domain name
>>>>>>>> is not set in the /etc/idmapd.conf
>>>>>> 
>>>>>> Is there a man page update that goes with this? The order in
>>>>>> which the library searches for the domain name should be
>>>>>> documented. idmapd.conf(5), maybe.
>>>> Yes... I should have made this an RFC patch since I just
>>>> wanted to get core out there for for comments... 
>>>> The man page needs to updated as well as the configure.ac.
>> To enable this feature IMO a better choice is to use a command
>> line option on nfsidmap and rpc.idmapd.
> I've be thinking about this... I don't think a command line 
> option is possible... How does a command line option tell a 
> internal library routine what to do? w/out creating new interface
> which is something I don't think we want to do...

I may have mentioned this elsewhere, but I changed my mind about this
already:

There's probably no need to have a command line option or a build-time
setting here, because setting the Domain = variable in /etc/idmapd.conf
is enough to disable the new query.


--
Chuck Lever



