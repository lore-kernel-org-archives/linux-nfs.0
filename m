From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: patch "net: deliver skbs on inactive slaves to exact matches"
 stalls 	nfs mounts
Date: Wed, 16 Jun 2010 15:36:33 -0700
Message-ID: <4C1951F1.9010004@intel.com>
References: <AANLkTil5gBFkXgmImU1Mt8uJXKTTNCen8NtzWpBxaYdq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Fred Isaman <iisaman@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <AANLkTil5gBFkXgmImU1Mt8uJXKTTNCen8NtzWpBxaYdq@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fred Isaman wrote:
> I am using vmware fusion 3.1.0 on a macbook pro host with a fedora 12
> guest running a 2.6.35-rc3 based kernel,  Upgrading from rc2 to rc3
> introduced a long delay when the guest attempts an nfs mount (~120
> secs).  Reverting patch 597a264b1a9c7e36d1728f677c66c5c1f7e3b837
> "net: deliver skbs on inactive slaves to exact matches" changes back
> to normal behavior.
> 
> Fred

This should be fixed here,

 From e897082fe7a5b591dc4dd5599ac39081a7c8e482 Mon Sep 17 00:00:00 2001
From: John Fastabend <john.r.fastabend@intel.com>
Date: Sun, 13 Jun 2010 10:36:30 +0000
Subject: [PATCH] net: fix deliver_no_wcard regression on loopback device

deliver_no_wcard is not being set in skb_copy_header.
In the skb_cloned case it is not being cleared and
may cause the skb to be dropped when the loopback device
pushes it back up the stack.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Tested-by: Markus Trippelsdorf <markus@trippelsdorf.de>
Signed-off-by: David S. Miller <davem@davemloft.net>
