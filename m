Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57767 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322Ab1F3VI6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jun 2011 17:08:58 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p5UL8vnH001059
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 14:08:57 -0700
Message-ID: <4E0CE5E9.2090401@candelatech.com>
Date: Thu, 30 Jun 2011 14:08:57 -0700
From: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Subject: Potential locking issue in sunrpc
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This method in sched.c says we should have a lock for ASYNC

/*
  * Make an RPC task runnable.
  *
  * Note: If the task is ASYNC, this must be called with
  * the spinlock held to protect the wait queue operation.
  */
static void rpc_make_runnable(struct rpc_task *task)

However, I don't think the lock is being taken for
the call path starting with rpcb_call_async in
rpcb_clnt.c:

rpcb_call_async
rpc_run_task
rpc_execute
rpc_make_runnable

Is the comment on the make_runnable method wrong, or are we missing locking?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

