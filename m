Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:54196 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751358AbaIXQno (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2014 12:43:44 -0400
Date: Wed, 24 Sep 2014 18:43:41 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] nfsd: split nfsd4_callback initialization and use
Message-ID: <20140924164341.GA10208@lst.de>
References: <1411553959-5280-1-git-send-email-hch@lst.de> <1411553959-5280-4-git-send-email-hch@lst.de> <20140924112954.5d0771b8@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140924112954.5d0771b8@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 24, 2014 at 11:29:54AM -0400, Jeff Layton wrote:
> > Split out initializing the nfs4_callback structure from using it.  For
> > the NULL callback this gets rid of tons of pointless re-initializations.
> > 
> > Note that I don't quite understand what protects us from running multiple
> > NULL callbacks at the same time, but at least this chance doesn't make
> > it worse..
> > 
> 
> Doesn't the workqueue ensure that? Or am I misunderstanding what you're
> saying there?

For the code after my patch that is indeed the case, but before my
patch we'd re-initialize various fields in cl_cb_null everytime
do_probe_callback gets called.

