From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sunrpc: Convert (void)snprintf to snprintf
Date: Mon, 08 Mar 2010 12:16:10 -0800 (PST)
Message-ID: <20100308.121610.51678711.davem@davemloft.net>
References: <1267857980.849.22.camel@Joe-Laptop.home>
	<4B951BF0.9050403@oracle.com>
	<1268066310.1925.26.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: chuck.lever@oracle.com, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36401
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755587Ab0CHUPv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Mar 2010 15:15:51 -0500
In-Reply-To: <1268066310.1925.26.camel-AkRN8/LKpobuYGix6ZUp1Q@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 08 Mar 2010 08:38:30 -0800

> (Applies on top of "Remove uses of NIPQUAD, use %pI4")
> 
> Casts to void of snprintf are most uncommon in kernel source.
> 9 use casts, 1301 do not.
> 
> Remove the remaining uses in net/sunrpc/
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Also applied, thanks Joe.
