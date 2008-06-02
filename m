From: James Lentini <jlentini@netapp.com>
Subject: Re: [PATCH] update mount.nfs example in NFS/RDMA documentation
Date: Mon, 2 Jun 2008 15:30:35 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806021528140.26788@jlentini-linux.nane.netapp.com>
References: <alpine.LFD.1.10.0805291534360.2898@jlentini-linux.nane.netapp.com> <A04A3C4F-EF91-4204-B28F-E63BFEAF3241@oracle.com> <alpine.LFD.1.10.0805301805490.26788@jlentini-linux.nane.netapp.com> <A4F07986-C129-4D87-9C82-61FC797A178F@oracle.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19292 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752717AbYFBTai (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jun 2008 15:30:38 -0400
In-Reply-To: <A4F07986-C129-4D87-9C82-61FC797A178F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 30 May 2008, Chuck Lever wrote:

> > In the instructions, I'll recommend
> > that the binary be copied as follows:
> > 
> > $ sudo cp utils/mount/mount.nfs /sbin/mount.nfs
> > 
> > > The tcp_wrappers package is needed to build nfs-utils in any case, so it
> > > would
> > > be helpful to mention that too.
> > 
> > I'd like to leave that detail to the nfs-utils README. Does that sound
> > reasonable?
> 
> If you're going to provide a blanket pointer to the nfs-utils README 
> for building it, and omit any specific instructions from 
> nfs-rdma.txt (aside from copying the mount.nfs executable), that 
> sounds reasonable.

I'd like to provide a few hints about how to build nfs-utils, 
specifically the note on the --disable-gss and --disable-nfsv4 flags. 
We've had questions on this in the past. I'll add a note about 
tcp_wrappers.
