Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47979 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965033AbcAZP6x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2016 10:58:53 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Remote access to pmem on storage targets
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160126082533.GR24938@quack.suse.cz>
Date: Tue, 26 Jan 2016 10:58:44 -0500
Cc: lsf-pc@lists.linux-foundation.org,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F0E2108B-891C-4570-B486-7DC7C4FB59C4@oracle.com>
References: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com> <20160126082533.GR24938@quack.suse.cz>
To: Jan Kara <jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 26, 2016, at 3:25 AM, Jan Kara <jack@suse.cz> wrote:
> 
> Hello,
> 
> On Mon 25-01-16 16:19:24, Chuck Lever wrote:
>> I'd like to propose a discussion of how to take advantage of
>> persistent memory in network-attached storage scenarios.
>> 
>> RDMA runs on high speed network fabrics and offloads data
>> transfer from host CPUs. Thus it is a good match to the
>> performance characteristics of persistent memory.
>> 
>> Today Linux supports iSER, SRP, and NFS/RDMA on RDMA
>> fabrics. What kind of changes are needed in the Linux I/O
>> stack (in particular, storage targets) and in these storage
>> protocols to get the most benefit from ultra-low latency
>> storage?
>> 
>> There have been recent proposals about how storage protocols
>> and implementations might need to change (eg. Tom Talpey's
>> SNIA proposals for changing to a push data transfer model,
>> Sagi's proposal to utilize DAX under the NFS/RDMA server,
>> and my proposal for a new pNFS layout to drive RDMA data
>> transfer directly).
>> 
>> The outcome of the discussion would be to understand what
>> people are working on now and what is the desired
>> architectural approach in order to determine where storage
>> developers should be focused.
>> 
>> This could be either a BoF or a session during the main
>> tracks. There is sure to be a narrow segment of each
>> track's attendees that would have interest in this topic.
> 
> So hashing out details of pNFS layout isn't interesting to many people.
> But if you want a broader architectural discussion about how to overcome
> issues (and what those issues actually are) with the use of persistent
> memory for NAS, then that may be interesting. So what do you actually want?

I mentioned pNFS briefly only as an example. There have
been a variety of proposals and approaches so far, and
it's time, I believe, to start focusing our efforts.

Thus I'm requesting a "broader architectural discussion
about how to overcome issues with the use of persistent
memory for NAS," in particular how we'd like to do this
with the Linux implementations of the iSER, SRP, and
NFS/RDMA protocols using DAX/pmem or NVM[ef].

It is not going to be like the well-worn paradigm that
involves a page cache on the storage target backed by
slow I/O operations. The protocol layers on storage
targets need a way to discover memory addresses of
persistent memory that will be used as source/sink
buffers for RDMA operations.

And making data durable after a write is going to need
some thought. So I believe some new plumbing will be
necessary.

I know this is not everyone's cup of tea. A BoF would
be fine, if the PC believes that is a better venue (and
I'm kind of leaning that way myself).


--
Chuck Lever




