Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:5010 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760376Ab0HEQkm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Aug 2010 12:40:42 -0400
Message-ID: <4C5AE988.4050605@panasas.com>
Date: Thu, 05 Aug 2010 19:40:40 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: pnfs git tree status pnfs-all-2.6.35-2010-08-05
References: <4C111B9C.3080603@panasas.com> <4C1A4F0E.5070406@panasas.com> <4C455C58.8040300@panasas.com> <4C5ADF14.6090901@panasas.com>
In-Reply-To: <4C5ADF14.6090901@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hit Send too soon.
Subject is correct now.

On Aug. 05, 2010, 18:56 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> pnfs-all-2.6.35-2010-08-05 is based over v2.6.35
> I started with the pnfs-submit branch squashing but there's
> a lot of work to be done there to tidy it up and prepare
> a series for review.
> Andy has graciously offered his help with this task. Thanks!
> 
> At this point we'll hold off with new patches for submission
> until we're done with squashing the series and then every
> new SQUASHME patch sent must indicate which patch(es) it needs
> to be squashed into so not to create a huge back log like we have today.
> 
> Here's the list of patches that went into the latest linux-pnfs tree as of 2010-08-05
> since last update pnfs-all-2.6.35-rc5-2010-07-20:
> 
> pnfs-submit:
>   Andy Adamson     83c4c44 SQUASHME pnfs-submit remove pnfs4_layout_reclaim
>   Andy Adamson     67282c6 SQUASHME pnfs-submit destroy all layouts upon lease expiration
>   Ricardo Labiaga  f20c76e SQUASHME: pnfs-submit: Use generic layout name to load layout modules
>   Benny Halevy     fa73e39 SQUASHME: pnfs-submit: reduce nesting level in set_pnfs_layoutdriver
> 
> pnfs-block:
>   Jim Rees         b51aad4 pnfs-block: Add support for simple rpc pipefs
>   Jim Rees         123741a pnfs-block: Remove device creation from kernel
> 
> 
> http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree is updated
> with the latest information.
> 
> Note that Ricardo's "Use generic layout name to load layout modules"
> patch renamed the nfslayoutdriver module to "nfs_layout_nfsv41_files"
> so it can be loaded automagically by the kernel. The blocks and objects
> modules should be renamed along the same lines (TODO).
> 
> Benny
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
