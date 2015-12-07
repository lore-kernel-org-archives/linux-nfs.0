Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:48992 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754978AbbLGNHT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 08:07:19 -0500
Date: Mon, 7 Dec 2015 14:07:16 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151207130716.GA30843@lst.de>
References: <20151130213420.GA31564@fieldses.org> <20151130193313.5bb10791@synchrony.poochiereds.net> <20151201115600.GA1557@lst.de> <20151201174800.407e2c40@synchrony.poochiereds.net> <20151202072504.GA15839@lst.de> <20151203220850.GC19518@fieldses.org> <20151204083803.GA2440@lst.de> <20151204155110.64a352dd@tlielax.poochiereds.net> <20151205120222.GA27009@lst.de> <20151205072409.46d66109@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151205072409.46d66109@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 05, 2015 at 07:24:09AM -0500, Jeff Layton wrote:
> If we treat NFS4_OK and NFS4ERR_DELAY equivalently, then we're
> expecting the client to eventually return NFS4ERR_NOMATCHING_LAYOUT (or
> a different error) to break the cycle of retransmissions. But, HZ/100
> is enough time for the client to return a layout and request a new one.
> We may never see that error -- only a continual cycle of
> CB_LAYOUTRECALL/LAYOUTRETURN/LAYOUTGET.
> 
> I think we need a more reliable way to break that cycle so we don't end
> up looping like that. We should either cancel any active callbacks
> before reallowing LAYOUTGETs, or move the timeout handling outside of
> the RPC state machine (like Bruce was suggesting).

We block all new LAYOUTGETS as long as fi_lo_recalls is non-zero,
and we only only decrement it from nfsd4_cb_layout_release.  The
way I understand the RPC state machine that means we block new LAYOUTGETS
until we have successfully finished the recall.
