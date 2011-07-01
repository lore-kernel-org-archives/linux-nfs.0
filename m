Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34567 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921Ab1GATuD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jul 2011 15:50:03 -0400
Message-ID: <4E0E24EA.20300@candelatech.com>
Date: Fri, 01 Jul 2011 12:50:02 -0700
From: Ben Greear <greearb@candelatech.com>
To: netdev <netdev@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: another sunrpc locking question
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


It seems that the rpc_shutdown_client logic grabs
a clnt->cl_lock lock, and then in the rpc_exit logic it
writes to the task->tk_action.

But, I don't see anything keeping that from racing with
the __rpc_execute() logic, which might also be modifying
the task object without any locks held.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

