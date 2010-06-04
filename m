From: David Miller <davem@davemloft.net>
Subject: Re: NULL Pointer Deference: NFS & Telnet
Date: Fri, 04 Jun 2010 16:15:30 -0700 (PDT)
Message-ID: <20100604.161530.245412851.davem@davemloft.net>
References: <1274851741.25136.16.camel@edumazet-laptop>
	<27F9C60D11D683428E133F85D2BB4A53043E3EE6A3@dlee03.ent.ti.com>
	<1274906933.2542.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Cc: x0066660@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-omap@vger.kernel.org, tony@atomide.com,
	santosh.shilimkar@ti.com, Tristram.Ha@micrel.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1274906933.2542.17.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 May 2010 22:48:53 +0200

> Le mercredi 26 mai 2010 =E0 15:19 -0500, Arce, Abraham a =E9crit :
>=20
>> By increasing the allocation length of our rx skbuff the corruption =
issue is fixed... I have increased it by 2... Were we writing outside o=
ur boundaries of skb data?
>>=20
>> Please let me know about this approach...
>>=20
>> diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
>> index b4fb07a..6da81e1 100644
>> --- a/drivers/net/ks8851.c
>> +++ b/drivers/net/ks8851.c
>> @@ -504,7 +504,7 @@ static void ks8851_rx_pkts(struct ks8851_net *ks=
)
>>                                ks->rc_rxqcr | RXQCR_SDA | RXQCR_ADRF=
E);
>>=20
>>                 if (rxlen > 0) {
>> -                       skb =3D netdev_alloc_skb(ks->netdev, rxlen +=
 2 + 8);
>> +                       skb =3D netdev_alloc_skb(ks->netdev, rxlen +=
 4 + 8);
>>                         if (!skb) {
>>=20
>> Best Regards
>> Abraham
>>=20
>=20
> Yes that makes sense, nr_frag is right after the packet (padded to L1
> cache size)
>=20
> But please do the correct allocation ?
>=20
> Also, we dont need FCS ?

Can we make some progress and get this patch tested and formally
submitted so we can kill this bug?

Thanks!
