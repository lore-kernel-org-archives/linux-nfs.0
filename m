From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] nfs(5) updates
Date: Tue, 23 Sep 2008 12:16:14 -0400
Message-ID: <20080923161322.5119.20872.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:28399 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbYIWQSt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2008 12:18:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Here are a couple of updates to nfs(5) that relate to the use of the
NFS client's transport protocol mount options.  They attempt to
address recent concerns about how these options are documented.

Please consider these for the next release of nfs-utils.

---

Chuck Lever (2):
      nfs(5): Clarify behavior of the mountproto= and proto= options
      nfs(5): Replace the term "netid" in mount option descriptions


 utils/mount/nfs.man |   93 ++++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 87 insertions(+), 6 deletions(-)

-- 
Chuck Lever
