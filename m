From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: convert nfs4 callback thread to kthread API
Date: Wed, 20 Feb 2008 10:09:23 -0500
Message-ID: <1203520163.8620.14.camel@heimdal.trondhjem.org>
References: <1203515730-15974-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:52834 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751872AbYBTPJc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2008 10:09:32 -0500
In-Reply-To: <1203515730-15974-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-02-20 at 08:55 -0500, Jeff Layton wrote:
> There's a general push to convert kernel threads to use the (much
> cleaner) kthread API. This patch converts the NFSv4 callback kernel
> thread to the kthread API. In addition to being generally cleaner this
> also removes the dependency on signals when shutting down the thread.
> 
> Note that this patch depends on the recent patches to svc_recv() to
> make it check kthread_should_stop() periodically. Those patches are
> in Bruce's tree at the moment and are slated for 2.6.26 along with
> the lockd conversion, so this conversion is probably also appropriate
> for 2.6.26.

Since this only touches the callback server, can't we just ask Bruce to
pick up this patch and merge it together with the others?

Cheers
  Trond

