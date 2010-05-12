Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53510 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565Ab0ELM0u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 08:26:50 -0400
Date: Wed, 12 May 2010 08:26:49 -0400
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 8/9] nfsd4: keep a reference count on client while
	in use
Message-ID: <20100512122649.GB2266@fieldses.org>
References: <4BE9C7A2.8030801@panasas.com> <1273612434-13726-1-git-send-email-bhalevy@panasas.com> <20100512024030.GA27184@fieldses.org> <4BEA2E06.7070902@panasas.com> <4BEA4876.3030802@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4BEA4876.3030802@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 12, 2010 at 09:19:34AM +0300, Benny Halevy wrote:
> On May. 12, 2010, 7:26 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> > On May. 12, 2010, 5:40 +0300, " J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> >> Something still doesn't look quite right: a sequence operation
> >> increments cl_count from 1 to 2; then, say, an exchangeid in another
> >> thread expires the client, dropping cl_count from 2 to 1; then the
> >> laundromat runs, sees cl_count 1, and decides it can expire the
> >> client.  Meanwhile, the original compound is still running.
> >>
> >> Am I missing something?
> > 
> > Yeah.  exchange_id doesn't touch cl_refcount.  It may call expire_client
> > explicitly which will unhash the client but will not destroy it if cl_refcount > 0
> > the laundromat won't the client either after that since it's not on the lru list
> > any more (and even if it would, it's refcount is still great than zero so it would
> > have been ignored)
> 
> Sorry, I misspoken.  exchange_id may decrement cl_refcount via expire_client()
> but still the laundromat won't see it as expire_client will have already removed the
> client from client_lru.

So the only potential problems are with operations that reach the client
through the pointer in the session, so such operations may need to do
something special.  OK.

--b.
