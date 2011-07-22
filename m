Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:38914 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932297Ab1GVVo0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2011 17:44:26 -0400
In-Reply-To: <1311368872.4027.76.camel@dagon.hellion.org.uk>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
 <1311340653-19336-10-git-send-email-ian.campbell@citrix.com>
 <CAHXqBFLQFKqK=ORpDQx6s2ud8mWkx=YC_AT60GVS+4XK0H61pw@mail.gmail.com> <1311368872.4027.76.camel@dagon.hellion.org.uk>
From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Date: Fri, 22 Jul 2011 23:44:05 +0200
Message-ID: <CAHXqBF+TJrBvEo+fd4tfXxDucEx5QaCgfBWPQ2B5UPjYQUAUgg@mail.gmail.com>
Subject: Re: [PATCH 10/13] net: add paged frag destructor to skb_fill_page_desc()
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "James E.J. Bottomley" <JBottomley@parallels.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "Pekka Savola (ipv6)" <pekkas@netcore.fi>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "devel@open-fcoe.org" <devel@open-fcoe.org>
Content-Type: text/plain; charset=ISO-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

W dniu 22 lipca 2011 23:07 u¿ytkownik Ian Campbell
<Ian.Campbell@eu.citrix.com> napisa³:
> On Fri, 2011-07-22 at 20:58 +0100, Micha³ Miros³aw wrote:
>> 2011/7/22 Ian Campbell <ian.campbell@citrix.com>:
>> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> > index 9818fe2..faee8d3 100644
>> > --- a/include/linux/skbuff.h
>> > +++ b/include/linux/skbuff.h
>> > @@ -1134,12 +1134,14 @@ static inline int skb_pagelen(const struct sk_buff *skb)
>> >  * Does not take any additional reference on the fragment.
>> >  */
>> >  static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
>> > -                                       struct page *page, int off, int size)
>> > +                                       struct page *page,
>> > +                                       struct skb_frag_destructor *destroy,
>> > +                                       int off, int size)
>> >  {
>> >        skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
>> >
>> >        frag->page.p              = page;
>> > -       frag->page.destructor     = NULL;
>> > +       frag->page.destructor     = destroy;
>> >        frag->page_offset         = off;
>> >        frag->size                = size;
>> >  }
>>
>> You could just rename this function to e.g.
>> __skb_fill_fragile_page_desc() (or whatever name) add an inline
>> wrapper calling it with destroy == NULL. This will avoid touching all
>> those drivers which won't ever need this functionality.
>
> I could call this variant __skb_frag_init (which I think better fits
> into the pattern of the new functions) and leave the existing
> __skb_fill_page_desc as a compat wrapper if that's preferred but I was
> trying to avoid duplicating up constructors just for different sets of
> defaults.

It's just Huffman coding: since most users need destroy = NULL, it's
good to have a wrapper for this case as it will then take less time to
write and understand the code (you won't need to think what is this
NULL for in all those places).

Best Regards,
Micha³ Miros³aw
