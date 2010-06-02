From: Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/6] pnfs-submit cleanup layoutcommit for file layout
Date: Wed, 2 Jun 2010 14:05:59 -0400
Message-ID: <5562E9CC-03E5-4A0E-AB27-9DE70D75725D@netapp.com>
References: <1275494067-4058-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4733 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932596Ab0FBSGB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jun 2010 14:06:01 -0400
In-Reply-To: <1275494067-4058-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This time sent with the subject....

On Jun 2, 2010, at 11:54 AM, andros@netapp.com wrote:

>
> This is against the pnfs-submit branch of the 2.6.34 tree. They will  
> need to be
> applied against the 2.6.35-rc1 tree which I can do after comments.
>
> RFC: I would like comments, especially on
> 0006-SQUASHME-pnfs-submit-move-layoutcommit-to-nfs_write_.patch.
>
> Remove unused layoutcommit layoutdriver_io_operations. Will be  
> restored
> in post-submit patches
> 0001-SQUASHME-pnfs-submit-remove-setup_layoutcommit.patch
> 0002-SQUASHNE-pnfs-submit-remove-cleanup_layoutcommit.patch
> 0003-SQUASHME-pnfs-submit-remove-encode_layoutcommit.patch
>
> A cleanup, and call the async error handler.
> 0004-SQUASHME-pnfs-submit-cleanup-layoutcommit-call.patch
> 0005-SQUASHME-pnfs-submit-handle-async-layoutcommit-error.patch
>
> This next  patch moves the pnfs_layoutcommit_inode call to  
> nfs_write_inode,
> and it is the only call other than in layoutreturn. (removed calls in
> __nfs4_close, nfs_commit_inode, nfs_wb_sync).
>
> This is fine for the file layout, and I think it's OK for the object  
> and
> block layouts as well.
>
> I left the LAYOUTCOMMIT call in nfs_write_inode a synchronous call,  
> because
> nfs_commit_unstable_pages sets the FLUSH_SYNC flag. Should this
> be an asyc LAYOUTCOMMIT call?
>
> pnfs_layoutcommit_inode is called after nfs_commit_unstable_pages()  
> so that
> if LAYOUTCOMMIT fails, the unstable pages have been processed..
>
> The error handlers (sync and async) call nfs4_map_errors, so unhandled
> errors (such as NFS4ERR_BADLAYOUT) get returned to nfs_write_ioode  
> as -EIO.
>
> Examining the write_inode call paths, I could not see where the -EIO  
> would
> be passed back to the application.  Testing with pynfs which I
> had return NFS4ERR_BADLAYOUT to the layout commit call, shows the - 
> EIO return
> not stopping the client nor is the error reported back to the  
> application.
>
> We will add code to the error handlers for errors such as  
> NFS4ERR_BADLAYOUT
> that require us to stop using and free the layout, and redo the I/O  
> through
> the MDS.
>
> Anyway, review is much appreciated.
>
> 0006-SQUASHME-pnfs-submit-move-layoutcommit-to-nfs_write_.patch
>
> Testing:
> With CONFIG_NFS_V4_1 set
> NFSv4.1/pnfs passed Connectathon against write enabled GFS2/pNFS.  
> Note: there
> were exactly the same number of LAYOUTCOMMITS sent as were sent with
> pnfs_layoutcommit_inode being called from __nfs4_close (never  
> happened),
> nfs_commit_inode and nfs_wb_sync.
>
> Passed Connectathon general test against pynfs file layout server with
> the NFS4ERR_BADLAYOUT being returned on every third LAYOUTCOMMIT.
>
>
> -->Andy
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

