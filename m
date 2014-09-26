Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:53897 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755164AbaIZOA3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2014 10:00:29 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: blocklayout GETDEVICEINFO fix
Date: Fri, 26 Sep 2014 16:02:49 +0200
Message-Id: <1411740170-18611-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpc_pipefs pattern used for the GETDEVICEINFO implementation in the
blocklayout driver is fundamentally not thread safe.  Workloads like
dbench manage to trigger concurrent GETDEVICEINFO calls though, so we
need to add a critical section around it.

I also wonder if we should avoid even sending multiple GETDEVICEINFO
a a higher level in the NFS client, as ѕending multiple request just
to cancel out their action before adding them to the cache doesn't
seem very helpful.

