Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39498 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932651AbcKIQ1x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 Nov 2016 11:27:53 -0500
Date: Wed, 9 Nov 2016 11:27:52 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Tejun Heo <tj@kernel.org>,
        Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] fs/nfsd/nfs4callback: Remove deprecated
 create_singlethread_workqueue
Message-ID: <20161109162752.GA4952@fieldses.org>
References: <20160830205348.GA31915@Karyakshetra>
 <20161108213911.GA27681@fieldses.org>
 <20161108225221.GB6460@htj.duckdns.org>
 <20161109012725.GA29930@fieldses.org>
 <1478697488.7930.7.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1478697488.7930.7.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 09, 2016 at 08:18:08AM -0500, Jeff Layton wrote:
> On Tue, 2016-11-08 at 20:27 -0500, J. Bruce Fields wrote:
> > On Tue, Nov 08, 2016 at 05:52:21PM -0500, Tejun Heo wrote:
> > > 
> > > Hello, Bruce.
> > > 
> > > On Tue, Nov 08, 2016 at 04:39:11PM -0500, J. Bruce Fields wrote:
> > > > 
> > > > Apologies, just cleaning out old mail and finding some I should have
> > > > responded to long ago:
> > > > 
> > > > On Wed, Aug 31, 2016 at 02:23:48AM +0530, Bhaktipriya Shridhar wrote:
> > > > > 
> > > > > The workqueue "callback_wq" queues a single work item &cb->cb_work per
> > > > > nfsd4_callback instance and thus, it doesn't require execution ordering.
> > > > 
> > > > What's "execution ordering"?
> > > > 
> 
> AIUI, it means that jobs are always run in the order queued and are
> serialized.
> 
> > > > We definitely do depend on the fact that at most one of these is running
> > > > at a time.
> > > 
> 
> We do?
> 
> > > If there can be multiple cb's and thus cb->cb_work's per callback_wq,
> > > it'd need explicit ordering.  Is that the case?
> > 
> 
> These are basically client RPC tasks, and the cb_work just handles the
> submission into the client RPC state machine. Just because we're running
> several callbacks at the same time doesn't mean that they need to be
> strictly ordered. The client state machine can certainly handle running
> these in parallel.

I'm not worried about the rpc calls themselves, I'm worried about the
other stuff in nfsd4_run_cb_work(), especially
nfsd4_process_cb_update().

It's been a while since I thought about it and maybe it'd be OK with a
little bit of extra locking.

--b.

> > Yes, there can be multiple cb_work's.
> > 
> 
> Yes, but each is effectively a separate work unit. I see no reason why
> we'd need to order them at all.
> 
> -- 
> Jeff Layton <jlayton@poochiereds.net>
