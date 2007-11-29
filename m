From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 00/38] RPC Transport Switch
Date: Thu, 29 Nov 2007 16:55:10 -0600
Message-ID: <20071129225510.15275.82660.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:47417 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762916AbXK2XUM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:20:12 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset implements the RDMA Transport Driver for the 
SVC Transport Switch. This patchset has been tested with iozone
and Connectathon over NFS v3.

This patchset is against 2.6.24-rc3.

This patchset along with the SVC transport switch and client
side marshalling fix are also available in this git tree:

git://linux-nfs.org/~tomtucker/nfs-rdma-dev-2.6.git

-- 
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
