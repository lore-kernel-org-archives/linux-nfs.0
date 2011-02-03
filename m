Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53797 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755077Ab1BCS3A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Feb 2011 13:29:00 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/3] pnfs: fix pnfs lock inversion, try 2
Date: Thu,  3 Feb 2011 13:28:49 -0500
Message-Id: <1296757732-16261-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Changes from previous version:
- fix PATCH 1 to avoid introducing race in pnfs_destroy_layout with LAYOUTGET
- refactor PATCH 3 per Benny's suggestion


These fix the incorrect lock order used throughout the pnfs code. We
first simplify the logic (and in the process squash a few bugs), then
rearrange the code so we never have to take both i_lock and cl_lock
simultaneously.

Fred

