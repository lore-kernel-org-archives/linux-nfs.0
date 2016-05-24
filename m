Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41178 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752692AbcEXRnM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 May 2016 13:43:12 -0400
Subject: Re: [RFC PATCH 0/1] Create a DNS SRV record of the ID mapping domain
To: Chuck Lever <chuck.lever@oracle.com>
References: <1464020307-8806-1-git-send-email-steved@redhat.com>
 <B7AD5C8F-13A3-466A-BAC8-8A487939BC8F@oracle.com>
 <8d2c592d-2c43-85e4-a9fb-65b13206c2ee@RedHat.com>
 <D7102E5D-3328-4379-B8F2-BFDA86AAEBE4@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <c33c89df-ec54-fa6e-a84c-671f8a79f3c3@RedHat.com>
Date: Tue, 24 May 2016 13:43:11 -0400
MIME-Version: 1.0
In-Reply-To: <D7102E5D-3328-4379-B8F2-BFDA86AAEBE4@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/24/2016 12:20 PM, Chuck Lever wrote:
> 
> 
> So your security realm is redhat.com. Any way
> to discover that fact, either at system install
> time, or after every boot, or ... ?
Yea... put it DNS ;-) But I think the answer
is no... at least I don't know of a way. 

> 
> I think the ID mapping domain name only matters
> when you are using Kerberos? sec=sys should use
> only stringified UIDs.
Netapp filers still use name@domain strings and 
probably  Solaris servers... I think only Linux
use the stringified UIDs.


>>>
>>> How would "nfsidmap -d" work if the ID mapping
>>> domain was set via DNS?
>> I guess we would have to teach nfs4_get_default_domain()
>> to check DNS like nfs4_init_name_mapping() would.
> 
> Or both functions could use common infrastructure
> or a cached value.
Yeah.. we could make domain_from_dns() a bit smarter... 

> 
> 
>>> Would the DNS-derived ID domain name be cached
>>> somewhere?
>> Currently its stored in the global default_domain
>> variable in libnfsidmap... I think its a good
>> place for it to live. 
> 
> That means every time an application loads
> libnfsidmap, it has to retrieve the ID mapping
> domain from DNS again?
Yeah... which I didn't think it was a big deal with
rpc.idmap since its only started once... but
maybe that's not the best solution for every 
nfsidmap upcall, although the uid/gids are cached
maybe its not so bad.

> 
> What if you built a small tool that just set
> the Domain value in /etc/idmapd.conf during
> system startup?
I would hate to change something an admin has set.
I'm thinking if Domain is set in /etc/idmapd.conf
that override everything, including DNS.
 
> 
>   $ nfsidmap --txt
> 
> could retrieve it and display it,
> 
>   # nfsidmap --txt -s
> 
> could retrieve it and update idmapd.conf if
> there was a TXT record retrieved, for example.
I see what you are trying to do here... instead 
of rewriting idmapd.conf... we should probably
uses... the system that shall go nameless... systemd! ;-)

systemd could run the nfsidmap --txt command that would
create a file under /run, which is managed by the
systemd-tmpfiles package. rpcbind does something similar
to manage its warmstart up files. 

Then we could point rpc.idmap and nfsidmap to that
runtime file via the libnfsidmap interfaces. 

The problem with this is how do we expire this cache?
We would have to store the TTL to know when its time
to ping DNS again... Is the TTL returned in the DNS
query? 

> 
> Then the rest of the infrastructure would not
> have to change. Just a thought!
yeah we probably should cache but it does add 
a lot of complexity... Doesn't DNS cache things
internally? If so, would using that cache work?

steved.

