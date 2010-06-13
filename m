Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27832 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754378Ab0FMUSv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jun 2010 16:18:51 -0400
Received: from localhost.localdomain (kellyv2-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5DKIkfb012997
	for <linux-nfs@vger.kernel.org>; Sun, 13 Jun 2010 13:18:47 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/4]: Fix EAGAIN handling for the filelayout
Date: Sun, 13 Jun 2010 16:18:38 -0400
Message-Id: <1276460322-13873-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These patches remove pnfs_call_done and all the routines associated with it.
They were quite buggy for filelayout, and tended to crash the client anytime
EAGAIN handling was invoked (in particular on short reads.)

The first patch just has filelayout avoid using them entirely. It should NOT
be reverted in the post-submit.

The subsequent patches remove the unused code for pnfs-submit. It is
expected they will be reverted in the post-submit.

Fred

