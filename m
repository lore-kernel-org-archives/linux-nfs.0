Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:40173 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbbCPM1b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Mar 2015 08:27:31 -0400
Date: Mon, 16 Mar 2015 05:27:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsd use after free in 4.0-rc
Message-ID: <20150316122731.GA32163@infradead.org>
References: <20150315125614.GA766@infradead.org>
 <20150315180811.02847842@tlielax.poochiereds.net>
 <20150316114648.GA7432@infradead.org>
 <20150316082004.348e39af@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150316082004.348e39af@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 16, 2015 at 08:20:04AM -0400, Jeff Layton wrote:
> I just tried a v3.19 kernel on the server and could reproduce this
> there with generic/011 as well, so this looks like a preexisting bug of
> some sort. Perhaps the recent client changes to allow parallel opens
> are helping to expose it?

That sounds like a good explanation, as I've never seen this before
those changes were merged.
