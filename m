Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37457 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759693Ab3JPSzd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Oct 2013 14:55:33 -0400
Date: Wed, 16 Oct 2013 14:55:31 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Andi Kleen <andi@firstfloor.org>,
        "kwc@citi.umich.edu" <kwc@citi.umich.edu>
Subject: Re: [PATCH] sunrpc: trim off EC bytes in addition to the checksum
 blob when doing a GSSAPI v2 unwrap
Message-ID: <20131016185531.GC19067@fieldses.org>
References: <1381427810-10633-1-git-send-email-jlayton@redhat.com>
 <1381949005.17178.10.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381949005.17178.10.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 16, 2013 at 06:43:26PM +0000, Myklebust, Trond wrote:
> On Thu, 2013-10-10 at 13:56 -0400, Jeff Layton wrote:
> > As Bruce points out in RFC 4121, section 4.2.3:
> > 
> >    "In Wrap tokens that provide for confidentiality, the first 16 octets
> >     of the Wrap token (the "header", as defined in section 4.2.6), SHALL
> >     be appended to the plaintext data before encryption.  Filler octets
> >     MAY be inserted between the plaintext data and the "header.""
> > 
> > ...and...
> > 
> >    "In Wrap tokens with confidentiality, the EC field SHALL be used to
> >     encode the number of octets in the filler..."
> > 
> > It's possible for the client to stuff different data in that area on a
> > retransmission, which could make the checksum come out wrong in the DRC
> > code.
> > 
> > After decrypting the blob, we should trim off any extra count bytes in
> > addition to the checksum blob.
> > 
> > Reported-by: "J. Bruce Fields" <bfields@fieldses.org>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  net/sunrpc/auth_gss/gss_krb5_wrap.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > index 1da52d1..ec1f4d0 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > @@ -574,8 +574,8 @@ gss_unwrap_kerberos_v2(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
> >  	buf->head[0].iov_len -= GSS_KRB5_TOK_HDR_LEN + headskip;
> >  	buf->len -= GSS_KRB5_TOK_HDR_LEN + headskip;
> >  
> > -	/* Trim off the checksum blob */
> > -	xdr_buf_trim(buf, GSS_KRB5_TOK_HDR_LEN + tailskip);
> > +	/* Trim off the trailing "extra count" and checksum blob */
> > +	xdr_buf_trim(buf, ec + GSS_KRB5_TOK_HDR_LEN + tailskip);
> >  	return GSS_S_COMPLETE;
> >  }
> >  
> 
> If this is just padding, then why would it be anything other than '0',
> even on a retransmission? Clients are not supposed to leak random data
> to the server...

Right, the problem wasn't random padding data.

The problem was just with the xdr_buf length being wrong.  The nfsd drc
uses the length, and will notice if the length differs between two
otherwise identical rpc's.  So you'd have to have a pretty weird client
gss implementation, one that not only uses EC but that for some reason
uses a different EC value on retransmission.  I don't know if that's
even possible.

Currently there doesn't seem to be any other code that cares if buf->len
is right(the xdr decoding would only notice if buf->len is too short,
not if it's too long), but we should still try to get it right....

--b.
