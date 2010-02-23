Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:51009 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948Ab0BWULm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Feb 2010 15:11:42 -0500
Message-ID: <4B84360E.3050700@oracle.com>
Date: Tue, 23 Feb 2010 12:09:50 -0800
From: Chuck Lever <chuck.lever@oracle.com>
To: bpm@sgi.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] sunrpc: socket buffer size module parameter
References: <20100222215349.8481.80700.stgit@case> <20100222215447.8481.19927.stgit@case> <4B833056.8020703@oracle.com> <20100223161224.GG10942@sgi.com>
In-Reply-To: <20100223161224.GG10942@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 02/23/2010 08:12 AM, bpm@sgi.com wrote:
> Hey Chuck,
>
> On Mon, Feb 22, 2010 at 05:33:10PM -0800, Chuck Lever wrote:
>> On 02/22/2010 01:54 PM, Ben Myers wrote:
>>> +int            tcp_rcvbuf_nrpc = 6;
>>
>> Just curious, is this '6' a typo?
>
> Not a typo.  The original setting for tcp receive buffer was hardcoded
> at
>
> 3 (in svc_tcp_init and svc_tcp_recv_record)
> 	*
> sv_max_mesg
> 	*
> 2 (in svc_sock_setbufsize)
> 	
> That's where I came up with the 6 for the tcp recv buffer.  The setting
> hasn't changed.
>
>
>
> The UDP send/recv buffer settings and TCP send buffer settings were
> going to be
>
> ( 4 (default number of kernel threads on sles11)
> 	+
> 3 (as in svc_udp_recvfrom, etc) )
> 	*
> sv_max_mesg
> 	*
> 2 (in svc_sock_setbufsize)
>
> but 14 wasn't a very round number, so I went with 16 which also happened
> to match the slot_table_entries default.

It triggered my "naked integer" nerve.  It would be nice to provide some 
level of detail, similar to your description here, in the comments 
around these settings.  Perhaps some guidance for admins about how to 
choose these values would also be warranted.

Most importantly, though, there should be some documentation of why 
these are the chosen defaults.

>> Perhaps it would be nice to have a
>> single macro defined as the default value for all of these.
>>
>> Do we have a high degree of confidence that these new default settings
>> will not adversely affect workloads that already perform well?
>
> This patch has been in several releases of SGI's nfsd respin and I've
> heard nothing to suggest there is an issue.  I didn't spend much time
> taking measurements on UDP and didn't keep my TCP measurements.  If you
> feel measurements are essential I'll be happy to provide a few, but
> won't be able to get around to it for a little while.

There were recent changes to the server's default buffer size settings 
that caused problems for certain common workloads.

I don't think you need to go overboard with measurements and rationale, 
but some guarantee that these two patches won't cause performance 
regressions on typical NFS server workloads would be "nice to have."

-- 
Chuck Lever
