Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:45109 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890Ab1GOPgF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 11:36:05 -0400
Subject: Re: [PATCH/RFC 0/10] enable SKB paged fragment lifetime visibility
From: Ian Campbell <Ian.Campbell@eu.citrix.com>
To: David Miller <davem@davemloft.net>
CC: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <20110715.081735.2057304107637222967.davem@davemloft.net>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
	 <20110715.081735.2057304107637222967.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 15 Jul 2011 16:36:03 +0100
Message-ID: <1310744163.20648.21.camel@zakaz.uk.xensource.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-07-15 at 16:17 +0100, David Miller wrote:
> From: Ian Campbell <Ian.Campbell@citrix.com>
> Date: Fri, 15 Jul 2011 12:06:46 +0100
> 
> > What is the general feeling regarding this approach?
> 
> Not bad,

Thanks, I'll continue in this direction then.

>  I like that only the users of destructors pay the price of
> the extra atomics.

Yes, I very much wanted to avoid hitting everyone with extra overhead.

> Like you say in patch #8, I wouldn't bother adding a whole new
> ->sendpage_destructor() OP, just add the new argument to the existing
> method.

Will do.

Ian.

