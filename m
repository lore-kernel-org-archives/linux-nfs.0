Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49914 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937AbcEXQUT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2016 12:20:19 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC PATCH 0/1] Create a DNS SRV record of the ID mapping domain
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <8d2c592d-2c43-85e4-a9fb-65b13206c2ee@RedHat.com>
Date: Tue, 24 May 2016 12:20:13 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D7102E5D-3328-4379-B8F2-BFDA86AAEBE4@oracle.com>
References: <1464020307-8806-1-git-send-email-steved@redhat.com> <B7AD5C8F-13A3-466A-BAC8-8A487939BC8F@oracle.com> <8d2c592d-2c43-85e4-a9fb-65b13206c2ee@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 24, 2016, at 12:02 PM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> Hello,
> 
> On 05/23/2016 01:22 PM, Chuck Lever wrote:
>> 
>>> On May 23, 2016, at 12:18 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>> 
>>> I have a customer that requested the domain used
>>> to do the ID mapping be available via DNS SVR 
>>> record. I didn't think was that bad of an idea.
>> 
>> Solaris NFS peers look for a TXT record. This
>> facility has been around for a decade or more.
>> 
>> ;; NFSv4 domain (for idmapping).  See Sun doc 819-1634 and
>> ;;      http://tools.ietf.org/html/draft-mesta-nfsv4-domain-01.html
>> _nfsv4idmapdomain               IN TXT          "oracle.com"
> I see... Looks reasonable
> 
>> 
>> But there's no standard in this area. mesta-nfsv4-domain
>> was a personal I-D that never advanced. I brought it
>> up again in Orlando, and the WG decided to table it.
>> 
>> At the time it was decided that the right course of
>> action was for the NFSv4 idmapping domain to be set
>> based on security realm or other criteria. There was
>> no interest in involving DNS at all.
> Hmm... it seems pretty convenient to me... although
> its just another place for rpc.idmap to get hung. ;-)

Right, see below for a way to prevent that.


>>> IPA and FedFS use SRV records which seem to work out
>>> pretty well. This patch is heavily based on the 
>>> FedFS code. ;-) 
>>> 
>>> My only question is do we want libnfsidmap to be
>>> dependent on the resolver library. There has been
>>> some talk about moving libnfsidmap into nfs-utils
>>> which means nfs-utils would be dependent the
>>> resolver library. 
>>> 
>>> Note, this is not complete. If we are going to do
>>> this I have to document it somehow, either in 
>>> the man page or idmap.conf or both.
>>> 
>>> Just looking for thoughts... good/bad idea??
>> 
>> If you really do want to go down this path, I
>> think Linux should follow the existing de facto
>> standard (TXT), not invent its own. Maybe also
>> check how SMB does this.
> I think I will and I agree using a TXT RR is
> the way to go... Why reinvent the wheel?? 8-) 
> 
>> 
>> Involving a published DNS record format should
>> require standards action. But I was discouraged
>> from pursuing this further.
> I think if everybody is doing the same thing
> would be good enough...
> 
>> 
>> I think it's important to ask in what cases
>> will the ID mapping domain be different than
>> the system's DNS domain name, and is there a
>> preferable mechanism for determining the ID
>> mapping domain in those cases? Knowing more
>> about how your customer plans to use this
>> feature would help us discuss this more fully.
> This would help me here at Red Hat. I live
> on at (eat your own dog food) test network 
> that has its own DNS 
> 
> So steved@redhat.com maps into a valid id/gid but 
> steved@devel.redhat.com  does not so I need to add a 
> Domain=redhat.com in /etc/idmapd.conf to get
> v4 working. Having the domain in our test DNS 
> would work out well.

So your security realm is redhat.com. Any way
to discover that fact, either at system install
time, or after every boot, or ... ?

I think the ID mapping domain name only matters
when you are using Kerberos? sec=sys should use
only stringified UIDs.


> Also, the person that is asking for this is
> probably moving from a Solaris env to Linx
> env... That's just a guess. 
> 
>> 
>> I've also proposed the ability to set the ID
>> mapping domain via a command line tool like
>> nfsidmap. But I never got past the difficulties
>> of parsing and updating the /etc/idmapd.conf
>> file. It makes sense to add an API to libnfsidmap
>> for setting the system's ID mapping domain name.
> Does having the domain in DNS help with this? I'm
> thinking not... 
> 
>> 
>> How would "nfsidmap -d" work if the ID mapping
>> domain was set via DNS?
> I guess we would have to teach nfs4_get_default_domain()
> to check DNS like nfs4_init_name_mapping() would.

Or both functions could use common infrastructure
or a cached value.


>> Would the DNS-derived ID domain name be cached
>> somewhere?
> Currently its stored in the global default_domain
> variable in libnfsidmap... I think its a good
> place for it to live. 

That means every time an application loads
libnfsidmap, it has to retrieve the ID mapping
domain from DNS again?

What if you built a small tool that just set
the Domain value in /etc/idmapd.conf during
system startup?

  $ nfsidmap --txt

could retrieve it and display it,

  # nfsidmap --txt -s

could retrieve it and update idmapd.conf if
there was a TXT record retrieved, for example.

Then the rest of the infrastructure would not
have to change. Just a thought!

--
Chuck Lever



