Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42945 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227AbbKWTFf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2015 14:05:35 -0500
Date: Mon, 23 Nov 2015 14:05:34 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: Re: [patch] nfsd: fix a warning message
Message-ID: <20151123190534.GC12032@fieldses.org>
References: <20151121102850.GA7002@mwanda>
 <20151122080418.65d93f86@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151122080418.65d93f86@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 22, 2015 at 08:04:18AM -0500, Jeff Layton wrote:
> On Sat, 21 Nov 2015 13:28:50 +0300
> Dan Carpenter <dan.carpenter@oracle.com> wrote:

Thanks, applying for 4.5.--b.

> 
> > The WARN() macro takes a condition and a format string.  The condition
> > was accidentally left out here so it just prints the function name
> > instead of the message.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 6b800b5..7af023f 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -2240,7 +2240,8 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
> >  	base = resp->cstate.data_offset;
> >  	slot->sl_datalen = buf->len - base;
> >  	if (read_bytes_from_xdr_buf(buf, base, slot->sl_data, slot->sl_datalen))
> > -		WARN("%s: sessions DRC could not cache compound\n", __func__);
> > +		WARN(1, "%s: sessions DRC could not cache compound\n",
> > +		     __func__);
> >  	return;
> >  }
> >  
> 
> Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
