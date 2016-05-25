Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20305 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbcEYQMe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 12:12:34 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC PATCH 0/1] Create a DNS SRV record of the ID mapping domain
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <335b4fac-3b9e-4281-d620-9dd085c93c4d@RedHat.com>
Date: Wed, 25 May 2016 12:12:28 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <3036B8A9-D65C-4342-ADF1-74A24BC9F9B0@oracle.com>
References: <1464020307-8806-1-git-send-email-steved@redhat.com> <B7AD5C8F-13A3-466A-BAC8-8A487939BC8F@oracle.com> <8d2c592d-2c43-85e4-a9fb-65b13206c2ee@RedHat.com> <D7102E5D-3328-4379-B8F2-BFDA86AAEBE4@oracle.com> <c33c89df-ec54-fa6e-a84c-671f8a79f3c3@RedHat.com> <AB5249F6-36B2-44DF-864E-9F90D16A07FE@oracle.com> <995c5e10-61a0-d32c-dcab-1f6a4e943eae@RedHat.com> <96802553-B978-4044-8697-0CE0A85BC255@oracle.com> <335b4fac-3b9e-4281-d620-9dd085c93c4d@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 25, 2016, at 12:07 PM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> 
> 
> On 05/25/2016 11:25 AM, Chuck Lever wrote:
>> 
>>> On May 25, 2016, at 8:14 AM, Steve Dickson <SteveD@redhat.com> wrote:
>>> Does that even work? How can you have multiple domains
>>> on the same host?
>> 
>> Which interface is used for the TXT record query?
> I'm assuming the interfaces in /etc/resolv.conf

The DHCP client can change /etc/resolv.conf.


>> If a system is on multiple networks with their
>> own DNS services, it is possible for them to see
>> a different TXT lookup result depending on which
>> interfaces happen to be up when the query is done,
>> and what DNS service has been set up by DHCP.
> From my understand of the BIND api, which is 
> very limited, domain names and field names
> are use to do lookups. Not interfaces. 
> 
>> 
>> 
>>> I would say we document the fact the first TXT record
>>> processed is the one we go with. All others are ignored.
>> 
>> Can that value be guaranteed to be the same after
>> every boot, even in the face of things like changing
>> order of interface bring-up and DHCP?
> none... we are asking for a TXT record called
> _nfsv4idmapdomain for from a particular domain.
> why would we care what interface it comes from?

The order in which interfaces initialize may control
the contents of /etc/resolv.conf.


>> The problem with "first TXT record processed" is that
>> the order these records are processed can change, and
>> thus the ID mapping domain name is potentially
>> different after every boot.
>> 
>> I think none of the automated mechanisms are 100%
>> reliable in this scenario, so the best that can be
>> done is to use the Domain setting in idmapd.conf.
>> But admins generally ignore this and hilarity ensues.
>> 
>> It may not be possible to solve it, but at least we
>> should provide tools for tracking down the issue if
>> it should occur. Maybe start by reporting the system's
>> ID mapping domain setting in the system log at boot
>> time, and how it was derived.
> I think this is a phase two thing... Lets the the 
> core up and working and then go from there.

Fair enough, but adding a log entry seems like
it is simple enough to do as part of phase one.


--
Chuck Lever



