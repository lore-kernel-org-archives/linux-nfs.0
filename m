Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40586 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752166AbdEYEBW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 May 2017 00:01:22 -0400
Date: Thu, 25 May 2017 12:01:19 +0800
From: Eryu Guan <eguan@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: fstests@vger.kernel.org,
        Weston Andros Adamson <dros@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH] nfs: test nfs4_getfacl near page size ACL from server
Message-ID: <20170525040119.GB23805@eguan.usersys.redhat.com>
References: <20170516120909.827-1-eguan@redhat.com>
 <20170516150745.GB21704@parsley.fieldses.org>
 <20170517033854.GA7250@eguan.usersys.redhat.com>
 <20170517172035.GD5011@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170517172035.GD5011@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 17, 2017 at 01:20:36PM -0400, J. Bruce Fields wrote:
> On Wed, May 17, 2017 at 11:38:54AM +0800, Eryu Guan wrote:
> > On Tue, May 16, 2017 at 11:07:45AM -0400, J. Bruce Fields wrote:
> > > On Tue, May 16, 2017 at 08:09:09PM +0800, Eryu Guan wrote:
> > > > Test nfs4_getfacl gets ACL list correctly from server when the ACL
> > > > length is close enough to the end of a page. On buggy NFS client
> > > > getxattr could return ERANGE. Upstream commit ed92d8c137b7 ("NFSv4:
> > > > fix getacl ERANGE for some ACL buffer sizes") fixed this bug in 4.11
> > > > kernel.
> > > 
> > > Thanks.
> > > 
> > > > Note that this reproducer was originally written by J. Bruce Fields.
> > > > 
> > > > Cc: J. Bruce Fields <bfields@redhat.com>
> > > > Cc: Weston Andros Adamson <dros@primarydata.com>
> > > > Cc: linux-nfs@vger.kernel.org
> > > > Signed-off-by: Eryu Guan <eguan@redhat.com>
> > > > ---
> > > > 
> > > > Hi all,
> > > > 
> > > > This is the first attempt to add NFS specific tests to fstests with the hope
> > > > that we'll have more NFS tests go to fstests and more people testing NFS by
> > > > running fstests, it would be great if fstests could be part of the Linux NFS
> > > > development workflow too.
> > > 
> > > What's the difference between fstests and xfstests?
> > 
> > Sorry, I should have mentioned that xfstests has been renamed to
> > fstests in 2014[1], so they're the same thing.
> 
> That could be better advertised.  A google search for "fstests" for
> example turns up mostly irrelevant results.  And I can't recall anyone
> at LSF/MM meetings, for example, calling it anything other than
> "xfstests"?

(Sorry for getting back to this late.)

Yes, that's a problem, it's been 'xfstests' for at least 14 years and
'fstests' is only there for 3 years, sometimes (or most of the times) we
still call it 'xfstests' for a better understanding.

But at least this thread does 'advertise' fstests to NFS list, I guess :)

> 
> Anyway, thanks for adding this.  I do a partial fstests run as part of

Can I take it as a "Reviewed-by" tag? :)

> my regular testing but I'm not great about keeping it updated.

fstests is updated weekly, but usually only one or two new tests (or
none) are added in a update, so not keeping it up-to-date is not a big
issue. Running existing tests would be good enough too.

For a quick smoke test

'./check -nfs -g quick'

(run tests in 'quick' group) will do, it only takes around 10 minutes for me to complete.

And for something more thoroughly, you can do

'./check -nfs -g auto'

(run tests in 'auto' group), which will take longer time but runs many
more tests.

I test every RC release with local-mounted NFS, with NFSv3,
NFSv4.0/4.1/4.2. Here're the 'known issues' I have for 4.11 kernel (I
think some failures are false alert, the tests need updates, some
failures may long standing & low priority bugs on NFS? But I'm not sure
which is which)

Failures for all NFS versions:
generic/035	test fail in rename syscall test, test reported
		"t_rename_overwrite: fstat(3): Stale file handle"
