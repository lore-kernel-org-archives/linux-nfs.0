Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44750 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138AbaLRP6j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2014 10:58:39 -0500
Date: Thu, 18 Dec 2014 10:58:38 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "J. R. Okajima" <hooanon05g@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@primarydata.com>
Subject: Re: [PATCH] dcache: return -ESTALE not -EBUSY on distributed fs race
Message-ID: <20141218155838.GD18179@fieldses.org>
References: <20141217195911.GF9617@fieldses.org>
 <20141217200153.GG9617@fieldses.org>
 <12689.1418917838@jrobl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <12689.1418917838@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 19, 2014 at 12:50:38AM +0900, J. R. Okajima wrote:
> 
> "J. Bruce Fields":
> > It's still kind of a bandaid, but it's the only thing I've thought of
> > that at least helps a little and isn't a huge pain.  Any other ideas?
> 
> How about introducing a tiny inline function which returns either EBUSY
> or ESTALE?
> 
> static inline int busy_or_stale()
> {
> 	if (!test_distributed_fs())
> 		return -EBUSY;
> 	return -ESTALE;
> }

Why do you think -EBUSY's the right error in the local filesystem case?

This condition really shouldn't happen in the local filesystem case
anyway.  If anything maybe it should be -EIO, since it looks like a sign
your filesystem's corrupted.

> For nfs, the test function will be something like this.
> 
> int test_nfsd()
> {
> 	int ret;
> 	struct task_struct *tsk = current;
> 	char comm[sizeof(tsk->comm)];
> 
> 	ret = 0;
> 	if (tsk->flags & PF_KTHREAD) {
> 		get_task_comm(comm, tsk);
> 		ret = !strcmp(comm, "nfsd");
> 	}
> 
> 	return ret;
> }
> 
> I know this "by-name" test is not good.

Also you'd want to be checking for nfs, not nfsd.

--b.
