Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:31484 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752304Ab0HSUuO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Aug 2010 16:50:14 -0400
Message-ID: <4C6D9903.1060206@panasas.com>
Date: Thu, 19 Aug 2010 23:50:11 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: andros@netapp.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/50] Squashed and re-organized pnfs-submit tree
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Andy,  I merged these patches with restored sign-offs and a couple minor touch-ups
to make sure all compile.  There's still zero diff from the original pnfs-submit
branch.  The pnfs-all-latest tip is at pnfs-all-2.6.35-2010-08-19.
With regards to the patch descriptions, we've changed the patcheset so much
it just makes more sense to re-write the commentary when we're close to have the
final version.

Let's get on with the renaming now and then we'll continue to rearrange the set
for review and clean it up further.

Benny

On Aug. 14, 2010, 0:31 +0300, andros@netapp.com wrote:
> Here is the pnfs-submit tree all squashed and reorganized. The resultant tree
> is unchanged. The patch comments and Signed-off-by's need to be added.
> 
> We may want to split or re-order some of the patches. I left the "introduce
> new file" patches #6-9 unsquashed, but we probably want to squash them into
> the patch that uses them first.
> 
> Patches 1-4 are not pnfs patches, and should be submitted to Trond/Bruce.
> 
> Patch #50 "SQUASHME pnfs_submit: remove this unused code"
> should not be squashed, but removed.
> 
> Patches 47,-49 are for the post-submit trees.
> 
> -->Andy
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
