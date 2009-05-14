From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone over NFS
Date: Thu, 14 May 2009 09:34:03 -0400
Message-ID: <x49octv7qr8.fsf@segfault.boston.devel.redhat.com>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com>
	<20090508120119.8c93cfd7.akpm@linux-foundation.org>
	<20090511081415.GL4694@kernel.dk>
	<x49skjb21b7.fsf@segfault.boston.devel.redhat.com>
	<20090511165826.GG4694@kernel.dk>
	<x494ovp4r51.fsf@segfault.boston.devel.redhat.com>
	<20090512204433.7eb69075.akpm@linux-foundation.org>
	<x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com>
	<x49k54ku7i2.fsf@segfault.boston.devel.redhat.com>
	<1242258338.5407.244.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58155 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751317AbZENNfK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 May 2009 09:35:10 -0400
In-Reply-To: <1242258338.5407.244.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org> (Trond
	Myklebust's message of "Wed, 13 May 2009 19:45:38 -0400")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <trond.myklebust@fys.uio.no> writes:

> On Wed, 2009-05-13 at 15:29 -0400, Jeff Moyer wrote:
>> Hi, netdev folks.  The summary here is:
>> 
>> A patch added in the 2.6.30 development cycle caused a performance
>> regression in my NFS iozone testing.  The patch in question is the
>> following:
>> 
>> commit 47a14ef1af48c696b214ac168f056ddc79793d0e
>> Author: Olga Kornievskaia <aglo@citi.umich.edu>
>> Date:   Tue Oct 21 14:13:47 2008 -0400
>> 
>>     svcrpc: take advantage of tcp autotuning
>>  
>> which is also quoted below.  Using 8 nfsd threads, a single client doing
>> 2GB of streaming read I/O goes from 107590 KB/s under 2.6.29 to 65558
>> KB/s under 2.6.30-rc4.  I also see more run to run variation under
>> 2.6.30-rc4 using the deadline I/O scheduler on the server.  That
>> variation disappears (as does the performance regression) when reverting
>> the above commit.
>
> It looks to me as if we've got a bug in the svc_tcp_has_wspace() helper
> function. I can see no reason why we should stop processing new incoming
> RPC requests just because the send buffer happens to be 2/3 full. If we
> see that we have space for another reply, then we should just go for it.
> OTOH, we do want to ensure that the SOCK_NOSPACE flag remains set, so
> that the TCP layer knows that we're congested, and that we'd like it to
> increase the send window size, please.
>
> Could you therefore please see if the following (untested) patch helps?

I'm seeing slightly better results with the patch:

71548
75987
71557
87432
83538

But that's still not up to the speeds we saw under 2.6.29.  The packet
capture for one run can be found here:
  http://people.redhat.com/jmoyer/trond.pcap.bz2

Cheers,
Jeff
