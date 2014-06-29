Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f54.google.com ([209.85.192.54]:57903 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbaF2PIe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Jun 2014 11:08:34 -0400
Received: by mail-qg0-f54.google.com with SMTP id q107so1149565qgd.13
        for <linux-nfs@vger.kernel.org>; Sun, 29 Jun 2014 08:08:33 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sun, 29 Jun 2014 11:08:31 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 023/117] nfsd: Convert nfsd4_process_open1() to work
 with lookup_clientid()
Message-ID: <20140629110831.719e57f1@f20.localdomain>
In-Reply-To: <20140629121600.GD16150@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
	<1403810017-16062-24-git-send-email-jlayton@primarydata.com>
	<20140629121600.GD16150@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 29 Jun 2014 05:16:00 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> > +static __be32 lookup_clientid(clientid_t *clid,
> > +		struct nfsd4_compound_state *cstate,
> > +		struct nfsd_net *nn);
> 
> This hunk should have been in the previous patch.  Or given that
> lookup_clientid was mostly rewritten it make sense to just move it to
> avoid the forward declaration entirely.
> 

Does it? It's not until this patch that the forward declaration is
needed at all. That said, I have a general aversion to forward
declarations so moving it up sounds good to me.

> Otherwise looks good to me,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks!
-- 
Jeff Layton <jlayton@primarydata.com>
