From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/24] RPC server support rpcbind v4 plus additional
	clean ups
Date: Mon, 14 Apr 2008 15:14:12 -0400
Message-ID: <20080414191412.GN15950@fieldses.org>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60989 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750737AbYDNTOX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Apr 2008 15:14:23 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 14, 2008 at 12:26:38PM -0400, Chuck Lever wrote:
> Hi Bruce, Trond -
> 
> This patch series provides some minor clean ups, and finishes with an
> implementation of support for rpcbind version 4 registration.  Version 4
> support can be entirely disabled in favor of legacy behavior with a kernel
> build option, and the default is to use rpcbind version 2 when registering
> kernel RPC services.
> 
> There are 24 patches in this series, but only a few are more than trivial and
> hopefully fewer yet are controversial.  I've tried to split these so that
> server side and client side changes are in separate patches.
> 
> It would be helpful for me if they could be considered for 2.6.26.

Thanks.  I've applied 3, 7, 9, and 10, and I'm mostly assuming the
others are Somebody Else's Problem for now.  Please feel free to correct
that idea.

--b.
