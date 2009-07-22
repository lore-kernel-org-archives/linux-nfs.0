From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs4 write delegation status
Date: Wed, 22 Jul 2009 12:38:10 -0400
Message-ID: <20090722163810.GB4491@fieldses.org>
References: <fe2cbb740907211447t4dfcc0dara63bb96648599638@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
To: "David V. Cloud" <david.v.cloud@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33934 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753484AbZGVQiK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2009 12:38:10 -0400
In-Reply-To: <fe2cbb740907211447t4dfcc0dara63bb96648599638-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 21, 2009 at 05:47:17PM -0400, David V. Cloud wrote:
> Hi all,
> I was playing with nfs4 delegation, finding out that write delegations have
> never been granted. I am using Benny Halevy's git tree with latest
> pnfs-block-all branch. With rpcdebug,  I found out that the write-delegation
> grant was rejected due to setlease failure with error code (-11, which is
> -EAGAIN). I finally figured out that this failure was caused by the
> following lines in generic_setlease function,
> 
>         if ((arg == F_WRLCK)
>             && ((atomic_read(&dentry->d_count) > 1)
>             || (atomic_read(&inode->i_count) > 1)))
>             goto out;
> 
> In my nfsd, the i_count, and d_count turn out to be 2 (no conflicts actaully
> exist in my test case), so write-delegations always failed. I did find some
> similar posts on nfs4 related mail lists about this problem. One possible
> hack by Ajay could be found at
> http://osdir.com/ml/linux.nfsv4/2006-08/msg00063.html
> 
> I am curious whether there is any progress in awarding write delegation in
> current linux nfs4 implementation (for example, any git branch with write
> delegation enabled I can pull?) Or, is write-delegation feature available in
> other systems like OpenSolaris?
> 
> Any suggestion if I would like to enable and test write delegation? I think
> some changes are needed to the setlease interface, right?

I really don't want to enable write delegations until we figure out how
to enforce them correctly against local (non-nfs) users of the exported
filesystem as well.  In addition to breaking delegations on read opens,
that means breaking delegations or doing a cb_getattr on operations like
stat.

--b.