generic/294	expect EEXIST not EROFS

Failures for NFSv3
generic/258	NFSv3 does not support timestamp before epoch
generic/375	sgid not cleared on setfacl, Permission denied

Failures for NFSv4.0/4.1/4.2
generic/011	sometimes direstress test failed, rarely happened
generic/401	NFSv4 reports . and .. dtype as unknown

I use this 'local.config' file for fstests to test NFS, and update the
'vers=3' mount option as needed
----->8------
TEST_DEV=localhost:/mnt/nfsexport
TEST_DIR=/mnt/testarea/test
SCRATCH_DEV=localhost:/mnt/nfsscratch
SCRATCH_MNT=/mnt/testarea/scratch
TEST_FS_MOUNT_OPTS="-o vers=3"
MOUNT_OPTIONS="-o vers=3"
-----8<------

> 
> --b.
> 
> > > > fstests does find NFS bugs (some are regression bugs), I noticed at least three
> > > > regressions introduced in 4.12-rc1 release, one was reported to nfs list[1].

Some updates on these bugs.

> > > > The other two regressions are:
> > > > a) generic/095 crashes NFS (not sure server or client yet, not reproduced
> > > >    manually yet)

This is a bit hard to reproduce, I bisected this to commit "1df631a mm:
make rmap_walk() return void", but I suspected the result is wrong.. I'm
doing further testings to confirm.

> > > > b) copy_file_range(2) hang on NFSv4.2 mount, caught by just added
> > > >    copy_file_range tests.

There's a patch to fix this bug, thanks for the quick response!

Thanks,
Eryu

