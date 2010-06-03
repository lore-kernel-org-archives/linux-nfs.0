From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 0/6] pnfs-submit cleanup layoutcommit for file layout
Date: Thu, 03 Jun 2010 11:10:25 +0300
Message-ID: <4C076371.4060304@panasas.com>
References: <1275494067-4058-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:51201 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752988Ab0FCIK3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jun 2010 04:10:29 -0400
In-Reply-To: <1275494067-4058-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/02/2010 06:54 PM, andros@netapp.com wrote:
> This is against the pnfs-submit branch of the 2.6.34 tree. They will need to be
> applied against the 2.6.35-rc1 tree which I can do after comments.
> 
> RFC: I would like comments, especially on
> 0006-SQUASHME-pnfs-submit-move-layoutcommit-to-nfs_write_.patch.
> 
> Remove unused layoutcommit layoutdriver_io_operations. Will be restored
> in post-submit patches
> 0001-SQUASHME-pnfs-submit-remove-setup_layoutcommit.patch
> 0002-SQUASHNE-pnfs-submit-remove-cleanup_layoutcommit.patch

These two should be combined. The cleanup_ is to clean after
what's done in setup_.

> 0003-SQUASHME-pnfs-submit-remove-encode_layoutcommit.patch
> 

For example objects can do with this one only

> A cleanup, and call the async error handler.
> 0004-SQUASHME-pnfs-submit-cleanup-layoutcommit-call.patch
> 0005-SQUASHME-pnfs-submit-handle-async-layoutcommit-error.patch
> 
> This next  patch moves the pnfs_layoutcommit_inode call to nfs_write_inode,
> and it is the only call other than in layoutreturn. (removed calls in
> __nfs4_close, nfs_commit_inode, nfs_wb_sync).
> 
> This is fine for the file layout, and I think it's OK for the object and
> block layouts as well.
> 

It sounds very nice. It might have problems though. On the NFS_STABLE path
again. Because of this stupid thing I found that when returning NFS_STABLE
from writes, and no commits are called, then the internal i_size does not
get updated until after the layout commit has returned and the client detects
a change_attr on server. (Even if it was this client that caused the update)

But this should be fixed regardless. And currently I'm running with
commits on in objlayout. (Which reminds me to send the patch to Benny)

So yes I like this change a lot. It makes tons of sense to me as well.

> I left the LAYOUTCOMMIT call in nfs_write_inode a synchronous call, because
> nfs_commit_unstable_pages sets the FLUSH_SYNC flag. Should this
> be an asyc LAYOUTCOMMIT call?
> 

look at the struct writeback_control *wbc received, it has a flag which states
if this is sync or async do according to that flag. (Tell me if you don't find it)

> pnfs_layoutcommit_inode is called after nfs_commit_unstable_pages() so that
> if LAYOUTCOMMIT fails, the unstable pages have been processed..
> 
> The error handlers (sync and async) call nfs4_map_errors, so unhandled
> errors (such as NFS4ERR_BADLAYOUT) get returned to nfs_write_ioode as -EIO.
> 
> Examining the write_inode call paths, I could not see where the -EIO would
> be passed back to the application.  Testing with pynfs which I
> had return NFS4ERR_BADLAYOUT to the layout commit call, shows the -EIO return
> not stopping the client nor is the error reported back to the application.
> 
> We will add code to the error handlers for errors such as NFS4ERR_BADLAYOUT 
> that require us to stop using and free the layout, and redo the I/O through
> the MDS.
> 
> Anyway, review is much appreciated.
> 
> 0006-SQUASHME-pnfs-submit-move-layoutcommit-to-nfs_write_.patch
> 
> Testing:
> With CONFIG_NFS_V4_1 set
> NFSv4.1/pnfs passed Connectathon against write enabled GFS2/pNFS. Note: there
> were exactly the same number of LAYOUTCOMMITS sent as were sent with
> pnfs_layoutcommit_inode being called from __nfs4_close (never happened),
> nfs_commit_inode and nfs_wb_sync.
> 
> Passed Connectathon general test against pynfs file layout server with
> the NFS4ERR_BADLAYOUT being returned on every third LAYOUTCOMMIT.
> 

Andy you got this patchset all backwards. And they are not a set.

4,5,6 are to go in first and are intended for the full tree
and the .34 and .33 backport tree's as well. If I want to test
with them I'll need them stand alone un-conflicting.

Then 1+2,3 are something else and should be done on top of these above.
If they are self sustained and could be re applied on the to of the tree
as patch -R, then grate. If not then a "bring them back patch" could be
nice. without them we can't test any of this.

> 
> -->Andy
> 

Boaz
