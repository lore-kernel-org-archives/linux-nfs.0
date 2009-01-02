From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] Two minor lockd clean-ups
Date: Thu, 1 Jan 2009 19:46:22 -0500
Message-ID: <20090102004622.GC32676@fieldses.org>
References: <20081231210449.4959.41094.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:59536 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107AbZABAqZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Jan 2009 19:46:25 -0500
In-Reply-To: <20081231210449.4959.41094.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 31, 2008 at 04:05:55PM -0500, Chuck Lever wrote:
> Hi Bruce-
> 
> Here are two clean-up patches from the end of my NFSD for-2.6.29
> series that are probably safe to include now.

Both applied, thanks.--b.

> 
> ---
> 
> Chuck Lever (2):
>       NLM: Clean up flow of control in make_socks() function
>       NLM: Refactor make_socks() function
> 
> 
>  fs/lockd/svc.c |   49 ++++++++++++++++++++++++++++---------------------
>  1 files changed, 28 insertions(+), 21 deletions(-)
> 
> -- 
> Chuck Lever <chuck.lever@oracle.com>
