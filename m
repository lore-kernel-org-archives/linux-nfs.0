Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58328 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756158Ab1ILOmN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 10:42:13 -0400
Subject: RE: Regression seen when HIGHMEM enabled with NFS on 3.1rc4 kernel
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Sricharan R <r.sricharan@ti.com>
Cc: linux-omap@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 12 Sep 2011 10:41:49 -0400
In-Reply-To: <dbdc7c3761a82e0b84f2f49c533c07a5@mail.gmail.com>
References: <CAJ7qFSeB8bAGdYfZs-LFHuYqGWNA2RidY0EBEFw_1CndvG7q5A@mail.gmail.com>
	 <1315594317.17611.25.camel@lade.trondhjem.org>
	 <dbdc7c3761a82e0b84f2f49c533c07a5@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1315838509.12736.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-09-12 at 11:46 +0530, Sricharan R wrote: 
> Hi Trond,
> [....]
> 
> >>          1) In the above piece of code, the *ppage value from ops-
> >>sendpage
> >>             function is finally passed on to Kmap by the lower level
> code
> >to
> >>             get the virtual address of the page.
> >>          2) In some corner cases the value of *ppage pointer is NULL.
> >>          3) When highmem is enabled and a NULL pointer is passed to
> >>             Kmap, then kmap finally crashes. But in the case when
> highmem
> >>             is disabled, then kmap returns a junk value for NULL
> pointer.
> >>
> >>             Highmem Enabled , kmap( NULL )-----> kernel crashes.
> >>
> >>            Highmem disabled, kmap( NULL )-----> junk value is returned.
> >>                Subsequently this message is observed on
> >>                                                 the console.
> >>
> >>                                 "RPC call returned error 14"
> >>
> >>          4) Now the question is why is the value of *ppage = NULL is
> >passed
> >>             from the above piece of code to lower layers.
> >>            Should that not have handled *ppage = NULL? and kmap should
> >not
> >>             have received a NULL pointer?
> >
> >I wouldn't expect *ppage to be NULL under any circumstances, so I'm
> >really curious as to what is happening here.
> >
> >Could you perhaps add a printk() to that section of code to print out
> >the values of 'xdr->page_base', 'xdr->page_len', 'len' and 'remainder'
> >in the case where *ppage == NULL?
> >
> 
> 
> Thanks for the response.
> I added a printk just before err = sock->ops->sendpage(sock, *ppage, base,
> len, flags);
> So here are values when *ppage is NULL.
> 
> xdr->page_base= 0xCE9  xdr->page_len=0x400 len=0xE9 remainder=0x0.
> 
> Thanks,
>  Sricharan

Can you please tell me what the mount options are for this setup?

Are you running any applications that might be using O_DIRECT writes?

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

