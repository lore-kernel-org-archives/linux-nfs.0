Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33640 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754544AbbLPPP7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2015 10:15:59 -0500
From: Christoph Hellwig <hch@lst.de>
To: chuck.lever@oracle.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: small svc_rdma cleanup
Date: Wed, 16 Dec 2015 16:11:03 +0100
Message-Id: <1450278664-2133-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This makes use of the now always available local_dma_lkey, and goes on top
of Chuck's "[PATCH v4 00/11] NFS/RDMA server patches for v4.5" series.

