From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] SUNRPC: prevent task_cleanup running on freed xprt
Date: Tue, 03 Aug 2010 17:32:22 -0400
Message-ID: <1280871142.14520.7.camel@heimdal.trondhjem.org>
References: <20100803132453.4fa18444@tlielax.poochiereds.net>
	 <1280860815.9771.25.camel@heimdal.trondhjem.org>
	 <1280861363.12283.2.camel@heimdal.trondhjem.org>
	 <20100803212220.GI31579@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:54787 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453Ab0HCVc2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 17:32:28 -0400
In-Reply-To: <20100803212220.GI31579@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-08-03 at 17:22 -0400, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@redhat.com>
> 
> We saw a report of a NULL dereference in xprt_autoclose:
> 
> 	https://bugzilla.redhat.com/show_bug.cgi?id=611938
> 
> This appears to be the result of an xprt's task_cleanup running after
> the xprt is destroyed.  Nothing in the current code appears to prevent
> that.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---

Thanks. Applied to nfs-for-2.6.36...

Trond

