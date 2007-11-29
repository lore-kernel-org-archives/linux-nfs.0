From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 0/8] RDMA Transport Provider
Date: Thu, 29 Nov 2007 16:44:12 -0600
Message-ID: <20071129224412.14887.14136.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields-ag9A2Eb6PFsgsBAKwltoeQ@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:48889 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933888AbXK2XDb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:03:31 -0500
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
