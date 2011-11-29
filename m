Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:48416 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab1K2Vum (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 16:50:42 -0500
Message-ID: <4ED55399.4060707@panasas.com>
Date: Tue, 29 Nov 2011 13:50:17 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>,
        <bhalevy@tonian.com>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com> <4ED54FE4.9050008@panasas.com>
In-Reply-To: <4ED54FE4.9050008@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2011 01:34 PM, Boaz Harrosh wrote:
> But just do the above and you'll see that it is perfect.
> 
> BTW don't limit the lo_segment size by the max_io_size. This is why you
> have .bg_test to signal when IO is maxed out.
> 
> - The read segments should be as big as possible (i_size long)
> - The Write segments should ideally be as big as the Application
>   wants to write to. (Amount of dirty pages at time of nfs-write-out
>   is a very good first approximation).
> 
> So I guess it is: I hate these patches, to much mess, too little goodness.
> 
> Thank
> Boaz
> 

Ho and one more thing.

Also Files when they will support segments and servers that request segments,
like the CEPH server, will very much enjoy the above, .i.e: Tell me the amount
you know you want to write.

And surly Objects will enjoy that tremendously. Is it a 17 bytes text file, or
the beginning of a big video file.

But the problem with Files and Objects is that they need a layout first before
they can do the right thing in .pg_test and say if this belongs to this IO or
to the next. (Files is stipe_unit maxed+aliened, Objects raid-group boundary)

So your solution is not good for files and Objects, my way solves them two.

Thanks
Boaz
