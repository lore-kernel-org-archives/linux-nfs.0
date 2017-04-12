Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36749 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752668AbdDLJwI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Apr 2017 05:52:08 -0400
Date: Wed, 12 Apr 2017 11:52:05 +0200
From: Jan Kara <jack@suse.cz>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org,
        linux-block@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 21/25] nfs: Convert to separately allocated bdi
Message-ID: <20170412095205.GC11138@quack2.suse.cz>
References: <20170329105623.18241-1-jack@suse.cz>
 <20170329105623.18241-22-jack@suse.cz>
 <20170412082034.GU9830@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170412082034.GU9830@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed 12-04-17 01:20:34, Christoph Hellwig wrote:
> >  /*
> >   * Finish setting up an NFS2/3 superblock
> >   */
> 
> I was just looking why you didn't update the v4 variant, but it seems
> like the comment above is simply incorrect..

Yes, it's used for NFS4 as well AFAICT.

> Thus the patch looks fine:
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
