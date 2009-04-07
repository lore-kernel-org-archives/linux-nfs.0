From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [PATCH 3/5] nfs-utils: query for remote port using rpcbind
   instead of getaddrinfo
Date: Tue, 07 Apr 2009 15:43:39 -0400
Message-ID: <49dbacf3.14025a0a.5898.ffffbaa2@mx.google.com>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
 <1239117946-7535-4-git-send-email-jlayton@redhat.com>
 <41F98279-F000-4C1C-8E44-3568C89FC2BD@oracle.com>
 <49db7f0d.85c2f10a.5025.ffffb257@mx.google.com>
 <20090407131151.69203e5e@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:58723 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755583AbZDGTnt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2009 15:43:49 -0400
Received: by yx-out-2324.google.com with SMTP id 31so2770675yxl.1
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2009 12:43:48 -0700 (PDT)
In-Reply-To: <20090407131151.69203e5e-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 01:11 PM 4/7/2009, Jeff Layton wrote:
>On Tue, 07 Apr 2009 12:27:49 -0400
>Tom Talpey <tmtalpey@gmail.com> wrote:
>
>> At 12:02 PM 4/7/2009, Chuck Lever wrote:
>> >
>> >On Apr 7, 2009, at 11:25 AM, Jeff Layton wrote:
>> >> +	/* Use standard NFS port for NFSv4 */
>> >> +	if (program == 100003 && version == 4) {
>> >> +		port = 2049;
>> >> +		goto set_port;
>> >> +	}
>> >
>> >I think this patch set looks pretty reasonable.  Here's my one  
>> >remaining quibble.
>> >
>> >You can specify "port=" for nfs4 mounts, in which case we want to use  
>> >that value here, too, I think.  It would be simpler overall if the  
>> 
>> *Must* use a port= specification. The 2049 definition is only true for
>> NFSv4/TCP, as a counterexample the NFSv4/RDMA IANA binding is
>> port 20049. So slamming the port to 2049 would break NFSv4/RDMA.
>> 
>
>rpc.gssd doesn't seem to be rdma-enabled at this point. It only seems
>to handle "tcp" and "udp" in the existing code.

Fair enough. But hardwiring 2049 for all transports is going to very
problematic. What's the motivation for bypassing the rpcbind query
altogether (that "goto set_port" skips over it)? Why not at least
try the query first?

>Does libtirpc handle RDMA properly? If so, this might not be too hard
>to enable, but I'd probably rather see it in a follow on patchset (and
>maybe by someone with more of a clue about RDMA than I currently have).

No, libtirpc doesn't have any RDMA support. But, there's no need for
RDMA support in it - only NFS does RDMA, in practice, and currently
that's just in-kernel.

My concern is simply that there be a way to specify, or discover a port
that isn't 2049 here. If mount.nfs supports it, other nfs-utils should too.

Tom.

