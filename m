From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Support for IPv6 in the showmount command
Date: Tue, 18 Nov 2008 14:29:28 -0500
Message-ID: <20081118192711.22516.2801.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:50920 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbYKRTbG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Nov 2008 14:31:06 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

These patches implement support for rpcbind v3/v4 queries and IPv6 NFS
servers in the showmount command.  Please consider these for the next
release of nfs-utils.

Thanks!

---

Chuck Lever (4):
      showmount command: support querying IPv6 servers
      showmount command: move logic to acquire RPC client handle out of main()
      showmount command: Remove unused local getport() implementation
      showmount command: call nfs_getport instead of local getport


 utils/showmount/showmount.c |  237 +++++++++++++++++--------------------------
 1 files changed, 91 insertions(+), 146 deletions(-)

-- 
Chuck Lever
