From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] mountd: fix --manage-gids hang due to int/uint bug
Date: Mon, 8 Mar 2010 11:28:44 -0500
Message-ID: <20100308162844.GA31579@fieldses.org>
References: <20100302204930.GA8609@fieldses.org> <4B95249C.9020306@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59721 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755411Ab0CHQ1W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Mar 2010 11:27:22 -0500
In-Reply-To: <4B95249C.9020306-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 08, 2010 at 11:23:56AM -0500, Steve Dickson wrote:
> 
> 
> On 03/02/2010 03:49 PM, J. Bruce Fields wrote:
> > From: J. Bruce Fields <bfields@citi.umich.edu>
> > 
> > A uid or gid should be represented as unsigned, not signed.
> > 
> > The conversion to signed here could cause a hang on access by an unknown
> > user to a server running mountd with --manage-gids; such a user is
> > likely to be mapped to 232-1, which may be converted to 231-1 when
> > represented as an int, resulting in a downcall for uid 231-1, hence the
> > original rpc hanging forever waiting for a cache downcall for 232-1.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> Committed... 

Thanks.

But, that's really weird: where did all the carat's (^'s) go, in 2^32
and 2^31?

--b.
