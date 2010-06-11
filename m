Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32582 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751628Ab0FKHkx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:40:53 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7eoVa027834
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:40:52 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/7] LAYOUTGET invocation cleanup patches
Date: Fri, 11 Jun 2010 03:40:32 -0400
Message-Id: <1276242039-18649-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These patches, applied to the head of pnfs-all-latest after rebase, bring
the blocklayout back in synch with the generic code changed by my previous
patches and the rebase.  The final tree containing the fully rebased tree
with these patches applied is at
git://linux-nfs.org/~isaman/pnfs-block.git in the branch for-benny-20100611.

Fred

