From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 0/4] pnfs-submit code removal patches
Date: Thu,  8 Jul 2010 15:25:18 -0400
Message-ID: <1278617122-24164-1-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22871 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758511Ab0GHTZZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jul 2010 15:25:25 -0400
Received: from localhost.localdomain (khang-lxp.hq.netapp.com [10.58.60.105] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o68JPOdK010802
	for <linux-nfs@vger.kernel.org>; Thu, 8 Jul 2010 12:25:25 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All these patches should be immediately reverted in the post-submit branch.

The first three take advantage of the fact that we are only using
full-file layouts to remove some code.

The fourth is a repeat of a previously sent patch that seems to have
fallen throught the the cracks.

Fred

