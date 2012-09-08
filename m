Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 5350504D.static.ziggozakelijk.nl ([83.80.80.77]:29831 "EHLO
	ns2.tasking.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754593Ab2IHTcY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 8 Sep 2012 15:32:24 -0400
Received: from leonino.tasking.nl (nl-fg300a-1-dmz.tasking.nl [172.16.1.8])
	by ns2.tasking.nl (8.14.5/8.14.5) with ESMTP id q88JWMM9029787
	(version=TLSv1/SSLv3 cipher=DHE-DSS-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Sat, 8 Sep 2012 21:32:22 +0200 (MEST)
Received: from lahti.tasking.nl (lahti.tasking.nl [172.17.2.45])
	by leonino.tasking.nl (8.14.5/8.14.5) with ESMTP id q88JWLhG014523
	for <linux-nfs@vger.kernel.org>; Sat, 8 Sep 2012 21:32:22 +0200 (MEST)
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0
Reply-To: dick.streefland@altium.nl (Dick Streefland)
References: <20120302184918.GA20702@hostway.ca> <loom.20120905T093214-245@post.gmane.org> <loom.20120905T093214-245@post.gmane.org> <4FA345DA4F4AE44899BD2B03EEEC2FA908F86381@SACEXCMBX04-PRD.hq.netapp.com> <6cb9.5049fd40.b47c1@altium.nl> <6cb9.5049fd40.b47c1@altium.nl> <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E302@SACEXCMBX04-PRD.hq.netapp.com> <447c.504a05c9.dd0a9@altium.nl> <447c.504a05c9.dd0a9@altium.nl> <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E833@SACEXCMBX04-PRD.hq.netapp.com>
From: dick.streefland@altium.nl (Dick Streefland)
Subject: Re: [3.2.5] NFSv3 CLOSE_WAIT hang
Content-Type: text/plain; charset=us-ascii
Message-ID: <74c7.504b9d45.a5956@altium.nl>
Date: Sat, 08 Sep 2012 19:32:21 -0000
From: rnews@altium.nl
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
| Yes. Can you please see if the following patch fixes the UDP hang?
| 
| 8<---------------------------------------------------------------------
| From f39c1bfb5a03e2d255451bff05be0d7255298fa4 Mon Sep 17 00:00:00 2001
| From: Trond Myklebust <Trond.Myklebust@netapp.com>
| Date: Fri, 7 Sep 2012 11:08:50 -0400
| Subject: [PATCH] SUNRPC: Fix a UDP transport regression
| 
| Commit 43cedbf0e8dfb9c5610eb7985d5f21263e313802 (SUNRPC: Ensure that
| we grab the XPRT_LOCK before calling xprt_alloc_slot) is causing
| hangs in the case of NFS over UDP mounts.
| 
| Since neither the UDP or the RDMA transport mechanism use dynamic slot
| allocation, we can skip grabbing the socket lock for those transports.
| Add a new rpc_xprt_op to allow switching between the TCP and UDP/RDMA
| case.
| 
| Note that the NFSv4.1 back channel assigns the slot directly
| through rpc_run_bc_task, so we can ignore that case.
| 
| Reported-by: Dick Streefland <dick.streefland@altium.nl>
| Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
| Cc: stable@vger.kernel.org [>= 3.1]

This patch appears to fix the issue for me. I cannot reproduce the
hang anymore.

-- 
Dick

