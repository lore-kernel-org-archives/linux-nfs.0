Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31966 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755048Ab0EEDH5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 May 2010 23:07:57 -0400
Received: from localhost.localdomain (makada1-lxp.hq.netapp.com [10.58.60.192] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4537cgW024006
	for <linux-nfs@vger.kernel.org>; Tue, 4 May 2010 20:07:39 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/8]: pnfs_submit: removal of fsdata manipulation 
Date: Sun,  2 May 2010 21:00:41 -0400
Message-Id: <1272848449-19170-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These revert patches in the submit branch in order to remove the fsdata manipulation needed by the block driver, followed immediately by the post-submit "un-reverts".

They apply on top of the 13 patches Andy previously sent.

Fred

