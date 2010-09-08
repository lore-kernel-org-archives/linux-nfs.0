Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36565 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756043Ab0IHQXB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Sep 2010 12:23:01 -0400
Message-ID: <4C87B862.7010006@RedHat.com>
Date: Wed, 08 Sep 2010 12:22:58 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] Handle "proto=rdma" regressions
References: <20100907162156.3392.90376.stgit@seurat.1015granger.net> <4C867D14.4000203@RedHat.com> <43D9263D-B84F-46C8-837A-622DFA568391@oracle.com>
In-Reply-To: <43D9263D-B84F-46C8-837A-622DFA568391@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/07/2010 03:21 PM, Chuck Lever wrote:
> 
> On Sep 7, 2010, at 1:57 PM, Steve Dickson wrote:
> 
>>
>>
>> On 09/07/2010 12:25 PM, Chuck Lever wrote:
>>> Steve-
>>>
>>> This series is entirely untested, and is meant to be only an example
>>> of how we could handle "proto=rdma" and "rdma" in mount.nfs.
>>>
>>> The last patch in the series may not work at all.  It depends on the
>>> kernel returning EPROTONOSUPPORT for "vers=4,rdma".
>>>
>>> ---
>>>
>>> Chuck Lever (4):
>>>      mount.nfs: Prepare way for "vers=4,rdma" mounts
>>>      mount.nfs: Support an "rdma" mount option
>>>      mount.nfs: Use nfs_nfs_protocol() for checking for proto=rdma
>>>      getport: Recognize "rdma" and "rdma6" netid
>>>
>>>
>>> support/include/nfsrpc.h |    6 ++++++
>>> support/nfs/getport.c    |   25 +++++++++++++++++++++++++
>>> utils/mount/network.c    |    9 +++++++--
>>> utils/mount/nfs.man      |   11 ++++++++++-
>>> utils/mount/stropts.c    |   16 ++++++++--------
>>> 5 files changed, 56 insertions(+), 11 deletions(-)
>>>
>> With all due respect... NACK.... Here is why...
>>
>> 1) RDMA is not a network protocol and as I found out this
>>   weekend it *never* be one, so I see absolutely no reason 
>>   to treat RDMA like something it will never be. So using 
>>   nfs_nfs_protocol() is incorrect. 
> 
> I wrote this code, Steve.  That means I can say with authority that claiming 
> this usage of nfs_nfs_protocol() is "incorrect" is entirely your opinion, 
> and a mistaken one at that.
I have been mistaken before and will be again... I'm able to admit to that.

> 
> Look very closely at nfs_nfs_protcol().  It, like all the functions in that 
> part of utils/mount/network.c, is nothing more than a parser.  It is 
> designed to parse the "proto=" mount option.  We specify RDMA mounts with 
> "proto=rdma".  Thus it is an existing mechanism that was purposely designed 
> to parse this mount option and this value.
> 
> nfs_nfs_protocol() also parses the "tcp" and "udp" mount options.  We want to add support for a stand-alone "rdma" option, which is pretty much the same idea as the existing short-hand stand-alone options "tcp" and "udp" (which are not netids, by the way, they are protocol names).  Why would we not use the existing parsing function for parsing a new transport-related option?
> 
>> 2) Instead of modifying a couple if statements you are
>>   now making it a two step process to handle RDMA mount,
>>   which is not simpler.
> 
> I don't follow this at all.  What two step process?
This 
     if (nfs_nfs_proto())
then 
     if (proto == RDMA)

verses

if (nfs_rdma_option())

Two steps verse one...

> 
> My patches change the code to work exactly as I intended RDMA to work when 
> I wrote this two years ago.  The patches do not add any new steps.  
> In fact, it does pretty much exactly what your patch does, but it 
> avoids adding the rdma_enabled() function, and reuses code that is specifically designed for this purpose.
> 
> Look again very closely at nfs_nfs_protocol().  In my patch it does exactly the same work that rdma_enabled() does by making similar po_foo calls, but it also works for "tcp" "udp" and "proto=netid" in general.  Doesn't that seem to you like the right tool for the job?
> 
>> 3) Due to potential problems with callback with v4 the default
>>   version needs to be v3. But I do feel allowing the version
>>   to be set on the command line should work....
> 
> If a specific clientaddr= value is required for NFSv4 over RDMA mounts, that should be documented in nfs(5).  Or, if no clientaddr= should be specified, we should add code in the mount.nfs command to avoid appending clientaddr= for NFSv4 over RDMA mounts.
> 
> But this suggests that we haven't tested or documented NFSv4 over RDMA in a public manner.  Is that the case?
> 
>> One thing that has become very apparent to me is, RDMA
>> is not a network protocol and its not even a well defined 
>> netid. RDMA a special case (to use your words) so that is
>> they way we should treated..
> 
> It is true that RDMA is not a network protocol.  
> I don't see why that has any bearing on why a separate option parser is 
> needed for "proto=rdma".  The value of proto= is a netid string, and "rdma" 
> is a valid netid string, whether it is completely defined to include a 
> full definition of an underlying transport protocol or not.
> 
> If "rdma" has things in common with the other transports we already handle, 
> what benefit is there from adding more logic for it, just because "it's a 
> special case?" As far as I can tell, none.  Adding more logic just makes 
> the code more complicated.  Folding "rdma" into the existing code paths 
> designed for parsing netids and transport protocols therefore makes better 
> long term sense.
> 
> If it helps, the existing special casing in stropts.c which you replaced 
> was probably not optimal.  It should have used nfs_nfs_protocol() all along.  
> But I don't have RDMA here to test it, and no-one has complained about it, so 
> it lays fallow.
At the end of the day... both patches/ideas do the exact same thing, 
just differently... 

> 
> For a year now I've been arguing these points around mount.nfs that 
> should be obvious to everyone.  I'm really really tired of it.  
I am too... very tired of wasting time such trivial points...
 
Chuck I have the ultimate respect for your passion, intelligence
and global understand of our technology. But its becoming very
tiresome you not allowing anybody to make any changes in the mount
code.. 

> I've offered more than once to help by taking upstream and RH mount.nfs 
> bugs, but even though I know you are overworked you still insist on 
> trying to fix these yourself.  
Well thankfully there are people who think I'm doing a good job
and do think I have a clue as to what I am doing... 

> You then ask for comments and review, and defensively reject comments 
> and suggestions made by the code's original author, who really is the 
> ultimate authority on this code.
So since you wrote most of the code that make you the sole owner 
of the code and only you are allowed to changed it?? How does that
fit in the open source model? Isn't that more of a proprietary model?

> 
> So, go ahead and commit whatever you want.  Since last year, I don't 
> want to argue any more.
> 
Then stop... Arguments like this will stop when you become more open 
to other people's opinion and ideas when it comes to the mounting code.
You do not own the code... the community does... 

To move this forward, I *will* commit your patches as is, assuming
testing goes well... Not for technology reasons, since both patches
are technically equivalent, but to show I do not have to have 
everything exactly the way I want it... Please take note!     

steved.
 
