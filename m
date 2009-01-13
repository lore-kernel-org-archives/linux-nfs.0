From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] Detect user space support for rpcbind v4
Date: Tue, 13 Jan 2009 12:31:33 -0500
Message-ID: <20090113172538.6755.83766.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:59240 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857AbZAMRb6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2009 12:31:58 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Here's what I'm considering.

If the kernel detects that user space doesn't support rpcbind protocol
version 4, it falls back to version 2.  If it is trying to register an
IPv6 RPC service, it fails outright.

All of this can be disabled completely in favor of legacy behavior by
disabling CONFIG_SUNRPC_REGISTER_V4.

In addition, I will add CONFIG options to enable/disable lockd and NFSD
listening on IPv6 sockets, to prevent all this noise for anyone using
classic IPv4-only.  These will appear only if CONFIG_SUNRPC_REGISTER_V4
is enabled.

I haven't yet pursued why the kernel doesn't report the program version
mismatch to higher layers.  That will be needed to make these changes
work correctly.

These patches have been compile-tested only.

---

Chuck Lever (3):
      SUNRPC: Clearer error message when user space is running portmap
      SUNRPC: Clearer error message when user space is running portmap
      SUNRPC: Don't use EPROTONOSUPPORT in svc_register()


 net/sunrpc/svc.c |   99 ++++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 84 insertions(+), 15 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
