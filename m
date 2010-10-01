Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out5.smtp.messagingengine.com ([66.111.4.29]:41874 "EHLO
	out5.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752499Ab0JAJGd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 05:06:33 -0400
Subject: Re: [PATCH 06/17] Add an AT_NO_AUTOMOUNT flag to suppress terminal
 automount
From: Ian Kent <raven@themaw.net>
To: David Howells <dhowells@redhat.com>
Cc: viro@ftp.linux.org.uk, jmoyer@redhat.com, linux-fs@vger.kernel.org,
        autofs@linux.kernel.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org
In-Reply-To: <20100930181526.30939.22704.stgit@warthog.procyon.org.uk>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
	 <20100930181526.30939.22704.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 01 Oct 2010 16:55:47 +0800
Message-ID: <1285923347.3207.7.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-09-30 at 19:15 +0100, David Howells wrote:
> Add an AT_NO_AUTOMOUNT flag to suppress terminal automounting of directories
> with follow_link semantics.  This can be used by fstatat() users to permit the
> gathering of attributes on an automount point and also prevent
> mass-automounting of a directory of automount points by ls.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> Acked-by: Ian Kent <raven@themaw.net>
> ---
> 
>  fs/namei.c            |    6 ++++++
>  fs/stat.c             |    4 +++-
>  include/linux/fcntl.h |    1 +
>  include/linux/namei.h |    2 ++
>  4 files changed, 12 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index 86421f9..74bce3a 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -625,6 +625,12 @@ static int follow_automount(struct path *path, unsigned flags,
>  	if (!path->dentry->d_op || !path->dentry->d_op->d_automount)
>  		return -EREMOTE;
>  
> +	/* We don't want to mount if someone supplied AT_NO_AUTOMOUNT
> +	 * and this is the terminal part of the path.
> +	 */
> +	if ((flags & LOOKUP_NO_AUTOMOUNT) && !(flags & LOOKUP_CONTINUE))
> +		return -EXDEV; /* we actually want to stop here */

Oops, we missed this -EXDEV when we made the change to -EISDIR.

Ian

