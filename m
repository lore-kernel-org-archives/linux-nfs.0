Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:58564 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641Ab1GCOzs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Jul 2011 10:55:48 -0400
Subject: Re: [PATCH] nfs: Don't deref potentially NULL pointer returned by strsep
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <alpine.LNX.2.00.1107030938430.16316@swampdragon.chaosbits.net>
Date: Sun, 3 Jul 2011 10:09:32 -0400
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, Gero Kuhlmann <gero@gkminix.han.de>
Message-Id: <14B45086-2D98-4706-B1FE-7EBB8E777EEF@oracle.com>
References: <alpine.LNX.2.00.1107030938430.16316@swampdragon.chaosbits.net>
To: Jesper Juhl <jj@chaosbits.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jul 3, 2011, at 3:40 AM, Jesper Juhl wrote:

> In fs/nfs/nfsroot.c:root_nfs_parse_options() we call strsep(), which
> may return NULL, but we do not test the return value before
> dereferencing the pointer.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
> fs/nfs/nfsroot.c |    2 ++
> 1 files changed, 2 insertions(+), 0 deletions(-)
> 
>  Compile tested only.
> 
> diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
> index c4744e1..b6ac860 100644
> --- a/fs/nfs/nfsroot.c
> +++ b/fs/nfs/nfsroot.c
> @@ -191,6 +191,8 @@ static int __init root_nfs_parse_options(char *incoming, char *exppath,
> 	 * Set the NFS remote path
> 	 */
> 	p = strsep(&incoming, ",");
> +	if (!p)
> +		return -1;

strsep() may return NULL only if the value of "incoming" is NULL.  But callers ensure that "incoming" always contains the address of a fixed buffer.  Thus if strsep() returns NULL here there is some kind of programming error; it's not the result of invalid input.

Do you have a reproducible test case to make this fail?

> 	if (*p != '\0' && strcmp(p, "default") != 0)
> 		if (root_nfs_copy(exppath, p, exppathlen))
> 			return -1;

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



