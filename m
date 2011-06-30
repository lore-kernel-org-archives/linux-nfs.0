Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53402 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514Ab1F3W5Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jun 2011 18:57:24 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p5UMvNDL009283
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 15:57:23 -0700
Message-ID: <4E0CFF53.3090503@candelatech.com>
Date: Thu, 30 Jun 2011 15:57:23 -0700
From: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Subject: Questionable comment for rpc_execute()
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The comment below says that task is guaranteed to be freed,
but that appears only true for non-async tasks.

Also, should we lock task->tk_waitqueue before calling rpc_make_runnable
(at least for async tasks)?  I'm basing this question on comments for
rpc_make_runnable claiming to need the spinlock held for the wait-queue
for async tasks.

/*
  * User-visible entry point to the scheduler.
  *
  * This may be called recursively if e.g. an async NFS task updates
  * the attributes and finds that dirty pages must be flushed.
  * NOTE: Upon exit of this function the task is guaranteed to be
  *	 released. In particular note that tk_release() will have
  *	 been called, so your task memory may have been freed.
  */
void rpc_execute(struct rpc_task *task)
{
	rpc_set_active(task);
	rpc_make_runnable(task);
	if (!RPC_IS_ASYNC(task))
		__rpc_execute(task);
}

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

