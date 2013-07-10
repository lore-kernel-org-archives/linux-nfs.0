Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f41.google.com ([209.85.160.41]:38724 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754712Ab3GJRdN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Jul 2013 13:33:13 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp16so6959911pbb.0
        for <linux-nfs@vger.kernel.org>; Wed, 10 Jul 2013 10:33:13 -0700 (PDT)
Message-ID: <51DD9AD5.1030508@gmail.com>
Date: Wed, 10 Jul 2013 10:33:09 -0700
From: Dean <seattleplus@gmail.com>
MIME-Version: 1.0
To: "J.Bruce Fields" <bfields@citi.umich.edu>
CC: NeilBrown <neilb@suse.de>, Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
References: <20130710092255.0240a36d@notabene.brown> <20130710022735.GI8281@fieldses.org>
In-Reply-To: <20130710022735.GI8281@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 > This could significantly limit the amount of parallelism that can be 
achieved for a single TCP connection (and given that the
 > Linux client strongly prefers a single connection now, this could 
become more of an issue).

I understand the simplicity in using a single tcp connection, but 
performance-wise it is definitely not the way to go on WAN links. When 
even a miniscule amount of packet loss is added to the link (<0.001% 
packet loss), the tcp buffer collapses and performance drops 
significantly (especially on 10GigE WAN links).  I think new TCP 
algorithms could help the problem somewhat, but nothing available today 
makes much of a difference vs. cubic.

Using multiple tcp connections allows better saturation of the link, 
since when packet loss occurs on a stream, the other streams can fill 
the void.  Today, the only solution is to scale up the number of 
physical clients, which has high coordination overhead, or use a wan 
accelerator such as Bitspeed or Riverbed (which comes with its own 
issues such as extra hardware, cost, etc).


> It does make a difference on high bandwidth-product networks (something
> people have also hit).  I'd rather not regress there and also would
> rather not require manual tuning for something we should be able to get
> right automatically.'

Previous to this patch, the tcp buffer was fixed to such a small size 
(especially for writes) that the idea of parallelism was moot anyways.  
Whatever the tcp buffer negotiates to now is definitely bigger than was 
what there before hand, which I think is brought out by the fact that no 
performance regression was found.

Regressing back to the old way is a death nail to any system with a 
delay of >1ms or a bandwidth of >1GigE, so I definitely hope we never go 
there.  Of course, now that autoscaling allows the tcp buffer to grow to 
reasonable values to achieve good performance for 10+GigE and WAN links, 
if we can improve the parallelism/stability even further, that would be 
great.
Dean
