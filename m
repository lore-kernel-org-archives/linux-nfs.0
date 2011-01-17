From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] NFS4: Avoid potential NULL pointer dereference in
 decode_and_add_ds().
Date: Mon, 17 Jan 2011 19:42:26 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101171941560.27021@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1101162145290.13377@swampdragon.chaosbits.net> <AANLkTik+Z5C89Hb9Xu3az=deMsXj4rqvYpU=i7vXgdFx@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-kernel@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:14848 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab1AQSm0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jan 2011 13:42:26 -0500
In-Reply-To: <AANLkTik+Z5C89Hb9Xu3az=deMsXj4rqvYpU=i7vXgdFx-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 17 Jan 2011, Fred Isaman wrote:

> On Sun, Jan 16, 2011 at 3:50 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> > strrchr() can return NULL if nothing is found. If this happens we'll
> > dereference a NULL pointer in
> > fs/nfs/nfs4filelayoutdev.c::decode_and_add_ds().
> >
> > I tried to find some other code that guarantees that this can never
> > happen but I was unsuccessful. So, unless someone else can point to some
> > code that ensures this can never be a problem, I believe this patch is
> > needed.
> >
> 
> The only guarantee is the assumption that the server isn't sending
> garbage.  As such, this patch looks good to me.
> 

Thanks. Can I add your Acked-by: if/when I resend the patch?

-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

