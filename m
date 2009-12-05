From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [Patch 0/3] Reclaim State Bug Fixes
Date: Sat,  5 Dec 2009 12:11:21 -0800
Message-ID: <1260043884-16267-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46956 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757917AbZLEURB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Dec 2009 15:17:01 -0500
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following three patches fix a number of problems during state
reclaim.  They apply to Trond's master branch.

[PATCH 1/3] nfs41: Mark stateids in need of reclaim if state manager gets stale clientid
[PATCH 2/3] nfs41: Handle session errors during delegation return
[PATCH 3/3] nfs41: Retry delegation return if it failed with session error

These were tested on top of an old version of Andy's session draining
patches.

- ricardo


