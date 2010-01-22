From: Chuck Lever <chuck.lever@oracle.com>
Subject: [RFC] [PATCH 0/4] Protocol family negotiation in mount.nfs
Date: Fri, 22 Jan 2010 16:06:12 -0500
Message-ID: <20100122210221.10598.84522.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: jlayton@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:54191 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453Ab0AVVG7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jan 2010 16:06:59 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff-

For the record, here are patches that add support to mount.nfs for
negotiating the protocol family correctly with servers that have both
IPv4 and IPv6 addresses.

I've done some basic testing here against Solaris NFS servers, Linux
with rpcbind (Fedora 12), and Linux with portmap (Ubuntu 9.10).

---

Chuck Lever (4):
      text-based mount: Support protocol family negotiation
      text-based mount: Set addr= option in nfs_try_mount_foo()
      text-based mount: Replace nfs_lookup() with getaddrinfo(3)
      text-based mount: Retry when server can't be reached


 utils/mount/nfs.man   |    6 ++
 utils/mount/stropts.c |  120 ++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 107 insertions(+), 19 deletions(-)

-- 
chuck[dot]lever[at]oracle[dot]com
