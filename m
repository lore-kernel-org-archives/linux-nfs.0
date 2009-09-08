From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] support "-t nfs -o vers=4" [take 3]
Date: Tue, 08 Sep 2009 17:02:39 -0400
Message-ID: <20090908210012.3326.57767.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:24954 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbZIHVE3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2009 17:04:29 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

These changes accompany kernel support for "-t nfs -o vers=4".

One patch description was clarified, and a bug was fixed in the last
patch of this series.

---

Chuck Lever (3):
      mount.nfs: Detect "-t nfs -o vers=4" mounts
      umount.nfs: Skip UMNT call for "-t nfs -o vers=4" mounts
      mount.nfs: Support "vers=4" in nfs_nfs_version()


 utils/mount/network.c   |   14 +++++++++-----
 utils/mount/network.h   |    1 +
 utils/mount/nfsumount.c |    4 ++++
 utils/mount/stropts.c   |   10 ++++++++--
 4 files changed, 22 insertions(+), 7 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
