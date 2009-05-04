From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] More missing ipv6.ko nits
Date: Mon, 04 May 2009 13:01:17 -0400
Message-ID: <20090504165839.2733.50787.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:27968 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238AbZEDRB1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2009 13:01:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

These patches address a few minor problems with how the NFS client behaves in
the absence of ipv6.ko.  One of these problems was introduced in 2.6.30-rc,
and thus should be considered for upstream now.  The other is a long-standing
problem (I traced it back as far as August of 2006).

---

Chuck Lever (2):
      NFS: Fix false error return from nfs_callback_up() if ipv6.ko is not available
      NFS: Return error code from nfs_callback_up() to user space


 fs/nfs/callback.c |    4 +++-
 fs/nfs/client.c   |   11 +++++++----
 2 files changed, 10 insertions(+), 5 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
