Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:40719 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754587AbcEXU5R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 May 2016 16:57:17 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 51282280823
	for <linux-nfs@vger.kernel.org>; Tue, 24 May 2016 22:57:15 +0200 (CEST)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 375A3165A
	for <linux-nfs@vger.kernel.org>; Tue, 24 May 2016 22:57:13 +0200 (MEST)
Date: Tue, 24 May 2016 22:57:12 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Thomas Haynes <loghyr@primarydata.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <1785943916.14223495.1464123432988.JavaMail.zimbra@desy.de>
In-Reply-To: <FD49095E-BBF5-48FB-9313-B2874122701C@primarydata.com>
References: <1464020307-8806-1-git-send-email-steved@redhat.com> <B7AD5C8F-13A3-466A-BAC8-8A487939BC8F@oracle.com> <8d2c592d-2c43-85e4-a9fb-65b13206c2ee@RedHat.com> <D7102E5D-3328-4379-B8F2-BFDA86AAEBE4@oracle.com> <c33c89df-ec54-fa6e-a84c-671f8a79f3c3@RedHat.com> <AB5249F6-36B2-44DF-864E-9F90D16A07FE@oracle.com> <FD49095E-BBF5-48FB-9313-B2874122701C@primarydata.com>
Subject: Re: [RFC PATCH 0/1] Create a DNS SRV record of the ID mapping
 domain
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Thomas Haynes" <loghyr@primarydata.com>
> To: "Chuck Lever" <chuck.lever@oracle.com>
> Cc: "Steve Dickson" <SteveD@redhat.com>, "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
> Sent: Tuesday, May 24, 2016 9:34:28 PM
> Subject: Re: [RFC PATCH 0/1] Create a DNS SRV record of the ID mapping domain

>> On May 24, 2016, at 11:20 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>>> 
>>> On May 24, 2016, at 1:43 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>> 
>>> 
>>> 
>>> On 05/24/2016 12:20 PM, Chuck Lever wrote:
>>>> 
>>>> 
>>>> So your security realm is redhat.com. Any way
>>>> to discover that fact, either at system install
>>>> time, or after every boot, or ... ?
>>> Yea... put it DNS ;-) But I think the answer
>>> is no... at least I don't know of a way.
>>> 
>>>> 
>>>> I think the ID mapping domain name only matters
>>>> when you are using Kerberos? sec=sys should use
>>>> only stringified UIDs.
>>> Netapp filers still use name@domain strings and
>>> probably  Solaris servers... I think only Linux
>>> use the stringified UIDs.
>> 
> 
> C-mode uses stringified UIDs. Not so sure about 7-mode.
> 
> Primary Data uses stringified UIDs.


dCache server accepts stringified UIDs and returns
name@domain when possible.

A SRV record will help with auto configuration as
our nfsv4 domain and dns domain are different (long
story).

Tigran.


> 
> 
>> I'm pretty sure recent Solaris servers will behave
>> like Linux. But there's plenty of S10 out there.
>> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
