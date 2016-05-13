Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:31537 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753076AbcEMUu4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 May 2016 16:50:56 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH 0/5] Add copy_file_range() tests
Date: Fri, 13 May 2016 16:50:47 -0400
Message-ID: <1463172652-22361-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These tests exercise the copy_file_range() system call, and check copying
data to both a new file and overwriting data inside an existing file.  The
first patch adds the copy_file_range() utility for using the systemcall, and
is heavily based on src/cloner.c.  The remaining patches add my tests.

Thanks,
Anna

Anna Schumaker (5):
  src/copy_file_range: Add a program for testing vfs_copy_file_range()
  generic/343: Add copy to new file test
  generic/344: Add small copies to new file test
  generic/345: Add copy test that overwrites data
  generic/346: Add a copy test for overwriting small amounts of data

 .gitignore            |   1 +
 common/rc             |   7 ++
 src/Makefile          |   3 +-
 src/copy_file_range.c | 189 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/343     |  96 +++++++++++++++++++++++++
 tests/generic/343.out |  17 +++++
 tests/generic/344     |  86 +++++++++++++++++++++++
 tests/generic/344.out |  13 ++++
 tests/generic/345     | 107 ++++++++++++++++++++++++++++
 tests/generic/345.out |  17 +++++
 tests/generic/346     |  94 +++++++++++++++++++++++++
 tests/generic/346.out |  17 +++++
 tests/generic/group   |   4 ++
 13 files changed, 650 insertions(+), 1 deletion(-)
 create mode 100644 src/copy_file_range.c
 create mode 100644 tests/generic/343
 create mode 100644 tests/generic/343.out
 create mode 100644 tests/generic/344
 create mode 100644 tests/generic/344.out
 create mode 100644 tests/generic/345
 create mode 100644 tests/generic/345.out
 create mode 100644 tests/generic/346
 create mode 100644 tests/generic/346.out

-- 
2.8.2

