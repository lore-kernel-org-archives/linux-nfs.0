Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:27109 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751372AbcIGT4W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Sep 2016 15:56:22 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH v2 0/4] Add copy_file_range() tests
Date: Wed, 7 Sep 2016 15:56:15 -0400
Message-ID: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These tests exercise the copy_file_range() system call, and check copying
data to both a new file and overwriting data inside an existing file.  I use
the xfs_io "copy_range" command for the actual copies, so running these
tests requires an up-to-date version of xfsprogs.

Thanks,
Anna

Anna Schumaker (4):
  generic/377: Add copy to new file test
  generic/378: Add small copies to new file test
  generic/379: Add copy test that overwrites data
  generic/380: Add a copy test for overwriting small amounts of data

 tests/generic/377     | 102 +++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/377.out |  21 ++++++++++
 tests/generic/378     |  88 +++++++++++++++++++++++++++++++++++++++++
 tests/generic/378.out |  14 +++++++
 tests/generic/379     | 107 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/379.out |  17 ++++++++
 tests/generic/380     |  94 ++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/380.out |  17 ++++++++
 tests/generic/group   |   4 ++
 9 files changed, 464 insertions(+)
 create mode 100644 tests/generic/377
 create mode 100644 tests/generic/377.out
 create mode 100644 tests/generic/378
 create mode 100644 tests/generic/378.out
 create mode 100644 tests/generic/379
 create mode 100644 tests/generic/379.out
 create mode 100644 tests/generic/380
 create mode 100644 tests/generic/380.out

-- 
2.9.3

