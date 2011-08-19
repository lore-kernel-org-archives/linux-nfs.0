Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:32040 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754766Ab1HSNpW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 09:45:22 -0400
Subject: Re: [PATCH/RFC v3 0/75] enable SKB paged fragment lifetime
 visibility
From: Ian Campbell <Ian.Campbell@eu.citrix.com>
To: David Miller <davem@davemloft.net>
CC: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <20110819.063410.475175569086272526.davem@davemloft.net>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
	 <20110819.062958.1560313540665582388.davem@davemloft.net>
	 <20110819.063410.475175569086272526.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 19 Aug 2011 14:45:20 +0100
Message-ID: <1313761520.5010.363.camel@zakaz.uk.xensource.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-08-19 at 14:34 +0100, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 19 Aug 2011 06:29:58 -0700 (PDT)
> 
> > From: Ian Campbell <Ian.Campbell@citrix.com>
> > Date: Fri, 19 Aug 2011 14:26:33 +0100
> > 
> >> This is v3 of my series to enable visibility into SKB paged fragment's
> > 
> > Please tone down the patch count :-/  I'm not going to review anything more
> > than ~20 or so patches at a time from any one person.

Unfortunately I didn't see any middle ground between one massive patch
munging drivers with lots of different maintainers and one patch per
maintainer (which is loads).

I'll resend in batches of ~20. After the first patch all the "convert to
SKB paged frag API" patches are independent.

Would you be willing to just review patches 1-20 of this series? In
which case I could avoid spamming the list with those again now.

> Also none of your patches will even apply to net-next GIT since nearly
> all the ethernet drivers have been moved under drivers/net/ethernet

Yes, I noted that in my intro mail and will rebase for v4. Since it's
mostly just been code motion I think review in the old place will still
be largely valid.

Ian.

