Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35834 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759631Ab1IISwR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2011 14:52:17 -0400
Subject: Re: Regression seen when HIGHMEM enabled with NFS on 3.1rc4 kernel
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "R, Sricharan" <r.sricharan@ti.com>
Cc: linux-omap@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 09 Sep 2011 14:51:57 -0400
In-Reply-To: <CAJ7qFSeB8bAGdYfZs-LFHuYqGWNA2RidY0EBEFw_1CndvG7q5A@mail.gmail.com>
References: <CAJ7qFSeB8bAGdYfZs-LFHuYqGWNA2RidY0EBEFw_1CndvG7q5A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1315594317.17611.25.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-09-09 at 18:40 +0530, R, Sricharan wrote: 
> Sorry resending again. My mailer settings thrashed my earlier email.
> 
> Hi,
>   A kernel crash is observed on 3.1rc4 kernel when HIGHMEM is enabled and
>   kernel is booted with a NFS on omap4430sdp. The issue happens in the below
>   scenario.
> 
>        In file net/sunrpc/xprtsock.c,
>          static int xs_send_pagedata( xxx, struct xdr_buf *xdr, ..)
>          {
>                 Struct page **ppage;
>                 ....
>                 .....
>                 ppage = xdr->pages + (base >> PAGE_SHIFT);
>                 ....
>             err = sock->ops->sendpage(sock, *ppage, base, len, flags);
> 
>             ...
>          }
> 
>          1) In the above piece of code, the *ppage value from ops->sendpage
>             function is finally passed on to Kmap by the lower level code to
>             get the virtual address of the page.
>          2) In some corner cases the value of *ppage pointer is NULL.
>          3) When highmem is enabled and a NULL pointer is passed to
>             Kmap, then kmap finally crashes. But in the case when highmem
>             is disabled, then kmap returns a junk value for NULL pointer.
> 
>             Highmem Enabled , kmap( NULL )-----> kernel crashes.
> 
>            Highmem disabled, kmap( NULL )-----> junk value is returned.
>                Subsequently this message is observed on
>                                                 the console.
> 
>                                 "RPC call returned error 14"
> 
>          4) Now the question is why is the value of *ppage = NULL is passed
>             from the above piece of code to lower layers.
>            Should that not have handled *ppage = NULL? and kmap should not
>             have received a NULL pointer?

I wouldn't expect *ppage to be NULL under any circumstances, so I'm
really curious as to what is happening here.

Could you perhaps add a printk() to that section of code to print out
the values of 'xdr->page_base', 'xdr->page_len', 'len' and 'remainder'
in the case where *ppage == NULL?

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

