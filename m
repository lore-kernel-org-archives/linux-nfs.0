From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/4] NLM: Introduce completion function to match
	nlmclnt_init
Date: Mon, 07 Jan 2008 21:04:15 -0500
Message-ID: <1199757855.15265.3.camel@heimdal.trondhjem.org>
References: <20071220200405.3358.54150.stgit@manray.1015granger.net>
	 <1199397248.1913.15.camel@heimdal.trondhjem.org>
	 <AB3076F8-4E4F-4862-A47E-5917BFBB702B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:45635 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752781AbYAHCEU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jan 2008 21:04:20 -0500
In-Reply-To: <AB3076F8-4E4F-4862-A47E-5917BFBB702B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-01-07 at 18:04 -0500, Chuck Lever wrote:
> Hi Trond-
> 
> On Jan 3, 2008, at 4:54 PM, Trond Myklebust wrote:
> > On Thu, 2007-12-20 at 15:04 -0500, Chuck Lever wrote:
> >> Introduce the other book-end for nlmclnt_init(). This function is  
> >> invoked
> >> by the NFS client during unmount processing to release the  
> >> nlm_host struct
> >> that was pinned by nlmclnt_init() during mount processing.
> >
> > Does this really need to be a separate patch from the nlmclnt_init?
> >
> > Furthermore, those EXPORT_SYMBOL() should really be EXPORT_SYMBOL_GPL.
> > We don't want to make this an official ABI.
> 
> Should I change nlmclnt_proc() to use EXPORT_SYMBOL_GPL then?

Please do, yes. As you can see from the git tree and latest NFS_ALL, I'm
also restricting the sunrpc interfaces to _GPL-only. We don't want these
interfaces to be used by out-of-tree modules.

Cheers
  Trond

