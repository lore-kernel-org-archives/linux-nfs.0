From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH RFC v2 06/21] nfs: nfs4xdr: optimize RESERVE_SPACE in encode_create_session and encode_sequence
Date: Fri, 14 Aug 2009 14:49:26 -0400
Message-ID: <10346A84-B1F3-4161-B518-0F5D68D2DC9B@oracle.com>
References: <4A8571E2.8020800@panasas.com> <1250259553-13672-1-git-send-email-bhalevy@panasas.com> <9734995E-20F8-4E53-83CD-BA95145D15ED@oracle.com> <1250269055.5476.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:31443 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049AbZHNSti (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 14:49:38 -0400
In-Reply-To: <1250269055.5476.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 14, 2009, at 12:57 PM, Trond Myklebust wrote:
> On Fri, 2009-08-14 at 12:32 -0400, Chuck Lever wrote:
>> On Aug 14, 2009, at 10:19 AM, Benny Halevy wrote:
>>> Coalesce multilpe constant RESERVE_SPACEs into one
>>>
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>> ---
>>> fs/nfs/nfs4xdr.c |   22 +++++-----------------
>>> 1 files changed, 5 insertions(+), 17 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>>> index 17915c8..d460d81 100644
>>> --- a/fs/nfs/nfs4xdr.c
>>> +++ b/fs/nfs/nfs4xdr.c
>>> @@ -1562,17 +1562,15 @@ static void encode_create_session(struct
>>> xdr_stream *xdr,
>>> 	uint32_t len;
>>> 	struct nfs_client *clp = args->client;
>>>
>>> -	RESERVE_SPACE(4);
>>> -	*p++ = cpu_to_be32(OP_CREATE_SESSION);
>>> +	len = scnprintf(machine_name, sizeof(machine_name), "%s",
>>> +			clp->cl_ipaddr);
>>>
>>> -	RESERVE_SPACE(8);
>>> +	RESERVE_SPACE(20 + 2*28 + 20 + len + 12);
>>
>> It would be nicer if we could use the foo_maxsz macros or "n *
>> sizeof(__be32)" here somehow instead of integers.

Note the use of "somehow" implying that my suggestion is not supposed  
to be a precise proscription for how to code it.  I presume we all  
understand well enough the meaning of these macros to get the idea of  
what I was trying to say.

> No. sizeof(__be32) is a constant == 4. Spelling it out in every
>>
> reserve_space would be bloat, not documentation.

>
> foo_maxsz is something completely different: it spells out the maximum
> possible buffer size. Please don't confuse that with the actual buffer
> content size.

The effective difference between foo_maxsz and the other macros is  
only in the variable size parts of each argument set.  maxsz can be  
constructed with a number of fixed size pieces that can be used  
separately or combined into a single macro that _is_ appropriate to  
use in the XDR routines.  Since we are explicitly adding the actual  
lengths of variable sized arguments before calling reserve_space(), I  
don't see a problem with using length macros for each argument.

The risk of using naked integers in the XDR routines is that if  
there's a length bug in the maxsz macros, we also need to visit the  
XDR routines carefully to find other instances of the same problem.   
If we use macros everywhere, then fixing one length macro will address  
all similar instances at once...

Maybe this isn't a big deal for something like the kernel's rpcbind  
client, but nfs4xdr.c is already complex enough that I would easily  
accept a slight decrease in readability to reduce the nontrivial risk  
of getting these values wrong.  Take it from someone who has found and  
fixed several such problems over the past few years: this is not a  
documentation issue.

Benny has combined the reserve_space() calls into a single call in  
each XDR routine, thus visually separating the marshalling of each  
argument from its related XDR buffer management.  If you already know  
what you're looking at, that's not much of an issue.  But for those  
who have never seen this code before, I think this reduces legibility  
in favor of a slight code optimization.  Using length macros would  
make it easier to understand the relationship between marshalling and  
buffer management in each routine.

> IOW: Please just leave the above as it is.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
