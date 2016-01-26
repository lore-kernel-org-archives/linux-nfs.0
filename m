Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54664 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932755AbcAZIZW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jan 2016 03:25:22 -0500
Date: Tue, 26 Jan 2016 09:25:33 +0100
From: Jan Kara <jack@suse.cz>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Remote access to pmem on storage targets
Message-ID: <20160126082533.GR24938@quack.suse.cz>
References: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Mon 25-01-16 16:19:24, Chuck Lever wrote:
> I'd like to propose a discussion of how to take advantage of
> persistent memory in network-attached storage scenarios.
> 
> RDMA runs on high speed network fabrics and offloads data
> transfer from host CPUs. Thus it is a good match to the
> performance characteristics of persistent memory.
> 
> Today Linux supports iSER, SRP, and NFS/RDMA on RDMA
> fabrics. What kind of changes are needed in the Linux I/O
> stack (in particular, storage targets) and in these storage
> protocols to get the most benefit from ultra-low latency
> storage?
> 
> There have been recent proposals about how storage protocols
> and implementations might need to change (eg. Tom Talpey's
> SNIA proposals for changing to a push data transfer model,
> Sagi's proposal to utilize DAX under the NFS/RDMA server,
> and my proposal for a new pNFS layout to drive RDMA data
> transfer directly).
> 
> The outcome of the discussion would be to understand what
> people are working on now and what is the desired
> architectural approach in order to determine where storage
> developers should be focused.
> 
> This could be either a BoF or a session during the main
> tracks. There is sure to be a narrow segment of each
> track's attendees that would have interest in this topic.

So hashing out details of pNFS layout isn't interesting to many people.
But if you want a broader architectural discussion about how to overcome
issues (and what those issues actually are) with the use of persistent
memory for NAS, then that may be interesting. So what do you actually want?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
