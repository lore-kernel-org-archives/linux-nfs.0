Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61793 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162478Ab3DEVQc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 17:16:32 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 0/2] Stable patches for NFSv4/4.1 trunking
Date: Fri,  5 Apr 2013 17:16:26 -0400
Message-Id: <1365196588-25403-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following two sets of issues for the stable kernel were found when
debugging the rpcsec_gss patches.
Thanks to Bryan for helping with testing.

Trond Myklebust (2):
  NFSv4: Fix a memory leak in nfs4_discover_server_trunking
  NFSv4/4.1: Fix bugs in nfs4[01]_walk_client_list

 fs/nfs/nfs4client.c | 44 ++++++++++++++++++++++++++++----------------
 fs/nfs/nfs4state.c  |  8 +++++++-
 2 files changed, 35 insertions(+), 17 deletions(-)

-- 
1.8.1.4

