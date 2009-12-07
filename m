From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] SUNRPC: IS_ERR/PTR_ERR confusion
Date: Mon, 07 Dec 2009 18:06:39 -0500
Message-ID: <1260227199.2951.15.camel@localhost>
References: <4B1CE844.1040108@gmail.com>
	 <20091207152654.GA29416@fieldses.org>  <1260227059.2951.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Roel Kluin <roel.kluin@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40337 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935702AbZLGXGe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 18:06:34 -0500
In-Reply-To: <1260227059.2951.13.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-12-07 at 18:04 -0500, Trond Myklebust wrote: 
> On Mon, 2009-12-07 at 10:26 -0500, J. Bruce Fields wrote: 
> > On Mon, Dec 07, 2009 at 12:34:28PM +0100, Roel Kluin wrote:
> > > IS_ERR returns 1 or 0, PTR_ERR returns the error value.
> > 
> > Whoops, thanks, looks like that was my mistake, from
> > 79a3f20b641f9f93787ada49d1d7cfa98ee5a11e "rpc: use count of pipe openers
> > to wait for first open".
> 
> Are you planning on shepherding this fix into mainline, or should I?
> 
> Trond

BTW: It should probably be labelled as 'Cc: stable@kernel.org' since it
appears to be a 2.6.29 bug...

Trond
