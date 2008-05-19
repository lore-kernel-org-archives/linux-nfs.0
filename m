From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 6/8] SUNRPC: Add second output line for each RPC task
	in rpc_show_tasks
Date: Mon, 19 May 2008 12:31:42 -0400
Message-ID: <1211214702.16052.7.camel@localhost>
References: <20080518021241.8366.12464.stgit@ellison.1015granger.net>
	 <20080518021650.8366.96474.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63777 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997AbYESQbr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 12:31:47 -0400
In-Reply-To: <20080518021650.8366.96474.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2008-05-17 at 22:16 -0400, Chuck Lever wrote:
> Add a second output line displayed for each RPC task shown via
> rpc_show_tasks.  This second line is for non-columnar variable-length
> data (like the name of the RPC wait queue the task is waiting on, or
> the procedure name).

I don't really agree with this: it makes the output harder to parse
rather than easier. grep, awk and friends don't cope well with
multi-line data...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
