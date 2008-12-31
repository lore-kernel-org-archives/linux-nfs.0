From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/5] recent patches conflict with Harvey's printf
	formatters
Date: Tue, 30 Dec 2008 20:43:56 -0500
Message-ID: <20081231014356.GD30341@fieldses.org>
References: <20081229221603.28005.42498.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:34958 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959AbYLaBn6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Dec 2008 20:43:58 -0500
In-Reply-To: <20081229221603.28005.42498.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 29, 2008 at 05:20:07PM -0500, Chuck Lever wrote:
> Hi Bruce-
> 
> I pulled from Linus's tree today, and found that Harvey's IP address print
> formatters have already been merged.  I had conflicts with some of the NSM
> IPv6 patches I've already sent you that use the old NIP macros.
> 
> Here are the conflicting patches, updated to use Harvey's new formatters.
> You may have already done some of this work to merge your NFSD tree into
> linux-next, but I did update at least one patch description.

Thanks, done.  (I rebased my for-2.6.29 branch onto latest linus tip,
merged by hand, then did a diff-of-diffs between my results and yours,
which just caught the one commit message edit.)  The result is at

	git://linux-nfs.org/~bfields/linux.git for-2.6.29

I expect I'll be more completely back at work Jan. 1 or 2nd, look
through my mailbox for any more stragglers at that point, then send
Linus a pull message by early next week.

--b.

> 
> I have already updated the NFSD patches that are still pending, so you'll
> get those changes when I resend that series.
> 
> ---
> 
> Chuck Lever (5):
>       NSM: Move nsm_find() to fs/lockd/mon.c
>       NSM: Support IPv6 version of mon_name
>       NLM: Add helper to handle IPv4 addresses
>       NLM: Support IPv6 scope IDs in nlm_display_address()
>       NLM: Remove AF_UNSPEC arm in nlm_display_address()
> 
> 
>  fs/lockd/clntproc.c            |    6 -
>  fs/lockd/host.c                |  121 ------------
>  fs/lockd/mon.c                 |  411 +++++++++++++++++++++++++++++-----------
>  include/linux/lockd/lockd.h    |   25 ++
>  include/linux/lockd/sm_inter.h |   31 ---
>  5 files changed, 322 insertions(+), 272 deletions(-)
> 
> -- 
> Chuck Lever <chuck.lever@oracle.com>
