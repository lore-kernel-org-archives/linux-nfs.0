Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:52806 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbaGOQ6X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 12:58:23 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so5028452qge.39
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2014 09:58:23 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 15 Jul 2014 12:58:21 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: silence sparse warning about accessing
 credentials
Message-ID: <20140715125821.5fc2ad42@tlielax.poochiereds.net>
In-Reply-To: <20140715164527.GA9127@infradead.org>
References: <1405420134-3736-1-git-send-email-jlayton@primarydata.com>
	<20140715164527.GA9127@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 15 Jul 2014 09:45:27 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Tue, Jul 15, 2014 at 06:28:54AM -0400, Jeff Layton wrote:
> > sparse says:
> > 
> >     fs/nfsd/auth.c:31:38: warning: incorrect type in argument 1 (different address spaces)
> >     fs/nfsd/auth.c:31:38:    expected struct cred const *cred
> >     fs/nfsd/auth.c:31:38:    got struct cred const [noderef] <asn:4>*real_cred
> > 
> > Add a new accessor for the ->real_cred and use that to fetch the
> > pointer. Accessing current->real_cred directly is actually quite safe
> > since we know that they can't go away so this is mostly a cosmetic fixup
> > to silence sparse.
> 
> This looks reasonable, but I'd suggest Ccing linux-kernel for changes to
> global headers.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Ok, good point. I'll resend and cc there.

FWIW, I also sent a patch to linux-sparse today which will silence the
last sparse warning when building nfsd.ko.

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
