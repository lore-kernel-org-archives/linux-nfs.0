Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:39635 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518Ab1JQVho (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Oct 2011 17:37:44 -0400
Received: by gyb13 with SMTP id 13so3421082gyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 17 Oct 2011 14:37:44 -0700 (PDT)
Message-ID: <4E9CA019.1070009@tonian.com>
Date: Mon, 17 Oct 2011 14:37:29 -0700
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: [osd-dev] [PATCHSET 0/5] pnfsd-exofs: Adapt to Latest ore/exofs
 changes
References: <4E8D9D56.6020803@panasas.com> <4E9C78B0.7080909@tonian.com>
In-Reply-To: <4E9C78B0.7080909@tonian.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK, I pushed this to

git://git.linux-nfs.org/projects/bhalevy/linux-pnfs.git
at tag pnfs-all-3.1-rc9-2011-10-17

Benny

On 2011-10-17 11:49, Benny Halevy wrote:
> Hmm, I get the following compile error.
> 
> Is there a chance you have some local changes in your tree you haven't committed
> to 6127dbde SQUASHME pnfsd-exofs: Serve out a single group layout at a time
> 
> fs/exofs/export.c: In function ‘exofs_layout_get’:
> fs/exofs/export.c:143:2: warning: passing argument 3 of ‘ore_calc_stripe_info’ makes integer from pointer without a cast [enabled by default]
> include/scsi/osd_ore.h:174:6: note: expected ‘u64’ but argument is of type ‘struct ore_striping_info *’
> fs/exofs/export.c:143:2: error: too few arguments to function ‘ore_calc_stripe_info’
> include/scsi/osd_ore.h:174:6: note: declared here
> 
> Since si.length is not in use in exofs_layout_get
> This fix should work, right?
> 
> git diff --stat -p -M
>  fs/exofs/export.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/exofs/export.c b/fs/exofs/export.c
> index 815e807..8a0e510 100644
> --- a/fs/exofs/export.c
> +++ b/fs/exofs/export.c
> @@ -140,7 +140,7 @@ static enum nfsstat4 exofs_layout_get(
>  	/* Fill in a pnfs_osd_layout struct */
>  	ore_layout_2_pnfs_layout(&layout, &sbi->layout);
> 
> -	ore_calc_stripe_info(&sbi->layout, res->lg_seg.offset, &si);
> +	ore_calc_stripe_info(&sbi->layout, res->lg_seg.offset, 0, &si);
>  	layout.olo_comps_index = si.dev;
>  	layout.olo_num_comps = sbi->layout.group_width * sbi->layout.mirrors_p1;
> 
> 
> 
> 
> On 2011-10-06 05:21, Boaz Harrosh wrote:
>> Benny Hi
>>
>> I'm sending the changes needed to *pnfsd-exofs* branch which are needed
>> in order to work with latest, for v3.2, ore/exofs changes.
>>
>> Assuming you have set up:
>>    git remote add loo git://git.open-osd.org/linux-open-osd.git
>>
>> For your convenience the patches are also available at:
>>
>>    git cherry-rebase 5d2d53b7..loo/pnfsd-exofs
>>
>> You will also need to merge or put somewhere all these changes on the
>> linux-open-osd linux-next branch (Actually the ore-devel branch)
>>
>>    git cherry-rebase loo/linus..loo/ore-devel
>>
>> Here are the sets of patches in the two groups:
>>
>> [pnfsd-exofs 5d2d53b7..loo/pnfsd-exofs(6127dbd)]
>>
>>   This set is based on the base, none SQUASHME, pnfsd-exofs patches
>> 	[5d2d53b7] pnfsd-exofs: layoutreturn pnfs-obj information decoding
>>
>>   7638472 SQUASHME: pnfsd-exofs: convert to v3.1 ORE			  - Your original conversion
>>   51f3837 SQUASHME: pnfsd-exofs: Convert to ORE 3.1 PART2
>>   590139b SQUASHME: pnfsd-exofs: Fix export of only one group layout
>>   fba7909 SQUASHME: pnfsd-exofs: Type & Name of the devices array changed
>>   6127dbd SQUASHME pnfsd-exofs: Serve out a single group layout at a time 
>>
>>
>>
>> [ore/exofs/pnfs-obj changes for Linux v3.2 merge window]
>>
>>   My tree is based on v3.1-rc6 but you might want to base them on your pnfs/pnfs-block branch
>>   or have them all in a third branch and merge three branches on the top
>>
>>   []$ git log --oneline --reverse loo/linus..loo/ore-devel
>>
>>   a8f8c45 osd: Kconfig remove wrong FIXME
>>   1958c7c2 exofs/ore.c: local functions should be static
>>   de74b05 exofs/super.c: local functions should be static
>>   5bf696d exofs: Rename struct ore_components comps => oc
>>   8d2d83a exofs: Remove unused data_map member from exofs_sb_info
>>   eb507bc ore: Make ore_striping_info and ore_calc_stripe_info public
>>   d866d87 ore/exofs: Change the type of the devices array (API change)
>>   6d52274 ore: Only IO one group at a time (API change)
>>   a723afe ore: cleanup: Embed an ore_striping_info inside ore_io_state
>>   bcad9f7 ore: Remove check for ios->kern_buff in _prepare_for_striping to later
>>   c8dfed0 exofs: Support for short read/writes
>>   b2e3e8d ore: Support for short read/writes
>>   c0ba6d0 ore: Support for partial component table
>>   3c5aedd ore/exofs: Define new ore_verify_layout
>>   f6ee1e2 ore/exofs: Change ore_check_io API
>>   9bb8a8e pnfs-obj: Remove redundant EOF from objlayout_io_state
>>   e4ec2af pnfs-obj: Return PNFS_NOT_ATTEMPTED in case of read/write_pagelist
>>   8b40d31 pnfs-obj: Get rid of objlayout_{alloc,free}_io_state
>>   6b09277 pnfs-obj: Rename objlayout_io_state => objlayout_io_res
>>   739c109 pnfs-obj: move to ore 01: ore_layout & ore_components
>>   23a91ad pnfs-obj: move to ore 02: move to ORE
>>   b82cbb8 pnfs-obj: move to ore 03: Remove old raid engine
>> 	Up to here is the intended patches for Linux v3.2
>>   c0cf571 ore: Make ore_calc_stripe_info EXPORT_SYMBOL
>> 	This patch is intended for the pnfsd-exofs branch after it will be
>> 	rebased on ore/exofs for v3.2 above (As is it will not patch there)
>>
>> Cheers
>> Boaz
>> _______________________________________________
>> osd-dev mailing list
>> osd-dev@open-osd.org
>> http://mailman.open-osd.org/mailman/listinfo/osd-dev
