Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47900 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422979AbbD2Nqd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Apr 2015 09:46:33 -0400
Date: Wed, 29 Apr 2015 06:46:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH, RFC] backchannel overflows
Message-ID: <20150429134631.GA17647@infradead.org>
References: <20150428202157.GA23972@infradead.org>
 <5540C9BD.2080402@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5540C9BD.2080402@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 29, 2015 at 08:08:29PM +0800, Kinglong Mee wrote:
> > diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> > index 84326e9..7afb3ef 100644
> > --- a/fs/nfs/callback.h
> > +++ b/fs/nfs/callback.h
> > @@ -205,7 +205,7 @@ extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
> >   * so we limit their concurrency to 1 by setting up the maximum number
> >   * of slots for the backchannel.
> >   */
> > -#define NFS41_BC_MIN_CALLBACKS 1
> > +#define NFS41_BC_MIN_CALLBACKS 2
> >  #define NFS41_BC_MAX_CALLBACKS 1
> 
> Are you sure that's okay without update NFS41_BC_MAX_CALLBACKS?

Yes, NFS41_BC_MIN_CALLBACKS is the number of slots we tell the sunrpc
layer to allocate, while NFS41_BC_MAX_CALLBACKS is used for nfs-internal
accounting.  So having them different is intentional for this rfc.  If
we'll have to merge this instead of a better fix we defintively should
fix up the naming, though.
