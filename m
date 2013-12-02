Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35940 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868Ab3LBRZs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 12:25:48 -0500
Date: Mon, 2 Dec 2013 09:25:47 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: 3.12-rc2 nfsd oops in nfsd_cache_lookup
Message-ID: <20131202172547.GA5211@infradead.org>
References: <20131201102954.GA26976@infradead.org>
 <20131202122219.043174d6@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131202122219.043174d6@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 02, 2013 at 12:22:19PM -0500, Jeff Layton wrote:
> Looks like a similar oops to the one reported here:
> 
>     https://bugzilla.redhat.com/show_bug.cgi?id=1025907
> 
> Do you have a way to reproduce this reliably?

Seem to happen about 2/3s of the time when running xfstests on a v3
export for me.  The other one third create a different lockup in the
same test that I'm looking at at the moment.

