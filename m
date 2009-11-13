From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] SUNRPC: Address buffer overrun in rpc_uaddr2sockaddr()
Date: Sat, 14 Nov 2009 08:23:07 +0900
Message-ID: <1258154588.2981.5.camel@heimdal.trondhjem.org>
References: <20091113154934.1828.46527.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:60254 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932245AbZKMXXH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Nov 2009 18:23:07 -0500
In-Reply-To: <20091113154934.1828.46527.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-11-13 at 10:52 -0500, Chuck Lever wrote:
> Hi Trond-
> 
> I haven't heard from the reporter, but since 2.6.32-final is imminent,
> would you consider this for 2.6.32-rc ?  As far as I can tell, this
> issue was introduced in 2.6.32-rc and is not applicable for stable.

I've put it in the 'bugfixes' and 'linux-next' git trees. We'll give it
a few days testing there before I ask Linus to pull.

Cheers
  Trond

