Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:43938 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753790AbbBBMnx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Feb 2015 07:43:53 -0500
Date: Mon, 2 Feb 2015 13:43:49 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 10/20] nfsd: implement pNFS operations
Message-ID: <20150202124349.GA15598@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de> <1421925006-24231-11-git-send-email-hch@lst.de> <20150129203346.GA11064@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150129203346.GA11064@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 29, 2015 at 03:33:46PM -0500, J. Bruce Fields wrote:
> Is there no old_stateid case for layout stateids?  And is there any
> chance of wraparound?  (I was comparing to check_stateid_generation and
> expecting the only difference to be the handling of the generation-zero
> case.)

12.5.3. explicitly mentions that LAYOUTGET and LAYOUTRETURN might be
outstading and processed in parallel, and sais that pNFS operations
use special stateid rules.  It does not explicitly say that old stateids
are ok, but the model described in there very much requires the server
to not reject them.

> > +static inline u64
> > +layout_end(struct nfsd4_layout_seg *seg)
> > +{
> > +	u64 end = seg->offset + seg->length;
> > +	return end >= seg->offset ? seg->length : NFS4_MAX_UINT64;
> 
> Shouldn't that be
> 
> 	return end >= seg->offset ? end : NFS_MAX_UINT64;
> 
> ?

Yes.  This is an interesting one that sneaked in, and it turns out
besides dislabling layout merging it didn't have adverse effects.

> > +}
> > +
> > +static void
> > +layout_update_len(struct nfsd4_layout_seg *lo, u64 end)
> > +{
> > +	if (end == NFS4_MAX_UINT64)
> > +		lo->length = NFS4_MAX_UINT64;
> 
> Is this case necessary?
> 
> > +	else
> > +		lo->length = end - lo->offset;


We use NFS4_MAX_UINT64 as a magic value for layouts until the
field end, as specified in the standard.  But because we do all
kinds of calculations using the end value we need to propagate
that magic from and to it.

> Should any of these have OP_MODIFIES_SOMETHING set?  (Basically: would
> we be in trouble if we succesfully completed one of these operations and
> then weren't able to encode the result?)

All but GETDEVICEINFO should get it.

I've implemented all your suggested changes and will send out and update
after doing a little more testing.
