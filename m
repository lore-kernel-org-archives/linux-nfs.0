From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/2] NFS: Clean up nfs_update_request()
Date: Wed, 18 Jun 2008 17:01:39 -0400
Message-ID: <1213822899.25182.21.camel@localhost>
References: <20080616192348.20513.72423.stgit@localhost.localdomain>
	 <20080616192348.20513.3284.stgit@localhost.localdomain>
	 <B9BACB96-E0DB-4C6D-B55D-A50CC6F94474@oracle.com>
	 <1213739807.7288.86.camel@localhost>  <485972AE.9030405@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: chuck.lever@oracle.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35345 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752942AbYFRVCf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jun 2008 17:02:35 -0400
In-Reply-To: <485972AE.9030405@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-06-18 at 16:40 -0400, Chuck Lever wrote:
> > No. If the page is being written out, then we _must_ release all locks,
> > wait on the request, and try again. This is not a change compared to the
> > previous incarnation.
> 
> Right, understood... but I think the logic added here is harder to 
> understand and thus more prone to break when something changes than the 
> previous incarnation was.

I don't understand: The behaviour and the results are exactly the same
as before. All that has happened is that the existing code to update a
request got shuffled into a separate function. If the request is locked,
so that we can't update it, we still wait for the request to become
unlocked, then release it and try the lookup again. There is no new
logic...
The only 'change' is a cosmetic one: the new routine has somehow to
signal to the caller that the lock attempt failed, so it returns an
error code EAGAIN to do so.

One alternative might be to move the code that waits on the lock into
nfs_try_to_update_request(), but I don't like that idea for two reasons:

     1. waiting on the lock isn't related to updating the request
     2. Once the request has been unlocked, you _still_ have to return
        to nfs_setup_write_request() because the old request might have
        completed, and been removed from the inode altogether. IOW: you
        still don't get rid of the need to signal the EAGAIN.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
