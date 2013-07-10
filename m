Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tuna.sandelman.ca ([209.87.252.184]:60051 "EHLO
	tuna.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754342Ab3GJUAj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Jul 2013 16:00:39 -0400
From: Michael Richardson <mcr@sandelman.ca>
To: Dean <seattleplus@gmail.com>
cc: "J.Bruce Fields" <bfields@citi.umich.edu>, NeilBrown <neilb@suse.de>,
        Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
In-Reply-To: <51DD9AD5.1030508@gmail.com>
References: <20130710092255.0240a36d@notabene.brown> <20130710022735.GI8281@fieldses.org> <51DD9AD5.1030508@gmail.com>
Date: Wed, 10 Jul 2013 15:59:25 -0400
Message-ID: <21294.1373486365@sandelman.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Dean <seattleplus@gmail.com> wrote:
    >> This could significantly limit the amount of parallelism that can be
    > achieved for a single TCP connection (and given that the
    >> Linux client strongly prefers a single connection now, this could
    > become more of an issue).

    > I understand the simplicity in using a single tcp connection, but
    > performance-wise it is definitely not the way to go on WAN links. When
    > even a miniscule amount of packet loss is added to the link (<0.001%
    > packet loss), the tcp buffer collapses and performance drops

And just remember bufferbloat.

    > Using multiple tcp connections allows better saturation of the link,
    > since when packet loss occurs on a stream, the other streams can fill
    > the void.  Today, the only solution is to scale up the number of
    > physical clients, which has high coordination overhead, or use a wan
    > accelerator such as Bitspeed or Riverbed (which comes with its own
    > issues such as extra hardware, cost, etc).

This is true on high speed links with few bottlenecks, but not so much when
there is a DSL-type bottleneck and excessive buffers.

--
]               Never tell me the odds!                 | ipv6 mesh networks [
]   Michael Richardson, Sandelman Software Works        | network architect  [
]     mcr@sandelman.ca  http://www.sandelman.ca/        |   ruby on rails    [

