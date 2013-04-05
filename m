Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61793 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162690Ab3DEVQj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 17:16:39 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 0/3] Fixes for the rpcsec_gss patches
Date: Fri,  5 Apr 2013 17:16:33 -0400
Message-Id: <1365196596-25439-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patches address issues that were found in connection with the
patch "NFS: Use "krb5i" to establish NFSv4 state whenever possible"

Again, thanks to Bryan for testing...

Trond Myklebust (3):
  NFSv4: Fix the fallback to AUTH_NULL if krb5i is not available
  NFSv4: Fix issues in nfs4_discover_server_trunking
  NFSv4: Don't clear the machine cred when client establish returns
    EACCES

 fs/nfs/nfs4client.c |  2 ++
 fs/nfs/nfs4state.c  | 23 ++++++-----------------
 2 files changed, 8 insertions(+), 17 deletions(-)

-- 
1.8.1.4

