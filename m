Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60147 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbaJWHgI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Oct 2014 03:36:08 -0400
Date: Thu, 23 Oct 2014 00:36:08 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3] NFS: Implement SEEK
Message-ID: <20141023073608.GB18399@infradead.org>
References: <1411754328-18589-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1411754328-18589-2-git-send-email-Anna.Schumaker@Netapp.com>
 <54480A77.4000804@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54480A77.4000804@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 22, 2014 at 03:50:15PM -0400, Anna Schumaker wrote:
> >  int nfs4_call_sync(struct rpc_clnt *clnt,
> >  		   struct nfs_server *server,
> >  		   struct rpc_message *msg,
> > @@ -8431,7 +8430,8 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
> >  		| NFS_CAP_CHANGE_ATTR
> >  		| NFS_CAP_POSIX_LOCK
> >  		| NFS_CAP_STATEID_NFSV41
> > -		| NFS_CAP_ATOMIC_OPEN_V1,
> > +		| NFS_CAP_ATOMIC_OPEN_V1
> > +		| NFS_CAP_SEEK,
> 
> This looks like it really does add the capability to nfs_v4_2_minor_ops, so I'm not sure how it ended up modifying nfs_v4_1_minor_ops instead.  Anyway, I just posted a fix to set the flag in the right place.

Given that the caps were the same before this is something that patch
can easily do when applying patches with a fuzz.
