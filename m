From: James Lentini <jlentini@netapp.com>
Subject: Re: [PATCH] update mount.nfs example in NFS/RDMA documentation
Date: Fri, 30 May 2008 17:13:44 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0805301712040.26788@jlentini-linux.nane.netapp.com>
References: <alpine.LFD.1.10.0805291534360.2898@jlentini-linux.nane.netapp.com> <20080529221558.GF24018@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8931 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753364AbYE3VNq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 May 2008 17:13:46 -0400
In-Reply-To: <20080529221558.GF24018@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 29 May 2008, J. Bruce Fields wrote:

> On Thu, May 29, 2008 at 03:40:49PM -0400, James Lentini wrote:
> > 
> > Bruce,
> > 
> > Below is an update to the NFS/RDMA documentation that clarifies how 
> > to run mount.nfs. Could you please merge this for 2.6.26?
> 
> Sure, but:
> 
> > 
> > Signed-off-by: James Lentini <jlentini@netapp.com>
> > 
> > --- a/Documentation/filesystems/nfs-rdma.txt	2008-05-29 15:09:38.753033000 -0400
> > +++ b/Documentation/filesystems/nfs-rdma.txt	2008-05-29 15:31:33.374948000 -0400
> > @@ -5,7 +5,7 @@
> >  ################################################################################
> >  
> >   Author: NetApp and Open Grid Computing
> > - Date: February 25, 2008
> > + Date: May 29, 2008
> 
> I'm getting rejects--the version upstream right now is dated April 
> 15. Could you re-diff that?

Sorry Bruce. I diff it against the version in the master branch of 
your git repo. I should have switched to the for-2.6.26 branch. I'll 
incorporate Chuck's comments and resend.
