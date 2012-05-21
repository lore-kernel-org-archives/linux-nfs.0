Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60375 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754523Ab2EUQQs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 May 2012 12:16:48 -0400
Date: Mon, 21 May 2012 12:16:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 09/14] NFS: Force server to drop NFSv4 state
Message-ID: <20120521161646.GJ24299@fieldses.org>
References: <20120518220145.774.53741.stgit@degas.1015granger.net>
 <20120518220632.774.79191.stgit@degas.1015granger.net>
 <20120521160844.GH24299@fieldses.org>
 <F7B056E4-D6FC-450B-98E2-129C051CFAE7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F7B056E4-D6FC-450B-98E2-129C051CFAE7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 21, 2012 at 12:11:48PM -0400, Chuck Lever wrote:
> 
> On May 21, 2012, at 12:08 PM, J. Bruce Fields wrote:
> 
> > On Fri, May 18, 2012 at 06:06:33PM -0400, Chuck Lever wrote:
> >> @@ -3937,8 +3937,13 @@ static void nfs4_construct_boot_verifier(struct nfs_client *clp,
> >> {
> >> 	__be32 verf[2];
> >> 
> >> -	verf[0] = (__be32)clp->cl_boot_time.tv_sec;
> >> -	verf[1] = (__be32)clp->cl_boot_time.tv_nsec;
> >> +	if (test_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state)) {
> >> +		verf[0] = (__be32)CURRENT_TIME.tv_sec;
> >> +		verf[1] = (__be32)CURRENT_TIME.tv_nsec;
> > 
> > I suppose it's pretty unlikely this could happen within a jiffy of
> > setting cl_boot_time?
> 
> Boot time has nanosecond resolution.  I'm pretty sure we are safe here.

CURRENT_TIME is only updated every jiffy.  It would still have to happen
ridiculously fast, but I think that's milliseconds rather than
nanoseconds.

> > Would it be simpler to use some special value (all-zeros?) instead?
> 
> We'd have to pick a value that was guaranteed never to be a valid time stamp.

A client that thinks it's currently Jan. 1 1970 probably has bigger
problems.

I dunno, your call.

--b.
