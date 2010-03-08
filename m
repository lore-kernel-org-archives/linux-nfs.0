From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH resend] net/sunrpc: Remove uses of NIPQUAD, use %pI4
Date: Mon, 08 Mar 2010 08:58:27 -0500
Message-ID: <1268056707.3097.4.camel@localhost.localdomain>
References: <1267857980.849.22.camel@Joe-Laptop.home>
	 <20100307.152830.191688665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: joe@perches.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24862 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754383Ab0CHN7R convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Mar 2010 08:59:17 -0500
In-Reply-To: <20100307.152830.191688665.davem@davemloft.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2010-03-07 at 15:28 -0800, David Miller wrote: 
> From: Joe Perches <joe@perches.com>
> Date: Fri, 05 Mar 2010 22:46:20 -0800
> 
> > Originally submitted Jan 1, 2010
> > http://patchwork.kernel.org/patch/71221/
> > 
> > Convert NIPQUAD to the %pI4 format extension where possible
> > Convert %02x%02x%02x%02x/NIPQUAD to %08x/ntohl
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> Trond, are you going to integrate this?
> 
> Otherwise I'm going to.

If you're planning another push to Linus then feel free to push this
too.

If not, then I do have a couple of small cleanups and fixes that I want
to push before the merge window closes, so I could send Joe's patch
together with those...

Cheers
  Trond
