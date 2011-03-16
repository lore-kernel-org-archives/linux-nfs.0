Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57889 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859Ab1CPWzi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2011 18:55:38 -0400
Date: Wed, 16 Mar 2011 18:55:25 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Mi Jinlong <mijinlong@cn.fujitsu.com>, roel <roel.kluin@gmail.com>,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] nfsd: wrong index used in inner loop
Message-ID: <20110316225524.GC17004@fieldses.org>
References: <4D76A06A.4090405@gmail.com>
 <20110309004955.GD15814@fieldses.org>
 <4D79A183.8090306@cn.fujitsu.com>
 <20110314222229.GJ25442@fieldses.org>
 <1300146731.3026.4.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1300146731.3026.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 14, 2011 at 07:52:11PM -0400, Trond Myklebust wrote:
> On Mon, 2011-03-14 at 18:22 -0400, J. Bruce Fields wrote:
> > On Fri, Mar 11, 2011 at 12:13:55PM +0800, Mi Jinlong wrote:
> > > 
> > > 
> > > J. Bruce Fields:
> > > > On Tue, Mar 08, 2011 at 10:32:26PM +0100, roel wrote:
> > > >> @@ -1215,7 +1215,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
> > > >>  			READ_BUF(4);
> > > >>  			READ32(dummy);
> > > >>  			READ_BUF(dummy * 4);
> > > >> -			for (i = 0; i < dummy; ++i)
> > > >> +			for (j = 0; j < dummy; ++j)
> > > >>  				READ32(dummy);
> > > 
> > >   We must not use dummy for index here.
> > >   After the first index, READ32(dummy) will change dummy!!!!
> > 
> > Actually, wait, this is kind of silly.  I don't see why we couldn't just
> > skip the loop and do
> > 
> > 	p += dummy;
> 
> This is exactly why I _hate_ the READ*() macros and their ilk, and am
> really happy we got rid of them in the client.

Agreed, I'm all for getting rid of them completely.

> READ_BUF() _sets_ p to whatever the value of argp->p is, and then
> updates argp->p. It is just very very very hard to see that due to the
> lack of transparency.
>
> IOW: You don't need the "p += dummy" either. That happens automatically
> when you next invoke READ_BUF().

Yes, you're right, we could remove that silly loop entirely.

--b.
