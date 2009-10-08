From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Two minor bug fixes
Date: Thu, 08 Oct 2009 13:36:54 -0400
Message-ID: <20091008173520.12619.10662.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:21762 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755700AbZJHRjI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Oct 2009 13:39:08 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Please consider the following two patches for nfs-utils.

---

Chuck Lever (2):
      mount.nfs: Assume v2/v3 if mount-related options are present
      mount: ECONNREFUSED is a permanent error


 utils/mount/stropts.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
