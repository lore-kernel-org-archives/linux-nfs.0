Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yb0-f176.google.com ([209.85.213.176]:34188 "EHLO
        mail-yb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751696AbcKHW6w (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Nov 2016 17:58:52 -0500
Date: Tue, 8 Nov 2016 17:52:21 -0500
From: Tejun Heo <tj@kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] fs/nfsd/nfs4callback: Remove deprecated
 create_singlethread_workqueue
Message-ID: <20161108225221.GB6460@htj.duckdns.org>
References: <20160830205348.GA31915@Karyakshetra>
 <20161108213911.GA27681@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161108213911.GA27681@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Bruce.

On Tue, Nov 08, 2016 at 04:39:11PM -0500, J. Bruce Fields wrote:
> Apologies, just cleaning out old mail and finding some I should have
> responded to long ago:
> 
> On Wed, Aug 31, 2016 at 02:23:48AM +0530, Bhaktipriya Shridhar wrote:
> > The workqueue "callback_wq" queues a single work item &cb->cb_work per
> > nfsd4_callback instance and thus, it doesn't require execution ordering.
> 
> What's "execution ordering"?
> 
> We definitely do depend on the fact that at most one of these is running
> at a time.

If there can be multiple cb's and thus cb->cb_work's per callback_wq,
it'd need explicit ordering.  Is that the case?

Thanks.

-- 
tejun
