From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 10/27] NSM: Remove !nsm check from nsm_release()
Date: Wed, 10 Dec 2008 16:11:05 -0500
Message-ID: <20081210211104.GH1212@fieldses.org>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net> <20081206000308.24075.73629.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49538 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752828AbYLJVLI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2008 16:11:08 -0500
In-Reply-To: <20081206000308.24075.73629.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 05, 2008 at 07:03:09PM -0500, Chuck Lever wrote:
> The nsm_release() function should never be called with a NULL handle
> point.  If it is, that's a bug.

OK, both applied.--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/lockd/mon.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index f3ae631..c2f4607 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -288,8 +288,6 @@ retry:
>   */
>  void nsm_release(struct nsm_handle *nsm)
>  {
> -	if (!nsm)
> -		return;
>  	if (atomic_dec_and_lock(&nsm->sm_count, &nsm_lock)) {
>  		list_del(&nsm->sm_link);
>  		spin_unlock(&nsm_lock);
> 
