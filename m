From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] lockd: fix race in nlm_release()
Date: Wed, 20 Feb 2008 18:46:25 -0500
Message-ID: <20080220234625.GN30160@fieldses.org>
References: <20080220191153.GG30160@fieldses.org> <1203535466.15034.5.camel@heimdal.trondhjem.org> <20080220192759.GI30160@fieldses.org> <1203536918.15034.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44415 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753143AbYBTXq1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2008 18:46:27 -0500
In-Reply-To: <1203536918.15034.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 20, 2008 at 02:48:38PM -0500, Trond Myklebust wrote:
> 
> On Wed, 2008-02-20 at 14:27 -0500, J. Bruce Fields wrote:
> > On Wed, Feb 20, 2008 at 02:24:26PM -0500, Trond Myklebust wrote:
> > > 
> > > On Wed, 2008-02-20 at 14:11 -0500, J. Bruce Fields wrote:
> > > > From: J. Bruce Fields <bfields@citi.umich.edu>
> > > > 
> > > > The sm_count is decremented to zero but left on the nsm_handles list.
> > > > So in the space between decrementing sm_count and acquiring nsm_mutex,
> > > > it is possible for another task to find this nsm_handle, increment the
> > > > use count and then enter nsm_release itself.
> > > > 
> > > > Thus there's nothing to prevent the nsm being freed before we acquire
> > > > nsm_mutex here.
> > > > 
> > > > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > > > ---
> > > >  fs/lockd/host.c |   10 ++++------
> > > >  1 files changed, 4 insertions(+), 6 deletions(-)
> > > > 
> > > > Am I missing something here?--b.
> > > > 
> > > > diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> > > > index c3f1194..960911c 100644
> > > > --- a/fs/lockd/host.c
> > > > +++ b/fs/lockd/host.c
...
> > If you've got any other suggestions while I'm in the general area, I'm
> > all ears.
> 
> Just the usual plea to replace the host->h_server flag with 2 separate
> lists: one list of client nlm_hosts, and one list of server
> nlm_hosts :-)

OK, I'm looking at that.

> ...Oh and a minor optimisation: If we're using a loopback mount, I don't
> think we'll ever need to monitor 'localhost' :-)

I assumed one of the only uses for loopback mounts was for testing and
development, in which case it's better to keep the loopback behavior
similar to non-loopback behavior, even if it's a little silly.  No?

--b.
