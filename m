Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57609 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753517Ab1FNVAZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:00:25 -0400
Received: by iwn34 with SMTP id 34so4992399iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2011 14:00:24 -0700 (PDT)
Message-ID: <4DF7CBE6.1050406@tonian.com>
Date: Tue, 14 Jun 2011 17:00:22 -0400
From: Benny Halevy <benny@tonian.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCHSET 0/8] pnfsd-exofs: New set of exofs pnfs export patches
References: <4DF7CA2F.7030407@panasas.com>
In-Reply-To: <4DF7CA2F.7030407@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-14 16:53, Boaz Harrosh wrote:
> 
> Benny hi
> 
> I'm submitting a new SQUASHED set of exofs patches. These should completely
> replace the patches you have now in the pnfsd-exofs{-all} branch
> 

Great, thanks!

> If anyone is curios I'll send a SQUASHME patchset as reply to this mail.
> 
> I Think the pnfsd-exofs branch should advance down to before the pnfsd-exp-all.
> It should be the first or second candidate for inclusion.

makes sense

> 
> BTW: You forgot to branch the pnfs-blocks branch last time.

Already fixed... (pnfs-block is there)

> 
> I think that now, since most of the client code is in-tree and all the common code
> is in. It would be easier to work with a tree that has two separate branches for the
> 1.block-layout and 2.server branches. And the pnfs-all-latest which merges the two.
> 
> something like:
> 
> 
>                 |----pnfsd(including gfs2_---pnfsd-exofs---pnfsd-exp----pnfsd-spnfs----pnfsd-spnfs-blocks ---|
> nfs-linux-next--|                                                                                            + --- pnfs-all-latest
>                 | --------pnfs-blocks------------------------------------------------------------------------|

Good point, I'll try it out.

> 
> * "+" means a merge
> 
> It will be much easier to develop this way
> 
> usual list of patches:
> 
> [PATCH 1/8] nfs_xdr: Move nfs4_string definition out of #ifdef CONFIG_NFS_V4
> [PATCH 2/8] exofs: pnfs-tree: Remove pnfs-osd private definitions
> [PATCH 3/8] pnfs-obj: pnfs_osd_xdr: Remove dead code and cleanup
>  
>     Intended for upstream
> 
> [PATCH 4/8] pnfsd-exofs: pnfs objects server XDR functions
> [PATCH 5/8] pnfsd-exofs: Add pNFS export support
> [PATCH 6/8] pnfsd-exofs: get_device_info implementation.
> [PATCH 7/8] pnfsd-exofs: Recall layouts on truncate
> [PATCH 8/8] pnfsd-exofs: layoutreturn pnfs-obj information decoding
> 
>    New exofs pnfs export patches

Where are the patches? :)

Benny

> 
> Thanks
> Boaz
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
