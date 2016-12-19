Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18501 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932807AbcLSWfZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Dec 2016 17:35:25 -0500
Date: Mon, 19 Dec 2016 14:34:47 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Eryu Guan <eguan@redhat.com>
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>, fstests@vger.kernel.org,
        linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v4 1/5] generic/392: Add copy to new file test
Message-ID: <20161219223447.GA7300@birch.djwong.org>
References: <20161208184909.23321-1-Anna.Schumaker@Netapp.com>
 <20161208184909.23321-2-Anna.Schumaker@Netapp.com>
 <20161219100404.GD1859@eguan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161219100404.GD1859@eguan.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 19, 2016 at 06:04:04PM +0800, Eryu Guan wrote:
> Hi Anna,
> 
> On Thu, Dec 08, 2016 at 01:49:04PM -0500, Anna Schumaker wrote:
> > This test copies data from various points in a source file to a new
> > file.  This is useful for testing the basics of copy_file_range().
> > 
> > Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> Sorry for the late review. I tested this patchset on 4.9 kernel and
> xfs_io with your return code fix applied.
> 
> I met some common failures/behaviors in these tests, so I only comment
> on this patch.
> 
> > ---
> >  common/rc             |   6 +++
> >  tests/generic/392     | 102 ++++++++++++++++++++++++++++++++++++++++++++++++++
> >  tests/generic/392.out |  26 +++++++++++++
> >  tests/generic/group   |   1 +
> >  4 files changed, 135 insertions(+)
> >  create mode 100755 tests/generic/392
> >  create mode 100644 tests/generic/392.out
> > 
> > diff --git a/common/rc b/common/rc
> > index 8c99306..7c5d2a8 100644
> > --- a/common/rc
> > +++ b/common/rc
> > @@ -2054,6 +2054,12 @@ _require_xfs_io_command()
> >  	"chproj")
> >  		testio=`$XFS_IO_PROG -F -f -c "chproj 0" $testfile 2>&1`
> >  		;;
> > +	"copy_range")
> > +		testcopy=$TEST_DIR/$$.copy.xfs_io
> > +		$XFS_IO_PROG -F -f -c "pwrite 0 4k" $testfile 2>&1 > /dev/null
> > +		testio=`$XFS_IO_PROG -F -f -c "copy_range $testfile" $testcopy 2>&1`
> > +		rm -f $testcopy 2>&1 > /dev/null
> > +		;;
> >  	"falloc" )
> >  		testio=`$XFS_IO_PROG -F -f -c "falloc 0 1m" $testfile 2>&1`
> >  		;;
> 
> This is not able to _notrun as expect on a kernel without
> copy_file_range syscall support, e.g. 4.4 kernel, xfs_io reports
> "+copy_range: Function not implemented"
> 
> I think we need a new check on $testio after the case switch, e.g.
> 
> echo $testio | grep -q "not implemented" \
> 	&& _notrun "xfs_io $command is not implemented in kernel"
> 
> > diff --git a/tests/generic/392 b/tests/generic/392
> > new file mode 100755
> > index 0000000..466643a
> > --- /dev/null
> > +++ b/tests/generic/392
> > @@ -0,0 +1,102 @@
> > +#!/bin/bash
> > +# FS QA Test No. 392
> > +#
> > +# Tests vfs_copy_file_range():
> > +#   - Copy a file
> > +#   - Copy beginning of original to new file
> > +#   - Copy middle of original to a new file
> > +#   - Copy end of original to new file
> > +#   - Copy middle of original to a new file, creating a hole
> > +#-----------------------------------------------------------------------
> > +# Copyright (c) 2016 Netapp, Inc. All rights reserved.
> > +#
> > +# This program is free software; you can redistribute it and/or
> > +# modify it under the terms of the GNU General Public License as
> > +# published by the Free Software Foundation.
> > +#
> > +# This program is distributed in the hope that it would be useful,
> > +# but WITHOUT ANY WARRANTY; without even the implied warranty of
> > +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > +# GNU General Public License for more details.
> > +#
> > +# You should have received a copy of the GNU General Public License
> > +# along with this program; if not, write the Free Software Foundation,
> > +# Inc.,  51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
> > +#-----------------------------------------------------------------------
> > +#
> > +
> > +seq=`basename $0`
> > +seqres=$RESULT_DIR/$seq
> > +echo "QA output created by $seq"
> > +
> > +here=`pwd`
> > +tmp=/tmp/$$
> > +status=1    # failure is the default!
> > +trap "_cleanup; exit \$status" 0 1 2 3 15
> > +
> > +_cleanup()
> > +{
> > +	cd /
> > +	rm -rf $tmp.*
> > +}
> > +
> > +# get standard environment
> > +. common/rc
> > +. common/filter
> > +
> > +# real QA test starts here
> > +_supported_fs generic
> > +_supported_os Linux
> > +
> > +_require_xfs_io_command "copy_range"
> > +_require_test
> > +
> > +testdir=$TEST_DIR/test-$seq
> > +rm -rf $testdir
> > +mkdir $testdir
> > +rm -f $seqres.full
> > +
> > +echo "Create the original file and then copy"
> > +$XFS_IO_PROG -f -c 'pwrite -S 0x61 0    1000' $testdir/file >> $seqres.full 2>&1
> > +$XFS_IO_PROG -f -c 'pwrite -S 0x62 1000 1000' $testdir/file >> $seqres.full 2>&1
> > +$XFS_IO_PROG -f -c 'pwrite -S 0x63 2000 1000' $testdir/file >> $seqres.full 2>&1
> > +$XFS_IO_PROG -f -c 'pwrite -S 0x64 3000 1000' $testdir/file >> $seqres.full 2>&1
> > +$XFS_IO_PROG -f -c 'pwrite -S 0x65 4000 1000' $testdir/file >> $seqres.full 2>&1
> > +$XFS_IO_PROG -f -c "copy_range $testdir/file" "$testdir/copy"
> > +cmp $testdir/file $testdir/copy
> > +echo "Original md5sums:"
> > +md5sum $testdir/{file,copy} | _filter_test_dir
> > +
> > +echo "Copy beginning of original file"
> > +$XFS_IO_PROG -f -c "copy_range -l 1000 $testdir/file" "$testdir/beginning"
> > +cmp -n 1000 $testdir/file $testdir/beginning
> > +echo "md5sums after copying beginning:"
> > +md5sum $testdir/{file,beginning} | _filter_test_dir
> > +
> > +echo "Copy middle of original file"
> > +$XFS_IO_PROG -f -c "copy_range -s 1000 -l 3000 $testdir/file" "$testdir/middle"
> > +cmp -n 3000 $testdir/file $testdir/middle 1000
> > +echo "md5sums after copying middle:"
> > +md5sum $testdir/{file,middle} | _filter_test_dir
> > +
> > +echo "Copy end of original file"
> > +$XFS_IO_PROG -f -c "copy_range -s 4000 -l 1000 $testdir/file" "$testdir/end"
> > +cmp -n 1000 $testdir/file $testdir/end 4000
> > +echo "md5sums after copying end:"
> > +md5sum $testdir/{file,end} | _filter_test_dir
> > +
> > +echo "Copy beyond end of original file"
> > +$XFS_IO_PROG -f -c "copy_range -s 4000 -l 2000 $testdir/file" "$testdir/beyond"
> 
> This didn't return EINVAL for me on xfs, ext4 and NFS, btrfs reported
> EINVAL but it failed cmp and md5sum test at many other places. What is
> the expected behavior?
>
> generic/393 and generic/396 failed in a similar way, missing
> "copy_range: Invalid argument" in the test output.
> 
> And seems copy_range -l option doesn't work well with xfs reflink
> enabled? I saw many EINVALs when testing reflink enabled xfs, all these
> 5 tests failed. Kernel bug or xfs_io bug or we just want to _notrun on
> reflink xfs?

