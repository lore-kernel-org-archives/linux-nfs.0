From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] First set of 2.6.27 patches
Date: Sat, 17 May 2008 22:16:06 -0400
Message-ID: <20080518021241.8366.12464.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:47907 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbYERCam (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 May 2008 22:30:42 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Here are the first eight patches I'd like you to consider for 2.6.27.  The
Kconfig patch was part of the Kconfig clean-up series included in 2.6.26,
but was somehow missed.

The SUNRPC patches add some enhancements to RPC debugging.

---

Chuck Lever (8):
      SUNRPC: Display symbolic function addresses in rpc_show_tasks
      SUNRPC: Rename "call_" functions that are no longer FSM states
      SUNRPC: Add second output line for each RPC task in rpc_show_tasks
      SUNRPC: Refactor rpc_show_tasks
      SUNRPC: Don't display the rpc_show_tasks header if there are no tasks
      SUNRPC: Use RPC procedure name in call_verify
      SUNRPC: Use RPC procedure name in call_start
      NFS: Update help text for CONFIG_NFS_FS


 fs/Kconfig                   |  115 ++++++++++++++++----------------
 include/linux/sunrpc/sched.h |    1 
 net/sunrpc/clnt.c            |  150 +++++++++++++++++++++++++++---------------
 net/sunrpc/sched.c           |    2 -
 4 files changed, 156 insertions(+), 112 deletions(-)

-- 
Chuck Lever
