From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfs: remove BKL from callback server
Date: Mon, 30 Nov 2009 08:44:21 -0500
Message-ID: <1259588661.3419.5.camel@localhost>
References: <20091009151151.GB9436@fieldses.org>
	 <20091129212444.GC7216@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64645 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753126AbZK3NoZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Nov 2009 08:44:25 -0500
In-Reply-To: <20091129212444.GC7216@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-11-29 at 16:24 -0500, J. Bruce Fields wrote: 
> By the way, did this get applied?

I found a 100% identical patch that I wrote immediately after I got back
from the kernel summit. However, since it looks as if your patch
predates mine, I'll replace it...

> And is there someplace I should be looking for your pending patches
> other than
> 
> 	git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git
> 
> ?  Currently they don't seem to have anything not upstream.  (But I may
> have overlooked something.)

I'm still running my own tests, so nothing has been published yet...

Cheers
  Trond

