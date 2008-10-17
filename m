From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Enable NFSv4 callback server to listen on
	AF_INET6 sockets
Date: Fri, 17 Oct 2008 09:46:45 -0400
Message-ID: <1224251205.7722.22.camel@localhost>
References: <20081016212513.21561.55647.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25980 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753403AbYJQNrk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 09:47:40 -0400
In-Reply-To: <20081016212513.21561.55647.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-10-16 at 17:41 -0400, Chuck Lever wrote:
> Allow the NFS callback server to listen for requests via an AF_INET6 or
> AF_INET socket when IPv6 support is present in the kernel.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> I just pulled from your origin/master branch, and this patch appears to
> be missing from the 2.6.28 merge.  The patch was posted originally in
> late August to linux-nfs.
> 
>   http://marc.info/?l=linux-nfs&m=121987073015249&w=2
> 
> Bruce took the others in that series, but I think he may have left this
> one for you since it hits only the client.

I didn't take it at the time because it wouldn't even apply, let alone
compile, without commit e851db5b05408b89b9a9429a66814b79fabee2a1.

I'll push it to Linus later today.
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
