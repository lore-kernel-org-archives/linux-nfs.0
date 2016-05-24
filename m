Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:29727 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754209AbcEXTef convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 May 2016 15:34:35 -0400
From: Thomas Haynes <loghyr@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH 0/1] Create a DNS SRV record of the ID mapping domain
Date: Tue, 24 May 2016 19:34:28 +0000
Message-ID: <FD49095E-BBF5-48FB-9313-B2874122701C@primarydata.com>
References: <1464020307-8806-1-git-send-email-steved@redhat.com>
 <B7AD5C8F-13A3-466A-BAC8-8A487939BC8F@oracle.com>
 <8d2c592d-2c43-85e4-a9fb-65b13206c2ee@RedHat.com>
 <D7102E5D-3328-4379-B8F2-BFDA86AAEBE4@oracle.com>
 <c33c89df-ec54-fa6e-a84c-671f8a79f3c3@RedHat.com>
 <AB5249F6-36B2-44DF-864E-9F90D16A07FE@oracle.com>
In-Reply-To: <AB5249F6-36B2-44DF-864E-9F90D16A07FE@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 24, 2016, at 11:20 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On May 24, 2016, at 1:43 PM, Steve Dickson <SteveD@redhat.com> wrote:
>> 
>> 
>> 
>> On 05/24/2016 12:20 PM, Chuck Lever wrote:
>>> 
>>> 
>>> So your security realm is redhat.com. Any way
>>> to discover that fact, either at system install
>>> time, or after every boot, or ... ?
>> Yea... put it DNS ;-) But I think the answer
>> is no... at least I don't know of a way. 
>> 
>>> 
>>> I think the ID mapping domain name only matters
>>> when you are using Kerberos? sec=sys should use
>>> only stringified UIDs.
>> Netapp filers still use name@domain strings and 
>> probably  Solaris servers... I think only Linux
>> use the stringified UIDs.
> 

C-mode uses stringified UIDs. Not so sure about 7-mode.

Primary Data uses stringified UIDs.


> I'm pretty sure recent Solaris servers will behave
> like Linux. But there's plenty of S10 out there.
> 


