From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] Initial set of 2.6.27 patches, take 2
Date: Tue, 20 May 2008 16:29:17 -0400
Message-ID: <20080520202108.3851.7464.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:44499 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759138AbYETU3k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 May 2008 16:29:40 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Resending the first batch of 2.6.27 patches, with fixes.  The trailing
whitespace in fs/Kconfig has been removed, and the rpc_show_task() changes
place all output data on a single line for each task.  Patch descriptions have
been expanded to provide sample output.

---

Chuck Lever (8):
      SUNRPC: Display symbolic function addresses in rpc_show_tasks
      SUNRPC: Rename "call_" functions that are no longer FSM states
      SUNRPC: Display some debugging information as text rather than numbers
      SUNRPC: Refactor rpc_show_tasks
      SUNRPC: Don't display the rpc_show_tasks header if there are no tasks
      SUNRPC: Use RPC procedure name in call_verify
      SUNRPC: Use RPC procedure name in call_start
      NFS: Update help text for CONFIG_NFS_FS


 fs/Kconfig                   |  115 ++++++++++++++++-----------------
 include/linux/sunrpc/sched.h |    1 
 net/sunrpc/clnt.c            |  147 +++++++++++++++++++++++++++---------------
 net/sunrpc/sched.c           |    2 -
 4 files changed, 153 insertions(+), 112 deletions(-)

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
