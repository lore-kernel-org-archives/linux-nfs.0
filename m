Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50827 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752766AbdCBSlF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Mar 2017 13:41:05 -0500
Date: Thu, 2 Mar 2017 10:40:57 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-fsdevel@vger.kernel.org, hch@lst.de,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 1/3] fs: Don't copy beyond the end of the file
Message-ID: <20170302184057.GM26319@birch.djwong.org>
References: <20170302160211.30451-1-kolga@netapp.com>
 <20170302160211.30451-2-kolga@netapp.com>
 <20170302165839.GC5269@birch.djwong.org>
 <9265113A-877D-4C62-9A3F-65D09D0FC404@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <9265113A-877D-4C62-9A3F-65D09D0FC404@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 02, 2017 at 01:21:49PM -0500, Olga Kornievskaia wrote:
> 
> > On Mar 2, 2017, at 11:58 AM, Darrick J. Wong <darrick.wong@oracle.com> wrote:
> > 
> > On Thu, Mar 02, 2017 at 11:02:09AM -0500, Olga Kornievskaia wrote:
> >> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> >> 
> >> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> >> ---
> >> fs/read_write.c | 3 +++
> >> 1 file changed, 3 insertions(+)
> >> 
> >> diff --git a/fs/read_write.c b/fs/read_write.c
> >> index 5816d4c..1d9e305 100644
> >> --- a/fs/read_write.c
> >> +++ b/fs/read_write.c
> >> @@ -1526,6 +1526,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> >> 	if (unlikely(ret))
> >> 		return ret;
> >> 
> >> +	if (pos_in >= i_size_read(inode_in))
> >> +		return -EINVAL;
> >> +
> > 
> > This ought to go in vfs_clone_file_prep_inodes.
> > 
> > (He says, noticing that btrfs never got updated to use that validator…)
> 
> I apologize I’m not fully understanding the suggestion here. How btrfs is
> related to the check that I’m suggesting for the copy_file_range().  I don’t
> see how it would fix the problem for the copy_file_range().

Never mind, I misread vfs_copy as vfs_clone and thought you were talking
about something else. :(

Sorry about the noise.

--D

> Is the suggestion that NFS’s clone implementation is suppose to call
> vfs_clone_file_prep_inodes() where the check would be added and thus
> because vfs_copy_file_range() first decides to call clone() instead of
> copy() then that check would be met?
> 
> > 
> > --D
> > 
> >> 	if (!(file_in->f_mode & FMODE_READ) ||
> >> 	    !(file_out->f_mode & FMODE_WRITE) ||
> >> 	    (file_out->f_flags & O_APPEND))
> >> -- 
> >> 1.8.3.1
> >> 
> 
