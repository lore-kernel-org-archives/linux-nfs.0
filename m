From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] SUNRPC: Fix memory leak introduced by commit 510deb0d
Date: Tue, 08 Apr 2008 12:20:37 -0400
Message-ID: <1207671637.10273.5.camel@heimdal.trondhjem.org>
References: <20080408144713.20422.40323.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9497 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837AbYDHQUv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 12:20:51 -0400
In-Reply-To: <20080408144713.20422.40323.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-04-08 at 10:47 -0400, Chuck Lever wrote:
> Commit 510deb0d was supposed to move the xprt_create_transport() call in
> rpc_create(), but neglected to remove the old call site.  This resulted in
> a transport leak after every rpc_create() call.
> 
> This leak is present in 2.6.24 and 2.6.25.

Argh. I'll pass that on asap...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
