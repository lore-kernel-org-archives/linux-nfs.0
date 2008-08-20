From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs_file_flush() question
Date: Tue, 19 Aug 2008 17:30:52 -0700
Message-ID: <1219192252.7150.30.camel@localhost>
References: <20080819201731.GA25036@yahoo-inc.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:55030 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751826AbYHTAa5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Aug 2008 20:30:57 -0400
In-Reply-To: <20080819201731.GA25036@yahoo-inc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-08-19 at 15:17 -0500, Quentin Barnes wrote:
> > If I don't know the correct mtime attribute of the file when I close it,
> 
> If I follow the code, you do know the mtime when closing the
> file.  With V3, from the WRITE and COMMIT, you're given weak cache
> consistency data containing the the updated mtimes, correct?

No. Please note the difference between a call to nfs_update_inode(), and
a call to nfs_refresh_inode(). The latter tries to be more careful about
updating the inode attributes if there is a chance that we may have
raced with another RPC call to the same inode, and hence that the
attributes returned may be stale.

> But making the change to nfs_revalidate_inode() by itself only
> helps in the case where the file was open O_RDWR and no write(2)
> was done.  The code still needed to be updated to use the WCC data
> at the right time.  In the older kernels when nfs_wb_all() ended up
> calling nfs_update_inode() which was clearing the cache when it saw
> the mtime change from the WRITE.  I tracked down why.  Newer kernels
> (2.6.24 and later) had nfs_post_op_update_inode_force_wcc() call
> added to nfs3_write_done() which updated the inode with the WCC data
> from the WRITE so the later call to nfs_update_inode() didn't see
> an unexpected mtime change flagging the attribute and data cache as
> invalid.

See above.

Cheers
  Trond

