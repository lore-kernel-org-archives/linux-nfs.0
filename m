From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 04/33] NFS: Fix nfs_wb_page() to always exit with an
	error or a clean page
Date: Mon, 21 Apr 2008 20:14:08 -0400
Message-ID: <1208823248.7767.36.camel@heimdal.trondhjem.org>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080419204048.14124.46594.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <5A5AEA53-E5D2-4A26-A478-2C26A44B8FE7@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25487 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758160AbYDVAOJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Apr 2008 20:14:09 -0400
In-Reply-To: <5A5AEA53-E5D2-4A26-A478-2C26A44B8FE7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-04-21 at 14:53 -0400, Chuck Lever wrote:
> Hi Trond-
> 
> On Apr 19, 2008, at 4:40 PM, Trond Myklebust wrote:
> > It is possible for nfs_wb_page() to sometimes exit with 0 return  
> > value, yet
> > the page is left in a dirty state.
> > For instance in the case where the server rebooted, and the COMMIT  
> > request
> > failed, then all the previously "clean" pages which were cached by the
> > server, but were not guaranteed to have been writted out to disk,
> > have to be redirtied and resent to the server.
> > The fix is to have nfs_wb_page_priority() check that the page is clean
> > before it exits...
> 
> We have somewhat similar logic in nfs_wb_page_cancel and  
> __nfs_write_mapping.  How is it that these two are not affected by the  
> "server reboot / commit failed" scenario?  Do they simply retry until  
> the resent write succeeds?

Who said they're not affected?

The difference is that nfs_wb_page_cancel() will attempt to clear all
requests that are not committed instead of redirtying them.

OTOH, nfs_write_mapping() can and will leave dirty pages under certain
circumstances.

> > This fixes a condition that triggers the BUG_ON(PagePrivate(page)) in
> > nfs_create_request() when we're in the nfs_readpage() path.
> 
> Seems like there's more at stake here than just triggering a BUG.
> 
> In the launder_page path, dirty data could be lost if nfs_wb_page  
> returns zero, but hasn't successfully flushed the data to the server,  
> right?
> 
> In the nfs_flush_incompatible path, you would lose write ordering at  
> the least... couldn't that potentially result in data corruption?

Yes.

> I don't recall the test case that triggered the BUG.  Do we have a  
> test that is run often (eg. fsx or fsx-odirect) that exercises this  
> path?

You would have to either cause the RPC call to fail due to something
like an ENOMEM error, or you would have to have a server reboot at the
'right' moment.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
