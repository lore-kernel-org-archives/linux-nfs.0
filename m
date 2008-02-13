From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 07/11] NFSD: Use "depends on" for PROC_FS dependency
Date: Wed, 13 Feb 2008 16:48:25 -0500
Message-ID: <1202939305.10574.28.camel@heimdal.trondhjem.org>
References: <20080211221216.1047.31922.stgit@manray.1015granger.net>
	 <20080212212325.GM18625@fieldses.org>
	 <1202852836.9228.1.camel@heimdal.trondhjem.org>
	 <20080212223235.GP18625@fieldses.org>
	 <1202857069.9228.14.camel@heimdal.trondhjem.org>
	 <47B33A99.60400@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: chuck.lever@oracle.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:48835 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934795AbYBMVsl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Feb 2008 16:48:41 -0500
In-Reply-To: <47B33A99.60400@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-02-13 at 13:44 -0500, Chuck Lever wrote:
> Trond Myklebust wrote:
> > On Tue, 2008-02-12 at 17:32 -0500, J. Bruce Fields wrote:
> >>>> I assume nobody cares?
> >>> You assume wrongly. Patch NAKed...
> >> Do you have a use case in mind?  (Just curious.)
> > 
> > Embedded systems often compile without sysctl and/or procfs support. Why
> > shouldn't they be able to run an NFS client with RPCSEC_GSS?
> 
> OK, it looks like the patch that adds the "depends on SYSCTL" to the 
> LOCKD entry will cause NFS-enabled builds to break if CONFIG_SYSCTL is 
> disabled, thanks to the recent addition of nlmclnt_init and nlmclnt_done.
> 
> Probably the better solution in this case is to ifdef out the 
> register_sysctl() call in lockd if CONFIG_SYSCTL isn't set.  In the long 
> run, should we make it possible to build the NFS client without lockd?

In the long run, we really ought to try to make it possible to build a
NFSv3-only, or a NFSv4-only client, so yes...


