Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58243 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbaF3LED (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 07:04:03 -0400
Date: Mon, 30 Jun 2014 04:04:02 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 018/117] nfsd: clean up nfs4_release_lockowner
Message-ID: <20140630110402.GB2002@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
 <1403810017-16062-19-git-send-email-jlayton@primarydata.com>
 <20140629064738.GA17739@infradead.org>
 <20140629070812.414343ae@tlielax.poochiereds.net>
 <20140630070208.541871b7@f20.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140630070208.541871b7@f20.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2014 at 07:02:08AM -0400, Jeff Layton wrote:
> I started looking at reorganizing the function like you suggested, and
> there's a bit of a problem. Once we start adding in locking this
> becomes a bit of a mess, at least until the ownerstr_hashtbl gets moved
> into the nfs4_client.
> 
> What I'd suggest is that we go ahead and take this patch as-is for now,
> and I'll do the reorganization of the function along those lines in a
> later patch once we only need to deal with the cl_lock there. Sound ok?

ok..

