From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] SUNRPC: RPC client's TCP transport ignores errors
	during connect
Date: Tue, 08 Apr 2008 14:00:12 -0400
Message-ID: <1207677612.11699.14.camel@heimdal.trondhjem.org>
References: <20080408173602.21776.60671.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11881 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752693AbYDHSFy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 14:05:54 -0400
In-Reply-To: <20080408173602.21776.60671.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-04-08 at 13:38 -0400, Chuck Lever wrote:
> Found this while poking at the RPC server registration logic.  It appears to
> fix the problem I was seeing with refused TCP connections.

BTW: Exactly how did this fix the problem?

As I said, it looks to me as if a report other than ENOTCONN or
ETIMEDOUT will automatically result in the rpc task aborting.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
