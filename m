From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 07/11] NFSD: Use "depends on" for PROC_FS dependency
Date: Tue, 12 Feb 2008 17:57:49 -0500
Message-ID: <1202857069.9228.14.camel@heimdal.trondhjem.org>
References: <20080211221216.1047.31922.stgit@manray.1015granger.net>
	 <20080212212325.GM18625@fieldses.org>
	 <1202852836.9228.1.camel@heimdal.trondhjem.org>
	 <20080212223235.GP18625@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:37250 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752648AbYBLW6A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2008 17:58:00 -0500
In-Reply-To: <20080212223235.GP18625@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-02-12 at 17:32 -0500, J. Bruce Fields wrote:
> > > I assume nobody cares?
> > 
> > You assume wrongly. Patch NAKed...
> 
> Do you have a use case in mind?  (Just curious.)

Embedded systems often compile without sysctl and/or procfs support. Why
shouldn't they be able to run an NFS client with RPCSEC_GSS?

The other argument is that there is _nothing_ in the actual auth_gss
code that depends on procfs. The "dependency" (if there is one) is
between net/sunrpc/cache.c and procfs, and in fact, both sunrpc and the
auth_gss modules will compile just fine without procfs.



