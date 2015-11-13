Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33430 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbbKMJWy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Nov 2015 04:22:54 -0500
Received: from hch by bombadil.infradead.org with local (Exim 4.80.1 #2 (Red Hat Linux))
	id 1ZxAZK-0001hb-Go
	for linux-nfs@vger.kernel.org; Fri, 13 Nov 2015 09:22:54 +0000
Date: Fri, 13 Nov 2015 01:22:54 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: lock reclaim failed!
Message-ID: <20151113092254.GA5047@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I see the following running xfstestst on latest Linus' tree against
as sever from the same tree:

generic/089	[ 2000.358405] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
[ 2001.769939] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
[ 2001.770732] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
[ 2122.608136] NFS: nfs4_reclaim_open_state: Lock reclaim failed!

