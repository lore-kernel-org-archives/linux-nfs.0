Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34004 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751096AbcIIGVi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 02:21:38 -0400
Date: Fri, 9 Sep 2016 14:21:36 +0800
From: Eryu Guan <eguan@redhat.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v2 1/4] generic/377: Add copy to new file test
Message-ID: <20160909062136.GY27776@eguan.usersys.redhat.com>
References: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
 <20160907195619.25914-2-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160907195619.25914-2-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 07, 2016 at 03:56:16PM -0400, Anna Schumaker wrote:
> This test copies data from various points in a source file to a new
> file.  This is useful for testing the basics of copy_file_range().
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
>  tests/generic/377     | 102 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/377.out |  21 +++++++++++
>  tests/generic/group   |   1 +
>  3 files changed, 124 insertions(+)
>  create mode 100644 tests/generic/377

File mode of test case should be 755, i.e. it has x permission. So "git
diff" won't complain the mode change after running these tests.

>  create mode 100644 tests/generic/377.out
> 
> diff --git a/tests/generic/377 b/tests/generic/377
> new file mode 100644
> index 0000000..352b9bb
> --- /dev/null
> +++ b/tests/generic/377
> @@ -0,0 +1,102 @@
> +#!/bin/bash
> +# FS QA Test No. 377
> +#
> +# Tests vfs_copy_file_range():
> +#   - Copy a file
> +#   - Copy beginning of original to new file
> +#   - Copy middle of original to a new file
> +#   - Copy end of original to new file
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
> +_supported_os Linux

Need "_supported_fs generic" in all these tests.

> +
> +_require_xfs_io_command "copy_range"

Do we need to test the support status on kernel side? e.g. what happens
if filesystems have no "copy_file_range" implemented? Seems
copy_file_range falls back to splice in this case, but I'm not sure. If
so I think it's OK to have no kernel side detection.

> +_require_test
> +
> +testdir=$TEST_DIR/test-$seq
> +rm -rf $testdir
> +mkdir $testdir
> +
> +_checksum_files()

We usually name local functions without the leading "_".

> +{
> +	for f in $*; do
> +		md5sum $testdir/$f | _filter_test_dir
> +	done
> +}
> +
> +rm -f $seqres.full
> +
> +echo "Create the original file and then copy"
> +$XFS_IO_PROG -f -c 'pwrite -S 0x61 0    1000' $testdir/file >> $seqres.full 2>&1
> +$XFS_IO_PROG -f -c 'pwrite -S 0x62 1000 1000' $testdir/file >> $seqres.full 2>&1
> +$XFS_IO_PROG -f -c 'pwrite -S 0x63 2000 1000' $testdir/file >> $seqres.full 2>&1
> +$XFS_IO_PROG -f -c 'pwrite -S 0x64 3000 1000' $testdir/file >> $seqres.full 2>&1
> +$XFS_IO_PROG -f -c 'pwrite -S 0x65 4000 1000' $testdir/file >> $seqres.full 2>&1
> +$XFS_IO_PROG -f -c "copy_range $testdir/file" "$testdir/copy"
> +cmp $testdir/file $testdir/copy
> +echo "Original md5sums:"
> +_checksum_files file copy

I saw test failures when testing on XFS and btrfs, 4.8-rc3 kernel, and
similar failures in other tests. Are these failures expected?

[root@dhcp-66-86-11 xfstests]# diff -u tests/generic/377.out /root/workspace/xfstests/results//xfs_4k_crc/generic/377.out.bad
--- tests/generic/377.out       2016-09-09 12:17:40.790000000 +0800
+++ /root/workspace/xfstests/results//xfs_4k_crc/generic/377.out.bad    2016-09-09 14:14:48.483000000 +0800
@@ -4,18 +4,22 @@
 e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-377/file
 e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-377/copy
 Copy beginning of original file
+cmp: EOF on /mnt/testarea/test/test-377/beginning
 md5sums after copying beginning:
 e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-377/file
-cabe45dcc9ae5b66ba86600cca6b8ba8  TEST_DIR/test-377/beginning
+d41d8cd98f00b204e9800998ecf8427e  TEST_DIR/test-377/beginning
 Copy middle of original file
