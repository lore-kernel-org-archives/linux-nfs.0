Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34715 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755333Ab1G2MLf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 08:11:35 -0400
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Greg Banks <gnb@fastmail.fm>
Cc: Christoph Hellwig <hch@infradead.org>, NeilBrown <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
In-Reply-To: <5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm>
References: <20110729153207.17af3085@notabene.brown>
	 <4E324DB4.7060600@fastmail.fm> <1311921035.7845.10.camel@edumazet-laptop>
	 <4E3258E1.6020000@fastmail.fm> <20110729103634.GA12050@infradead.org>
	 <5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 29 Jul 2011 14:11:31 +0200
Message-ID: <1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Le vendredi 29 juillet 2011 à 21:58 +1000, Greg Banks a écrit :

> 
> Sure, and a whole lot of the callsites are ("..._%d", cpu), hence the  
> unfortune :(

BTW, we could name nfsd threads differently :

Currently, they all are named : "nfsd"

If SVC_POOL_PERCPU is selected, we could name them : 
nfsd_c0 -> nfsd_cN

If SVC_POOL_PERNODE is selected, we could name them :
nfsd_n0  -> nfsd_nN

That would help to check with "ps aux" which cpu/nodes are under stress.



