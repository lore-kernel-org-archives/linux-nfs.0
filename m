From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 0/2] nfs-utils: nfsstat fix for 2.6.33
Date: Wed, 30 Dec 2009 16:53:53 +0200
Message-ID: <4B3B6981.8030807@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:8393 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752943AbZL3Ox4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Dec 2009 09:53:56 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve,

The first patch in this series adds reclaim_complete to the client stats.
The second one cleans up the array size definitions for nfs ops.

[PATCH 1/2] nfsstat: update cltproc4info for 2.6.33
[PATCH 2/2] nfsstat: use symbolic constants for operation array sizes

Benny
