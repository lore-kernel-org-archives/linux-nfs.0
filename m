Return-Path: linux-nfs-owner@vger.kernel.org
Received: from edge3.cs.stonybrook.edu ([130.245.9.168]:16408 "EHLO
	edge3.cs.stonybrook.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729AbaAIVbg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jan 2014 16:31:36 -0500
From: Ming Chen <mchen@cs.stonybrook.edu>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "Erez Zadok" <ezk@fsl.cs.sunysb.edu>,
        "dhildeb@us.ibm.com" <dhildeb@us.ibm.com>,
        "geoff@cs.hmc.edu" <geoff@cs.hmc.edu>
Subject: [PATCH] nfsd: consider CLAIM_FH when handing out delegation
Date: Thu, 9 Jan 2014 21:26:10 +0000
Message-ID: <F2EEB2C045C93A4889A2C09F59EDB20858153672@mail2.cs.stonybrook.edu>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CLAIM_FH was added by NFSv4.1.  It is the same as CLAIM_NULL except that it
uses only current FH to identify the file to be opened.

The NFS client is using CLAIM_FH if the FH is available when opening a file.
Currently, we cannot get any delegation if we stat a file before open it
because the server delegation code does not recognize CLAIM_FH.

We tested this patch and found delegation can be handed out now when claim is
CLAIM_FH.

See http://marc.info/?l=linux-nfs&m=136369847801388&w=2 and
http://www.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues#New_open_claim_types

Signed-off-by: Ming Chen <mchen@cs.stonybrook.edu>
---
 fs/nfsd/nfs4state.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 105d6fa..514d9c2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3125,6 +3125,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 				goto out_no_deleg;
 			break;
 		case NFS4_OPEN_CLAIM_NULL:
+		case NFS4_OPEN_CLAIM_FH:
 			/*
 			 * Let's not give out any delegations till everyone's
 			 * had the chance to reclaim theirs....
-- 
1.7.1