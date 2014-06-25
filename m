Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:36221 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756886AbaFYQEp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 12:04:45 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: <linux-rdma@vger.kernel.org>
Cc: <linux-nfs@vger.kernel.org>, "Shirley Ma" <shirley.ma@oracle.com>,
        "Chuck Lever" <chuck.lever@oracle.com>,
        "Veeresh U. Kokatnur" <veereshuk@chelsio.com>,
        "'Indranil Choudhury'" <indranil@chelsio.com>
Subject: NFSRDMA test branch
Date: Wed, 25 Jun 2014 11:05:12 -0500
Message-ID: <004a01cf908f$3e8a7c60$bb9f7520$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey,

Going forward, I am maintaining a git tree to be used by the various interested parties to
test the current NFSRDMA related client and server patches that are heading upstream.
The idea is to keep the current patches in a single repo that test groups can pull from.
The repo is currently backed against 3.16-rc2 and contains these patches so far:

Chuck Lever (13):
      xprtrdma: Fix panic in rpcrdma_register_frmr_external()
      xprtrdma: Protect ->qp during FRMR deregistration
      xprtrdma: Limit data payload size for ALLPHYSICAL
      xprtrdma: Update rkeys after transport reconnect
      xprtrdma: Don't drain CQs on transport disconnect
      xprtrdma: Unclutter struct rpcrdma_mr_seg
      xprtrdma: Encode Work Request opcode in wc->wr_id
      xprtrdma: Back off rkey when FAST_REG_MR fails
      xprtrdma: Refactor rpcrdma_buffer_put()
      xprtrdma: Release FRMR segment buffers during LOCAL_INV completion
      xprtrdma: Clean up rpcrdma_ep_disconnect()
      xprtrdma: Remove RPCRDMA_PERSISTENT_REGISTRATION macro
      xprtrdma: Handle additional connection events

Steve Wise (1):
      iw_cxgb4: call iwpm_init() only once

If you have critical patches that you would like included, please point me at them.  I
request that the patches be only fixes that allow forward testing progress, critical
regression fixes, or fixes that are heading upstream and are NFSRDMA related.  As patches
under review change, I'll update my git tree and send up notifications when it changes.

The branch is named for-test and the repo is at: 

git://git.linux-nfs.org/projects/swise/linux.git

Thanks,

Steve.

