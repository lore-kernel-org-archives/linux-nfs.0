Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:59127 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751613Ab0GLPdo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 11:33:44 -0400
Message-ID: <4C3B35D5.7050003@panasas.com>
Date: Mon, 12 Jul 2010 18:33:41 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
CC: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/16] pnfs-submit fix layout allocation and reference
 	counting
References: <1278542063-4009-1-git-send-email-andros@netapp.com>	<4C35A588.7040103@panasas.com> <AANLkTim1mQiVIum5X4YPUYx3KYaN6WMiXhTL9Oyb-WDE@mail.gmail.com>
In-Reply-To: <AANLkTim1mQiVIum5X4YPUYx3KYaN6WMiXhTL9Oyb-WDE@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/08/2010 07:14 PM, William A. (Andy) Adamson wrote:
> On Thu, Jul 8, 2010 at 6:16 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> On 07/08/2010 01:34 AM, andros@netapp.com wrote:
>>
>> Why don't we allocate this at inode allocation.
> 
> We don't know if we need it at inode allocation. Remember, GFS2 only
> uses RO layouts. 

right! optimize for a specific File System (broken at that).

I don't mind if you leave the current code placement and allocate
layout_type on first layout-request (first call to _pnfs_update_layout)
Then deallocate at inode destruction.

The few places that couple the destruction of all layout segments
and return them, with the layout_type structure deallocation should just
be de-coupled. Don't mix up between the allocation/deallocation of
layout_type and destruction of layout-segments.

> Plus, the protocol allows a file system to use more
> than one layout type and each layout type has a different private
> portion of the layout structure.

We don't support that, now, for other reasons. Lets not go there.

> 
> 
> Actually this is not true. pnfs_destroy_layout is not only called a
> inode destruction - it is also called in pnfs_reclaim_layout (state
> reclaim after reboot)
> 
> In this case, the layout will be destroyed while the inode continues on.
> 

You mean the layout-segments. But the layout_type can stay, why deallocate
it? it will be needed again.

> The use and implementation of pnfs_reclaim_layout needs a review.
> 
> The question is, when should the nfs_inode->layout be freed when the
> inode is not? These are candidates.
>  - reclaim state after server reboot (current code does this)
>  - reclaim state after a network partition (current code does this)
>  - file system migration
>  - switching to a different file system replica
>  - CB_LAYOUTRECALL FSID
>  - CB_LAYOUTRECALL ALL
> 

None of the above. These are all related to on-the-line layouts which
are layout-segments in our code. The governing structure is just an
inode-thing/per-layout-type.

If we follow my simple rules then you see that all these run-away pnfs
flags and states that where put back into nfsi can return to ->layout.

Boaz
