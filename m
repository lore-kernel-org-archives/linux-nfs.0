From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: [PATCH] SUNRPC: Initialize source address if passed-in srcaddr
 is AF_UNSPEC
Date: Mon, 1 Nov 2010 16:08:22 -0400
Message-ID: <20101101200822.GA3598@elliptictech.com>
References: <20101101195631.9279.16018.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.elliptictech.com ([209.217.122.41]:46942 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434Ab0KAUbh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Nov 2010 16:31:37 -0400
In-Reply-To: <20101101195631.9279.16018.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-11-01 15:58 -0400, Chuck Lever wrote:
> Recently xs_bind() was changed so it can't tolerate an AF_UNSPEC
> bind address; it needs a fully initialized ANYADDR.  We recently fixed
> this case in xprtsock.c, but some upper layer protocols seem to assume
> that it's OK to pass in an AF_UNSPEC address for the source address.
> Catch that case too.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> Untested.

This one seems to correct the issue.

Tested-by: Nick Bowler <nbowler@elliptictech.com>

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
