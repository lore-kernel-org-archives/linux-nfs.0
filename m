Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54506 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752564AbcETPh0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 May 2016 11:37:26 -0400
Date: Fri, 20 May 2016 11:37:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: =?utf-8?B?VG9tw6HFoQ==?= Trnka <ttrnka@mail.muni.cz>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc: fix stripping of padded MIC tokens
Message-ID: <20160520153724.GF2119@fieldses.org>
References: <38521704.8vjDAt0XQs@mintaka.ncbr.muni.cz>
 <1463758273.14305.1.camel@poochiereds.net>
 <20160520153428.GE2119@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20160520153428.GE2119@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 20, 2016 at 11:34:28AM -0400, J. Bruce Fields wrote:
> On Fri, May 20, 2016 at 11:31:13AM -0400, Jeff Layton wrote:
> > On Fri, 2016-05-20 at 16:41 +0200, Tomáš Trnka wrote:
> > > The length of the GSS MIC token need not be a multiple of four bytes.
> > > It is then padded by XDR to a multiple of 4 B, but unwrap_integ_data()
> > > would previously only trim mic.len + 4 B. The remaining up to three
> > > bytes would then trigger a check in nfs4svc_decode_compoundargs(),
> > > leading to a "garbage args" error and mount failure:
> > > 
> > > nfs4svc_decode_compoundargs: compound not properly padded!
> > > nfsd: failed to decode arguments!
> > > 
> > > This would prevent older clients using the pre-RFC 4121 MIC format
> > > (37-byte MIC including a 9-byte OID) from mounting exports from v3.9+
> > > servers using krb5i.
> > > 
> > > The trimming was introduced by commit 4c190e2f913f ("sunrpc: trim off
> > > trailing checksum before returning decrypted or integrity authenticated
> > > buffer").
> > > 
> > > Signed-off-by: Tomáš Trnka <ttrnka@mail.muni.cz>
> > > ---
> > >  net/sunrpc/auth_gss/svcauth_gss.c | 4 ++--
> > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c 
> > > b/net/sunrpc/auth_gss/svcauth_gss.c
> > > index 1095be9..4605dc7 100644
> > > --- a/net/sunrpc/auth_gss/svcauth_gss.c
> > > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> > > @@ -857,8 +857,8 @@ unwrap_integ_data(struct svc_rqst *rqstp, struct xdr_buf 
> > > *buf, u32 seq, struct g
> > >  		goto out;
> > >  	if (svc_getnl(&buf->head[0]) != seq)
> > >  		goto out;
> > > -	/* trim off the mic at the end before returning */
> > > -	xdr_buf_trim(buf, mic.len + 4);
> > > +	/* trim off the mic and padding at the end before returning */
> > > +	xdr_buf_trim(buf, round_up_to_quad(mic.len) + 4);
> > >  	stat = 0;
> > >  out:
> > >  	kfree(mic.data);
> > 
> > Looks reasonable:
> > 
> > Acked-by: Jeff Layton <jlayton@poochiereds.net>
> 
> Thanks!  Applying for 4.6 and stable.

(Err, 4.7.  All these version numbers run into each other...).
