Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43166 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754755AbcLTD0b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Dec 2016 22:26:31 -0500
Date: Tue, 20 Dec 2016 11:26:28 +0800
From: Eryu Guan <eguan@redhat.com>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>, fstests@vger.kernel.org,
        linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v4 1/5] generic/392: Add copy to new file test
Message-ID: <20161220032628.GE1859@eguan.usersys.redhat.com>
References: <20161208184909.23321-1-Anna.Schumaker@Netapp.com>
 <20161208184909.23321-2-Anna.Schumaker@Netapp.com>
 <20161219100404.GD1859@eguan.usersys.redhat.com>
 <20161219223447.GA7300@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161219223447.GA7300@birch.djwong.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 19, 2016 at 02:34:47PM -0800, Darrick J. Wong wrote:
> > 
> > And seems copy_range -l option doesn't work well with xfs reflink
> > enabled? I saw many EINVALs when testing reflink enabled xfs, all these
> > 5 tests failed. Kernel bug or xfs_io bug or we just want to _notrun on
> > reflink xfs?
> 
> Ugggggggghhhhhhhhh...
> 
> Prior to hch's vfs patch reorganizing vfs_copy_file_range to try clone first,
> this happened[1]:
> 
> ret = -EOPNOTSUPP;
> if (file_out->f_op->copy_file_range)
> 	ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
> 					      pos_out, len, flags);
> if (ret == -EOPNOTSUPP)
> 	ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
> 			len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);
> 
> Note that copy_file_range pointed to XFS's clone_range implementation,
> so if you pass in an offset/length that aren't block aligned, the clone
> code returns EINVAL and ... we pass that out to userspace instead of
> falling back.
> 
> Now it does this[2]:
> 
> if (file_in->f_op->clone_file_range) {
> 	ret = file_in->f_op->clone_file_range(file_in, pos_in,
> 			file_out, pos_out, len);
> 	if (ret == 0) {
> 		ret = len;
> 		goto done;
> 	}
> }
> 
> if (file_out->f_op->copy_file_range) {
> 	ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
> 					      pos_out, len, flags);
> 	if (ret != -EOPNOTSUPP)
> 		goto done;
> }
> 
> ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
> 		len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);
> 
> XFS removed the copy_file_range pointer, so therefore we'll try to
> reflink the range and if that doesn't succeed we'll fall back to
> whatever do_splice_direct does.  All those EINVALs should go away
> shortly, at least on reflink-XFS.

Good to know, thanks for the explanation!

Eryu

> 
> --D
> 
> [1] https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?id=ffecee4f2442bb8cb6b34c3335fef4eb50c22fdd#n1545
> [2] https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c#n1543
> 
> > 
> > Thanks,
> > Eryu
> > --
> > To unsubscribe from this list: send the line "unsubscribe fstests" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
