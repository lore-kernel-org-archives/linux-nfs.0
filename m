Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mfb02-md.ns.itscom.net ([175.177.155.110]:47269 "EHLO
	mfb02-md.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbaLRP75 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Dec 2014 10:59:57 -0500
Received: from mail02-md.ns.itscom.net (mail02-md.ns.itscom.net [175.177.155.112])
	by mfb02-md.ns.itscom.net (Postfix) with ESMTP id D43ED170EA07
	for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2014 00:50:41 +0900 (JST)
From: "J. R. Okajima" <hooanon05g@gmail.com>
Subject: Re: [PATCH] dcache: return -ESTALE not -EBUSY on distributed fs race
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@primarydata.com>
In-Reply-To: <20141217200153.GG9617@fieldses.org>
References: <20141217195911.GF9617@fieldses.org> <20141217200153.GG9617@fieldses.org>
Date: Fri, 19 Dec 2014 00:50:38 +0900
Message-ID: <12689.1418917838@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


"J. Bruce Fields":
> It's still kind of a bandaid, but it's the only thing I've thought of
> that at least helps a little and isn't a huge pain.  Any other ideas?

How about introducing a tiny inline function which returns either EBUSY
or ESTALE?

static inline int busy_or_stale()
{
	if (!test_distributed_fs())
		return -EBUSY;
	return -ESTALE;
}

For nfs, the test function will be something like this.

int test_nfsd()
{
	int ret;
	struct task_struct *tsk = current;
	char comm[sizeof(tsk->comm)];

	ret = 0;
	if (tsk->flags & PF_KTHREAD) {
		get_task_comm(comm, tsk);
		ret = !strcmp(comm, "nfsd");
	}

	return ret;
}

I know this "by-name" test is not good.


J. R. Okajima
