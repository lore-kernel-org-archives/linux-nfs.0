Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:40045 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965642Ab2EOQXh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 12:23:37 -0400
Message-ID: <4FB282F7.5090408@panasas.com>
Date: Tue, 15 May 2012 19:23:19 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: Peng Tao <bergwolf@gmail.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>, Peng Tao <tao.peng@emc.com>
Subject: Re: [PATCH 1/2] NFS: call block plug around direct write
References: <1337096303-2516-1-git-send-email-bergwolf@gmail.com> <20120515160855.GA5911@infradead.org>
In-Reply-To: <20120515160855.GA5911@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/15/2012 07:08 PM, Christoph Hellwig wrote:

> On Tue, May 15, 2012 at 11:38:22PM +0800, Peng Tao wrote:
>> We bypass generic_file_aio_write() but would want to call block plug.
> 
> We in this case is the pnfs block driver at most.  Thus these should
> be pnfs block code.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


I thought so too.

But reading the code more closely it might be hard for the blocklayout
to figure out the right state to call these two. Specially the call to
blk_finish_plug(). So you might need to add a new LD API such as
LD()->finish_plug() which is empty for others.

But again inspecting the code it looks like blk_start_plug() is a no-op
and blk_finish_plug() is specially optimized for the empty case.

So is it worth it, the extra effort? I do understand the temptation
to get lazy here.

Just my $0.017
Boaz
