Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53551 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750708AbaJaREW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Oct 2014 13:04:22 -0400
From: Eryu Guan <eguan@redhat.com>
To: fstests@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Eryu Guan <eguan@redhat.com>
Subject: [PATCH v2 0/5] re-enable tests that require scratch dev on NFS
Date: Sat,  1 Nov 2014 01:03:55 +0800
Message-Id: <1414775040-4051-1-git-send-email-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The commit below disables tests requires scratch dev running on NFS

c041421 xfstests: stop special casing nfs and udf

Now re-enable them to get a larger test coverage on NFS.

Also do more updates to avoid unnecessary failures on NFS.

I tested against NFSv3 NFSv4.0 NFSv4.1 (both server and client are linux
running 3.18-rc1 kernel), the results look good.

Failures on NFSv3:
generic/035 generic/089 generic/258 generic/294

Failures on NFSv4.0:
generic/035 generic/169 generic/294

Failures on NFSv4.1:
I hit kernel BUG_ON when testing on NFSv4.1 in generic/285
SEEK_DATA/SEEK_HOLE test. I think there's already a patch to fix it.

http://www.spinics.net/lists/linux-nfs/msg47359.html

Note that generic/294 does remount,ro on SCRATCH_DEV, but TEST_DEV is
affected too, so some tests after generic/294 fail because of EROFS.
Run the failed tests separately and they all passed.

I'm not sure if it's a bug, but I filed one, please see
https://bugzilla.redhat.com/show_bug.cgi?id=1158046


The third patch disables all atime related tests on NFS, and Christoph
starts a discussion about NFS atime handling issue in v1 thread. Before
there's a conclusion I keep the patch as it is, and we can update it
later when we decide to test atime on NFS again.

v2:
- introduce _scratch_cleanup_files helper to remove all files on
  $SCRATCH_MNT, for later CIFS use. (Christoph Hellwig)
- split _require_relatime change into another patch (Christoph Hellwig)

v1: http://www.spinics.net/lists/linux-nfs/msg47423.html

Thanks,
Eryu

---

Eryu Guan (5):
  common: re-enable tests that require scratch dev on NFS
  common: add _require_block_device() helper
  common: skip atime related tests on NFS
  common: use _scratch_mount helper in _require_relatime()
  generic/277: add _require_attrs

 common/rc         | 46 ++++++++++++++++++++++++++++++++++++++++++----
 tests/generic/003 |  1 +
 tests/generic/076 |  1 +
 tests/generic/192 |  1 +
 tests/generic/277 |  2 ++
 5 files changed, 47 insertions(+), 4 deletions(-)

-- 
1.9.3

