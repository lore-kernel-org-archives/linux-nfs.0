From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 07/10] pnfs-submit: avoid race handling return on close
Date: Tue, 15 Jun 2010 14:19:51 -0400
Message-ID: <1276625991.2988.1.camel@heimdal.trondhjem.org>
References: <1276566375-24566-1-git-send-email-iisaman@netapp.com>
	 <1276566375-24566-2-git-send-email-iisaman@netapp.com>
	 <1276566375-24566-3-git-send-email-iisaman@netapp.com>
	 <1276566375-24566-4-git-send-email-iisaman@netapp.com>
	 <1276566375-24566-5-git-send-email-iisaman@netapp.com>
	 <1276566375-24566-6-git-send-email-iisaman@netapp.com>
	 <1276566375-24566-7-git-send-email-iisaman@netapp.com>
	 <1276566375-24566-8-git-send-email-iisaman@netapp.com>
	 <4C17B304.4070308@panasas.com>
	 <AANLkTilDj2Ua_t77kk5Gj_t0vqEcOJFKlqODAj18KQnm@mail.gmail.com>
	 <1276623230.8767.48.camel@heimdal.trondhjem.org>
	 <AANLkTimScICltrCrtEIz7qw1GzuaTGNwCVTk-ZTsZO4_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Benny Halevy <bhalevy@panasas.com>,
	Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:41242 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754682Ab0FOSUB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 14:20:01 -0400
In-Reply-To: <AANLkTimScICltrCrtEIz7qw1GzuaTGNwCVTk-ZTsZO4_-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-06-15 at 13:52 -0400, Fred Isaman wrote:
> On Tue, Jun 15, 2010 at 1:33 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Tue, 2010-06-15 at 13:32 -0400, Fred Isaman wrote:
> >> On Tue, Jun 15, 2010 at 1:06 PM, Benny Halevy <bhalevy@panasas.com> wrote:
> >> > On Jun. 14, 2010, 21:46 -0400, Fred Isaman <iisaman@netapp.com> wrote:
> >> >> This prepares for the next patch.
> >> >>
> >> >> NOTE this doesn't really fix any current race, since
> >> >> layout going to NULL is OK.  But layout changing from NULL to nonNULL
> >> >> is a real race that is not fixed
> >> >>
> >> >> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> >> >> ---
> >> >>  fs/nfs/nfs4state.c        |    5 +++--
> >> >>  fs/nfs/pnfs.c             |   11 +++++++++++
> >> >>  include/linux/nfs4_pnfs.h |    2 ++
> >> >>  3 files changed, 16 insertions(+), 2 deletions(-)
> >> >>
> >> >> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> >> >> index d5144bd..8a7a64c 100644
> >> >> --- a/fs/nfs/nfs4state.c
> >> >> +++ b/fs/nfs/nfs4state.c
> >> >> @@ -594,11 +594,12 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state,
> >> >>       } else {
> >> >>  #ifdef CONFIG_NFS_V4_1
> >> >>               struct nfs_inode *nfsi = NFS_I(state->inode);
> >> >> +             int roc = nfs4_roc_iomode(nfsi);
> >> >>
> >> >> -             if (has_layout(nfsi) && nfsi->layout.roc_iomode) {
> >> >> +             if (roc) {
> >> >>                       struct nfs4_pnfs_layout_segment range;
> >> >>
> >> >> -                     range.iomode = nfsi->layout.roc_iomode;
> >> >> +                     range.iomode = roc;
> >> >>                       range.offset = 0;
> >> >>                       range.length = NFS4_MAX_UINT64;
> >> >>                       pnfs_return_layout(state->inode, &range, NULL,
> >> >> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> >> >> index 6def09c..bd11ec7 100644
> >> >> --- a/fs/nfs/pnfs.c
> >> >> +++ b/fs/nfs/pnfs.c
> >> >> @@ -321,6 +321,17 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
> >> >>  #define BUG_ON_UNLOCKED_LO(lo) do {} while (0)
> >> >>  #endif /* CONFIG_SMP */
> >> >>
> >> >> +int nfs4_roc_iomode(struct nfs_inode *nfsi)
> >> >> +{
> >> >> +     int rv = 0;
> >> >> +
> >> >> +     spin_lock(&pnfs_spinlock);
> >> >
> >> > Why take the global lock rather than nfsi->lo_lock?
> >> >
> >> > Benny
> >>
> >> You are right. That would be a copy-paste error.
> >
> > What's an nfsi->lo_lock, and why do we need one?
> >
> > Trond
> >
> >
> 
> It protects nfsi->layout and its contents.
> 
> Fred

Yes, but why do we need an extra spinlock? We already have
inode->i_lock. Why can't you just reuse that?

