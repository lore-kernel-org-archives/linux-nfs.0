Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53835 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754404AbaHZN6W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 09:58:22 -0400
Date: Tue, 26 Aug 2014 06:58:21 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        bfields@fieldses.org, cluster-devel@redhat.com,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/10] locks: define a lm_setup handler for leases
Message-ID: <20140826135821.GA18599@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
 <1408804878-1331-8-git-send-email-jlayton@primarydata.com>
 <20140824155858.GF15908@infradead.org>
 <20140824211953.1dfd7f77@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140824211953.1dfd7f77@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 24, 2014 at 09:19:53PM -0400, Jeff Layton wrote:
> > I don't think this is a good idea.  The errors in __f_setown come from
> > the security modules, and they could change easily.  If you can convince
> > the LSM people to change their file_set_fowner routine to return void
> > we could change __f_setown to return void as well and be done with it,
> > but without that this looks too dangerous.
> > 
> 
> Understood. I figured that this might not be acceptable. I can make
> this propagate the error back up, but cleaning up the mess may not be
> easy. I'll see what I can do.

I'd say talk to the LSM people.  Right now they are only using it to
set up private data pointers, so they might agree on turning it into
a void return.  Or just be bold and do that work yourself, include it in
this series and just Cc them.

