Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:35002 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755743Ab2GaLCe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jul 2012 07:02:34 -0400
Message-ID: <5017BB46.6080203@parallels.com>
Date: Tue, 31 Jul 2012 15:02:30 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: SUNRPC lients: Pipefs mount races
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Trond.
I found one more race in SUNRPC PipeFS mount notification and clients creation.
Now the problem is in SUNRPC clients.
Races are shown below:

CPU#0						CPU#1
------------------------------------		--------------------------------
nfs_create_rpc_client
   rpc_create
   rpc_new_client
   rpc_setup_pipedir	(no sb)
						rpc_mount
						notifier_call(SUNRPC - clnt.c)
   rpc_register_client
nfs_idmap_new
nfs_mark_client_ready(NFS_CS_READY)
						notifier_call(NFS - idmap.c)
						__rpc_pipefs_event
						BUG_ON(cl_dentry == NULL)

How would you prefer to fix this?
Looks like we could either try to add SUNRPC client to the list before PipeFS 
dentry creation or create the dentry for SUNRPC client from NFS code in 
__rpc_pipefs_event() instead of BUG_ON.

-- 
Best regards,
Stanislav Kinsbursky
