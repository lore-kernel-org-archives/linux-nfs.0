Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38542 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751670AbcKIB10 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Nov 2016 20:27:26 -0500
Date: Tue, 8 Nov 2016 20:27:25 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tejun Heo <tj@kernel.org>
Cc: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] fs/nfsd/nfs4callback: Remove deprecated
 create_singlethread_workqueue
Message-ID: <20161109012725.GA29930@fieldses.org>
References: <20160830205348.GA31915@Karyakshetra>
 <20161108213911.GA27681@fieldses.org>
 <20161108225221.GB6460@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161108225221.GB6460@htj.duckdns.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 08, 2016 at 05:52:21PM -0500, Tejun Heo wrote:
> Hello, Bruce.
> 
> On Tue, Nov 08, 2016 at 04:39:11PM -0500, J. Bruce Fields wrote:
> > Apologies, just cleaning out old mail and finding some I should have
> > responded to long ago:
> > 
> > On Wed, Aug 31, 2016 at 02:23:48AM +0530, Bhaktipriya Shridhar wrote:
> > > The workqueue "callback_wq" queues a single work item &cb->cb_work per
> > > nfsd4_callback instance and thus, it doesn't require execution ordering.
> > 
> > What's "execution ordering"?
> > 
> > We definitely do depend on the fact that at most one of these is running
> > at a time.
> 
> If there can be multiple cb's and thus cb->cb_work's per callback_wq,
> it'd need explicit ordering.  Is that the case?

Yes, there can be multiple cb_work's.

--b.
