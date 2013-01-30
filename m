Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45694 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751668Ab3A3U7a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jan 2013 15:59:30 -0500
Date: Wed, 30 Jan 2013 15:59:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Pin GSS module while handling flavor lookups
Message-ID: <20130130205927.GG14256@fieldses.org>
References: <20130130193120.1289.33936.stgit@seurat.1015granger.net>
 <20130130202742.GE14256@fieldses.org>
 <8EA112A2-AF62-422D-B677-C17F28416F1A@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8EA112A2-AF62-422D-B677-C17F28416F1A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 30, 2013 at 03:44:37PM -0500, Chuck Lever wrote:
> 
> On Jan 30, 2013, at 3:27 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Jan 30, 2013 at 02:34:30PM -0500, Chuck Lever wrote:
> >> Add an API similar to rpcauth_lookup_pseudoflavor().  The NFS server
> >> should not call GSS API functions directly without first pinning
> >> the GSS module.
> >> 
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >> 
> >> Bruce-
> >> 
> >> Are you interested in taking something like this (untested) patch
> >> for 3.9?  (This has pre-requisites I posted earlier this week).
> > 
> > OK.  Let me know what you want me to do.
> 
> Since the pre-requisites are going through Trond, I can just send it in through him, as long as you both agree to it.

OK, feel free to add my ACK.

--b.
