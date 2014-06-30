Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:51569 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755370AbaF3KfU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 06:35:20 -0400
Date: Mon, 30 Jun 2014 03:35:15 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 023/117] nfsd: Convert nfsd4_process_open1() to work
 with lookup_clientid()
Message-ID: <20140630103515.GC22010@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
 <1403810017-16062-24-git-send-email-jlayton@primarydata.com>
 <20140629121600.GD16150@infradead.org>
 <20140629110831.719e57f1@f20.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140629110831.719e57f1@f20.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 29, 2014 at 11:08:31AM -0400, Jeff Layton wrote:
> > This hunk should have been in the previous patch.  Or given that
> > lookup_clientid was mostly rewritten it make sense to just move it to
> > avoid the forward declaration entirely.
> > 
> 
> Does it? It's not until this patch that the forward declaration is
> needed at all.

You're right, sorry..

