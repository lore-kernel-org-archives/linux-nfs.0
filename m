Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61007 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753040Ab0LOVxV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 16:53:21 -0500
Subject: Re: [PATCH 05/31] NFS: Introduce new-style XDR decoding functions
 for NFSv2
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1292449722.3068.75.camel@heimdal.trondhjem.org>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
	 <20101214145510.2293.97597.stgit@matisse.1015granger.net>
	 <1292449722.3068.75.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 15 Dec 2010 16:53:20 -0500
Message-ID: <1292450000.3068.77.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-15 at 16:48 -0500, Trond Myklebust wrote:
> On Tue, 2010-12-14 at 09:55 -0500, Chuck Lever wrote:
> > We'd like to prevent local buffer overflows caused by malicious or
> > broken servers.  New xdr_stream style decoders can do that.
> > 
> > For efficiency, we also eventually want to be able to pass xdr_streams
> > from call_decode() to all XDR decoding functions, rather than building
> > an xdr_stream in every XDR decoding function in the kernel.
> > 
> > nfs_decode_dirent() is renamed to follow the naming convention of the
> > other two dirent decoders.
> > 
> > Static helper functions are left without the "inline" directive.  This
> > allows the compiler to choose automatically how to optimize these for
> > size or speed.
> > 
> > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > Tested-by: J. Bruce Fields <bfields@redhat.com>
> 
> error: patch failed: fs/nfs/nfs2xdr.c:630
> error: fs/nfs/nfs2xdr.c: patch does not apply
> 
> 

Never mind. That looks like it might be something I introduced.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

