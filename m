Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35898 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755306AbaJ3TAh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Oct 2014 15:00:37 -0400
Date: Thu, 30 Oct 2014 12:00:35 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: netdev@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: nfs stalls over loopback interface (no sk_data_ready events?)
Message-ID: <20141030190035.GA23129@infradead.org>
References: <20141027152900.4e81a9d5@tlielax.poochiereds.net>
 <20141029102123.58f6c960@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141029102123.58f6c960@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 29, 2014 at 10:21:23AM -0400, Jeff Layton wrote:
> Looks some change that went into -rc2 has fixed the problem for me.
> Christoph, can you confirm that this no longer occurs with -rc2?

I can't reproduce it anymore on -rc2.


However:

generic/133 fails fairly reliably with:

	 Buffered writer, buffered reader
	+pread64: Device or resource busy


