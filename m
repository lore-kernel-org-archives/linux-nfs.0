Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57419 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbaF3LDX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 07:03:23 -0400
Date: Mon, 30 Jun 2014 04:03:22 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 022/117] nfsd: Cache the client that was looked up in
 lookup_clientid()
Message-ID: <20140630110322.GA2002@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
 <1403810017-16062-23-git-send-email-jlayton@primarydata.com>
 <20140629121419.GC16150@infradead.org>
 <20140629105702.2ca9e6ee@f20.localdomain>
 <20140630103453.GB22010@infradead.org>
 <20140630065913.2fe89c25@f20.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140630065913.2fe89c25@f20.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2014 at 06:59:13AM -0400, Jeff Layton wrote:
> +       /*
> +        * For v4.1+ we get the client in the SEQUENCE op. If we don't have one
> +        * cached already then we know this is for is for v4.0 and "sessions"
> +        * will be false.
> +        */
> +       found = find_confirmed_client(clid, false, nn);
> 
> FWIW, the main reason for the comment is to explain why we're
> hardcoding the "session" arg to false here instead of using
> cstate->session.

I'd either just use it to future proof it, or add an assert that it's
really not set..

