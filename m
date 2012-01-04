Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10021 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756829Ab2ADWDf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2012 17:03:35 -0500
Message-ID: <1325714612.25276.1.camel@lade.trondhjem.org>
Subject: Re: [PATCH] NFS: Fix a few issues with cached state owners
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 04 Jan 2012 17:03:32 -0500
In-Reply-To: <A9614C89-6666-420F-B945-B5C879034086@oracle.com>
References: <1325697256.18462.24.camel@lade.trondhjem.org>
	 <1325713927-25519-1-git-send-email-Trond.Myklebust@netapp.com>
	 <BB6B1D30-BEA3-402E-BF77-1C21F182C46F@oracle.com>
	 <A9614C89-6666-420F-B945-B5C879034086@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2012-01-04 at 16:58 -0500, Chuck Lever wrote: 
> On Jan 4, 2012, at 4:56 PM, Chuck Lever wrote:
> 
> > 
> > On Jan 4, 2012, at 4:52 PM, Trond Myklebust wrote:
> > 
> >> The garbage collector needs to remove the entry from the lru list
> >> _and_ the red-black tree atomically in order avoid races in
> >> nfs4_get_state_owner.
> >> 
> >> Fix a case in nfs4_get_state_owner in which the garbage-collector
> >> list was being manipulated while not holding the appropriate spin
> >> lock.
> >> 
> >> nfs4_drop_state_owner doesn't need to look at sp->so_lru: the caller
> >> must have a reference to the state owner, so it can't be on the
> >> garbage-collection list.
> >> 
> >> Run the garbage collector _after_ we've looked up the state owner
> >> for efficiency reasons.
> >> 
> >> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> 
> You might consider squashing this with my patch.  The list_del_init() outside the cl_lock is enough to warrant it.

Sure, as long as you're fine with that.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

