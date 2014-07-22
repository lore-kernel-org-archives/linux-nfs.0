Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:46002 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752536AbaGVSOt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 14:14:49 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: <linux-rdma@vger.kernel.org>
Cc: <linux-nfs@vger.kernel.org>, "'Shirley Ma'" <shirley.ma@oracle.com>,
        "'Chuck Lever'" <chuck.lever@oracle.com>,
        "'Veeresh U. Kokatnur'" <veereshuk@chelsio.com>,
        "'Indranil Choudhury'" <indranil@chelsio.com>
Subject: NFSRDMA test branch update to 3.16-rc6
Date: Tue, 22 Jul 2014 13:14:52 -0500
Message-ID: <006601cfa5d8$d5331f10$7f995d30$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 Hey all,
 
 I've updated the for-test branch of git://git.linux-nfs.org/projects/swise/linux.git.  It
is based on tag v3.16-rc6 and has these additional patches including v4 of Chuck's client
series:

[swise@build linux]$ git shortlog v3.16-rc6.. stevo-nfs/for-test
Chuck Lever (23):
      xprtrdma: Fix panic in rpcrdma_register_frmr_external()
      xprtrdma: Protect ia->ri_id when unmapping/invalidating MRs
      xprtrdma: Limit data payload size for ALLPHYSICAL
      xprtrdma: Update rkeys after transport reconnect
      xprtrdma: On disconnect, don't ignore pending CQEs
      xprtrdma: Don't invalidate FRMRs if registration fails
      xprtrdma: Unclutter struct rpcrdma_mr_seg
      xprtrdma: Back off rkey when FAST_REG_MR fails
      xprtrdma: Chain together all MWs in same buffer pool
      xprtrdma: Properly handle exhaustion of the rb_mws list
      xprtrdma: Reset FRMRs when FAST_REG_MR is flushed by a disconnect
      xprtrdma: Reset FRMRs after a flushed LOCAL_INV Work Request
      xprtrdma: Don't post a LOCAL_INV in rpcrdma_register_frmr_external()
      xprtrdma: Disable completions for FAST_REG_MR Work Requests
      xprtrdma: Disable completions for LOCAL_INV Work Requests
      xprtrdma: Rename frmr_wr
      xprtrdma: Allocate each struct rpcrdma_mw separately
      xprtrdma: Schedule reply tasklet once per upcall
      xprtrdma: Make rpcrdma_ep_disconnect() return void
      xprtrdma: Remove RPCRDMA_PERSISTENT_REGISTRATION macro
      xprtrdma: Handle additional connection events
      [v2,1/2] svcrdma: Increase credit limit to 32
      [v2,2/2] svcrdma: Add zero padding if the client doesn't send it

Steve Wise (1):
      svcrdma: send_write() must not overflow the device's max sge


