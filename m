Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40626 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753446AbcEYMOc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 May 2016 08:14:32 -0400
Subject: Re: [RFC PATCH 0/1] Create a DNS SRV record of the ID mapping domain
To: Chuck Lever <chuck.lever@oracle.com>
References: <1464020307-8806-1-git-send-email-steved@redhat.com>
 <B7AD5C8F-13A3-466A-BAC8-8A487939BC8F@oracle.com>
 <8d2c592d-2c43-85e4-a9fb-65b13206c2ee@RedHat.com>
 <D7102E5D-3328-4379-B8F2-BFDA86AAEBE4@oracle.com>
 <c33c89df-ec54-fa6e-a84c-671f8a79f3c3@RedHat.com>
 <AB5249F6-36B2-44DF-864E-9F90D16A07FE@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <995c5e10-61a0-d32c-dcab-1f6a4e943eae@RedHat.com>
Date: Wed, 25 May 2016 08:14:30 -0400
MIME-Version: 1.0
In-Reply-To: <AB5249F6-36B2-44DF-864E-9F90D16A07FE@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/24/2016 02:20 PM, Chuck Lever wrote:
>>>  $ nfsidmap --txt
>>> >> 
>>> >> could retrieve it and display it,
>>> >> 
>>> >>  # nfsidmap --txt -s
>>> >> 
>>> >> could retrieve it and update idmapd.conf if
>>> >> there was a TXT record retrieved, for example.
>> > I see what you are trying to do here... instead 
>> > of rewriting idmapd.conf... we should probably
>> > uses... the system that shall go nameless... systemd! ;-)
>> > 
>> > systemd could run the nfsidmap --txt command that would
>> > create a file under /run, which is managed by the
>> > systemd-tmpfiles package. rpcbind does something similar
>> > to manage its warmstart up files. 
>> > 
>> > Then we could point rpc.idmap and nfsidmap to that
>> > runtime file via the libnfsidmap interfaces.
> Or provide a setting in /etc/idmapd.conf which is
> the pathname of the /run file.
> 
> It's a little nicer if these settings were all in
> one place instead of split between /etc/sysconfig,
> systemd configuration, and idmapd.conf.hostnamectl
I agree... but... we are dealing with systemd which 
limits your options when it comes to reading in
configuration files.

> 
> No Domain= setting means:
> 1. use the contents of the /run file
> 2. if no /run file exists, or it's empty, use the
> current mechanism to determine the ID mapping
> domain name
Right... but changing the name of the /run file
really does not have to changeable, IMHO... 
 
> 
> How does hostnamectl work? does it use /run files?
Taking a quick look it appears not to... I see a lot
of dbus code... It does not look too interesting to me. 

> 
> 
>> > The problem with this is how do we expire this cache?
>> > We would have to store the TTL to know when its time
>> > to ping DNS again... Is the TTL returned in the DNS
>> > query?
> I'm not aware of any required caching semantics
> (again, no real standard here).
> 
> I wouldn't expect this setting to change very
> often. Perhaps once per boot, or once per system
> wake-up, or whenever there is a network configuration
> change, is good enough. My guess is you don't want
> this changing arbitrarily with running users on
> the system. So maybe once per boot is the right
> answer.
Fine... we can deal with expiring the cache if
it becomes an issue... 

> 
> "nfsidmap --txt -s" could force a refresh by hand.
True.

> 
> (Also we need to figure out how to break a tie
> on multi-homed systems where more than one TXT
> record is found; maybe the only thing to do in
> that case is use Domain= , but you'd kind of
> prefer good behavior without needing a manual
> setting).
Does that even work? How can you have multiple domains
on the same host? 

I would say we document the fact the first TXT record
processed is the one we go with. All others are ignored.

steved.
