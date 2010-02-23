Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:50895 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752499Ab0BWQLf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Feb 2010 11:11:35 -0500
Date: Tue, 23 Feb 2010 10:12:24 -0600
From: bpm@sgi.com
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] sunrpc: socket buffer size module parameter
Message-ID: <20100223161224.GG10942@sgi.com>
References: <20100222215349.8481.80700.stgit@case> <20100222215447.8481.19927.stgit@case> <4B833056.8020703@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B833056.8020703@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Chuck,

On Mon, Feb 22, 2010 at 05:33:10PM -0800, Chuck Lever wrote:
> On 02/22/2010 01:54 PM, Ben Myers wrote:
>> +int            tcp_rcvbuf_nrpc = 6;
>
> Just curious, is this '6' a typo?

Not a typo.  The original setting for tcp receive buffer was hardcoded
at

3 (in svc_tcp_init and svc_tcp_recv_record)
	*
sv_max_mesg
	*
2 (in svc_sock_setbufsize)
	
That's where I came up with the 6 for the tcp recv buffer.  The setting
hasn't changed.



The UDP send/recv buffer settings and TCP send buffer settings were
going to be

( 4 (default number of kernel threads on sles11)
	+
3 (as in svc_udp_recvfrom, etc) )
	*
sv_max_mesg
	* 
2 (in svc_sock_setbufsize)

but 14 wasn't a very round number, so I went with 16 which also happened
to match the slot_table_entries default.

> Perhaps it would be nice to have a  
> single macro defined as the default value for all of these.
>
> Do we have a high degree of confidence that these new default settings  
> will not adversely affect workloads that already perform well?

This patch has been in several releases of SGI's nfsd respin and I've
heard nothing to suggest there is an issue.  I didn't spend much time
taking measurements on UDP and didn't keep my TCP measurements.  If you
feel measurements are essential I'll be happy to provide a few, but
won't be able to get around to it for a little while.

Thanks,
	Ben
