From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] Three short patches for 2.6.31
Date: Fri, 15 May 2009 11:32:46 -0400
Message-ID: <20090515153111.17053.3822.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:39391 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbZEOPdG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 May 2009 11:33:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Please consider these for 2.6.31.

---

Chuck Lever (3):
      SUNRPC: Use AUTH_NULL for GETPORT/GETADDR requests
      lockd: Don't bother with RPC ping for NSM upcalls
      lockd: Update NSM state from SM_MON replies


 fs/lockd/clntproc.c         |    2 +-
 fs/lockd/mon.c              |   19 +++++++++++++------
 include/linux/lockd/lockd.h |    2 +-
 net/sunrpc/rpcb_clnt.c      |    4 ++--
 4 files changed, 17 insertions(+), 10 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
