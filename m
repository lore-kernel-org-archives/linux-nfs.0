Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:47673 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754126Ab0GHQOI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jul 2010 12:14:08 -0400
Received: by gye5 with SMTP id 5so488550gye.19
        for <linux-nfs@vger.kernel.org>; Thu, 08 Jul 2010 09:14:05 -0700 (PDT)
In-Reply-To: <4C35A588.7040103@panasas.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
	<4C35A588.7040103@panasas.com>
Date: Thu, 8 Jul 2010 12:14:05 -0400
Message-ID: <AANLkTim1mQiVIum5X4YPUYx3KYaN6WMiXhTL9Oyb-WDE@mail.gmail.com>
Subject: Re: [PATCH 0/16] pnfs-submit fix layout allocation and reference
	counting
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 8, 2010 at 6:16 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 07/08/2010 01:34 AM, andros@netapp.com wrote:
>
> Hi Andy,
>
>> The current nfs_inode has an embedded pnfs_layout_type structure, with per
>> layout type private data allocated. Change nfs_inode->layout to be a pointer
>> to a pnfs_layout_type structure, embed the pnfs_layout_type in the per
>> layout type structure, and allocate both.
>>
>
> Amen
>
>> The current pnfs_layout_type allocation waits on a bit lock to handle
>> concurrent allocation attempts. Replace this with the normal form.
>>
>
> Why don't we allocate this at inode allocation.

We don't know if we need it at inode allocation. Remember, GFS2 only
uses RO layouts. Plus, the protocol allows a file system to use more
than one layout type and each layout type has a different private
portion of the layout structure.


> Or inode iget() once
> and be done with it.
> Why the fights, races, and error handling?
> In a normal pnfs-able mount five-9(s) percent of IO operations need
> a layout_type structure. Let's optimize the fast path. On these
> rare "error" cases when we could not get any lsegs and eventually
> did not use the nfsi->layout, who cares that we allocated extra
> 20 bytes.
>
>> The current pnfs_layout_type reference counting is very un-clear, and one
>> instance of put_layout was called outside the i_lock which probably was
>> causing the intermittant pnfs_layout_type refcount bug we've been seeing.
>>
>> Replace the nfs_inode->layout reference counting with the following scheme:
>>
>> As in the current code, the pnfs_layout_type reference counting is always done
>> with the inode->i_lock held.
>>
>> The nfs_inode->layout comes into existence when the first layout_segment is
>> cached and stays until inode is destroyed.

Actually this is not true. pnfs_destroy_layout is not only called a
inode destruction - it is also called in pnfs_reclaim_layout (state
reclaim after reboot)

In this case, the layout will be destroyed while the inode continues on.

The use and implementation of pnfs_reclaim_layout needs a review.

The question is, when should the nfs_inode->layout be freed when the
inode is not? These are candidates.
 - reclaim state after server reboot (current code does this)
 - reclaim state after a network partition (current code does this)
 - file system migration
 - switching to a different file system replica
 - CB_LAYOUTRECALL FSID
 - CB_LAYOUTRECALL ALL

>>
>
> I see that you have thought about my proposal. I have not looked at the
> patches yet, will do soon.
>
> So I have a brave question. If nfs_inode->layout is only freed at
> inode-destroy, why do we need to ref-count it. Refcounting is for
> holding things so they don't go away. But since now the nfsi->layout
> stays until the very end then what's the point?
>
> If you really think it is possible that the layout is held longer then
> the inode itself then, 1- this is surly a bug, I'm not sure you can do
> much with a layout with a dangling inode pointer. 2- Fine then just
> take the inode reference. If you equate the life time of these two
> objects why not use the ref that is already there?
>
>> 1) alloc nfs_inode->layout:
>>         - Initialized to 1. This holds it around for the clp->cl_layouts
>>         (layout->lo_layouts) list.
>>
>> 2) Each layoutget
>>    layoutget    GET
>>    layoutget release PUT
>>
>> 3) insert lseg into nfs_inode->layout->segs GET
>>    remove lseg from nfs_inode->layout->segs  PUT
>>
>> I/O - no reference (except the lseg is used and referenced in 3)
>>
>> 4) Each layoutcommit references the layout which keeps it around while in use
>>    by the call which could race with layoutreturn
>>
>>    layoutcommit GET
>>    layoutcommit release PUT
>>
>> 5) Each layoutreturn references the layout which keeps it around while in use
>>    by the call.
>>
>>    layoutreturn  GET
>>    layoutreturn release  PUT
>>
>
> 2, 4, 5 - surly the inode ref-count is taken during RPC?
> 3 - inode gone while IO? I don't think so.
>
>> 6) inode destruction (usually umount)
>>
>>    Destroy_layout PUT to balance initial allocation where it is set to 1.
>>
>
> inode are destructed when evicted from cache and/or at last reference
> drop. Also at umount, but you should start testing like I do, "git clone"
> you'll see inodes start to be destroyed 27 seconds into the operation.
>
>> When the reference moves from 1->0 the layout is removed from the nfs_client
>> cl_layouts list and freed.
>>
>
> The nfs_client->cl_layouts operations can be moved to the first/last lseg
> insertion/removal, as an optimization step.
>
>>
>> Change nfs_inode->layout to be a pointer to a pnfs_layout_type strucure.
>>
>> 0001-SQUASHME-pnfs-submit-add-state-flag-for-layoutcommit.patch
>> 0002-SQUASHME-pnfs-submit-move-pnfs_layout_suspend-back-t.patch
>> 0003-SQUASHME-pnfs-submit-embed-pnfs_layout_type.patch
>> 0004-SQUASHME-pnfs-submit-filelayout-use-new-alloc-free_l.patch
>>
>> Rewrite the pnfs_layout_type allocation and reference counting
>>
>> 0005-SQUASHME-pnfs-submit-rewrite-layout-allocation.patch
>> 0006-SQUASHME-pnfs-submit-fix-pnfs_update_layout-referenc.patch
>> 0007-SQUASHME-pnfs_submit-don-t-get-a-reference-on-bounda.patch
>> 0008-SQUASHME-pnfs-submit-don-t-reference-the-layout-in-i.patch
>> 0009-SQUASHME-pnfs-submit-pnfs_update_layout-always-refer.patch
>> 0010-SQUASHME-pnfs-submit-reference-the-layout-when-inser.patch
>> 0011-SQUASHME-pnfs-submit-rename-put_layout-to-put_layout.patch
>> 0012-SQUASHME-pnfs-submit-reference-layout-across-layoutc.patch
>> 0013-SQUASHME-pnfs-submit-reference-layout-for-layoutretu.patch
>> 0014-SQUASHME-pnfs-submit-remove-put_layout-from-pnfs_fre.patch
>> 0015-SQUASHME-pnfs-submit-do-not-reference-a-layout-in-de.patch
>> 0016-SQUASHME-pnfs-submit-remove-grab_current_layout.patch
>>
>> Testing;
>>
>> CONFIG_NFS_V4_1 set:
>> Connectathon tests pass against GFS2/pNFS and pyNFS file layout server. Tested
>> with layout return-on-close off and on.
>>
>> CONFIG_NFS_V4_1 not set;
>> NFSv4.0 mount passes Connectation tests.
>>
>> -->Andy
>
> Thanks Andy for this work. The code is really getting clearer finally.
>
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
