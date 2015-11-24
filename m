Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:50277 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752992AbbKXS3p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2015 13:29:45 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH Version 2 0/2] Adding to tracepoints
Date: Tue, 24 Nov 2015 13:29:40 -0500
Message-ID: <1448389782-99578-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

First patch adds stateid information to tracepoints (openstateid, delegation 
stateid, and locking stateid). Version 2 of this patch fixes two things from 
the previous version: (1) typo in printout missing ":" in one stateid, (2)
close tracepoint should take stateid from the args instead of the state passed
in as state's stateid could be delegation stateid.

Second patch adds a new tracepoint nfs_cached_open() 

Olga Kornievskaia (2):
  Adding stateid information to tracepoints
  Adding tracepoint to cached open

 fs/nfs/internal.h  |   9 ++
 fs/nfs/nfs4proc.c  |  15 +--
 fs/nfs/nfs4trace.h | 294 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 286 insertions(+), 32 deletions(-)

-- 
1.8.3.1

