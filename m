Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48226 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204AbaELQGb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 May 2014 12:06:31 -0400
Date: Mon, 12 May 2014 12:06:08 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 02/43] nfsd4: tweak nfsd4_encode_getattr to take
 xdr_stream
Message-ID: <20140512160608.GD2633@pad.redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-3-git-send-email-bfields@redhat.com>
 <20140512053554.GC29134@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140512053554.GC29134@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 11, 2014 at 10:35:54PM -0700, Christoph Hellwig wrote:
> >   * Note: @fhp can be NULL; in this case, we might have to compose the filehandle
> >   * ourselves.
> > - *
> > - * countp is the buffer size in _words_
> >   */
> >  __be32
> > -nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
> > -		struct dentry *dentry, __be32 **buffer, int count, u32 *bmval,
> > +nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export *exp,
> 
> Can you make sure that line that the patches touch don't exceed 80
> lines?  There's quite a few more through the series, including new code.

OK, this one is fixed and I'm working through the others and fixing a
few other checkpatch complaints while I'm at it (mainly leftover
(char*)'s).

--b.

> 
> 
> Otherwise looks good,
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
