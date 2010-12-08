Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55140 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753795Ab0LHDpy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Dec 2010 22:45:54 -0500
Subject: Re: oops in nfs_flush_incompatible (and possible fix?)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1291778228.20468.6.camel@heimdal.trondhjem.org>
References: <20101206145743.4464c79d@tlielax.poochiereds.net>
	 <1291758082.3049.42.camel@heimdal.trondhjem.org>
	 <20101207165354.32c863f2@tlielax.poochiereds.net>
	 <1291768200.3049.51.camel@heimdal.trondhjem.org>
	 <20101207200344.68ff29e3@corrin.poochiereds.net>
	 <20101207213540.441330db@corrin.poochiereds.net>
	 <1291778228.20468.6.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Dec 2010 22:45:50 -0500
Message-ID: <1291779950.21760.1.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-12-07 at 22:17 -0500, Trond Myklebust wrote:
> OK... I think I see why the hang:
> 
> I believe that it is basically due to nfs_clear_page_tag_locked() making
> the assumption that if req->wb_page != NULL, then the corresponding
> nfsi->nfs_page_tree lock tag needs to be cleared.
> 
> Maybe we can do that differently by just setting a flag to indicate
> whether or not this request is mapped into the radix tree...

The following patch is completely untested, but should do the trick....

----------------------------------------------------------------------------------------
