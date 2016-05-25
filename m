Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22973 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbcEYPZc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 11:25:32 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC PATCH 0/1] Create a DNS SRV record of the ID mapping domain
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <995c5e10-61a0-d32c-dcab-1f6a4e943eae@RedHat.com>
Date: Wed, 25 May 2016 11:25:23 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <96802553-B978-4044-8697-0CE0A85BC255@oracle.com>
References: <1464020307-8806-1-git-send-email-steved@redhat.com> <B7AD5C8F-13A3-466A-BAC8-8A487939BC8F@oracle.com> <8d2c592d-2c43-85e4-a9fb-65b13206c2ee@RedHat.com> <D7102E5D-3328-4379-B8F2-BFDA86AAEBE4@oracle.com> <c33c89df-ec54-fa6e-a84c-671f8a79f3c3@RedHat.com> <AB5249F6-36B2-44DF-864E-9F90D16A07FE@oracle.com> <995c5e10-61a0-d32c-dcab-1f6a4e943eae@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 25, 2016, at 8:14 AM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> 
> 
> On 05/24/2016 02:20 PM, Chuck Lever wrote:
>>>> $ nfsidmap --txt
>>>>>> 
>>>>>> could retrieve it and display it,
>>>>>> 
>>>>>> # nfsidmap --txt -s
>>>>>> 
>>>>>> could retrieve it and update idmapd.conf if
>>>>>> there was a TXT record retrieved, for example.
>>>> I see what you are trying to do here... instead 
>>>> of rewriting idmapd.conf... we should probably
>>>> uses... the system that shall go nameless... systemd! ;-)
>>>> 
>>>> systemd could run the nfsidmap --txt command that would
>>>> create a file under /run, which is managed by the
>>>> systemd-tmpfiles package. rpcbind does something similar
>>>> to manage its warmstart up files. 
>>>> 
>>>> Then we could point rpc.idmap and nfsidmap to that
>>>> runtime file via the libnfsidmap interfaces.
>> Or provide a setting in /etc/idmapd.conf which is
>> the pathname of the /run file.
>> 
>> It's a little nicer if these settings were all in
>> one place instead of split between /etc/sysconfig,
>> systemd configuration, and idmapd.conf.hostnamectl
> I agree... but... we are dealing with systemd which 
> limits your options when it comes to reading in
> configuration files.
> 
>> 
>> No Domain= setting means:
>> 1. use the contents of the /run file
>> 2. if no /run file exists, or it's empty, use the
>> current mechanism to determine the ID mapping
>> domain name
> Right... but changing the name of the /run file
> really does not have to changeable, IMHO... 

Are /run files in the same place for every distribution?
If so, then I agree.


>> (Also we need to figure out how to break a tie
>> on multi-homed systems where more than one TXT
>> record is found; maybe the only thing to do in
>> that case is use Domain= , but you'd kind of
>> prefer good behavior without needing a manual
>> setting).
> Does that even work? How can you have multiple domains
> on the same host?

Which interface is used for the TXT record query?
If a system is on multiple networks with their
own DNS services, it is possible for them to see
a different TXT lookup result depending on which
interfaces happen to be up when the query is done,
and what DNS service has been set up by DHCP.


> I would say we document the fact the first TXT record
> processed is the one we go with. All others are ignored.

Can that value be guaranteed to be the same after
every boot, even in the face of things like changing
order of interface bring-up and DHCP?

The problem with "first TXT record processed" is that
the order these records are processed can change, and
thus the ID mapping domain name is potentially
different after every boot.

I think none of the automated mechanisms are 100%
reliable in this scenario, so the best that can be
done is to use the Domain setting in idmapd.conf.
But admins generally ignore this and hilarity ensues.

It may not be possible to solve it, but at least we
should provide tools for tracking down the issue if
it should occur. Maybe start by reporting the system's
ID mapping domain setting in the system log at boot
time, and how it was derived.

--
Chuck Lever



