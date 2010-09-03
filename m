Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51913 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753348Ab0ICT7w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Sep 2010 15:59:52 -0400
Message-ID: <4C8153B5.7020304@RedHat.com>
Date: Fri, 03 Sep 2010 15:59:49 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mount: RDMA processing in the mount command is broken
References: <1283457651-12010-1-git-send-email-steved@redhat.com> <1FB4635E-5757-420B-A32B-47D2D1778A56@oracle.com> <4C802914.50505@RedHat.com> <34BF22EC-F3D3-40AA-A4AA-8019886DAC94@oracle.com>
In-Reply-To: <34BF22EC-F3D3-40AA-A4AA-8019886DAC94@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey,

On 09/03/2010 12:01 PM, Chuck Lever wrote:
> 
> On Sep 2, 2010, at 6:45 PM, Steve Dickson wrote:
> 
>> Hey Chuck,
>>
>> On 09/02/2010 04:15 PM, Chuck Lever wrote:
>>>
>>> On Sep 2, 2010, at 4:00 PM, Steve Dickson wrote:
>>>
>>>> The mounting code that process RMDA mounts is broken in a few places
>>>>
>>>> First with '-o proto=rdma' was broken because nfs_get_proto()
>>>> did not how to convert a netid of 'rdma' in to a AF_INET
>>>> address family.
>>>
>>> The usual solution for that is to add appropriate definitions to /etc/netconfig.  
>>> Since "rdma" is going to become (or has become) a valid "IETF standard" netid, 
>>> shouldn't this be handled just like the other netids?  
>> No.. because it is not a netid... when 'rdma' become a netid we'll treat 
>> like one. Until the then let treat like we always have been... 
> 
> See the table in standards track RFC 5665 section 5.1.1, which defines 
> both "rdma" and "rdma6" netids.  "rdma" is a netid.
I stand corrected... Thank for pointing this RFC out. I looks
real interesting! ;-) 
  

> The way we treat  "proto=rdma" today is a hack which we should be rid of 
> as soon as possible.
>

> The real question is whether it is practical for libtirpc and getprotobyname(3) to 
> treat it like a netid at this time.  If it isn't, then we will need to 
> continue to special case it in the mount command.  That requires some internal 
> documentation of the issues, however.  At the very least you need a proper 
> comment in both copies of nfs_get_proto(), because for now this is a very 
> special case and should be treated as exceptional, not the norm.
Fine... A comment will be added.

> 
> The larger version of nfs_get_proto() should do something about "rdma6" too.

> 
>>> At some point "rdma" is going to start showing up in rpcbind, 
>>> so this is going to have to work like a normal netid.
>> When this happen I will be more that willing to accept 
>> the patches that will add support for the new netid.
>>
>>>
>>>> Secondly, '-o rdma' was broken because po_get() was being using
>>>> to detect the existence of 'rdma' in the options. With '-o rdma'
>>>> there is no value associated with that option so po_get()
>>>> was always return NULL.
>>>
>>> This should be handled just the same way the "udp" and "tcp" mount 
>>> options are handled, in nfs_nfs_protocol().  Just add an entry for 
>>> "rdma" in nfs_transport_opttbl. The problem is we don't have an 
>>> IPPROTO_ number for RDMA, so you'll have to make one up.
>> Exactly... And I was not about to make up a  IPPROTO_ number
>> I just think that's crazy...
> 
> "That's crazy" is an opinion.  Do you have a technical argument for not wanting 
>  to create a special value?
Because its simply not needed... I explain later in this email...  

> 
> It doesn't have to be in the system headers, since only 
> mount.nfs will use it, for now.  There isn't an IANA protocol number assigned 
> to it yet, it looks like, so we can't add it outside of mount.nfs.
When a number is assigned, we will add it and use it.. 

> 
> Basically you are ignoring the existing mechanism which mount.nfs uses for all the 
> other protocol names just because you don't want to add a 
> macro that defines NFSPROTO_RDMA ?
No. I'm improving code that was already there and again I just
don't see there is a need for a NFSPROTO_RDMA define... It will
not make the code any clear or cleaner that what I'm 
currently proposing...

