From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/23] Shorter series for 2.6.30
Date: Tue, 24 Mar 2009 18:49:06 -0400
Message-ID: <20090324224906.GT19389@fieldses.org>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:39323 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755284AbZCXWtK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2009 18:49:10 -0400
In-Reply-To: <20090319004024.32404.68289.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 18, 2009 at 08:45:17PM -0400, Chuck Lever wrote:
> Hi Trond, Bruce-
> 
> Since Trond has sent some late-breaking patches for 2.6.29, I had to
> fix some merge problems with my latest patch set.  Jeff also found a
> minor bug with rpcbind version 4 replies that I'd like to include.
> 
> I've stripped this patch set down so it is just 23 patches.
> Unfortunately, it touches server-side RPC stuff and client-side NFSv4
> callback and lockd support.  I don't see a clean way to split these up.
> 
> Can we discuss how to get these into 2.6.30?  Perhaps, since these have
> the greatest impact on client behavior, Trond should take all of these?

Except as noted (#2), I'm fine with them.  Happy to apply them to my
tree, or if Trond takes them, he can add an

	Acked-by: J. Bruce Fields <bfields@citi.umich.edu>

as desired to spread the blame around.

--b.