Ugggggggghhhhhhhhh...

Prior to hch's vfs patch reorganizing vfs_copy_file_range to try clone first,
this happened[1]:

ret = -EOPNOTSUPP;
if (file_out->f_op->copy_file_range)
	ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
					      pos_out, len, flags);
if (ret == -EOPNOTSUPP)
	ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
			len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);

Note that copy_file_range pointed to XFS's clone_range implementation,
so if you pass in an offset/length that aren't block aligned, the clone
code returns EINVAL and ... we pass that out to userspace instead of
falling back.

Now it does this[2]:

if (file_in->f_op->clone_file_range) {
	ret = file_in->f_op->clone_file_range(file_in, pos_in,
			file_out, pos_out, len);
	if (ret == 0) {
		ret = len;
		goto done;
	}
}

if (file_out->f_op->copy_file_range) {
	ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
					      pos_out, len, flags);
	if (ret != -EOPNOTSUPP)
		goto done;
}

ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
		len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);

XFS removed the copy_file_range pointer, so therefore we'll try to
reflink the range and if that doesn't succeed we'll fall back to
whatever do_splice_direct does.  All those EINVALs should go away
shortly, at least on reflink-XFS.

--D

[1] https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?id=ffecee4f2442bb8cb6b34c3335fef4eb50c22fdd#n1545
[2] https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c#n1543

> 
> Thanks,
> Eryu
> --
> To unsubscribe from this list: send the line "unsubscribe fstests" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
