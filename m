Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:48055 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752371Ab0G0Dnw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jul 2010 23:43:52 -0400
Subject: Re: [PATCH 1/6] Add a dentry op to handle automounting rather than
 abusing follow_link() [ver #2]
From: Ian Kent <raven@themaw.net>
To: David Howells <dhowells@redhat.com>
Cc: viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <30118.1280159695@redhat.com>
References: <1280157768.3569.14.camel@localhost>
	 <1279944664.2944.8.camel@localhost>
	 <20100722175847.5552.11520.stgit@warthog.procyon.org.uk>
	 <17723.1279897759@redhat.com> <9168.1280153997@redhat.com>
	 <30118.1280159695@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 27 Jul 2010 11:43:45 +0800
Message-ID: <1280202225.2944.20.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-07-26 at 16:54 +0100, David Howells wrote:
> Ian Kent <raven@themaw.net> wrote:
> 
> > > Does it make autofs easier if d_op->d_automount() is allowed to return
> > > -EXDEV to request this?  Then you can return it in Oz mode to allow the
> > > daemon to see/use the underlying mountpoint without recursing back into
> > > d_automount().
> > 
> > Yes, it's really useful.
> 
> I think what's required, then, is if d_automount() returns -EXDEV then:
> 
>  (1) If the dentry is terminal in the lookup path, then we just return -EXDEV
>      to indicate to __follow_mount() that we really do want to stop there.
> 
>  (2) If the dentry is not terminal, then we convert the error to -EREMOTE to
>      indicate that we can't complete the pathwalk as one of the earlier
>      components is inaccessible.

Is this something others need?

Again, the exists vs not yet exists case for paths within indirect
autofs mounts. At the moment I can just set the flag on all dentrys in
the autofs fs and return EXDEV for non-empty directories in order to
return the dentry as a path component. OTOH if the dentry is a mount
embeded in the path and the mount fails we get a error return.

I could clear the flag on non-root parent dentrys during mkdir if this
is needed by others.
  
> 
> See the attached patch.
> 
> David
> ---
> diff --git a/fs/namei.c b/fs/namei.c
> index c154112..6c385d4 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -653,8 +653,20 @@ static int follow_automount(struct path *path, unsigned flags, int res)
>  		return -ELOOP;
>  
>  	mnt = path->dentry->d_op->d_automount(path);
> -	if (IS_ERR(mnt))
> +	if (IS_ERR(mnt)) {
> +		/*
> +		 * The filesystem is allowed to return -EXDEV here to indicate
> +		 * they don't want to automount.  For instance, autofs would do
> +		 * this so that its userspace daemon can mount on this dentry.
> +		 *
> +		 * However, we can only permit this if it's a terminal point in
> +		 * the path being looked up; if it wasn't then the remainder of
> +		 * the path is inaccessible and we should say so.
> +		 */
> +		if (PTR_ERR(mnt) == -EXDEV && (flags & LOOKUP_CONTINUE))
> +			return -EREMOTE;
>  		return PTR_ERR(mnt);
> +	}
>  	if (!mnt) /* mount collision */
>  		return 0;
>  
> 