+cmp: EOF on /mnt/testarea/test/test-377/middle
 md5sums after copying middle:
 e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-377/file
-4197de9da5badfc302715486b82bcdf1  TEST_DIR/test-377/middle
+d41d8cd98f00b204e9800998ecf8427e  TEST_DIR/test-377/middle
 Copy end of original file
+cmp: EOF on /mnt/testarea/test/test-377/end
 md5sums after copying end:
 e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-377/file
-e68d4a150c4e42f4f9ea3ffe4c9cf4ed  TEST_DIR/test-377/end
+d41d8cd98f00b204e9800998ecf8427e  TEST_DIR/test-377/end
 Copy beyond end of original file
+cmp: EOF on /mnt/testarea/test/test-377/end
 md5sums after copying beyond:
 e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-377/file
-e68d4a150c4e42f4f9ea3ffe4c9cf4ed  TEST_DIR/test-377/beyond
+d41d8cd98f00b204e9800998ecf8427e  TEST_DIR/test-377/beyond

> +
> +echo "Copy beginning of original file"
> +$XFS_IO_PROG -f -c "copy_range -l 1000 $testdir/file" "$testdir/beginning"
> +cmp -n 1000 $testdir/file $testdir/beginning
> +echo "md5sums after copying beginning:"
> +_checksum_files file beginning
> +
> +echo "Copy middle of original file"
> +$XFS_IO_PROG -f -c "copy_range -s 1000 -l 3000 $testdir/file" "$testdir/middle"
> +cmp -n 3000 $testdir/file $testdir/middle 1000
> +echo "md5sums after copying middle:"
> +_checksum_files file middle
> +
> +echo "Copy end of original file"
> +$XFS_IO_PROG -f -c "copy_range -s 4000 -l 1000 $testdir/file" "$testdir/end"
> +cmp -n 1000 $testdir/file $testdir/end 4000
> +echo "md5sums after copying end:"
> +_checksum_files file end
> +
> +echo "Copy beyond end of original file"
> +$XFS_IO_PROG -f -c "copy_range -s 4000 -l 2000 $testdir/file" "$testdir/beyond"

I noticed that xfs_io hung on copying beyond EOF when testing with ext4
and NFSv4.1, xfs_io was in "R" state for 10 minutes until I killed it.
Is it kernel bug or test is not suitable on such filesystems?

Thanks,
Eryu

> +cmp -n 1000 $testdir/file $testdir/end 4000
> +echo "md5sums after copying beyond:"
> +_checksum_files file beyond
> +
> +#success, all done
> +status=0
> +exit
> diff --git a/tests/generic/377.out b/tests/generic/377.out
> new file mode 100644
> index 0000000..8ad8b53
> --- /dev/null
> +++ b/tests/generic/377.out
> @@ -0,0 +1,21 @@
> +QA output created by 377
> +Create the original file and then copy
> +Original md5sums:
> +e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-377/file
> +e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-377/copy
> +Copy beginning of original file
> +md5sums after copying beginning:
> +e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-377/file
> +cabe45dcc9ae5b66ba86600cca6b8ba8  TEST_DIR/test-377/beginning
> +Copy middle of original file
> +md5sums after copying middle:
> +e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-377/file
> +4197de9da5badfc302715486b82bcdf1  TEST_DIR/test-377/middle
> +Copy end of original file
> +md5sums after copying end:
> +e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-377/file
> +e68d4a150c4e42f4f9ea3ffe4c9cf4ed  TEST_DIR/test-377/end
> +Copy beyond end of original file
> +md5sums after copying beyond:
> +e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-377/file
> +e68d4a150c4e42f4f9ea3ffe4c9cf4ed  TEST_DIR/test-377/beyond
> diff --git a/tests/generic/group b/tests/generic/group
> index bad71bc..dec0d64 100644
> --- a/tests/generic/group
> +++ b/tests/generic/group
> @@ -379,3 +379,4 @@
>  374 auto quick clone dedupe
>  375 auto quick acl
>  376 auto quick metadata
> +377 auto quick copy
> -- 
> 2.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe fstests" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
