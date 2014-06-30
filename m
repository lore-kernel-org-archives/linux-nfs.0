Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:60168 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754937AbaF3Kxz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 06:53:55 -0400
Received: by mail-qc0-f180.google.com with SMTP id r5so6906191qcx.11
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 03:53:54 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 30 Jun 2014 06:53:25 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 037/117] nfsd: clean up helper __release_lock_stateid
Message-ID: <20140630065326.63303fe5@f20.localdomain>
In-Reply-To: <20140630104014.GA2049@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
	<1403810017-16062-38-git-send-email-jlayton@primarydata.com>
	<20140630104014.GA2049@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Jun 2014 03:40:14 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jun 26, 2014 at 03:12:17PM -0400, Jeff Layton wrote:
> > From: Trond Myklebust <trond.myklebust@primarydata.com>
> > 
> > Use filp_close instead of open coding. filp_close does a bit more than
> > just release the locks and put the filp. It also calls ->flush and
> > dnotify_flush, both of which should be done here anyway.
> 
> Looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> and this can probably move before the locking changes..
> 

We can't, actually. filp_close also does an fput, and that doesn't get
added until this patch:

    nfsd: Add locking to the nfs4_file->fi_fds[] array

But I can (and will) move it just after that patch.

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
