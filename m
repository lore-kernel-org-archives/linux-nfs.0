Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50192 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754661Ab0LOVtU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 16:49:20 -0500
Subject: Re: [PATCH 13/31] NFS: Introduce new-style XDR decoding functions
 for NFSv2
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101214145630.2293.21193.stgit@matisse.1015granger.net>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
	 <20101214145630.2293.21193.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 15 Dec 2010 16:49:07 -0500
Message-ID: <1292449747.3068.76.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-12-14 at 09:56 -0500, Chuck Lever wrote:
> We'd like to prevent local buffer overflows caused by malicious or
> broken servers.  New xdr_stream style decoders can do that.
> 
> For efficiency, we also eventually want to be able to pass xdr_streams
> from call_decode() to all XDR decoding functions, rather than building
> an xdr_stream in every XDR decoding function in the kernel.
> 
> Static helper functions are left without the "inline" directive.  This
> allows the compiler to choose automatically how to optimize these for
> size or speed.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Tested-by: J. Bruce Fields <bfields@redhat.com>
> ---
> 
>  fs/nfs/nfs3xdr.c     | 1534 +++++++++++++++++++++++++++++++++++++++++++++++---
>  include/linux/nfs3.h |    1 
>  2 files changed, 1451 insertions(+), 84 deletions(-)

Doesn't look like NFSv2 to me...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

