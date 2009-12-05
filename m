From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [Patch 0/4] RECLAIM_COMPLETE functionality
Date: Sat,  5 Dec 2009 12:20:24 -0800
Message-ID: <1260044428-16341-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13611 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756365AbZLEU0F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Dec 2009 15:26:05 -0500
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patches implement RECLAIM_COMPLETE functionality to
indicate completion of _global_ reclaims for the client.  They do
not yet implement RECLAIM_COMPLETE for file system migration.

[PATCH 1/4] Cleanup some NFSv4 XDR decode comments
[PATCH 2/4] nfs41: RECLAIM_COMPLETE XDR functionality
[PATCH 3/4] nfs41: RECLAIM_COMPLETE functionality
[PATCH 4/4] nfs41: Invoke RECLAIM_COMPLETE

A separate patch will be mailed to Bruce to integrate skeleton
functionality on the server side.  

The patches apply to Trond's master branch.  They were tested on
top of an old version of Andy's session draining patches, and
the previous state reclaim bug fix series.

- ricardo

