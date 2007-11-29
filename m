From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 00/38] SVC Transport Switch
Date: Thu, 29 Nov 2007 16:39:17 -0600
Message-ID: <20071129223917.14563.77633.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields-ag9A2Eb6PFsgsBAKwltoeQ@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:48896 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934111AbXK2XDi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:03:38 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series implements a pluggable transport switch for
RPC servers. This patchset is a rollup of the original
plus incremental patches.

In addition to the incremental change rollup:

- The address management logic in svc_xprt was cleaned up a
  based on feedback from Chuck Lever,

- A race was fixed whereby UDP RPC from different clients in parallel
  could corrupt each other's addresses.

- Changes were made to the sysctl implementation to comply 
  with the new 2.6.24 requirements regarding sysctl ids.

The following testing was done:

- Connectathon on V3 and V4 on TCP, UDP and RDMA mounts

- Kernel build on V3 RDMA mount.

This patchset is against the 2.6.24-rc3 kernel tree.

-- 
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
