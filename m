Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26272 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750969Ab0LMO7Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Dec 2010 09:59:25 -0500
Date: Mon, 13 Dec 2010 09:59:22 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: oops in nfs_flush_incompatible (and possible fix?)
Message-ID: <20101213095922.78751865@tlielax.poochiereds.net>
In-Reply-To: <20101209140135.2d02579d@barsoom.rdu.redhat.com>
References: <20101206145743.4464c79d@tlielax.poochiereds.net>
	<1291758082.3049.42.camel@heimdal.trondhjem.org>
	<20101207165354.32c863f2@tlielax.poochiereds.net>
	<1291768200.3049.51.camel@heimdal.trondhjem.org>
	<20101207200344.68ff29e3@corrin.poochiereds.net>
	<20101207213540.441330db@corrin.poochiereds.net>
	<1291778228.20468.6.camel@heimdal.trondhjem.org>
	<1291779950.21760.1.camel@heimdal.trondhjem.org>
	<1291781972.21760.2.camel@heimdal.trondhjem.org>
	<20101209140135.2d02579d@barsoom.rdu.redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 9 Dec 2010 14:01:35 -0500
Jeff Layton <jlayton@redhat.com> wrote:


> So, it looks good so far. If you like, you can add my. I'll let you
> know once the run is done.
> 
> Reviewed-by: Jeff Layton <jlayton@redhat.com>

Trond,

The test kernel with the backported patch for RHEL5 survived a 72 hour
run. The predecessors never made it past 12 hours or so. The patch
seems to be good.

Thanks for the quick turnaround!
-- 
Jeff Layton <jlayton@redhat.com>
