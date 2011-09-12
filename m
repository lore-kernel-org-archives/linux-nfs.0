Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:33700 "EHLO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751532Ab1ILGRH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 02:17:07 -0400
From: Sricharan R <r.sricharan@ti.com>
References: <CAJ7qFSeB8bAGdYfZs-LFHuYqGWNA2RidY0EBEFw_1CndvG7q5A@mail.gmail.com>
 <1315594317.17611.25.camel@lade.trondhjem.org>
In-Reply-To: <1315594317.17611.25.camel@lade.trondhjem.org>
Date: Mon, 12 Sep 2011 11:46:58 +0530
Message-ID: <dbdc7c3761a82e0b84f2f49c533c07a5@mail.gmail.com>
Subject: RE: Regression seen when HIGHMEM enabled with NFS on 3.1rc4 kernel
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-omap@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond,
[....]

>>          1) In the above piece of code, the *ppage value from ops-
>>sendpage
>>             function is finally passed on to Kmap by the lower level
code
>to
>>             get the virtual address of the page.
>>          2) In some corner cases the value of *ppage pointer is NULL.
>>          3) When highmem is enabled and a NULL pointer is passed to
>>             Kmap, then kmap finally crashes. But in the case when
highmem
>>             is disabled, then kmap returns a junk value for NULL
pointer.
>>
>>             Highmem Enabled , kmap( NULL )-----> kernel crashes.
>>
>>            Highmem disabled, kmap( NULL )-----> junk value is returned.
>>                Subsequently this message is observed on
>>                                                 the console.
>>
>>                                 "RPC call returned error 14"
>>
>>          4) Now the question is why is the value of *ppage = NULL is
>passed
>>             from the above piece of code to lower layers.
>>            Should that not have handled *ppage = NULL? and kmap should
>not
>>             have received a NULL pointer?
>
>I wouldn't expect *ppage to be NULL under any circumstances, so I'm
>really curious as to what is happening here.
>
>Could you perhaps add a printk() to that section of code to print out
>the values of 'xdr->page_base', 'xdr->page_len', 'len' and 'remainder'
>in the case where *ppage == NULL?
>


Thanks for the response.
I added a printk just before err = sock->ops->sendpage(sock, *ppage, base,
len, flags);
So here are values when *ppage is NULL.

xdr->page_base= 0xCE9  xdr->page_len=0x400 len=0xE9 remainder=0x0.

Thanks,
 Sricharan
