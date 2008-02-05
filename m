From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 4/5] NFSD: Remove NFSD_TCP kernel build option
Date: Mon, 04 Feb 2008 19:19:14 -0500
Message-ID: <1202170754.28484.57.camel@heimdal.trondhjem.org>
References: <20080205000442.18602.29035.stgit@manray.1015granger.net>
	 <47A7AB89.7020709@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, bfields@citi.umich.edu,
	linux-nfs@vger.kernel.org
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:49048 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755169AbYBEATX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2008 19:19:23 -0500
In-Reply-To: <47A7AB89.7020709-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-02-05 at 11:19 +1100, Greg Banks wrote:
> Chuck Lever wrote:
> > TCP support in the Linux NFS server is stable enough that we can leave it
> > on always.  CONFIG_NFSD_TCP adds about 10 lines of code, and defaults to
> > "Y" anyway.
> >
> > A run-time switch might be more appropriate if people feel they would like
> > to disable NFSD's TCP support.
> >
> >   
> Looks good.
> 
> Actually, I'd be inclined to go one step further and set UDP support
> off by default.

That will break older clients.

