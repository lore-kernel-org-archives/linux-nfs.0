Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47516 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754788AbcJYT7b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Oct 2016 15:59:31 -0400
Date: Tue, 25 Oct 2016 15:59:30 -0400
From: Fields Bruce James <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Rusty Russell <rusty@rustcorp.com.au>,
        Christoph Hellwig <hch@infradead.org>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: don't pass on-stack memory to sg_set_buf
Message-ID: <20161025195930.GB5129@fieldses.org>
References: <20161025184538.GA4612@fieldses.org>
 <A4086E5B-B808-4828-A25D-4AAB2504EC57@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <A4086E5B-B808-4828-A25D-4AAB2504EC57@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 25, 2016 at 07:34:43PM +0000, Trond Myklebust wrote:
> 
> > On Oct 25, 2016, at 14:45, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > As of ac4e97abce9b "scatterlist: sg_set_buf() argument must be in linear
> > mapping", sg_set_buf hits a BUG when make_checksum_v2->xdr_process_buf,
> > among other callers, passes it memory on the stack.
> > 
> > We only need a scatterlist to pass this to the crypto code, and it seems
> > like overkill to require kmalloc'd memory just to encrypt a few bytes,
> > but for now this seems the best fix.
> > 
> > Note many of these callers are in the NFS write paths, so we shouldn't
> > really be allocating GFP_KERNEL.  But we already have other allocations
> > in these code paths.  A larger redesign may be necessary to allow
> > allocations to be done earlier.
> 
> NACK…  I agree that there may already be borkage in RPCSEC_GSS-land, but that’s not a reason to be adding to the pile of things that need to be fixed… The allocations that lie in the RPC client’s encode/decode path do need to be GFP_NOFS….

OK.  Any disadvantage to keeping this patch with just GFP_NOFS
allocations everywhere that might be in the write path?

--b.
