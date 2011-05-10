Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10421 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750704Ab1EJU03 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 May 2011 16:26:29 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: jlayton@redhat.com, linux-nfs@vger.kernel.org
Subject: [RFC V2 0/1] SUNRPC: dynamic rpc_slot allocator
Date: Tue, 10 May 2011 16:26:39 -0400
Message-Id: <1305059200-412-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Second version. Responded to comments. 
As for the first version, I would appreciate comments on this patch.

Changes:

- kmalloc instead of mempools
- same dynamic allocator used by all interested transports.
- used GFP_ATOMIC for rpc_xprt and initial slot allocation
- UDP also uses dynamic allocation, but not in response to write_space callback.
- BC_TCP slots reduced to RPC_MIN_SLOT_TABLE. (could add dynamic if so desired)

See patch comments for more description.
 
The 10G test bed is not yet configured. I did test with VMs, copying a large
file over NFSv3/v4. For tcp, started with 2 slots, ended with 7. for udp (same
file), started with 2 slots, ended with 3.

-->Andy
