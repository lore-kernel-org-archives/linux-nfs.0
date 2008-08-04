From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: kernel BUG at fs/nfs/namespace.c:108!
Date: Mon, 4 Aug 2008 13:48:47 -0400
Message-ID: <20080804174847.GB25940@fieldses.org>
References: <72924.9082.qm@web39205.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Shahar Klein <shaharklein@yahoo.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43603 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751552AbYHDRst (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Aug 2008 13:48:49 -0400
In-Reply-To: <72924.9082.qm-OZWcxxNrvPKvuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 03, 2008 at 03:07:53AM -0700, Shahar Klein wrote:
> Hi  All
> 
> I came across this panic due to bad server and I am wondering
> why should an nfs client panic when stumbling upon an IS_ROOT dentry
> in the point where it tries to cross mount. I mean: should an 'Innocent' client
> 'pay' for bad server behavior?

Certainly I agree with the principle that a misbehaving server shouldn't
cause the client to panic, but how exactly does that happen here?  (How
will nfs_follow_mountpoint get called on a root dentry?)

--b.

> 
> Is it unsafe to just clear the path and return error?
> 
> 
> --- a/namespace.c       2008-08-03 12:29:21.000000000 +0300
> +++ b/namespace.c       2008-08-03 12:30:54.000000000 +0300
> @@ -100,7 +100,11 @@
> 
>         dprintk("--> nfs_follow_mountpoint()\n");
>   
> -       BUG_ON(IS_ROOT(dentry));
> +       if (IS_ROOT(dentry)) {
> +                 err = -EBUSY; // or any reasonable error
> +                 goto out_err;
> +                                                                                
> +       }
>         dprintk("%s: enter\n", __FUNCTION__);
>         dput(nd->dentry);
>         nd->dentry = dget(dentry);
> 
> 
> 
>       
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
