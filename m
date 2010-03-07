From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend] net/sunrpc: Remove uses of NIPQUAD, use %pI4
Date: Sun, 07 Mar 2010 15:28:30 -0800 (PST)
Message-ID: <20100307.152830.191688665.davem@davemloft.net>
References: <1267857980.849.22.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267857980.849.22.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 05 Mar 2010 22:46:20 -0800

> Originally submitted Jan 1, 2010
> http://patchwork.kernel.org/patch/71221/
> 
> Convert NIPQUAD to the %pI4 format extension where possible
> Convert %02x%02x%02x%02x/NIPQUAD to %08x/ntohl
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Trond, are you going to integrate this?

Otherwise I'm going to.
