Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:38151 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932106AbbDHQrc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2015 12:47:32 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <steved@redhat.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH 0/2] Mountstats Fixes
Date: Wed, 8 Apr 2015 12:47:25 -0400
Message-ID: <1428511647-14920-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I had some trouble using mountstats to analyze READ_PLUS operations, so I
wrote these patches to fix my issues.

I found that /proc/self/mountstats was reporting "GETDEVICELIST" as "51",
most likely because it was removed from the client but the nfs4_procedures
array still has a placeholder for it.  Mountstats crashes when it tries to
analyze "51", so the second patch fixes this issue by looking for numeric
operation names.  I'm willing to put in stubs for GETDEVICELIST back into
the client if that would be a better fix.

Thanks,
Anna


Anna Schumaker (2):
  mountstats: Resync NFSv4 Operations List
  mountstats: Only count operations that have names

 tools/mountstats/mountstats.py | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

-- 
2.3.5

