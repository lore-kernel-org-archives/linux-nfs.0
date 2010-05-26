From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: NULL Pointer Deference: NFS & Telnet
Date: Wed, 26 May 2010 07:29:01 +0200
Message-ID: <1274851741.25136.16.camel@edumazet-laptop>
References: <27F9C60D11D683428E133F85D2BB4A53043E33A997@dlee03.ent.ti.com>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EDFE6@dlee03.ent.ti.com>
	 <20100525.185236.193707791.davem@davemloft.net>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EDFF1@dlee03.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org" <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
	"Shilimkar, Santosh" <santosh.shilimkar@ti.com>
To: "Arce, Abraham" <x0066660@ti.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:41332 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab0EZF3K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 01:29:10 -0400
In-Reply-To: <27F9C60D11D683428E133F85D2BB4A53043E3EDFF1-lTKHBJngVwKIQmiDNMet8wC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le mardi 25 mai 2010 =C3=A0 21:02 -0500, Arce, Abraham a =C3=A9crit :
> Thanks David,
>=20
> > > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > > index f8abf68..eb81f76 100644
> > > --- a/net/core/skbuff.c
> > > +++ b/net/core/skbuff.c
> > > @@ -334,7 +334,7 @@ static void skb_release_data(struct sk_buff *=
skb)
> > >  	if (!skb->cloned ||
> > >  	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + =
1 : 1,
> > >  			       &skb_shinfo(skb)->dataref)) {
> > > -		if (skb_shinfo(skb)->nr_frags) {
> > > +		if (skb_shinfo(skb)->nr_frags && skb_has_frags(skb)) {
> > >  			int i;
> > >  			for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
> > >  				put_page(skb_shinfo(skb)->frags[i].page);
> >=20
> > skb_shinfo(skb)->nr_frags counts the number of entries contained
> > in the skb_shinfo(skb)->frags[] array.
> >=20
> > This has nothing to do with the frag list pointer,
> > skb_shinfo(skb)->frag_list, which is what skb_has_frags()
> > tests.
> >=20
> > You've got some kind of memory corruption going on and it
> > appears to have nothing to do with the code paths you're
> > playing with here.
>=20
> Do you have any recommendation on debugging technique/tool for this m=
emory corruption issue?
>=20
> Best Regards
> Abraham
> --

It seems quite strange. You have a skb->nr_frags > 0 value, but a
frags[i].page =3D 0 value

You might add following function :

shinfo_check(struct sk_buff *skb)
{
	struct skb_shared_info *shinfo =3D skb_shinfo(skb);
	int i;

	WARN_ON(shinfo->nr_frags >=3D MAX_SKB_FRAGS);
	for (i =3D 0; i < shinfo->nr_frags; i++)
		WARN_ON(!shinfo->frags[i].page);
}

And call it from various points, to check who corrupts your skb.



