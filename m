Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36342 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753996AbaH2TqZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Aug 2014 15:46:25 -0400
Date: Fri, 29 Aug 2014 15:46:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd4: fix rd_dircount enforcement
Message-ID: <20140829194624.GB13710@fieldses.org>
References: <20140829185510.GA13710@fieldses.org>
 <CAHQdGtQyZ0prJLpsDZ_E+qiF9OoxrxEtLOZw7w88eSTejYd=RA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQyZ0prJLpsDZ_E+qiF9OoxrxEtLOZw7w88eSTejYd=RA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 29, 2014 at 03:29:07PM -0400, Trond Myklebust wrote:
> On Fri, Aug 29, 2014 at 2:55 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> >
> > Commit 3b299709091b "nfsd4: enforce rd_dircount" totally misunderstood
> > rd_dircount; it refers to total non-attribute bytes returned, not number
> > of directory entries returned.
> >
> > Bring the code into agreement with RFC 3530 section 14.2.24.
> >
> > Cc: stable@kernel.org
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/nfsd/nfs4xdr.c | 14 +++++++++++++-
> >  1 file changed, 13 insertions(+), 1 deletion(-)
> >
> > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > index f9821ce6658a..e94457c33ad6 100644
> > --- a/fs/nfsd/nfs4xdr.c
> > +++ b/fs/nfsd/nfs4xdr.c
> > @@ -2657,6 +2657,7 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
> >         struct xdr_stream *xdr = cd->xdr;
> >         int start_offset = xdr->buf->len;
> >         int cookie_offset;
> > +       u32 name_and_cookie;
> >         int entry_bytes;
> >         __be32 nfserr = nfserr_toosmall;
> >         __be64 wire_offset;
> > @@ -2718,7 +2719,14 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
> >         cd->rd_maxcount -= entry_bytes;
> >         if (!cd->rd_dircount)
> >                 goto fail;
> > -       cd->rd_dircount--;
> > +       /*
> > +        * RFC 3530 14.2.24 describes rd_dircount as only a "hint", so
> > +        * let's always let through the first entry, at least:
> > +        */
> > +       name_and_cookie = 4 * XDR_QUADLEN(namlen) + 8;
> > +       if (name_and_cookie > cd->rd_dircount && cd->cookie_offset)
> > +               goto fail;
> > +       cd->rd_dircount -= min(cd->rd_dircount, name_and_cookie);
> >         cd->cookie_offset = cookie_offset;
> >  skip_entry:
> >         cd->common.err = nfs_ok;
> > @@ -3321,6 +3329,10 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
> >         }
> >         maxcount = min_t(int, maxcount-16, bytes_left);
> >
> > +       /* RFC 3530 14.2.24 allows us to ignore dircount when it's 0: */
> > +       if (!readdir->rd_dircount)
> > +               readdir->rd_dircount = INT_MAX;
> > +
> 
> Ah... Time to change the Linux client to always set this value to 0.
> It really is useless in our case.

I didn't look at the client.  Hm:

	uint32_t dircount = readdir->count >> 1
	...
	*p++ = cpu_to_be32(dircount);
	*p++ = cpu_to_be32(readdir->count);

Yeah, that's kind of arbitrary.  This dircount thing is just inherently
weird.  We could just revert the server back to ignoring it completely
like it used to--the spec only says it's a "hint", whatever that means.
But presumably somebody must have thought they had a use for it.

--b.
