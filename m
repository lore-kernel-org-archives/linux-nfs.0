Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34206 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758694Ab0J1NlW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 09:41:22 -0400
Subject: Re: [patch] nfs: check kmalloc() return
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: wharms@bfs.de
Cc: Dan Carpenter <error27@gmail.com>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
In-Reply-To: <4CC92338.7070304@bfs.de>
References: <20101028044403.GV6062@bicker>  <4CC92338.7070304@bfs.de>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Oct 2010 09:41:13 -0400
Message-ID: <1288273273.3194.16.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-10-28 at 09:16 +0200, walter harms wrote:
> 
> Dan Carpenter schrieb:
> > The decode_and_add_ds() should return NULL on failure.
> > 
> > Signed-off-by: Dan Carpenter <error27@gmail.com>
> > 
> > diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> > index 51fe64a..098113c 100644
> > --- a/fs/nfs/nfs4filelayoutdev.c
> > +++ b/fs/nfs/nfs4filelayoutdev.c
> > @@ -219,6 +219,8 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
> >  		goto out_err;
> >  	}
> >  	buf = kmalloc(rlen + 1, GFP_KERNEL);
> > +	if (!buf)
> > +		goto out_err;
> >  	buf[rlen] = '\0';
> >  	memcpy(buf, r_addr, rlen);
> >  
> 
> it seems that r_addr is a string, then kstdup() is emulated here.
> 
> re,
>  wh

Not quite. kstrdup() requires that the argument be a NUL-terminated
string. The above code doesn't.

Trond
