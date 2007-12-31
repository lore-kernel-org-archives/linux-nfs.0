From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 00/40] svc: SVC Transport Switch
Date: Sun, 30 Dec 2007 21:07:12 -0600
Message-ID: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41460 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751276AbXLaDHN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:07:13 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The Server Side Transport switch implements a pluggable transport
provider layer for RPC servers. This allows network transport drivers
to be dynamically loaded and registered, thereby extending the set of
transports that can carry RPC. This patchset includes a transport
provider driver for TCP and UDP sockets.

This version of the patchset is functionally equivalent to the
preceding patchset and includes the following improvements:

- Fixed a bug in svc_create_socket that resulted in svc_xprt_received
  being called without holding the XPT_BUSY bit.

- Added a BUG_ON in svc_xprt_received to catch providers calling
  svc_xprt_received without holding the XPT_BUSY bit.

- Removed code setting the XPT_BUSY bit in the create path and moved
  this logic to common code.

- Cleaned up the SMP locking strategy comment and moved it to
  svc_xprt.c

- Changed return type of svc_unreg_xprt_class to void

- Simplified transport class removal logic

- Fixed a white-space abuse issue
  
- Made some style changes to the patch comments

- Created a separate patch that moves the connection limit code to
  generic logic

- Created a separate patch that moves the call to svc_xprt_received
  out of tcp_accept and into common logic

- Created a separate patch for removal of unnecessary call to
  svc_sock_enqueue in svc_tcp_accept function

- Removed silly BUG_ON from kref svc_xprt_free callback function
  
- Moved unlock of svc_xprt_class list to after the try_module_lock
  call.

- Refactored svc_create_xprt logic

- Removed unnecessary call to svc_find_xprt in portlist code

-- 
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
