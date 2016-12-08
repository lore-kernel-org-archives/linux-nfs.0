Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:1988 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932229AbcLHSt3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Dec 2016 13:49:29 -0500
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@Netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH v4 0/5] Add copy_file_range() tests
Date: Thu, 8 Dec 2016 13:49:03 -0500
Message-ID: <20161208184909.23321-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These tests exercise the copy_file_range() system call, and check copying
data to both a new file and overwriting data inside an existing file.

The last patch is a duplicate of a patch I already submitted for the
xfs_io utility.  It adds in fixes for the 'copy_range' command so error
checking can work and so some copies won't loop forever.

Thanks,
Anna

Anna Schumaker (5):
  generic/392: Add copy to new file test
  generic/393: Add small copies to new file test
  generic/394: Add copy test that overwrites data
  generic/395: Add a copy test for overwriting small amounts of data
  generic/396: Add a copy test for invalid input

 common/rc             |   6 +++
 tests/generic/392     | 102 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/392.out |  26 +++++++++++++
 tests/generic/393     |  83 ++++++++++++++++++++++++++++++++++++++++
 tests/generic/393.out |  16 ++++++++
 tests/generic/394     | 100 +++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/394.out |  17 +++++++++
 tests/generic/395     |  87 ++++++++++++++++++++++++++++++++++++++++++
 tests/generic/395.out |  17 +++++++++
 tests/generic/396     |  68 +++++++++++++++++++++++++++++++++
 tests/generic/396.out |   8 ++++
 tests/generic/group   |   5 +++
 12 files changed, 535 insertions(+)
 create mode 100755 tests/generic/392
 create mode 100644 tests/generic/392.out
 create mode 100755 tests/generic/393
 create mode 100644 tests/generic/393.out
 create mode 100755 tests/generic/394
 create mode 100644 tests/generic/394.out
 create mode 100755 tests/generic/395
 create mode 100644 tests/generic/395.out
 create mode 100644 tests/generic/396
 create mode 100644 tests/generic/396.out

-- 
2.10.2

