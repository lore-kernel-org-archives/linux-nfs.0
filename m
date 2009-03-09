From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Non-IPv6 related client patches for 2.6.30
Date: Mon, 09 Mar 2009 14:20:17 -0400
Message-ID: <20090309181917.14860.88916.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:53049 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbZCISU7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Mar 2009 14:20:59 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Here are my non-IPv6 related patches for 2.6.30.  One of these you may
already have.

---

Chuck Lever (2):
      NFS: Do not display the setting of the "intr" mount option
      SUNRPC: Avoid spurious wake-up during UDP connect processing


 fs/nfs/super.c        |    1 -
 net/sunrpc/xprtsock.c |   45 +++++++++++++++++++++++++++------------------
 2 files changed, 27 insertions(+), 19 deletions(-)

-- 
Chuck Lever
