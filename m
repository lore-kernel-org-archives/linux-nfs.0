Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:36200 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540Ab1GOWe5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 18:34:57 -0400
In-Reply-To: <1310728031-19569-3-git-send-email-ian.campbell@citrix.com>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com> <1310728031-19569-3-git-send-email-ian.campbell@citrix.com>
From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Date: Sat, 16 Jul 2011 00:34:36 +0200
Message-ID: <CAHXqBF+xGAK6o0M0QCkuPKvziDK4Y3ceHVsmbB9tXiN3XX0-Sg@mail.gmail.com>
Subject: Re: [PATCH 03/10] net: add APIs for manipulating skb page fragments.
To: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

2011/7/15 Ian Campbell <ian.campbell@citrix.com>:
[...]
> +static inline dma_addr_t skb_frag_pci_map(struct pci_dev *hwdev,
> +                                         const skb_frag_t *frag,
> +                                         unsigned long offset,
> +                                         size_t size,
> +                                         int direction)
> +
> +{
> +       return pci_map_page(hwdev, __skb_frag_page(frag),
> +                           frag->page_offset + offset, size, direction);
> +}

You can get rid of this one, as drivers should be converted to generic
DMA API instead. The change is only in passing &pci_dev->dev instead
of pci_dev.

Best Regards,
Micha³ Miros³aw
