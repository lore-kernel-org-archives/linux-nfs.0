From: andros@netapp.com
Subject: [PATCH 0/2] nfs41 Fix session reset deadlocks Version 2
Date: Wed, 11 Nov 2009 17:47:16 -0500
Message-ID: <1257979638-2444-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22486 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751969AbZKLOiS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Nov 2009 09:38:18 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Fix session reset deadlocks Version 2.

These patches apply to tronds nfs-2.6 bugfix
branch (2.6.32-rc6 on top of these two already posted patches:
nfs41-fix-multiple-free-slot-calls.patch
nfs41-fix-race-on-session-reset.patch

Fix two problems reported by Trond:

0001-nfs41-remove-nfs4_recover_session.patch

Responded to comments and moved INIT_COMPLETION() call.
0002-nfs41-fix-state-manager-deadlock-in-session-reset.patch

Testing:

CONFIG_NFS_V4_1
v41 mount: Connectathon tests passed. PyNFS testclient.py SESSIONRESET tests
and the new INJECT_ERROR_CTHON test where NFS4ERR_BADSESSION was returned
every 50th SEQUENCE operation durring a Connectathon basic test run. This passed
with the session being reset 390 times from a variety of client compounds
(READ/WRITE/COMMIT/OPEN/CLOSE/ to name a few).

v4 mount: Connectathon tests passed.

no CONFIG_NFS_V4_1
v4 mount: Connectathon tests passed.

-->Andy


