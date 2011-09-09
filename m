Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:36122 "EHLO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933296Ab1IIMmw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2011 08:42:52 -0400
From: Sricharan R <r.sricharan@ti.com>
Date: Fri, 9 Sep 2011 18:12:44 +0530
Message-ID: <ef6baf9c7c0f44d1d50e3f65c6b038be@mail.gmail.com>
Subject: Regression seen when HIGHMEM enabled with NFS on 3.1rc4 kernel
To: linux-omap@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,
  A kernel crash is observed on 3.1rc4 kernel when HIGHMEM is enabled and
  kernel is booted with a NFS on omap4430sdp. The issue happens in the
below
  scenario.

       In file net/sunrpc/xprtsock.c,
         static int xs_send_pagedata( xxx, struct xdr_buf *xdr, ..)
         {
		Struct page **ppage;
		....
		.....
		ppage = xdr->pages + (base >> PAGE_SHIFT);
		....
            err = sock->ops->sendpage(sock, *ppage, base, len, flags);

            ...
         }

         1) In the above piece of code, the *ppage value from
ops->sendpage 		function is finally passed on to Kmap by the lower
level code to 		get the virtual address of the page.
	   2) In some corner cases the value of *ppage pointer is NULL.
         3) When highmem is enabled and a NULL pointer is passed to
            Kmap, then kmap finally crashes. But in the case when highmem
            is disabled, then kmap returns a junk value for NULL pointer.

               Highmem Enabled , kmap( NULL )-----> kernel crashes.

               Highmem disabled, kmap( NULL )-----> junk value is
returned.
		   				Subsequently this message
is observed on
						the console.

		                        "RPC call returned error 14"

         4) Now the question is why is the value of *ppage = NULL is
passed
		from the above piece of code to lower layers.
           Should that not have handled *ppage = NULL? and kmap should not
have received a NULL pointer?

Thanks,
  Sricharan
