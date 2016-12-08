Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47047 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752190AbcLHUU6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2016 15:20:58 -0500
Date: Thu, 8 Dec 2016 12:20:23 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v4 5/5] generic/396: Add a copy test for invalid input
Message-ID: <20161208202023.GD25841@birch.djwong.org>
References: <20161208184909.23321-1-Anna.Schumaker@Netapp.com>
 <20161208184909.23321-6-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161208184909.23321-6-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 08, 2016 at 01:49:08PM -0500, Anna Schumaker wrote:
> This test passes invalid argumnt combinations to the copy_file_range()
> system call to test that input is verified before attempting to copy.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
>  tests/generic/396     | 68 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/396.out |  8 ++++++
>  tests/generic/group   |  1 +
>  3 files changed, 77 insertions(+)
>  create mode 100644 tests/generic/396
>  create mode 100644 tests/generic/396.out
> 
> diff --git a/tests/generic/396 b/tests/generic/396
> new file mode 100644
> index 0000000..c262070
> --- /dev/null
> +++ b/tests/generic/396
> @@ -0,0 +1,68 @@
> +#!/bin/bash
> +# FS QA Test No. 396
> +#
> +# Tests vfs_copy_file_range() error checking
> +#-----------------------------------------------------------------------
> +# Copyright (c) 2016 Netapp, Inc. All rights reserved.
> +#
> +# This program is free software; you can redistribute it and/or
> +# modify it under the terms of the GNU General Public License as
> +# published by the Free Software Foundation.
> +#
> +# This program is distributed in the hope that it would be useful,
> +# but WITHOUT ANY WARRANTY; without even the implied warranty of
> +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> +# GNU General Public License for more details.
> +#
> +# You should have received a copy of the GNU General Public License
> +# along with this program; if not, write the Free Software Foundation,
> +# Inc.,  51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
> +#-----------------------------------------------------------------------
> +#
> +
> +seq=`basename $0`
> +seqres=$RESULT_DIR/$seq
> +echo "QA output created by $seq"
> +
> +here=`pwd`
> +tmp=/tmp/$$
> +status=1    # failure is the default!
> +trap "_cleanup; exit \$status" 0 1 2 3 15
> +
> +_cleanup()
> +{
> +	cd /
> +	rm -rf $tmp.*
> +}
> +
> +# get standard environment
> +. common/rc
> +. common/filter
> +
> +# real QA test starts here
> +_supported_fs generic
> +_supported_os Linux
> +
> +_require_xfs_io_command "copy_range"
> +_require_test
> +
> +testdir=$TEST_DIR/test-$seq
> +rm -rf $testdir
> +mkdir $testdir
> +rm -f $seqres.full
> +
> +echo "Create the original file"
> +$XFS_IO_PROG -f -c 'pwrite -S 0x61 0 1000' $testdir/file >> $seqres.full 2>&1
> +
> +echo "source pos > source size:"
> +$XFS_IO_PROG -f -c "copy_range -s 1000 -l 100 $testdir/file" "$testdir/copy"
> +
> +echo "target read-only"
> +$XFS_IO_PROG -r -f -c "copy_range -s 0 -l 100 $testdir/file" "$testdir/copy"
> +
> +echo "target append-only"
> +$XFS_IO_PROG -a -f -c "copy_range -s 0 -l 100 $testdir/file" "$testdir/copy"

Good start, though I can think of a few more things...

Copying when one or the other file arguments are directories/device files/etc.,
copies where pos < size but (pos + len) > size, copies where pos + len
overflow, overlapped src/dest ranges, and perhaps even copies across holes and
unwritten extents?

--D

> +
> +#success, all done
> +status=0
> +exit
> diff --git a/tests/generic/396.out b/tests/generic/396.out
> new file mode 100644
> index 0000000..4031883
> --- /dev/null
> +++ b/tests/generic/396.out
> @@ -0,0 +1,8 @@
> +QA output created by 396
> +Create the original file
> +source pos > source size:
> +copy_range: Invalid argument
> +target read-only
> +copy_range: Bad file descriptor
> +target append-only
> +copy_range: Bad file descriptor
> diff --git a/tests/generic/group b/tests/generic/group
> index 2b50ddb..eee0f39 100644
> --- a/tests/generic/group
> +++ b/tests/generic/group
> @@ -398,3 +398,4 @@
>  393 auto quick copy
>  394 auto quick copy
>  395 auto quick copy
> +396 auto quick copy
> -- 
> 2.10.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe fstests" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
