From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Two short pieces for nfs-utils
Date: Mon, 26 Oct 2009 17:03:11 -0400
Message-ID: <20091026210110.14346.90636.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:21520 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721AbZJZVD3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Oct 2009 17:03:29 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Here are two bug fixes for recent commits to nfs-utils.  The
nfs_set_version fix was revised based on review comments.

---

Chuck Lever (2):
      mount: Fix po_join() call site in nfs_try_mount_v4()
      mount.nfs: Assume v2/v3 if mount-related options are present


 utils/mount/stropts.c |   55 +++++++++++++++++++++++++++++++++++--------------
 1 files changed, 39 insertions(+), 16 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
