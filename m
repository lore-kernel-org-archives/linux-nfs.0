From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] 2nd IPv6 patchset for 2.6.28 (repost)
Date: Wed, 27 Aug 2008 16:56:58 -0400
Message-ID: <20080827204852.17837.38361.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:59511 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754897AbYH0U6A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2008 16:58:00 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Based on review comments, I've changed how the NFSv4 callback server
starts its listener.  If the kernel has IPv6 support, it will start an
AF_INET6 listener; otherwise it will start an AF_INET listener.

Subsequent lockd IPv6 patches already work this way, it turns out, so
I've updated the patch in this subseries that adds a helper to display
NLM IPv6 addresses.  If an IPv6 address is a mapped IPv4 address, it
will be displayed as a dotted-quad instead of as an IPv6 address.  This
should cause the helper to display IPv4-style addresses on systems that
use only IPv4, even though the listener is AF_INET6.  This effects
only error and debugging messages.

I should revisit other areas (already integrated, and in pending
patches) which display presentation format addresses, to ensure they
follow suit.

---

Chuck Lever (6):
      SUNRPC: Make svc_addr's argument a constant
      lockd: Add address family-agnostic helper for zeroing the port number
      lockd: Specify address family for source address
      lockd: address-family independent printable addresses
      NLM: Clean up before introducing new debugging messages
      NFS: Enable NFSv4 callback server to listen on AF_INET6 sockets


 fs/lockd/host.c             |  123 +++++++++++++++++++++++++++++++++----------
 fs/nfs/callback.c           |   19 +++++--
 include/linux/lockd/lockd.h |    4 +
 include/linux/sunrpc/svc.h  |    6 +-
 4 files changed, 115 insertions(+), 37 deletions(-)

-- 
Chuck Lever
