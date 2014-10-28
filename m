Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35005 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342AbaJ1NQu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2014 09:16:50 -0400
From: Eryu Guan <eguan@redhat.com>
To: fstests@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Eryu Guan <eguan@redhat.com>
Subject: [RFC PATCH 0/4] re-enable tests that require scratch dev on NFS
Date: Tue, 28 Oct 2014 21:16:07 +0800
Message-Id: <1414502171-10319-1-git-send-email-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This commit disables tests requires scratch dev running on NFS

c041421 xfstests: stop special casing nfs and udf

Now re-enable them to get a larger test coverage on NFS.

Also do more updates to avoid unnecessary failures on NFS.

I tested against NFSv3 NFSv4.0 NFSv4.1 (both linux server and client,
with 3.18-rc1 kernel), the results look good.

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
Run the failed tests seperately and they all passed.

I'm not sure if it's a bug, but I filed one, please see
https://bugzilla.redhat.com/show_bug.cgi?id=1158046

Thanks,
Eryu

---

Eryu Guan (4):
  common: re-enable tests that require scratch dev on NFS
  common: add _require_block_device() helper
  common: skip atime related tests on NFS
  generic/277: add _require_attrs

 common/rc         | 40 ++++++++++++++++++++++++++++++++++++----
 tests/generic/003 |  1 +
 tests/generic/076 |  1 +
 tests/generic/192 |  1 +
 tests/generic/277 |  2 ++
 5 files changed, 41 insertions(+), 4 deletions(-)

-- 
1.8.3.1

