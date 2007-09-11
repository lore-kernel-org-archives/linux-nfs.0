From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [OOPS] 2.6.23-rc5 in tcp/net/nfsd
Date: Tue, 11 Sep 2007 17:00:13 +0800
Message-ID: <E1IV1bR-0001CT-00@gondolin.me.apana.org.au>
References: <20070911083200.GA3409@hindley.org.uk>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	nfs@lists.sourceforge.net, neilb@suse.de
To: mark@hindley.org.uk (Mark Hindley)
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20070911083200.GA3409@hindley.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Mark Hindley <mark@hindley.org.uk> wrote:
>
> Code: 01 00 00 03 75 0e 8b 42 18 8b 40 0c 8b 80 c4 00 00 00 eb 0a 8b 4c 24 08 8b 41 18 8b 40 28 0f c8 89 04 24 8b 44 24 08 b9 04 00 00 <00> ba 03 00 00 00 bf a6 ff ff
> EIP: [<c02625bf>] ip_fragment+0x7f/0x680 SS:ESP 0068:ccb48b3c

The EIP is off by one byte.  So either a hardware problem or a
really unlikely result of stack corruption.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
