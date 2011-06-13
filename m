Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:22734 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895Ab1FMUxd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 16:53:33 -0400
Message-ID: <4DF678C5.1080001@panasas.com>
Date: Mon, 13 Jun 2011 16:53:25 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCHSET 0/2] Small change needed in nfs_xdr.h
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi trond

I need this simple patch:

    [PATCH 1/2] nfs_xdr: Move nfs4_string definition out of #ifdef CONFIG_NFS_V4
    
    exofs file system wants to use pnfs_osd_xdr.h file instead of
    redefining pnfs-objects types in it's private "pnfs.h" header.
    
    Before we do the switch we must make sure pnfs_osd_xdr.h is
    compilable also under NFS versions smaller than 4.1. Since now
    it is needed regardless of version, by the exofs code.
    
    Only miss-out is nfs4_string move it to global scope.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

So I can submit this patch to the exofs tree:
    [PATCH 1/2] exofs: pnfs-tree: Remove pnfs-osd private definitions
    
    Now that pnfs-osd has hit mainline we can remove exofs's
    private header. (And the FIXME comment)
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

The small problem is that if we both keep a copy of the patch in linux-next,
it will be fine until there are possibly more changes to nfs_xdr.h. git
merge will not like that.

If you have another batch for this -rc you could include the patch
and I'll rebase my linux-next on that -rc. Or we can risk having the same patch
and if there are any more changes just ping me and I'll see what I do with
linux-next. Or you can send me your ack-by: and I can submit it through
exofs tree.

Thanks
Boaz
