Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34920 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759434Ab1IISUb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2011 14:20:31 -0400
Subject: RE: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: tao.peng@emc.com
Cc: gusev.vitaliy@nexenta.com, gusev.vitaliy@gmail.com,
        linux-nfs@vger.kernel.org, bergwolf@gmail.com
Date: Fri, 09 Sep 2011 14:20:30 -0400
In-Reply-To: <F19688880B763E40B28B2B462677FBF805C3299D2F@MX09A.corp.emc.com>
References: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com>
	 <1315337382.16274.7.camel@lade.trondhjem.org> <4E669B21.30006@nexenta.com>
	 <1315348373.19556.22.camel@lade.trondhjem.org>
	 <F19688880B763E40B28B2B462677FBF805C3299CA3@MX09A.corp.emc.com>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B0ED3DF@SACMVEXC2-PRD.hq.netapp.com>
	 <CA+a=Yy71JNEgG4q0e69BWEjxqh71CTcfise6KKTyYkXGUM68Tw@mail.gmail.com>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B0ED4C8@SACMVEXC2-PRD.hq.netapp.com>
	 <F19688880B763E40B28B2B462677FBF805C3299D2F@MX09A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1315592430.17611.15.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-09-08 at 23:11 -0400, tao.peng@emc.com wrote: 
> HI, Trond,
> 
> > -----Original Message-----
> > From: Myklebust, Trond [mailto:Trond.Myklebust@netapp.com]
> > Sent: Friday, September 09, 2011 1:05 AM
> > To: Peng Tao
> > Cc: Peng, Tao; gusev.vitaliy@nexenta.com; gusev.vitaliy@gmail.com;
> > linux-nfs@vger.kernel.org
> > Subject: RE: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
> > 
> > > -----Original Message-----
> > > From: Peng Tao [mailto:bergwolf@gmail.com]
> > > Sent: Thursday, September 08, 2011 11:00 AM
> > > To: Myklebust, Trond
> > > Cc: tao.peng@emc.com; gusev.vitaliy@nexenta.com;
> > > gusev.vitaliy@gmail.com; linux-nfs@vger.kernel.org
> > > Subject: Re: [PATCH] nfs: fix inifinite loop at
> > > nfs4_layoutcommit_release
> > >
> > > On Thu, Sep 8, 2011 at 8:01 PM, Myklebust, Trond
> > > <Trond.Myklebust@netapp.com> wrote:
> > > >> -----Original Message-----
> > >
> > > >
> > > > Yes, but as far as I can see, even in the blocks case there can be
> > > multiple extents per layout segment. What if I write to one
> > > uninitialised extent, layoutcommit, then write to another uninitialized
> > > extent in the same layout segment and layoutcommit? In my reading of
> > > the code, there is a chance that the second layoutcommit will fail to
> > > pick up the layout segment, and so will fail to notify the MDS that the
> > > second extent now contains data.
> > >
> > > blocklayout does not decide what to layoutcommit according to the lseg
> > > list. Instead, it keeps track of each extent's state at the
> > > granularity of blocksize, and encode whatever needs layoutcommitted in
> > > the layoutcommit call. So in your above case, as long as the second
> > > layoutcommit is issued, blocklayout will encode the newly written
> > > extent in the second layoutcommit call, even if the lseg is not
> > > attached to the second layoutcommit.
> > >
> > > But that leads to another two question:
> > > 1. How do we protect against layoutrecall if lseg is not linked to
> > > layoutcommit? For this one, can we just reject layoutrecall if there
> > > is inflight layoutcommit? It will be less parallel but can guarantee
> > > current implementation correctness.
> > > 2. blocklayout ONLY: bl_committing may be overloaded by several
> > > layoutcommit calls and we don't have information in
> > > cleanup_layoutcommit() on how many entry should be removed from
> > > bl_committing. Maybe we can add a (void*) to struct
> > > nfs4_layoutcommit_data, so that LD can pass some private information
> > > between encode_layoutcommit() and cleanup_layoutcommit()?
> > 
> > 3. What is the purpose of pinning the layout segment at all if neither blocks, nor
> > objects nor files cares?
> I believe it is for protecting against layoutrecall. But since we are seperating lseg and LD specific layout information management, it is actually not working as expected.
> 
> > IOW: if both objects and blocks track the information that they need for
> > layoutcommit outside the layout segments, then why do we need the
> > NFS_LSEG_LAYOUTCOMMIT bit and pls_lc_list at all?
> If we remove NFS_LSEG_LAYOUTCOMMIT bit and pls_lc_list, we must find other method to protect agains freeing lseg while layoutcommit is needed or is going on. e.g., check for NFS_INO_LAYOUTCOMMIT bit and inflight layoutcommit in initiate_file_draining().

The easiest solution is to ensure we have only _one_ LAYOUTCOMMIT on the
wire at a time. Otherwise, you are looking at a many-to-many mapping
between layoutcommits and lsegs.

We should not expect to need multiple layoutcommits on the wire if pNFS
is working smoothly (i.e. no layout recalls), so optimising for that
case is wrong.
I'd also think that we want to order layoutcommit and ordinary commits
(for those NFS files servers that require both) so that we don't end up
writing a file size change to disk before the actual data is committed.

So why not just protect the layoutcommit call using the existing
nfs_commit_set_lock/nfs_commit_clear_lock?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

