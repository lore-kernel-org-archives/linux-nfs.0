From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 08/27] NSM: Add dprintk() calls in nsm_find and nsm_release
Date: Wed, 10 Dec 2008 16:10:41 -0500
Message-ID: <8CE84D92-B1D9-4A91-BCDC-385653C8DE0E@oracle.com>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net> <20081206000252.24075.51827.stgit@ingres.1015granger.net> <20081210210501.GG1212@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:48816 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828AbYLJVK5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2008 16:10:57 -0500
In-Reply-To: <20081210210501.GG1212@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 10, 2008, at Dec 10, 2008, 4:05 PM, J. Bruce Fields wrote:

> On Fri, Dec 05, 2008 at 07:02:53PM -0500, Chuck Lever wrote:
>> Introduce some dprintk() calls in fs/lockd/mon.c that are enabled by
>> the NLMDBG_MONITOR flag.  These report when we find, create, and
>> release nsm_handles.
>>
>> Since printk() can sleep, these are placed outside the nsm_lock
>> spinlock.
>
> Nope, printk() is designed to be callable from anywhere.  (This is
> documented e.g. in kernel/printk.c:printk().)  I've applied the
> following; look OK?

That's fine, but it will make applying later patches more difficult.

I can fix this up in my repo and resend subsequent patches if you  
like, or you can just delete that last sentence in the description,  
and apply this patch as is.

> --b.
>
> commit dfe441d67b96543eb8cdebd5323c3239e5460213
> Author: Chuck Lever <chuck.lever@oracle.com>
> Date:   Fri Dec 5 19:02:53 2008 -0500
>
>    NSM: Add dprintk() calls in nsm_find and nsm_release
>
>    Introduce some dprintk() calls in fs/lockd/mon.c that are enabled  
> by
>    the NLMDBG_MONITOR flag.  These report when we find, create, and
>    release nsm_handles.
>
>    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index d5bd847..c332c50 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -250,10 +250,15 @@ retry:
> 		atomic_inc(&pos->sm_count);
> 		kfree(nsm);
> 		nsm = pos;
> +		dprintk("lockd: found nsm_handle for %s (%s), cnt %d\n",
> +				pos->sm_name, pos->sm_addrbuf,
> +				atomic_read(&pos->sm_count));
> 		goto found;
> 	}
> 	if (nsm) {
> 		list_add(&nsm->sm_link, &nsm_handles);
> +		dprintk("lockd: created nsm_handle for %s (%s)\n",
> +				nsm->sm_name, nsm->sm_addrbuf);
> 		goto found;
> 	}
> 	spin_unlock(&nsm_lock);
> @@ -292,6 +297,8 @@ void nsm_release(struct nsm_handle *nsm)
> 	if (atomic_dec_and_lock(&nsm->sm_count, &nsm_lock)) {
> 		list_del(&nsm->sm_link);
> 		spin_unlock(&nsm_lock);
> +		dprintk("lockd: destroyed nsm_handle for %s (%s)\n",
> +				nsm->sm_name, nsm->sm_addrbuf);
> 		kfree(nsm);
> 	}
> }

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




