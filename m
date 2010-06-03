From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 0/4] pnfs-submit: cleanup layoutcommit verison 2
Date: Thu, 03 Jun 2010 20:11:37 +0300
Message-ID: <4C07E249.5000000@panasas.com>
References: <1275582327-9285-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:30600 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754494Ab0FCRLk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jun 2010 13:11:40 -0400
In-Reply-To: <1275582327-9285-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/03/2010 07:25 PM, andros@netapp.com wrote:
> Responded to comments.
> 
> This is against the pnfs-submit branch of the 2.6.34 tree. They will need to be
> applied against the 2.6.35-rc1 tree which I can do after comments.
> 
> A cleanup, and call the async error handler.
> 0001-SQUASHME-pnfs-submit-cleanup-layoutcommit-call.patch
> 0002-SQUASHME-pnfs-submit-handle-async-layoutcommit-erro.patch
> 
> These next two patches moves the pnfs_layoutcommit_inode call to
> nfs_write_inode, and it is the only call other than in layoutreturn.
> (removed calls in __nfs4_close, nfs_commit_inode, nfs_wb_sync).
> 
> 0003-SQUASHME-pnfs-remove-ifdef-around-layoutcommit_neede.patch
> 0004-SQUASHME-pnfs-submit-move-layoutcommit-to-nfs_write.patch
> 
> pnfs_layoutcommit_inode is called after nfs_commit_unstable_pages() so that
> if LAYOUTCOMMIT fails, the unstable pages have been processed..
> 
> The error handlers (sync and async) call nfs4_map_errors, so unhandled
> errors (such as NFS4ERR_BADLAYOUT) get returned to nfs_write_ioode as -EIO.
> 
> We will add code to the error handlers for errors such as NFS4ERR_BADLAYOUT
> that require us to stop using and free the layout, and redo the I/O through
> the MDS.
> 
> Testing:
> With CONFIG_NFS_V4_1 set
> NFSv4.1/pnfs passed Connectathon against write enabled GFS2/pNFS. Note: there
> were exactly the same number of LAYOUTCOMMITS sent as were sent with
> pnfs_layoutcommit_inode being called from __nfs4_close (never happened),
> nfs_commit_inode and nfs_wb_sync.
> 
> V4.0 mount passes Connectathon tests
> 
> With CONFIG_NFS_V4_1 not set
> 
> V4.0 mount passes Connectathon tests
> 
> -->Andy
> 

Hi Handy, I'll review this and Test on Sunday. Happy weekend.

Thanks
Boaz
