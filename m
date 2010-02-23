From: bpm@sgi.com
Subject: Re: [PATCH 2/2] sunrpc: socket buffer size module parameter
Date: Tue, 23 Feb 2010 14:48:45 -0600
Message-ID: <20100223204845.GN10942@sgi.com>
References: <20100222215349.8481.80700.stgit@case> <20100222215447.8481.19927.stgit@case> <4B833056.8020703@oracle.com> <20100223161224.GG10942@sgi.com> <4B84360E.3050700@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:58301 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752420Ab0BWUr4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Feb 2010 15:47:56 -0500
In-Reply-To: <4B84360E.3050700@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck,

On Tue, Feb 23, 2010 at 12:09:50PM -0800, Chuck Lever wrote:
> On 02/23/2010 08:12 AM, bpm@sgi.com wrote:
>> On Mon, Feb 22, 2010 at 05:33:10PM -0800, Chuck Lever wrote:
>>> On 02/22/2010 01:54 PM, Ben Myers wrote:
>>>> +int            tcp_rcvbuf_nrpc = 6;
>>>
>>> Just curious, is this '6' a typo?
>>
>> Not a typo.  The original setting for tcp receive buffer was hardcoded
>> at
>>
>> 3 (in svc_tcp_init and svc_tcp_recv_record)
>> 	*
>> sv_max_mesg
>> 	*
>> 2 (in svc_sock_setbufsize)
>> 	
>> That's where I came up with the 6 for the tcp recv buffer.  The setting
>> hasn't changed.
>>
>>
>>
>> The UDP send/recv buffer settings and TCP send buffer settings were
>> going to be
>>
>> ( 4 (default number of kernel threads on sles11)
>> 	+
>> 3 (as in svc_udp_recvfrom, etc) )
>> 	*
>> sv_max_mesg
>> 	*
>> 2 (in svc_sock_setbufsize)
>>
>> but 14 wasn't a very round number, so I went with 16 which also happened
>> to match the slot_table_entries default.
>
> It triggered my "naked integer" nerve.  It would be nice to provide some  
> level of detail, similar to your description here, in the comments  
> around these settings.

Sure... I'll add some comments.

> Perhaps some guidance for admins about how to  
> choose these values would also be warranted.

Learning how best to use the settings will take some experimentation
which is something I hadn't bothered to do.  Here I was simply trying to
remove a scalability limitation.

> Most importantly, though, there should be some documentation of why  
> these are the chosen defaults.
>
>>> Perhaps it would be nice to have a
>>> single macro defined as the default value for all of these.
>>>
>>> Do we have a high degree of confidence that these new default settings
>>> will not adversely affect workloads that already perform well?
>>
>> This patch has been in several releases of SGI's nfsd respin and I've
>> heard nothing to suggest there is an issue.  I didn't spend much time
>> taking measurements on UDP and didn't keep my TCP measurements.  If you
>> feel measurements are essential I'll be happy to provide a few, but
>> won't be able to get around to it for a little while.
>
> There were recent changes to the server's default buffer size settings  
> that caused problems for certain common workloads.

Yeah, I think I saw that stuff go by.

> I don't think you need to go overboard with measurements and rationale,  
> but some guarantee that these two patches won't cause performance  
> regressions on typical NFS server workloads would be "nice to have."

I'll do some benchmarking with tar and some streaming io with dd and
repost.  If you have some suggestions about appropriate workloads I'm
all ears. 

Thanks,
	Ben
