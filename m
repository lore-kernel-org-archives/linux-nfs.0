Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:22941 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955Ab2B0XSE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Feb 2012 18:18:04 -0500
Message-ID: <4F4C0F25.8000601@oracle.com>
Date: Mon, 27 Feb 2012 17:17:57 -0600
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Zach Brown <zab@zabbo.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH 22/22] nfs: add support for read_iter, write_iter
References: <1330377576-3659-1-git-send-email-dave.kleikamp@oracle.com>  <1330377576-3659-23-git-send-email-dave.kleikamp@oracle.com> <1330380530.5541.87.camel@lade.trondhjem.org>
In-Reply-To: <1330380530.5541.87.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/27/2012 04:08 PM, Myklebust, Trond wrote:
> On Mon, 2012-02-27 at 15:19 -0600, Dave Kleikamp wrote:
>> This patch implements the read_iter and write_iter file operations which
>> allow kernel code to initiate directIO. This allows the loop device to
>> read and write directly to the server, bypassing the page cache.
>>
>> Signed-off-by: Dave Kleikamp <dave.kleikamp@oracle.com>
>> Cc: Zach Brown <zab@zabbo.net>
>> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Cc: linux-nfs@vger.kernel.org
> 
> Performance is going to be absolutely terrible for O_DIRECT bvecs if you
> send just one page per RPC call. We are working on merging the O_DIRECT
> and page cache code in order to give O_DIRECT the ability to coalesce
> requests and do pNFS, and I'm hoping that code will be available soon.
> 
> In the meantime, wouldn't it be possible to add basic coalescing to
> nfs_direct_read_schedule_bvec/nfs_direct_write_schedule_bvec more or
> less in the same way that we do for multi-page iovec segments?
> i.e. if the next bvec is contiguous with the previous, and the resulting
> RPC read length < rsize / write length < wsize, then add it to the same
> RPC call.

I basically followed the example of what the block layer was doing, but
coalescing makes more sense for nfs. I'll rework it to do that.

Thanks,
Shaggy
