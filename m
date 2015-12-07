Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:34771 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755469AbbLGN2H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2015 08:28:07 -0500
Received: by qgeb1 with SMTP id b1so144198347qge.1
        for <linux-nfs@vger.kernel.org>; Mon, 07 Dec 2015 05:28:07 -0800 (PST)
Date: Mon, 7 Dec 2015 08:28:03 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151207082803.0b160bb6@tlielax.poochiereds.net>
In-Reply-To: <20151207130932.GB30843@lst.de>
References: <20151130193313.5bb10791@synchrony.poochiereds.net>
	<20151201115600.GA1557@lst.de>
	<20151201174800.407e2c40@synchrony.poochiereds.net>
	<20151202072504.GA15839@lst.de>
	<20151203220850.GC19518@fieldses.org>
	<20151204083803.GA2440@lst.de>
	<20151204155110.64a352dd@tlielax.poochiereds.net>
	<20151205120222.GA27009@lst.de>
	<20151205072409.46d66109@tlielax.poochiereds.net>
	<20151206080954.1fe7e5c9@tlielax.poochiereds.net>
	<20151207130932.GB30843@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 7 Dec 2015 14:09:32 +0100
Christoph Hellwig <hch@lst.de> wrote:

> On Sun, Dec 06, 2015 at 08:09:54AM -0500, Jeff Layton wrote:
> > Either way...in the near term we should probably take the patch
> > that I originally proposed, just to ensure that no one hits the
> > bugs that Kinglong hit. That does still leave some gaps in the
> > seqid handling, but those are preferable to the warning and
> > deadlock.
> > 
> > Bruce, does that sound reasonable? I can send that patch in a
> > separate email if you'd prefer.
> 
> What is the patch you proposed?  As far as I can tell the short term
> action would require two patches:
> 


The one I proposed is the one earlier in the thread that just drops the
mutex once the stateid has been copied (and so no longer holds it over
the CB RPC).


>  - treat 0 like NFS4ERR_DELAY (not directly related to your patch)
>  - send the old layout stateid with a recall, and only increment it
>    in nfsd4_cb_layout_release when we actually change the layout state

My understanding is that you need to increment the seqid when prior to
sending the callback. The basic idea there is that you want to ensure
that any LAYOUTGETs that were sent before the CB_LAYOUTRECALL get back
an OLD_STATEID error. RFC5661, Section 12.5.3:

    After the layout stateid is established, the server increments by
    one the value of the "seqid" in each subsequent LAYOUTGET and
    LAYOUTRETURN response, and in each CB_LAYOUTRECALL request.

> 
> We block all new LAYOUTGETS as long as fi_lo_recalls is non-zero,
> and we only only decrement it from nfsd4_cb_layout_release.  The
> way I understand the RPC state machine that means we block new
> LAYOUTGETS until we have successfully finished the recall.
>

Ok, so if you do treat 0 like NFS4ERR_DELAY then we shouldn't loop like
I was thinking. We do block LAYOUTGETs for a little longer than is
necessary, since you need to wait for the client to return
NFS4ERR_NOMATCHING_LAYOUT before the ->release op gets called but I
guess we can live with that.

-- 
Jeff Layton <jlayton@poochiereds.net>
