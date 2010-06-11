Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17848 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753432Ab0FKHgs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:36:48 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7akmO026274
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:36:47 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] LAYUOTGET invocation rebasing
Date: Fri, 11 Jun 2010 03:35:48 -0400
Message-Id: <1276241751-18180-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

I have published pnfs-all-latest rebased atop my submitted patches at
git://linux-nfs.org/~isaman/pnfs-block.git in the branch for-benny-20100611.

(Actually, I am uploading now...it is going very slowly.)

These three patches changed significantly in the rebase, so I include them
here for review.  (Two others nearby vanished entirely.) The basic idea is
that fsdata->ok_to_use_pnfs and PG_USE_PNFS can be replaced by checking
req->wb_lseg==NULL.

The rebase leaves the blocklayout directory untouched.  I've fixed that up
with some straightforward SQUASHME patches to come.

Fred

