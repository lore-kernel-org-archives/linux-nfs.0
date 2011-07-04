Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:10915 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753583Ab1GDJNi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jul 2011 05:13:38 -0400
Date: Mon, 4 Jul 2011 11:04:15 +0200 (CEST)
From: Jesper Juhl <jj@chaosbits.net>
To: Chuck Lever <chuck.lever@oracle.com>
cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, Gero Kuhlmann <gero@gkminix.han.de>
Subject: Re: [PATCH] nfs: Don't deref potentially NULL pointer returned by
 strsep
In-Reply-To: <14B45086-2D98-4706-B1FE-7EBB8E777EEF@oracle.com>
Message-ID: <alpine.LNX.2.00.1107041102001.24059@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1107030938430.16316@swampdragon.chaosbits.net> <14B45086-2D98-4706-B1FE-7EBB8E777EEF@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 3 Jul 2011, Chuck Lever wrote:

> 
> On Jul 3, 2011, at 3:40 AM, Jesper Juhl wrote:
> 
> > In fs/nfs/nfsroot.c:root_nfs_parse_options() we call strsep(), which
> > may return NULL, but we do not test the return value before
> > dereferencing the pointer.
> > 
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> > ---
> > fs/nfs/nfsroot.c |    2 ++
> > 1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> >  Compile tested only.
> > 
> > diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
> > index c4744e1..b6ac860 100644
> > --- a/fs/nfs/nfsroot.c
> > +++ b/fs/nfs/nfsroot.c
> > @@ -191,6 +191,8 @@ static int __init root_nfs_parse_options(char *incoming, char *exppath,
> > 	 * Set the NFS remote path
> > 	 */
> > 	p = strsep(&incoming, ",");
> > +	if (!p)
> > +		return -1;
> 
> strsep() may return NULL only if the value of "incoming" is NULL.  But 
> callers ensure that "incoming" always contains the address of a fixed 
> buffer.  Thus if strsep() returns NULL here there is some kind of 
> programming error; it's not the result of invalid input.
> 
> Do you have a reproducible test case to make this fail?
> 
Nope. I simply spotted the unchecked strsep() call and thought that it 
would be better to be defensive and check it in case callers change in the 
future and a bug creeps in that causes a NULL incoming to be passed. 
Perhaps a BUG_ON(!incoming) would be better - or perhaps just forget about 
it.

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