> > > > 
> > > > I'm still working on bisecting them now, will report to NFS list once I get
> > > > something.
> > > > 
> > > > Thanks,
> > > > Eryu
> > > > 
> > > > [1] https://www.spinics.net/lists/linux-nfs/msg63767.html
> > > > 
> > > >  common/config      |  2 ++
> > > >  common/nfs         | 35 +++++++++++++++++++++++++
> > > >  common/rc          |  1 +
> > > >  tests/nfs/001      | 77 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
> > > >  tests/nfs/001.out  |  2 ++
> > > >  tests/nfs/Makefile | 20 ++++++++++++++
> > > >  tests/nfs/group    |  6 +++++
> > > >  7 files changed, 143 insertions(+)
> > > >  create mode 100644 common/nfs
> > > >  create mode 100755 tests/nfs/001
> > > >  create mode 100644 tests/nfs/001.out
> > > >  create mode 100644 tests/nfs/Makefile
> > > >  create mode 100644 tests/nfs/group
> > > > 
> > > > diff --git a/common/config b/common/config
> > > > index 8211356..c3e9997 100644
> > > > --- a/common/config
> > > > +++ b/common/config
> > > > @@ -196,6 +196,8 @@ export XZ_PROG="`set_prog_path xz`"
> > > >  export FLOCK_PROG="`set_prog_path flock`"
> > > >  export LDD_PROG="`set_prog_path ldd`"
> > > >  export TIMEOUT_PROG="`set_prog_path timeout`"
> > > > +export NFS4_SETFACL_PROG="`set_prog_path nfs4_setfacl`"
> > > > +export NFS4_GETFACL_PROG="`set_prog_path nfs4_getfacl`"
> > > >  
> > > >  # use 'udevadm settle' or 'udevsettle' to wait for lv to be settled.
> > > >  # newer systems have udevadm command but older systems like RHEL5 don't.
> > > > diff --git a/common/nfs b/common/nfs
> > > > new file mode 100644
> > > > index 0000000..a03eaf4
> > > > --- /dev/null
> > > > +++ b/common/nfs
> > > > @@ -0,0 +1,35 @@
> > > > +#
> > > > +# NFS specific common functions.
> > > > +#
> > > > +
> > > > +# given an NFS export and a NFS version number, return 0 if
> > > > +# the mounted NFS is the given version. e.g.
> > > > +# _is_nfs_version $SCRATCH_DEV 4.2
> > > > +_is_nfs_version()
> > > > +{
> > > > +	local nfs_exp=$1
> > > > +	local nfs_ver=$2
> > > > +	_fs_options $1 | grep -q "vers=$2"
> > > > +}
> > > > +
> > > > +# require $TEST_DEV mounted as a given NFS version
> > > > +# e.g. _require_test_nfs_version 4.2
> > > > +_require_test_nfs_version()
> > > > +{
> > > > +	_require_test
> > > > +	if ! _is_nfs_version $TEST_DEV $1; then
> > > > +		_notrun "Test requires \$TEST_DEV mounted as NFSv$1"
> > > > +	fi
> > > > +}
> > > > +
> > > > +# require $SCRATCH_DEV mounted as a given NFS version
> > > > +# e.g. _require_scratch_nfs_version 4
> > > > +_require_scratch_nfs_version()
> > > > +{
> > > > +	_require_scratch
> > > > +	_scratch_mount
> > > > +	if ! _is_nfs_version $SCRATCH_DEV $1; then
> > > > +		_notrun "Test requires \$SCRATCH_DEV mounted as NFSv$1"
> > > > +	fi
> > > > +	_scratch_unmount
> > > > +}
> > > > diff --git a/common/rc b/common/rc
> > > > index aa35b5e..ca0a284 100644
> > > > --- a/common/rc
> > > > +++ b/common/rc
> > > > @@ -162,6 +162,7 @@ case "$FSTYP" in
> > > >  	 [ "$MKFS_F2FS_PROG" = "" ] && _fatal "mkfs.f2fs not found"
> > > >  	 ;;
> > > >      nfs)
> > > > +	 . ./common/nfs
> > > >  	 ;;
> > > >      cifs)
> > > >  	 ;;
> > > > diff --git a/tests/nfs/001 b/tests/nfs/001
> > > > new file mode 100755
> > > > index 0000000..764cde3
> > > > --- /dev/null
> > > > +++ b/tests/nfs/001
> > > > @@ -0,0 +1,77 @@
> > > > +#! /bin/bash
> > > > +# FS QA Test 001
> > > > +#
> > > > +# Test nfs4_getfacl gets ACL list correctly from server when the ACL length is
> > > > +# close enough to the end of a page. On buggy NFS client getxattr could return
> > > > +# ERANGE. Upstream commit ed92d8c137b7 ("NFSv4: fix getacl ERANGE for some ACL
> > > > +# buffer sizes") fixed this bug.
> > > > +#
> > > > +#-----------------------------------------------------------------------
> > > > +# Copyright (c) 2017 Red Hat Inc., All Rights Reserved.
> > > > +#
> > > > +# This program is free software; you can redistribute it and/or
> > > > +# modify it under the terms of the GNU General Public License as
> > > > +# published by the Free Software Foundation.
> > > > +#
> > > > +# This program is distributed in the hope that it would be useful,
> > > > +# but WITHOUT ANY WARRANTY; without even the implied warranty of
> > > > +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > > > +# GNU General Public License for more details.
> > > > +#
> > > > +# You should have received a copy of the GNU General Public License
> > > > +# along with this program; if not, write the Free Software Foundation,
> > > > +# Inc.,  51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
> > > > +#-----------------------------------------------------------------------
> > > > +#
> > > > +
> > > > +seq=`basename $0`
> > > > +seqres=$RESULT_DIR/$seq
> > > > +echo "QA output created by $seq"
> > > > +
> > > > +here=`pwd`
> > > > +tmp=/tmp/$$
> > > > +status=1	# failure is the default!
> > > > +trap "_cleanup; exit \$status" 0 1 2 3 15
> > > > +
> > > > +_cleanup()
> > > > +{
> > > > +	cd /
> > > > +	rm -f $tmp.* $acltest.*
> > > > +}
> > > > +
> > > > +# get standard environment, filters and checks
> > > > +. ./common/rc
> > > > +. ./common/filter
> > > > +
> > > > +# remove previous $seqres.full before test
> > > > +rm -f $seqres.full
> > > > +
> > > > +# real QA test starts here
> > > > +_supported_fs nfs
> > > > +_supported_os Linux
> > > > +_require_test_nfs_version 4
> > > > +_require_command $NFS4_SETFACL_PROG "nfs4_setfacl"
> > > > +_require_command $NFS4_GETFACL_PROG "nfs4_getfacl"
> > > > +
> > > > +acltest=$TEST_DIR/acltest.$seq
> > > > +rm -f $acltest.*
> > > > +touch $acltest.file $acltest.list
> > > > +
> > > > +# Setup a carefully made ACE list to make attr buffer length is close enough to
> > > > +# PAGE_SIZE (size is 4088 in this case, and this only works for 4k page size)
> > > > +# that leaves too little room for adding extra attr bitmap in this page
> > > > +echo "A::OWNER@:RW" >$acltest.list
> > > > +for ((i=9802; i < 10002; i++)); do echo "A::$i:RW" >>$acltest.list; done
> > > > +echo "A::GROUP@:RW" >>$acltest.list
> > > > +echo "A::EVERYONE@:RW" >>$acltest.list
> > > > +
> > > > +# Save ACL to testfile
> > > > +$NFS4_SETFACL_PROG -S $acltest.list $acltest.file
> > > > +
> > > > +# Dump ACL, expect correct number of ACE entries
> > > > +$NFS4_GETFACL_PROG $acltest.file >>$seqres.full 2>&1
> > > > +$NFS4_GETFACL_PROG $acltest.file | wc -l
> > > > +
> > > > +# success, all done
> > > > +status=0
> > > > +exit
> > > > diff --git a/tests/nfs/001.out b/tests/nfs/001.out
> > > > new file mode 100644
> > > > index 0000000..741ade0
> > > > --- /dev/null
> > > > +++ b/tests/nfs/001.out
> > > > @@ -0,0 +1,2 @@
> > > > +QA output created by 001
> > > > +203
> > > > diff --git a/tests/nfs/Makefile b/tests/nfs/Makefile
> > > > new file mode 100644
> > > > index 0000000..754f2b2
> > > > --- /dev/null
> > > > +++ b/tests/nfs/Makefile
> > > > @@ -0,0 +1,20 @@
> > > > +#
> > > > +# Copyright (c) 2017 Red Hat, Inc.  All Rights Reserved.
> > > > +#
> > > > +
> > > > +TOPDIR = ../..
> > > > +include $(TOPDIR)/include/builddefs
> > > > +
> > > > +NFS_DIR = nfs
> > > > +TARGET_DIR = $(PKG_LIB_DIR)/$(TESTS_DIR)/$(NFS_DIR)
> > > > +
> > > > +include $(BUILDRULES)
> > > > +
> > > > +install:
> > > > +	$(INSTALL) -m 755 -d $(TARGET_DIR)
> > > > +	$(INSTALL) -m 755 $(TESTS) $(TARGET_DIR)
> > > > +	$(INSTALL) -m 644 group $(TARGET_DIR)
> > > > +	$(INSTALL) -m 644 $(OUTFILES) $(TARGET_DIR)
> > > > +
> > > > +# Nothing.
> > > > +install-dev install-lib:
> > > > diff --git a/tests/nfs/group b/tests/nfs/group
> > > > new file mode 100644
> > > > index 0000000..2619eae
> > > > --- /dev/null
> > > > +++ b/tests/nfs/group
> > > > @@ -0,0 +1,6 @@
> > > > +# QA groups control file
> > > > +# Defines test groups and nominal group owners
> > > > +# - do not start group names with a digit
> > > > +# - comment line before each group is "new" description
> > > > +#
> > > > +001 auto quick nfs4_acl acl
> > > > -- 
> > > > 2.9.3
> > > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe fstests" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe fstests" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
