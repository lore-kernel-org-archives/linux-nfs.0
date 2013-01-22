Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f52.google.com ([209.85.160.52]:57657 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688Ab3AVEkL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 23:40:11 -0500
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Ben Greear <greearb@candelatech.com>
Cc: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <50FDDE35.7070806@candelatech.com>
References: <50FDADF4.3060601@candelatech.com>
	 <50FDDE35.7070806@candelatech.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 21 Jan 2013 20:40:06 -0800
Message-ID: <1358829606.3464.3151.camel@edumazet-glaptop>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-01-21 at 16:32 -0800, Ben Greear wrote:
> On 01/21/2013 01:07 PM, Ben Greear wrote:
> > I posted about this a few days ago, but this time the patches applied
> > are minimal and there are no out-of-tree kernel modules loaded.
> 
> Here's another crash, this time with SLUB memory debugging turned on.
> 
> Seems much harder to hit this way...I've only managed this one.  I
> believe the RCX register might be interesting...that 6b is probably
> freed memory poisioning.  Maybe skb or skb_dest() is already freed?
> 
> I have added a 'verify_mem_not_deleted(skb)' before the
> dst_input line in ip_rcv_finish..but so far, it hasn't
> hit the problem...
> 

There is no way skb is freed here.

I would say macvlan is at fault here.

It probably lacks a proper (dev->flags & IFF_UP) test.

Please try :

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index d3fb97d..c07bdef 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -111,9 +111,15 @@ static int macvlan_broadcast_one(struct sk_buff *skb,
 				 const struct ethhdr *eth, bool local)
 {
 	struct net_device *dev = vlan->dev;
+
 	if (!skb)
 		return NET_RX_DROP;
 
+	if (!(dev->flags & IFF_UP)) {
+		kfree_skb(skb);
+		return NET_RX_DROP;
+	}
+
 	if (local)
 		return vlan->forward(dev, skb);
 


