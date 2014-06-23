Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:63492 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755760AbaFWQTx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 12:19:53 -0400
Received: by mail-qa0-f47.google.com with SMTP id hw13so5776812qab.6
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 09:19:53 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 23 Jun 2014 12:19:51 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@primarydata.com>
Subject: Re: [PATCH v1 004/104] nfsd4: use cl_lock to synchronize all
 stateid idr calls
Message-ID: <20140623121951.191f92cb@tlielax.poochiereds.net>
In-Reply-To: <20140623160227.GB24193@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
	<1403189450-18729-5-git-send-email-jlayton@primarydata.com>
	<20140623160227.GB24193@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Jun 2014 09:02:27 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> This looks reasonable to me.  Am I right to assume this is just a
> preparation for the state lock removal?  As far as I can tell currently
> all calls are under nfs4_lock_state().
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> assuming it gets a proper patch description.
> 

Yes, that's correct, and that's the case with pretty much all of the
patches that add locking here. I can explicitly spell that out in every
patch description but that may get tedious over >100 patches.

Also, let's be careful about terminology here...

What we're removing is the client_mutex (which has unfortunately named
wrappers around it called nfs4_lock_state and nfs4_unlock_state).

We have yet another spinlock called the "state_lock" which protects the
nfs4_file hashes and such, as well as some of the delegation code.

-- 
Jeff Layton <jlayton@primarydata.com>
