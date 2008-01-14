From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Strange lockup during unmount in 2.6.22 -
	maybe	rpciod	deadlock?
Date: Mon, 14 Jan 2008 15:36:58 -0500
Message-ID: <1200343018.7470.56.camel@heimdal.trondhjem.org>
References: <18310.37731.29874.582772@notabene.brown>
	 <1200004896.13775.27.camel@heimdal.trondhjem.org>
	 <478BB194.3090103@uvm.edu> <1200339108.7470.45.camel@heimdal.trondhjem.org>
	 <478BC607.8050008@uvm.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Benjamin Coddington <Benjamin.Coddington@uvm.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:48916 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733AbYANUhD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 15:37:03 -0500
In-Reply-To: <478BC607.8050008@uvm.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-01-14 at 15:28 -0500, Benjamin Coddington wrote:
> Trond Myklebust wrote:
> > That shouldn't be the case in standard 2.6.22 unless you've also applied
> > the NFS_ALL patches. In that case, there is a fix (which has also been
> > applied to mainline) in
> > 
> >  http://client.linux-nfs.org/Linux-2.6.x/2.6.23-rc1/linux-2.6.23-001-fix_rpciod_down_race.dif
> 
> That fixed the problem -- still, do we care if we call async in 
> gss_destroying_context?  On umount the server drops out from under the 
> tasks..

It is useful when running against Solaris RPC servers, since they will
actually respect the request to destroy the context. In the long run, we
should fix up Linux servers to do the same.

Cheers,
  Trond

