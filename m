Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:44473 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185AbaGMLww (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Jul 2014 07:52:52 -0400
Received: by mail-qc0-f170.google.com with SMTP id c9so2586861qcz.29
        for <linux-nfs@vger.kernel.org>; Sun, 13 Jul 2014 04:52:52 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sun, 13 Jul 2014 07:52:50 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/11] nfsd: deny mode handling overhaul
Message-ID: <20140713075250.18677c29@tlielax.poochiereds.net>
In-Reply-To: <20140713114244.GA30809@infradead.org>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
	<20140710201448.GF26561@fieldses.org>
	<20140711074656.GA17661@infradead.org>
	<20140711143128.GA7305@fieldses.org>
	<20140711114227.2902a15e@tlielax.poochiereds.net>
	<20140713114244.GA30809@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 13 Jul 2014 04:42:44 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Fri, Jul 11, 2014 at 11:42:27AM -0400, Jeff Layton wrote:
> > Yes, thanks to both of you. The review and merging are much
> > appreciated. Only 89 patches to go once these go in!
> 
> Might help if we can get them into slighly smaller reviewable chunks,
> e.g. the next batch might be the stateid refcounting and everything
> around it, deferring the various client and session related bits and the
> fault injection changes for now.

That should be doable as long as we're ok with adding in superfluous
spinlocking until the client_mutex is removed. I'll work on breaking
out the next set. It might be a few days as I'm still looking at
whether it's feasible to not alter the sc_type like the code does today.

-- 
Jeff Layton <jlayton@primarydata.com>