> 
>> Plus it turns out we didn't need to.
>> All that's needed is for the address family to be set to 
>> AF_INET, from what Tom said. So it makes total sense put the
>> check in nfs_get_proto()
> 
> This part of my argument isn't about nfs_get_proto() or about "proto=rdma".
> I'm saying if we want a mount option that behaves like "udp" and "tcp" we 
> should treat it that way, and put it in nfs_trans_opttbl[], because 
> that's exactly why I created that table and nfs_nfs_protocol() 
> and po_rightmost() in the first place.
>From the user standpoint the rdma option will behave like udp and tcp.

> 
> Whenever practical, we should avoid the "slippery slope" of adding 
> special cases for these mount options.  
While I agree special cases can lead to slippery slopes, I don't
agree with of adding a tons and tons of code just for the sake
appearing to adhere to a yet not formed standard...  When an
IANA protocol number is assigned we will use it and properly
integrate it into the code.  But until then I think added one 
9 line routine and 3 if statements is not unreasonable. 

> I don't yet see a reason why this rule should not apply here.
My reasoning is this: We are enabling this new technology. If/When
this new technology matures, we (this code) will mature with it.
So adding these few lines (special cases to use your terms) is
need to enable this technology now, which is the right thing to do, IMHO...

> 
>>> What does the kernel do in these cases?
>> I took a quick look it appears they use IPPROTO_TCP (see xprt_setup_rdma())
>> but it appears they did not make up a IPPROTO_ number.
> 
> The kernel requires IPPROTO_TCP because it copies this to the mount 
> transport protocol value.  It could very easily have chosen a unique value.
> This very issue is why we have the XPRT_TRANSPORT_ macros in the kernel 
> in the first place.
My point was they didn't create unique value... 

> 
>>>> This patch address both those problems.
>>>
>>> Let's not riddle the mount code with these ad hoc string comparisons when 
>>> we've already got plenty adequate generic support for adding new transport labels.
>> Riddle?? I'm condensing two existing (broken) if statements and adding 
>> a third... I'm a bit taken back by your verbiage... I see changes to be
>> very unobtrusive and clean... with the befit of them working... ;-)
> 
> The only time "it works" is a reason to commit a patch is when "it is 
> the only way to get the job done" is also true.  I don't think that's 
> the case here.
> 
> I might be equally offended by your use of (broken).  Those if statements are 
> working as designed.  See my other e-mail.
By no means did I mean to offend you... I was not able to do a rdma mount
with either the "proto=rdma" or "-o rdma" option. When I changed those
if statements, I was able to...  That's all I meant by being broken. 

> 
> But to address a specific technical point: if nfs_nfs_protocol() 
> returned a specific value for "proto=rdma" or "rdma" then I don't think 
> you would need rdma_enabled() at all.
I took a look doing it this way... sincerely hoping it would be that
easy.. but its not... 

nfs_nfs_protocol() returns network established protocols for things like 
the portmapper, the configuration file and such... Now we have clearly 
established there is no IPPROTO_RDMA protocol, so I would have to teach 
all the callers of nfs_nfs_protocol() about IPPROTO_RDMA. 

Plus, nfs_get_proto() would still have to be taught about rdma since 
the first thing it does is call getnetconfigent() with the given netid and
we've clearly established we currently don't have the support for 
a rdma netid...

Now I'm not against doing this work, but let the IANA people to
give use something to work with. When I see the rdma protocol in
/etc/protocols and a IPPROTO_RDMA established, I will be more
than willing to do the work... but at this point, to simply
enable this new technology, its just not worth it... 

All that's need, at this point, is for the mount command to 
use the correct address family, set the correct protocol version 
and not do portmapper negation.. that's it!  

> 
> Looking at Neil's patches last week, it occurred to me that 
> we might want to grab the protocol settings in nfs_validate_options() 
> and cache that number in the mount_info (just as is done with the 
> version number). That way we would have that value throughout 
> the process and wouldn't need to reparse the mount options 
> multiple times when choosing how to process the mount request.
> 
I have not gotten to his patches yet... I've trying to get NFSoverRDMA
working... ;-) 

steved.
