From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Handle a zero-length auth flavor list
Date: Sat, 22 Aug 2009 13:34:18 -0400
Message-ID: <1250962458.8143.24.camel@heimdal.trondhjem.org>
References: <20090821215006.28834.73753.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:36368 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932832AbZHVReU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Aug 2009 13:34:20 -0400
In-Reply-To: <20090821215006.28834.73753.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-21 at 17:50 -0400, Chuck Lever wrote:
> Some releases of Linux rpc.mountd (nfs-utils 1.1.4 and later) return an
> empty auth flavor list if no sec= was specified for the export.  This is
> notably broken server behavior.
> 
> The new auth flavor list checking added in a recent commit rejects this
> case.  The OpenSolaris client does too.
> 
> The broken mountd implementation is already widely deployed.  To avoid
> a behavioral regression, the kernel's mount client skips flavor checking
> (ie reverts to the pre-2.6.32 behavior) if mountd returns an empty
> flavor list.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> Trond-
> 
> First proposal to address the empty flavor list regression.

Looks alright. Do we know that it fixes the problem for Fengguang?

Cheers
  Trond

