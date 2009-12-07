From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 0/5] Reclaim Stage Bug Fixes Version 2
Date: Mon,  7 Dec 2009 00:21:46 -0800
Message-ID: <1260174111-23160-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759039AbZLGI1n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 03:27:43 -0500
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following five patches fix problems during state reclaim.
They incorporate Trond's comments and apply to Trond's
nfs-for-next branch.  Patches 2 and 5 handle session errors by
scheduling the state recovery.  They do not differentiate between
DEAD/BADSESSION and other session errors in order to be consistent
with the existing error handling.  If this needs to be different,
I can submit a separate patch to address all of the areas that
handle this.

Patch 4 is new in the series.  It results from the changes requested
to Patch 1.

[PATCH 1/5] nfs41: Mark stateids in need of reclaim if state manager gets stale clientid
[PATCH 2/5] nfs41: Handle session errors during delegation return
[PATCH 3/5] nfs41: Retry delegation return if it failed with session error
[PATCH 4/5] nfs41: New NFS4CLNT_RECLAIM_COMPLETE_PENDING state
[PATCH 5/5] nfs41: Handle NFSv4.1 session errors in the delegation recall code

- ricardo


