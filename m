From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] nfs(8): Add description of lookupcache mount option
Date: Thu, 09 Jul 2009 16:40:18 -0400
Message-ID: <1247172018.5766.55.camel@heimdal.trondhjem.org>
References: <20090709201037.12662.80504.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:42394 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752892AbZGIUkZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jul 2009 16:40:25 -0400
In-Reply-To: <20090709201037.12662.80504.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-07-09 at 16:11 -0400, Chuck Lever wrote:
> See kernel commit 7973c1f1.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> Trond-
> 
> Noted the absense of a description in nfs(8) of the new lookupcache 
> mount option.  Cobbled together this explanation.  Before I submit
> this to Steve, any comments?

It looks alright to me. The one comment I have is that we should perhaps
note that support for the lookupcache option first appeared in kernel
2.6.28.

Cheers
  Trond

