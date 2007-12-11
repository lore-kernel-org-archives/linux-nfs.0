From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 00/38] svc: SVC Transport Switch
Date: Tue, 11 Dec 2007 17:31:50 -0600
Message-ID: <20071211233150.15718.40579.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:35337 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753147AbXLKXbu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 18:31:50 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The Server Side Transport switch implements a pluggable transport
provider layer for RPC servers. This switch allows network transport
drivers to be dynamically loaded and registered, thereby extending the
set of transports that can carry RPC. This patchset includes a
transport provider driver for TCP and UDP sockets.

This version of the patchset includes the following updates to the
original patch series:

- Changed transport hdr len fields and computations to use size_t

- Matched local variables to sign of socket specific write-space
  functions in xpo_wspace transport functions.

- Modified tcp_has_wspace function to include min_wspace consideration

- Changed address length functions to size_t

- Changed port helper function return types to unsigned short

- Changed error return from svc_addr_len to EAFNOSUPPORT from ENOTSUPP

- When modifying function prototypes or adding new functions adhered
  to convention of keeping signature on a single line.

- Removed debug printk from svc_send

- Created separate patch for change that moves the call to
  svc_xprt_received to common code for the accept path

- Combined the portlist update patches into a single patch and updated
  the error codes to give more helpful perror strings when writing
  garbage to the portlist file.

This patchset is based on 2.6.24-rc5 and has been tested on V2, V3 and
V4 over the UDP, TCP and RDMA transports.

-- 
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
