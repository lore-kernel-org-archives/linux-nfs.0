Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:24063 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751760AbdEJRrH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 10 May 2017 13:47:07 -0400
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@Netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH v6 0/5] Add copy_file_range() tests
Date: Wed, 10 May 2017 13:46:23 -0400
Message-ID: <20170510174628.22895-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These tests exercise the copy_file_range() system call, and check copying
data to both a new file and overwriting data inside an existing file.

Changes since v5:
- Update copyright lines
- Update test numbers
- Make sure tests pass with a variety of filesystems

Thanks,
Anna


Anna Schumaker (5):
  generic/429: Add copy to new file test
  generic/430: Add small copies to new file test
  generic/431: Add copy test that overwrites data
  generic/432: Add a copy test for overwriting small amounts of data
  generic/433: Add a copy test for invalid input

 common/rc             |   6 +++
 tests/generic/429     | 102 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/429.out |  25 +++++++++++++
 tests/generic/430     |  83 ++++++++++++++++++++++++++++++++++++++++
 tests/generic/430.out |  15 ++++++++
 tests/generic/431     | 100 +++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/431.out |  17 +++++++++
 tests/generic/432     |  87 ++++++++++++++++++++++++++++++++++++++++++
 tests/generic/432.out |  17 +++++++++
 tests/generic/433     |  79 ++++++++++++++++++++++++++++++++++++++
 tests/generic/433.out |  14 +++++++
 tests/generic/group   |   5 +++
 12 files changed, 550 insertions(+)
 create mode 100755 tests/generic/429
 create mode 100644 tests/generic/429.out
 create mode 100755 tests/generic/430
 create mode 100644 tests/generic/430.out
 create mode 100755 tests/generic/431
 create mode 100644 tests/generic/431.out
 create mode 100755 tests/generic/432
 create mode 100644 tests/generic/432.out
 create mode 100644 tests/generic/433
 create mode 100644 tests/generic/433.out

-- 
2.12.2

