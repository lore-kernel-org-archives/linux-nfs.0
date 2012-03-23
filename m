Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46522 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754288Ab2CWRZv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Mar 2012 13:25:51 -0400
Date: Fri, 23 Mar 2012 13:26:18 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v10 0/8] nfsd: overhaul the client name tracking code
Message-ID: <20120323132618.60e7e28d@corrin.poochiereds.net>
In-Reply-To: <20120323170630.GB6089@fieldses.org>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
	<20120323170630.GB6089@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 23 Mar 2012 13:06:30 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Mar 21, 2012 at 09:52:01AM -0400, Jeff Layton wrote:
> > This is the tenth iteration of this patchset. The primary motivation
> > of this respin is to fix up some merge conflicts with some fixes that
> > Bruce merged recently.
> 
> Thanks, these look fine.  I'm intending to merge for 3.4.  But I going
> want to spend some more time investigating the callback bug that
> excltest is triggering before committing to my for-3.4 branch.
> 
> --b.
> 

Thanks, and totally understood. No need to muddy the waters by merging new code...

> > 
> > For those who haven't followed along on the last few iterations, this
> > patchset also begins the "containerization" of nfsd. It introduces a
> > per-ns object that I envision growing over time as we make more of the
> > nfsd code namespace aware.
> > 
> > I've also rolled in the patch to convert the cl_cb_flags to a generic
> > flags field since that's a prerequisite, and added a patch to ensure
> > that no one tries to use the legacy client tracking code in anything but
> > the init_net namespace.
> > 
> > I'd like to see this go into 3.4 if possible...
> > 
> > Thanks,
> > 
> > Jeff Layton (8):
> >   nfsd: convert nfs4_client->cl_cb_flags to a generic flags field
> >   nfsd: add nfsd4_client_tracking_ops struct and a way to set it
> >   sunrpc: create nfsd dir in rpc_pipefs
> >   nfsd: add a per-net-namespace struct for nfsd
> >   nfsd: add a header describing upcall to nfsdcld
> >   nfsd: add the infrastructure to handle the cld upcall
> >   nfsd: add notifier to handle mount/unmount of rpc_pipefs sb
> >   nfsd: don't allow legacy client tracker init for anything but
> >     init_net
> > 
> >  fs/nfsd/netns.h          |   35 +++
> >  fs/nfsd/nfs4callback.c   |   14 +-
> >  fs/nfsd/nfs4proc.c       |    3 +-
> >  fs/nfsd/nfs4recover.c    |  636 +++++++++++++++++++++++++++++++++++++++++++++-
> >  fs/nfsd/nfs4state.c      |   74 +++---
> >  fs/nfsd/nfsctl.c         |   22 ++-
> >  fs/nfsd/state.h          |   26 ++-
> >  include/linux/nfsd/cld.h |   56 ++++
> >  net/sunrpc/rpc_pipe.c    |    5 +
> >  9 files changed, 796 insertions(+), 75 deletions(-)
> >  create mode 100644 fs/nfsd/netns.h
> >  create mode 100644 include/linux/nfsd/cld.h
> > 
> > -- 
> > 1.7.7.6
> > 


-- 
Jeff Layton <jlayton@redhat.com>
