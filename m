Return-Path: linux-nfs-owner@vger.kernel.org
Received: from linode.aoot.com ([69.164.194.13]:32920 "EHLO linode.aoot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750990AbaGOVEh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 17:04:37 -0400
Message-ID: <53C59320.70904@opengridcomputing.com>
Date: Tue, 15 Jul 2014 15:46:24 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        "Veeresh U. Kokatnur" <veereshuk@chelsio.com>
Subject: Re: [PATCH v2 0/2] NFS/RDMA server patches for 3.17
References: <20140715175144.3448.48674.stgit@klimt.1015granger.net>
In-Reply-To: <20140715175144.3448.48674.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/15/2014 12:54 PM, Chuck Lever wrote:
> Hi Steve-
>
> Can you include these 3.17 candidate patches in your testing branch?
>
> v2:
>
> - Second patch replaced with a lower-level fix
>

Done.

The for-test branch of git://git.linux-nfs.org/projects/swise/linux.git 
is now based on 3.16-rc5 plus:

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

Hariprasad S (2):
       iw_cxgb4: Fix skb_leak in reject_cr
       iw_cxgb4: clean up connection on arp error

Steve Wise (3):
       iw_cxgb4: call iwpm_init() only once
       iw_cxgb4: initialize the device status page
       svcrdma: send_write() must not overflow the device's max sge

