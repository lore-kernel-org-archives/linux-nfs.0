Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:21619 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756441AbcEXSUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2016 14:20:21 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC PATCH 0/1] Create a DNS SRV record of the ID mapping domain
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <c33c89df-ec54-fa6e-a84c-671f8a79f3c3@RedHat.com>
Date: Tue, 24 May 2016 14:20:14 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <AB5249F6-36B2-44DF-864E-9F90D16A07FE@oracle.com>
References: <1464020307-8806-1-git-send-email-steved@redhat.com> <B7AD5C8F-13A3-466A-BAC8-8A487939BC8F@oracle.com> <8d2c592d-2c43-85e4-a9fb-65b13206c2ee@RedHat.com> <D7102E5D-3328-4379-B8F2-BFDA86AAEBE4@oracle.com> <c33c89df-ec54-fa6e-a84c-671f8a79f3c3@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 24, 2016, at 1:43 PM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> 
> 
> On 05/24/2016 12:20 PM, Chuck Lever wrote:
>> 
>> 
>> So your security realm is redhat.com. Any way
>> to discover that fact, either at system install
>> time, or after every boot, or ... ?
> Yea... put it DNS ;-) But I think the answer
> is no... at least I don't know of a way. 
> 
>> 
>> I think the ID mapping domain name only matters
>> when you are using Kerberos? sec=sys should use
>> only stringified UIDs.
> Netapp filers still use name@domain strings and 
> probably  Solaris servers... I think only Linux
> use the stringified UIDs.

I'm pretty sure recent Solaris servers will behave
like Linux. But there's plenty of S10 out there.


>>>> How would "nfsidmap -d" work if the ID mapping
>>>> domain was set via DNS?
>>> I guess we would have to teach nfs4_get_default_domain()
>>> to check DNS like nfs4_init_name_mapping() would.
>> 
>> Or both functions could use common infrastructure
>> or a cached value.
> Yeah.. we could make domain_from_dns() a bit smarter... 
> 
>> 
>> 
>>>> Would the DNS-derived ID domain name be cached
>>>> somewhere?
>>> Currently its stored in the global default_domain
>>> variable in libnfsidmap... I think its a good
>>> place for it to live. 
>> 
>> That means every time an application loads
>> libnfsidmap, it has to retrieve the ID mapping
>> domain from DNS again?
> Yeah... which I didn't think it was a big deal with
> rpc.idmap since its only started once... but
> maybe that's not the best solution for every 
> nfsidmap upcall, although the uid/gids are cached
> maybe its not so bad.
> 
>> 
>> What if you built a small tool that just set
>> the Domain value in /etc/idmapd.conf during
>> system startup?
> I would hate to change something an admin has set.
> I'm thinking if Domain is set in /etc/idmapd.conf
> that override everything, including DNS.

Fair enough, there should be a way to override
the TXT value.


>>  $ nfsidmap --txt
>> 
>> could retrieve it and display it,
>> 
>>  # nfsidmap --txt -s
>> 
>> could retrieve it and update idmapd.conf if
>> there was a TXT record retrieved, for example.
> I see what you are trying to do here... instead 
> of rewriting idmapd.conf... we should probably
> uses... the system that shall go nameless... systemd! ;-)
> 
> systemd could run the nfsidmap --txt command that would
> create a file under /run, which is managed by the
> systemd-tmpfiles package. rpcbind does something similar
> to manage its warmstart up files. 
> 
> Then we could point rpc.idmap and nfsidmap to that
> runtime file via the libnfsidmap interfaces.

Or provide a setting in /etc/idmapd.conf which is
the pathname of the /run file.

It's a little nicer if these settings were all in
one place instead of split between /etc/sysconfig,
systemd configuration, and idmapd.conf.

No Domain= setting means:
1. use the contents of the /run file
2. if no /run file exists, or it's empty, use the
current mechanism to determine the ID mapping
domain name

How does hostnamectl work? does it use /run files?


> The problem with this is how do we expire this cache?
> We would have to store the TTL to know when its time
> to ping DNS again... Is the TTL returned in the DNS
> query?

I'm not aware of any required caching semantics
(again, no real standard here).

I wouldn't expect this setting to change very
often. Perhaps once per boot, or once per system
wake-up, or whenever there is a network configuration
change, is good enough. My guess is you don't want
this changing arbitrarily with running users on
the system. So maybe once per boot is the right
answer.

"nfsidmap --txt -s" could force a refresh by hand.

(Also we need to figure out how to break a tie
on multi-homed systems where more than one TXT
record is found; maybe the only thing to do in
that case is use Domain= , but you'd kind of
prefer good behavior without needing a manual
setting).


>> Then the rest of the infrastructure would not
>> have to change. Just a thought!
> yeah we probably should cache but it does add 
> a lot of complexity... Doesn't DNS cache things
> internally? If so, would using that cache work?

I think it's the same arrangement. The resolver's
cache is process-local.


--
Chuck Lever



