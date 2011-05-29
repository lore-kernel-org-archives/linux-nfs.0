Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:45886 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832Ab1E2KP4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 06:15:56 -0400
Message-ID: <4DE21CD5.8070907@panasas.com>
Date: Sun, 29 May 2011 13:15:49 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PACHSET 0/8] FIXES for pnfs for 2.6.40 - version 9
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi

I've re-rebased all the fixes in their intended place and cut a
tree on the git.open-osd.org git tree. (some base patches changed do to
conflicts with previous squashmes)

I have structured the above git tree as follows:
v2.6.39
	pnfs-submit----|
                       +---merge_and_compile
	pnfsd-exofs----|

So both client and server branches are based on Linus tree and are
conveniently merged in *merge_and_compile* for actual testing of the
code.

Benny please compare your final branch with the *pnfs-submit* branch
to make sure nothing is missing.

tree is at: git://git.open-osd.org/linux-open-osd.git 
	pnfs-submit pnfsd-exofs & merge_and_compile branches

[On the web:
 http://git.open-osd.org/gitweb.cgi?p=linux-open-osd.git;a=shortlog;h=refs/heads/merge_and_compile
]

I have left in the SQUASHME patches (And resending them in their mergeable
form, as reply to this set)

Here are the patches in pnfs-submit (rebase order)
(I have removed the two server patches from the pnfs-submit branch)

git log --oneline --reverse v.2.6.39..pnfs-submit:

	3b6445a NFSv4.1: fix typo in filelayout_check_layout
	67d51f6 NFSv4.1: use struct nfs_client to qualify deviceid
	45df3c8 pnfs: resolve header dependency in pnfs.h
	a1eaecb NFSv4.1: make deviceid cache global
	47a0c5c NFSv4.1: purge deviceid cache on nfs_free_client
[1/8]	bee4df2 SQUASHME: into NFSv4.1: purge deviceid cache - let ver < 4.1 compile
	43d3f13 pnfs: CB_NOTIFY_DEVICEID
	7073887 NFSv4.1: use layout driver in global device cache
	aca9487 SUNRPC: introduce xdr_init_decode_pages
	9734962 pnfs: Use byte-range for layoutget
	adda93b pnfs: align layoutget requests on page boundaries
	d3fa95a pnfs: Use byte-range for cb_layoutrecall
	fbc41a4 pnfs: client stats
	cb4a216 pnfs-obj: objlayoutdriver module skeleton
	0d81921 pnfs-obj: pnfs_osd XDR definitions
	08758d6 pnfs-obj: pnfs_osd XDR client implementation
	4e2d111 pnfs-obj: decode layout, alloc/free lseg
[2/8]	63ab8d8 SQUASHME V2: objio alloc/free lseg Bugs fixes
	33e6214 NEWVERSION: pnfs-obj: objio_osd device information retrieval and caching
	40981be pnfs: alloc and free layout_hdr layoutdriver methods
	d868d03 pnfs-obj: define per-inode private structure
	03287b4 pnfs: support for non-rpc layout drivers
	459cdad pnfs-obj: osd raid engine read/write implementation
[3/8]	5f4a353 SQUASHME: objio read/write patch: Bugs fixes
	a56f840 pnfs: layoutreturn
	79d5152 pnfs: layoutret_on_setattr
	b8b72b3 pnfs: encode_layoutreturn
[4/8]	3195a51 NEWVERSION: pnfs-obj: report errors and .encode_layoutreturn Implementation.
	2ae4424 pnfs: encode_layoutcommit
	9b0b09b pnfs-obj: objlayout_encode_layoutcommit implementation
	aa838bf NFSv4.1: unify pnfs_pageio_init functions
[5/8]	e7f243f SQUASHME: Fix BUG in: NFSv4.1: unify pnfs_pageio_init functions
	d93594a NFSv4.1: change pg_test return type to bool
	8630b61 NFSv4.1: use pnfs_generic_pg_test directly by layout driver
[6/8]	a1f29c7 NFSv4.1: define nfs_generic_pg_test
	
	(This one had merge conflict with e7f243f SQUASHME, so it is different)

[7/8]	413647e SQUASHME: Move a check from nfs_pageio_do_add_request to nfs_generic_pg_test
	(I've sent two changes to this. This is the unified fix)

	8e88dcd pnfs-obj: pg_test check for max_io_size
[8/8]	4e3c595 SQUASHME: pnfs-obj: objio_pg_test some checkpatch love

One might also be interested in the *pnfsd-exofs* branch. It includes all the server
patches, and exofs changes. And was changed to be made cleanly mergable with pnfs-submit.
(Please not that in it's current form it is not compilable before the merge do to headers
 changes that are in pnfs-submit.)

With the above unified tree I'm able to not crash and do pnfs-IO. I will continue the
testing all day, to make sure.

Thanks
Boaz

