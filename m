Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:56966 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751101AbdCQT5F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 15:57:05 -0400
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@Netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH v5 0/5] Add copy_file_range() tests
Date: Fri, 17 Mar 2017 15:52:28 -0400
Message-ID: <20170317195233.4042-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These tests exercise the copy_file_range() system call, and check copying
data to both a new file and overwriting data inside an existing file.

Sorry it took so long to get this version out.  I forgot about these patches
after the last submission.

Thanks,
Anna


Anna Schumaker (5):
  generic/416: Add copy to new file test
  generic/417: Add small copies to new file test
  generic/418: Add copy test that overwrites data
  generic/419: Add a copy test for overwriting small amounts of data
  generic/420: Add a copy test for invalid input

 common/rc             |   6 +++
 tests/generic/416     | 102 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/416.out |  26 +++++++++++++
 tests/generic/417     |  83 ++++++++++++++++++++++++++++++++++++++++
 tests/generic/417.out |  16 ++++++++
 tests/generic/418     | 100 +++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/418.out |  17 +++++++++
 tests/generic/419     |  87 ++++++++++++++++++++++++++++++++++++++++++
 tests/generic/419.out |  17 +++++++++
 tests/generic/420     |  76 +++++++++++++++++++++++++++++++++++++
 tests/generic/420.out |  12 ++++++
 tests/generic/group   |   5 +++
 12 files changed, 547 insertions(+)
 create mode 100755 tests/generic/416
 create mode 100644 tests/generic/416.out
 create mode 100755 tests/generic/417
 create mode 100644 tests/generic/417.out
 create mode 100755 tests/generic/418
 create mode 100644 tests/generic/418.out
 create mode 100755 tests/generic/419
 create mode 100644 tests/generic/419.out
 create mode 100644 tests/generic/420
 create mode 100644 tests/generic/420.out

-- 
2.12.0

