Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:48997 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753185AbbLGNJd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 08:09:33 -0500
Date: Mon, 7 Dec 2015 14:09:32 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151207130932.GB30843@lst.de>
References: <20151130193313.5bb10791@synchrony.poochiereds.net> <20151201115600.GA1557@lst.de> <20151201174800.407e2c40@synchrony.poochiereds.net> <20151202072504.GA15839@lst.de> <20151203220850.GC19518@fieldses.org> <20151204083803.GA2440@lst.de> <20151204155110.64a352dd@tlielax.poochiereds.net> <20151205120222.GA27009@lst.de> <20151205072409.46d66109@tlielax.poochiereds.net> <20151206080954.1fe7e5c9@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151206080954.1fe7e5c9@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 06, 2015 at 08:09:54AM -0500, Jeff Layton wrote:
> Either way...in the near term we should probably take the patch that I
> originally proposed, just to ensure that no one hits the bugs that
> Kinglong hit. That does still leave some gaps in the seqid handling,
> but those are preferable to the warning and deadlock.
> 
> Bruce, does that sound reasonable? I can send that patch in a separate
> email if you'd prefer.

What is the patch you proposed?  As far as I can tell the short term
action would require two patches:

 - treat 0 like NFS4ERR_DELAY (not directly related to your patch)
 - send the old layout stateid with a recall, and only increment it
   in nfsd4_cb_layout_release when we actually change the layout state
