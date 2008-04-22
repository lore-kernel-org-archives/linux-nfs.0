From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 07/33] NFS: Ensure that rpc_run_task() errors are
	propagated back to the caller
Date: Tue, 22 Apr 2008 11:10:58 -0400
Message-ID: <1208877058.11982.11.camel@heimdal.trondhjem.org>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080419204048.14124.4335.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <BE4F0130-A492-4229-83E4-E7C912B0ABF0@oracle.com>
	 <1208823472.7767.40.camel@heimdal.trondhjem.org>
	 <92201A7C-4650-450E-ABF2-EF699B208647@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56546 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754166AbYDVPL3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Apr 2008 11:11:29 -0400
In-Reply-To: <92201A7C-4650-450E-ABF2-EF699B208647@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-04-22 at 10:19 -0400, Chuck Lever wrote:

> 
> My point is that EFAULT isn't an appropriate return code if  
> rpc_run_task() fails.  EFAULT is appropriate only when the I/O engine  
> can't access the user's memory.
> 
> If no bytes were read, an error code that reflects the problem should  
> be returned.
> 
> 	task = rpc_run_task(&task_setup_data);
> 	if (IS_ERR(task) {
> 		result = PTR_ERR(task);
> 		break;
> 	}
> 	rpc_put_task(task);
> 
> The logic at the end of nfs_direct_read_schedule_segment() will take  
> care to return the number of bytes read, or an error code if no bytes  
> were read.

Then a fix should be applied to auth_gss.c: the EFAULT error message is
coming from the downcall code. If it is not appropriate to pass that on
to the RPC caller, then we should substitute an EACCES.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
