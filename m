Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2286 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755876Ab3J2NV2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 09:21:28 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Hellwig Christoph <hch@infradead.org>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFS: Allow for asynchronous WRITE_PLUS calls
Date: Tue, 29 Oct 2013 13:21:26 +0000
Message-ID: <78317EB5-0325-429B-89C8-F4092B677EC4@netapp.com>
References: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
 <1382972418-2249-3-git-send-email-bjschuma@netapp.com>
 <20131029073943.GD10889@infradead.org>
 <BF996CAD-1032-4434-A538-B678D047884B@netapp.com>
 <20131029124836.GA13482@infradead.org>
 <58212CB2-A01A-43F1-8760-5ED8ED75E081@netapp.com>
 <20131029130857.GB32094@infradead.org>
In-Reply-To: <20131029130857.GB32094@infradead.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2013, at 9:08 AM, Hellwig Christoph <hch@infradead.org> wrote:

> On Tue, Oct 29, 2013 at 01:05:44PM +0000, Myklebust, Trond wrote:
>> Imagine someone wanting to punch a 50TB hole in NTFS, for instance. It doesn't have real holes, so you'd end up needing to zero out the existing extents in that region of the file. That will take time, even with an O(nr_extents) algorithm.
> 
> That behaviour is not a hole punch, and should not be multiplexed onto
> a whole punch on the wire command!  If such a use case is important
> enough there should be an equivanet of the SCSI WRITE SAME command which
> might make some sense to be implemented async.
> 
> We'd surely not support it in the Linux nfsd, though.

The current draft spec even allows the client to specify a "pattern" to be written to the "hole". It is mainly there for applications like Oracle, that initialise empty blocks with a non-trivial pattern so that they can do the on-disk equivalent of memory poisoning. By doing it in this way, it allows the more powerful storage arrays to just implement that patterned region as a set of deduplicated blocks instead of actually allocating all the blocks.

You can indeed argue that filesystems that don't have holes and/or deduplication should not implement this operation at all, however the functionality is there in case they do...

