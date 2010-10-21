From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] Two clean-ups for 2.6.37
Date: Thu, 21 Oct 2010 11:16:48 -0400
Message-ID: <20101021151647.GB8738@fieldses.org>
References: <20101020155158.6446.29915.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36827 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750915Ab0JUPQv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 11:16:51 -0400
In-Reply-To: <20101020155158.6446.29915.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 20, 2010 at 11:52:40AM -0400, Chuck Lever wrote:
> Hi Bruce-
> 
> Here are the clean-up patches we discussed.  Compile-tested only.
> 
> ---
> 
> Chuck Lever (2):
>       SUNRPC: Properly initialize sock_xprt.srcaddr in all cases
>       SUNRPC: Use conventional switch statement when reclassifying sockets

Applied, thanks.

--b.
