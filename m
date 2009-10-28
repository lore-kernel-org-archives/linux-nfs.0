From: andros@netapp.com
Subject: [PATCH 0/2] nfs41 session bug fixes
Date: Wed, 28 Oct 2009 10:37:27 -0400
Message-ID: <1256740649-4899-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47940 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754115AbZJ1PB3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Oct 2009 11:01:29 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs41 session bug fixes. 2.6.43-rc5 tronds bugfixes branch

Fix multiple calls to nfs41_sequence_free_slot (Reported by Trond).
0001-nfs41-fix-multiple-free-slot-calls.patch

Fix a race between state manager session reset and queued RPCs calling
nfs41_setup_sequence.

0002-nfs41-fix-race-on-session-reset.patch

Passed Connectathon tests.

Passed pynfs testclient.py INJECT_ERROR_CTHON where Connectathon tests are run
against the pynfs 4.1 server configured to return a SEQUENCE error 
(NFS4ERR_SEQ_MISORDERED, NFS4ER_BADSESSION were tested) every 50th SEQUENCE
operation. The session was reset hundreds of times.

-->Andy

