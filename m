Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:49243 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932537AbbLGORE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 09:17:04 -0500
Date: Mon, 7 Dec 2015 15:17:01 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151207141701.GA1376@lst.de>
References: <20151201174800.407e2c40@synchrony.poochiereds.net> <20151202072504.GA15839@lst.de> <20151203220850.GC19518@fieldses.org> <20151204083803.GA2440@lst.de> <20151204155110.64a352dd@tlielax.poochiereds.net> <20151205120222.GA27009@lst.de> <20151205072409.46d66109@tlielax.poochiereds.net> <20151206080954.1fe7e5c9@tlielax.poochiereds.net> <20151207130932.GB30843@lst.de> <20151207082803.0b160bb6@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151207082803.0b160bb6@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 07, 2015 at 08:28:03AM -0500, Jeff Layton wrote:
> My understanding is that you need to increment the seqid when prior to
> sending the callback. The basic idea there is that you want to ensure
> that any LAYOUTGETs that were sent before the CB_LAYOUTRECALL get back
> an OLD_STATEID error. RFC5661, Section 12.5.3:
> 
>     After the layout stateid is established, the server increments by
>     one the value of the "seqid" in each subsequent LAYOUTGET and
>     LAYOUTRETURN response, and in each CB_LAYOUTRECALL request.

True.  Although I really don't see any way to make layoutrecall processing
race free that way.  I guess your patch to just drop the mutex is the
best we could do.

Note that it doesn't really matter for the current server, as we will
always recall the whole file, and thus leave no layout state for it on
the client.  But for finger grained recalls this could become a problem.
