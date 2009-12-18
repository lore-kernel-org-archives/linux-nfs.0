From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
Date: Fri, 18 Dec 2009 20:44:03 +0100
Message-ID: <1261165443.20899.555.camel@laptop>
References: <1261015420.1947.54.camel@serenity>
	 <1261037877.27920.36.camel@laptop>  <1261164799.1947.123.camel@serenity>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Trond.Myklebust@netapp.com, Wu Fengguang <fengguang.wu@intel.com>,
	"jens.axboe" <jens.axboe@oracle.com>
To: Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38491 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbZLRToe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Dec 2009 14:44:34 -0500
In-Reply-To: <1261164799.1947.123.camel@serenity>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-12-18 at 14:33 -0500, Steve Rago wrote:
> > > +void nfs_wait_woutstanding(struct inode *inode)
> > > +{
> > > +   if (nfs_max_woutstanding != 0) {
> > > +           unsigned long background_thresh;
> > > +           unsigned long dirty_thresh;
> > > +           long npages;
> > > +           struct nfs_inode *nfsi = NFS_I(inode);
> > > +
> > > +           get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
> > > +           npages = global_page_state(NR_FILE_DIRTY) +
> > > +                    global_page_state(NR_UNSTABLE_NFS) +
> > > +                    global_page_state(NR_WRITEBACK);
> > > +           if (npages >= background_thresh)
> > > +                   wait_event(nfsi->writes_wq,
> > > +                      atomic_read(&nfsi->writes) < nfs_max_woutstanding);
> > > +   }
> > > +}
> > 
> > This looks utterly busted too, why the global state and not the nfs
> > client's bdi state?
> > 
> > Also, why create this extra workqueue and not simply use the congestion
> > interface that is present? If the congestion stuff doesn't work for you,
> > fix that, don't add extra muck like this.
> 
> Pages are a global resource.  Once we hit the dirty_threshold, the
> system is going to work harder to flush the pages out.  This code
> prevents the caller from creating more dirty pages in this state,
> thereby making matters worse, when eager writeback is enabled.

You misunderstand, dirty limits are per BDI, all those npages might be
for !NFS traffic, in which case forcing the NFS into sync mode might be
the wrong thing to do.

The dirty pages are no longer a global resource in the current Linux
tree.

> This wait queue is used for different purposes than the congestion_wait
> interface.  Here we are preventing the caller from proceeding if there
> are too many NFS writes outstanding for this thread and we are in a
> memory pressure state.  It has nothing to do with the state of the bdi
> congestion. 

I'm thinking it ought to, congestion is exactly that, when the device
gets backed up and need to get moving.

