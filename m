Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56084 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755625Ab3BEPvr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2013 10:51:47 -0500
Date: Tue, 5 Feb 2013 10:51:44 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 8/8] nfsd: keep a checksum of the first 256 bytes of
 request
Message-ID: <20130205105144.664baaed@tlielax.poochiereds.net>
In-Reply-To: <20130205145547.GD9886@fieldses.org>
References: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
	<1359983887-28535-9-git-send-email-jlayton@redhat.com>
	<20130204202046.GB8709@fieldses.org>
	<20130205145547.GD9886@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 5 Feb 2013 09:55:47 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Feb 04, 2013 at 03:20:46PM -0500, J. Bruce Fields wrote:
> > On Mon, Feb 04, 2013 at 08:18:07AM -0500, Jeff Layton wrote:
> > > @@ -238,12 +243,37 @@ nfsd_reply_cache_shrink(struct shrinker *shrink, struct shrink_control *sc)
> > >  }
> > >  
> > >  /*
> > > + * Walk an xdr_buf and get a CRC for at most the first RC_CSUMLEN bytes
> > > + */
> > > +static u32
> > > +nfsd_cache_crc(struct xdr_buf *buf)
> > > +{
> > > +	u32 crc;
> > > +	const unsigned char *p = buf->head[0].iov_base;
> > > +	size_t csum_len = min_t(size_t, buf->head[0].iov_len + buf->page_len,
> > > +					RC_CSUMLEN);
> > > +	size_t len = min(buf->head[0].iov_len, csum_len);
> > > +
> > > +	/* rq_arg.head first */
> > > +	crc = crc32(crc_seed, p, len);
> > > +	csum_len -= len;
> > 
> > I'm getting a RPLY14 failure from pynfs --security=krb5i.
> > 
> > I suspect what's happening here is that the data you're checksumming
> > over includes the gss sequence number and the krbi integrity checksum.
> > Both those change, even on resends, to prevent an attacker from doing
> > something nefarious by resending an old rpc.
> > 
> > I think we really want to checksum just over the nfs-level data.  Our
> > checks for xid, program number, etc., already cover most of the rpc
> > header anyway.
> 
> I've dropped this for now, but applied the previous patches.
> 

Thanks -- this is a thorny problem to solve it seems...

The problem seems to be the checksum at the end of the NFS data in the
krb5i case. There's some similar stuff at the end of a decrypted krb5p
request too, but I'm not yet clear on what that is...

It would be nice if the RPC layer somehow would inform us of the length
of the "real" nfs data, but I don't think it does that currently.

-- 
Jeff Layton <jlayton@redhat.com>
