Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34729 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806AbcA0Kw4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jan 2016 05:52:56 -0500
Received: by mail-wm0-f46.google.com with SMTP id n5so21880236wmn.1
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jan 2016 02:52:55 -0800 (PST)
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Remote access to pmem on storage targets
To: Chuck Lever <chuck.lever@oracle.com>, Jan Kara <jack@suse.cz>
References: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com>
 <20160126082533.GR24938@quack.suse.cz>
 <F0E2108B-891C-4570-B486-7DC7C4FB59C4@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <56A8A183.30805@dev.mellanox.co.il>
Date: Wed, 27 Jan 2016 12:52:51 +0200
MIME-Version: 1.0
In-Reply-To: <F0E2108B-891C-4570-B486-7DC7C4FB59C4@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> So hashing out details of pNFS layout isn't interesting to many people.
>> But if you want a broader architectural discussion about how to overcome
>> issues (and what those issues actually are) with the use of persistent
>> memory for NAS, then that may be interesting. So what do you actually want?
>
> I mentioned pNFS briefly only as an example. There have
> been a variety of proposals and approaches so far, and
> it's time, I believe, to start focusing our efforts.
>
> Thus I'm requesting a "broader architectural discussion
> about how to overcome issues with the use of persistent
> memory for NAS," in particular how we'd like to do this
> with the Linux implementations of the iSER, SRP, and
> NFS/RDMA protocols using DAX/pmem or NVM[ef].

I agree,

I anticipate that we'll gradually see more and more implementations
optimizing remote storage access in the presence of pmem devices (maybe
even not only RDMA?). The straight forward approach would be for each
implementation to have it's own logic for accessing remote pmem
devices but I think we have a chance to consolidate that in a single
API for everyone.

I think the most natural way to start is NFS/RDMA (SCSI would be a bit
more challenging...)

> It is not going to be like the well-worn paradigm that
> involves a page cache on the storage target backed by
> slow I/O operations. The protocol layers on storage
> targets need a way to discover memory addresses of
> persistent memory that will be used as source/sink
> buffers for RDMA operations.
> And making data durable after a write is going to need
> some thought. So I believe some new plumbing will be
> necessary.

The challenge here is persistence semantics that are missing in
today's HCAs, so I think we should aim to have a SW solution for
remote persistence semantics with sufficient hooks for possible
HW that might be able to have it in the future...

> I know this is not everyone's cup of tea. A BoF would
> be fine, if the PC believes that is a better venue (and
> I'm kind of leaning that way myself).

I'd be happy to join such a discussion.
