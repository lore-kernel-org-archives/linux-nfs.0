Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:50852 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755332Ab1FTS45 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2011 14:56:57 -0400
Message-ID: <4DFF97C4.1050106@panasas.com>
Date: Mon, 20 Jun 2011 11:56:04 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "Halevy, Benny" <bhalevy@panasas.com>, Fred Isaman <iisaman@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH] FIXME: pnfs: BUG in layout_commit logic
References: <4DFBB71F.3050703@panasas.com>
In-Reply-To: <4DFBB71F.3050703@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/17/2011 01:20 PM, Boaz Harrosh wrote:
> 
> When segments are used with the pnfs-objects driver (which supports them)
> I get a crash in layout commit do to unbalanced lseg reference counting.
> (under reference)
> 
> With this patch taken from the blocks layout part of the patchset this
> problem goes away. But looking at the code it looks scary to me
> (I just don't understand it fully).
> 
> Fred please review this code, to see if you like what it does.
> 
> I will need a fix for the v3.0 Kernel
> 
> SOB: Boaz
<snip>

Benny, Fred, Hi.

This patch is from the pnfsblock branch:
	[0e5ef56b] pnfs: let layoutcommit code handle multiple segments
		   by: Peng Tao<bergwolf@gmail.com>

Except the above patch has one obvious bug where segments are not found
(See below)

Fred I'm not sure I like this patch it looks wrong to me. But it does
solve my immediate problem (Needed for this Kernel). Have you had a
chance to look at this code and think about what we should do?

Thanks
Boaz
---
SQUASHME: Fix BUG in: [0e5ef56b] pnfs: let layoutcommit code handle multiple segments

The patch: [0e5ef56b] pnfs: let layoutcommit code handle multiple segments
Broke pnfs_find_lseg because now with the new break, the smaller then last layouts
are never found.
(Though I agree that searching in reverse might be an optimization since the
 last one is usually what we need. (Perhaps reverse the offset test))

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d9ffaab..169fe92 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -905,7 +905,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 	dprintk("%s:Begin\n", __func__);
 
 	assert_spin_locked(&lo->plh_inode->i_lock);
-	list_for_each_entry_reverse(lseg, &lo->plh_segs, pls_list) {
+	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
 		    is_matching_lseg(&lseg->pls_range, range)) {
 			ret = get_lseg(lseg);
