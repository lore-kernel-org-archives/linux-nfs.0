From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/7] Remaining rpcbind patches for 2.6.27
Date: Mon, 30 Jun 2008 18:38:35 -0400
Message-ID: <20080630223646.24534.74654.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:11394 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764348AbYF3Wj4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 18:39:56 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Seven patches that implement kernel RPC service registration via rpcbind v4.
This allows the kernel to advertise IPv4-only services on hosts with IPv6
addresses, for example.

---

Chuck Lever (7):
      SUNRPC: Support registering IPv6 interfaces with local rpcbind daemon
      SUNRPC: Quickly detect missing portmapper during RPC service registration
      SUNRPC: introduce new rpc_task flag that fails requests on xprt disconnect
      SUNRPC: Refactor rpcb_register to make rpcbindv4 support easier
      SUNRPC: None of rpcb_create's callers wants a privileged source port
      SUNRPC: Introduce a specific rpcb_create for contacting localhost
      SUNRPC: Use correct XDR encoding procedure for rpcbind SET/UNSET


 include/linux/sunrpc/clnt.h  |    3 
 include/linux/sunrpc/sched.h |    2 
 net/sunrpc/clnt.c            |    2 
 net/sunrpc/rpcb_clnt.c       |  290 +++++++++++++++++++++++++++++++++++++-----
 4 files changed, 263 insertions(+), 34 deletions(-)

-- 
Chuck Lever
chu ckl eve rat ora cle dot com
