Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19263 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758249Ab1FKAw2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 20:52:28 -0400
Subject: Re: [patch 1/1]: fix bug in CREATE_SESSION encoding
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <benny@tonian.com>
Cc: Sid Moore <learnmost@gmail.com>, linux-nfs@vger.kernel.org
Date: Fri, 10 Jun 2011 20:52:27 -0400
In-Reply-To: <4DF276A0.6080504@tonian.com>
References: <BANLkTikv_vi7eR8Xu-_K5F5D5Smrj=goog@mail.gmail.com>
	 <4DF276A0.6080504@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1307753547.3421.6.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-06-10 at 15:55 -0400, Benny Halevy wrote: 
> On 2011-06-10 02:32, Sid Moore wrote:
> > Hi
> > 
> > I think it might be an error when typing. see the patch below.
> > 
> > 
> > --- a/fs/nfs/nfs4xdr.c
> > +++ b/fs/nfs/nfs4xdr.c
> > @@ -1772,7 +1772,7 @@ static void encode_create_session(struct xdr_stream *xdr,
> >         *p++ = cpu_to_be32(0);                          /* rdmachannel_attrs */
> > 
> >         /* Back Channel */
> > -       *p++ = cpu_to_be32(args->fc_attrs.headerpadsz); /* header
> > padding size */
> > +       *p++ = cpu_to_be32(args->bc_attrs.headerpadsz); /* header
> > padding size */
> >         *p++ = cpu_to_be32(args->bc_attrs.max_rqst_sz); /* max req size */
> >         *p++ = cpu_to_be32(args->bc_attrs.max_resp_sz); /* max resp size */
> >         *p++ = cpu_to_be32(args->bc_attrs.max_resp_sz_cached);  /* Max
> > resp sz cached */
> > 
> > --
> > Sid
> > --
> 
> Thanks for spotting this!
> Since we don't support header padding yet the following patch
> might be more appropriate.
> Trond, what do you think?

Agreed. If it is unused, then let's ditch it...

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

