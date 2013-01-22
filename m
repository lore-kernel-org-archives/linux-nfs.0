Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f52.google.com ([209.85.160.52]:63701 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622Ab3AVR0y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2013 12:26:54 -0500
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Ben Greear <greearb@candelatech.com>
Cc: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <1358875020.3464.4006.camel@edumazet-glaptop>
References: <50FDADF4.3060601@candelatech.com>
	 <50FDDE35.7070806@candelatech.com>
	 <1358829606.3464.3151.camel@edumazet-glaptop>
	 <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>
	 <1358875020.3464.4006.camel@edumazet-glaptop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Jan 2013 09:26:47 -0800
Message-ID: <1358875607.3464.4020.camel@edumazet-glaptop>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-22 at 09:17 -0800, Eric Dumazet wrote:
> On Tue, 2013-01-22 at 09:08 -0800, Ben Greear wrote:
> 
> > Unfortunately, I hit it again this morning after the first restart of
> > my application (which bounces all 3000 interfaces).  Memory poisoning
> > was disabled.
> 
> Is your NFS traffic using TCP or UDP ?
> 

Oh well, it seems macvlan.c has to skb_drop_dst(skb) before giving skb
to netif_rx()

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 68a43fe..4f049ee 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -114,6 +114,7 @@ static int macvlan_broadcast_one(struct sk_buff *skb,
 	if (!skb)
 		return NET_RX_DROP;
 
+	skb_dst_drop(skb);
 	if (local)
 		return vlan->forward(dev, skb);
 
@@ -220,6 +221,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 	if (!skb)
 		goto out;
 
+	skb_dst_drop(skb);
 	skb->dev = dev;
 	skb->pkt_type = PACKET_HOST;
 


