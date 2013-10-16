Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3989 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756196Ab3JPTSo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Oct 2013 15:18:44 -0400
Date: Wed, 16 Oct 2013 15:18:27 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Andi Kleen <andi@firstfloor.org>,
        "kwc@citi.umich.edu" <kwc@citi.umich.edu>
Subject: Re: [PATCH] sunrpc: trim off EC bytes in addition to the checksum
 blob when doing a GSSAPI v2 unwrap
Message-ID: <20131016151827.45373f68@tlielax.poochiereds.net>
In-Reply-To: <1381950587.17178.17.camel@leira.trondhjem.org>
References: <1381427810-10633-1-git-send-email-jlayton@redhat.com>
	<1381949005.17178.10.camel@leira.trondhjem.org>
	<20131016145314.14b2ac32@tlielax.poochiereds.net>
	<1381950587.17178.17.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Oct 2013 19:09:48 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2013-10-16 at 14:53 -0400, Jeff Layton wrote:
> > On Wed, 16 Oct 2013 18:43:26 +0000
> > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Thu, 2013-10-10 at 13:56 -0400, Jeff Layton wrote:
> > > > As Bruce points out in RFC 4121, section 4.2.3:
> > > > 
> > > >    "In Wrap tokens that provide for confidentiality, the first 16 octets
> > > >     of the Wrap token (the "header", as defined in section 4.2.6), SHALL
> > > >     be appended to the plaintext data before encryption.  Filler octets
> > > >     MAY be inserted between the plaintext data and the "header.""
> > > > 
> > > > ...and...
> > > > 
> > > >    "In Wrap tokens with confidentiality, the EC field SHALL be used to
> > > >     encode the number of octets in the filler..."
> > > > 
> > > > It's possible for the client to stuff different data in that area on a
> > > > retransmission, which could make the checksum come out wrong in the DRC
> > > > code.
> > > > 
> > > > After decrypting the blob, we should trim off any extra count bytes in
> > > > addition to the checksum blob.
> > > > 
> > > > Reported-by: "J. Bruce Fields" <bfields@fieldses.org>
> > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > > ---
> > > >  net/sunrpc/auth_gss/gss_krb5_wrap.c | 4 ++--
> > > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > > > 
> > > > diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > > > index 1da52d1..ec1f4d0 100644
> > > > --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > > > +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > > > @@ -574,8 +574,8 @@ gss_unwrap_kerberos_v2(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
> > > >  	buf->head[0].iov_len -= GSS_KRB5_TOK_HDR_LEN + headskip;
> > > >  	buf->len -= GSS_KRB5_TOK_HDR_LEN + headskip;
> > > >  
> > > > -	/* Trim off the checksum blob */
> > > > -	xdr_buf_trim(buf, GSS_KRB5_TOK_HDR_LEN + tailskip);
> > > > +	/* Trim off the trailing "extra count" and checksum blob */
> > > > +	xdr_buf_trim(buf, ec + GSS_KRB5_TOK_HDR_LEN + tailskip);
> > > >  	return GSS_S_COMPLETE;
> > > >  }
> > > >  
> > > 
> > > If this is just padding, then why would it be anything other than '0',
> > > even on a retransmission? Clients are not supposed to leak random data
> > > to the server...
> > > 
> > 
> > The Linux client routines are actually set up to fill this with 'X'
> > characters, not nulls. See gss_krb5_aes_encrypt, which does this:
> > 
> >         memset(ecptr, 'X', ec);
> > 
> > AFAICT, the spec doesn't actually say what's supposed to be in the
> > padding, just that it's to be ignored. I imagine that most clients will
> > just set this to a constant value like Linux does, but there doesn't
> > seem to be any guarantee of that, and there's no real point in keeping
> > it around.
> 
> The only caller of gss_krb5_aes_encrypt is gss_wrap_kerberos_v2(), which
> sets 'ec' to 0.
> 

Yes, I realize that. The Linux client currently never sends any
padding. I was just pointing out that the encrypt_v2 routine is set up
to handle a non-zero "ec" value, and that when it gets one it fills the
padding with X's. We could make that not even pass in an "ec" value at
all of course, but maybe it'll come in handy sometime.

-- 
Jeff Layton <jlayton@redhat.com>
