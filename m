From: Greg Banks <gnb@fastmail.fm>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Fri, 29 Jul 2011 23:30:05 +1000
Message-ID: <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
References: <20110729153207.17af3085@notabene.brown> <4E324DB4.7060600@fastmail.fm> <1311921035.7845.10.camel@edumazet-laptop> <4E3258E1.6020000@fastmail.fm> <20110729103634.GA12050@infradead.org> <5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm> <1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0 (iPhone Mail 7C144)
Content-Type: text/plain; charset=utf-8;
	format=flowed	delsp=yes
Cc: Christoph Hellwig <hch@infradead.org>, NeilBrown <neilb@suse.de>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:57411 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750901Ab1G2NaM convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2011 09:30:12 -0400
In-Reply-To: <1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Sent from my iPhone

On 29/07/2011, at 22:11, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le vendredi 29 juillet 2011 =C3=A0 21:58 +1000, Greg Banks a =C3=A9cr=
it :
>
>>
>> Sure, and a whole lot of the callsites are ("..._%d", cpu), hence th=
e
>> unfortune :(
>
> BTW, we could name nfsd threads differently :
>
> Currently, they all are named : "nfsd"
>
> If SVC_POOL_PERCPU is selected, we could name them :
> nfsd_c0 -> nfsd_cN
>
> If SVC_POOL_PERNODE is selected, we could name them :
> nfsd_n0  -> nfsd_nN
>
> That would help to check with "ps aux" which cpu/nodes are under =20
> stress.
>
>

I like it!

>

Greg.