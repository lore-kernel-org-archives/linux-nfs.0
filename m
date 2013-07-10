Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:43906 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754524Ab3GJRjp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Jul 2013 13:39:45 -0400
Message-ID: <51DD9C5A.3000505@candelatech.com>
Date: Wed, 10 Jul 2013 10:39:38 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Dean <seattleplus@gmail.com>
CC: "J.Bruce Fields" <bfields@citi.umich.edu>, NeilBrown <neilb@suse.de>,
        Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
References: <20130710092255.0240a36d@notabene.brown> <20130710022735.GI8281@fieldses.org> <51DD9AD5.1030508@gmail.com>
In-Reply-To: <51DD9AD5.1030508@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/10/2013 10:33 AM, Dean wrote:
>  > This could significantly limit the amount of parallelism that can be achieved for a single TCP connection (and given that the
>  > Linux client strongly prefers a single connection now, this could become more of an issue).
>
> I understand the simplicity in using a single tcp connection, but performance-wise it is definitely not the way to go on WAN links. When even a miniscule amount
> of packet loss is added to the link (<0.001% packet loss), the tcp buffer collapses and performance drops significantly (especially on 10GigE WAN links).  I
> think new TCP algorithms could help the problem somewhat, but nothing available today makes much of a difference vs. cubic.
>
> Using multiple tcp connections allows better saturation of the link, since when packet loss occurs on a stream, the other streams can fill the void.  Today, the
> only solution is to scale up the number of physical clients, which has high coordination overhead, or use a wan accelerator such as Bitspeed or Riverbed (which
> comes with its own issues such as extra hardware, cost, etc).

I have a set of patches that allows one to do multiple unique mounts to the same server from a single
client, but the patches are for the client side, so it would not help
non-Linux clients.  And, the patches were rejected for upstream as not being
useful.  But, if you are interested in such, please let me know and I can point
you to them...

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

