From: Chuck Lever <chuck.lever@oracle.com>
Subject: Comments on some of the work in NFS_ALL for 2.6.25
Date: Mon, 14 Jan 2008 17:47:58 -0500
Message-ID: <1F8E054F-E33A-4441-944F-84E64233436A@oracle.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62805 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666AbYANWtu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jan 2008 17:49:50 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

A couple of initial comments on the RPC client API cleanups in the  
latest NFS_ALL.

First, I'm a little uncomfortable with the new rpc_call_start()  
function.  Seems like that's a detail for the RPC client to manage,  
not the ULPs (nor the developers of ULPs who want to use the RPC  
client).  I think it would be cleaner (and less error prone) if the  
RPC client set up tk_action entirely automatically rather than  
requiring ULPs to know when to invoke rpc_call_start().

Second, I see that you have created a new rpc_run_task() function  
that replaces rpc_init_task + rpc_execute.  It manages the signal  
mask appropriately.  However, in the NFS direct I/O path, we still  
have a pair of rpc_clnt_sigmask() calls in nfs_direct_read() and  
nfs_direct_write() that wrap all the RPC dispatching done in the  
lower layers.

I had carefully optimized the direct path so there was only a single  
pair of sigmask calls for each application I/O request, rather than  
one pair for every dispatched RPC.  With the rpc_run_task interface,  
we're now back to doing one pair for each RPC.  That seems like a  
step backwards to me...?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



