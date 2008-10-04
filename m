From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/3] client-side lockd doesn't start UDP listener
Date: Sat, 4 Oct 2008 17:36:25 -0400
Message-ID: <20081004213625.GA3709@fieldses.org>
References: <20081003211305.9870.6835.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50270 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753209AbYJDVga (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Oct 2008 17:36:30 -0400
In-Reply-To: <20081003211305.9870.6835.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 03, 2008 at 05:15:14PM -0400, Chuck Lever wrote:
> Hi Bruce, Neil-
> 
> Here's my initial proposal to address the NFSv2/v3 lock recovery issue 
> that results from having no UDP lockd listener.
> 
> Comments?  Did I miss anything?

Looks fine; I can't see any problem.  So I've applied to for-2.6.28.
(An ack from Neil would be reassuring, though, if he gets a chance.)

--b.

> 
> ---
> 
> Chuck Lever (3):
>       NLM: Remove unused argument from svc_addsock() function
>       NLM: Remove "proto" argument from lockd_up()
>       NLM: Always start both UDP and TCP listeners
> 
>  fs/lockd/clntlock.c            |    4 ++--
>  fs/lockd/svc.c                 |   40 ++++++++++++++++++++--------------------
>  fs/nfsd/nfsctl.c               |    5 ++---
>  fs/nfsd/nfssvc.c               |   19 +++++++------------
>  include/linux/lockd/bind.h     |    2 +-
>  include/linux/sunrpc/svcsock.h |    5 +----
>  net/sunrpc/svcsock.c           |    4 +---
>  7 files changed, 34 insertions(+), 45 deletions(-)
> 
> -- 
> Chuck Lever
