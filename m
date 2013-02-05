Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46939 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755658Ab3BEOzu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2013 09:55:50 -0500
Date: Tue, 5 Feb 2013 09:55:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 8/8] nfsd: keep a checksum of the first 256 bytes of
 request
Message-ID: <20130205145547.GD9886@fieldses.org>
References: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
 <1359983887-28535-9-git-send-email-jlayton@redhat.com>
 <20130204202046.GB8709@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130204202046.GB8709@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 04, 2013 at 03:20:46PM -0500, J. Bruce Fields wrote:
> On Mon, Feb 04, 2013 at 08:18:07AM -0500, Jeff Layton wrote:
> > @@ -238,12 +243,37 @@ nfsd_reply_cache_shrink(struct shrinker *shrink, struct shrink_control *sc)
> >  }
> >  
> >  /*
> > + * Walk an xdr_buf and get a CRC for at most the first RC_CSUMLEN bytes
> > + */
> > +static u32
> > +nfsd_cache_crc(struct xdr_buf *buf)
> > +{
> > +	u32 crc;
> > +	const unsigned char *p = buf->head[0].iov_base;
> > +	size_t csum_len = min_t(size_t, buf->head[0].iov_len + buf->page_len,
> > +					RC_CSUMLEN);
> > +	size_t len = min(buf->head[0].iov_len, csum_len);
> > +
> > +	/* rq_arg.head first */
> > +	crc = crc32(crc_seed, p, len);
> > +	csum_len -= len;
> 
> I'm getting a RPLY14 failure from pynfs --security=krb5i.
> 
> I suspect what's happening here is that the data you're checksumming
> over includes the gss sequence number and the krbi integrity checksum.
> Both those change, even on resends, to prevent an attacker from doing
> something nefarious by resending an old rpc.
> 
> I think we really want to checksum just over the nfs-level data.  Our
> checks for xid, program number, etc., already cover most of the rpc
> header anyway.

I've dropped this for now, but applied the previous patches.

--b.
