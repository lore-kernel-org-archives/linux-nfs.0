From: andros@netapp.com
Subject: [PATCH 0/2] nfs41 client session bug fixes
Date: Wed, 21 Oct 2009 14:24:50 -0400
Message-ID: <1256149492-25481-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6584 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753881AbZJUSYt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Oct 2009 14:24:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs41 client session bug fixes.  2.6.32-rc2 nfs41-all branch.

Fix multiple calls to nfs41_sequence_free_slot (Reported by Trond).
Fix a race between state manager session reset and queued rpc's calling
nfs41_setup_sequence.

0001-nfs41-fix-multiple-free-slot-calls.patch
0002-nfs41-fix-race-on-session-reset.patch

Passed connectathon tests.
Passed pynfs testclient.py SESSION reset tests.
Passed connectathon basic tests against a with modified pynfs server that
returns NFS4ERR_SEQ_MISORDERED every 50 SEQUENCE operations.

-->Andy

