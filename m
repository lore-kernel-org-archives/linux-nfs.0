Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752530AbaLIT5T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 14:57:19 -0500
Date: Tue, 9 Dec 2014 14:57:15 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: linux-nfs@vger.kernel.org, dros@netapp.com
Subject: Re: [PATCH 1/2] nfsd4: fix xdr4 inclusion of escaped char
In-Reply-To: <20141209192406.GN20526@fieldses.org>
Message-ID: <alpine.OSX.2.19.9992.1412091429430.92934@planck.local>
References: <cover.1417985975.git.bcodding@redhat.com> <8ec7a52c7b6b5287e8bd87503834bae46377f3ef.1417985975.git.bcodding@redhat.com> <20141209192406.GN20526@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 9 Dec 2014, J. Bruce Fields wrote:

> On Sun, Dec 07, 2014 at 04:05:47PM -0500, Benjamin Coddington wrote:
> > Fix a bug where nfsd4_encode_components_esc() includes the esc_end char as
> > an additional string encoding.
>
> Has it had this problem since the escaping was added by e7a0444aef4a
> "mfsd" add addr escaping to fs_location hosts"?  I wonder why it wasn't
> noticed then.  Maybe the client always just chooses the first entry and
> doesn't care if there's a second entry for a host named "]".
>
> --b.

I think it has been there all along.  The linux client doesn't appear to
care about the second entry.

Ben

> >
> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > ---
> >  fs/nfsd/nfs4xdr.c |    3 +++
> >  1 files changed, 3 insertions(+), 0 deletions(-)
> >
> > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > index eeea7a9..6c92a53 100644
> > --- a/fs/nfsd/nfs4xdr.c
> > +++ b/fs/nfsd/nfs4xdr.c
> > @@ -1795,6 +1795,9 @@ static __be32 nfsd4_encode_components_esc(struct xdr_stream *xdr, char sep,
> >  		}
> >  		else
> >  			end++;
> > +		if (found_esc)
> > +			end = next;
> > +
> >  		str = end;
> >  	}
> >  	pathlen = htonl(xdr->buf->len - pathlen_offset);
> > --
> > 1.7.1
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
