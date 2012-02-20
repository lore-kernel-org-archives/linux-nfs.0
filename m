Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([209.198.142.2]:41330 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752327Ab2BTSo6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2012 13:44:58 -0500
Message-ID: <4F4294A9.20308@opengridcomputing.com>
Date: Mon, 20 Feb 2012 12:44:57 -0600
From: Tom Tucker <tom@opengridcomputing.com>
MIME-Version: 1.0
To: Dan Carpenter <dan.carpenter@oracle.com>
CC: tom@ogc.us, Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: question about map_read_chunks()
References: <20120220182003.GL2912@mwanda>
In-Reply-To: <20120220182003.GL2912@mwanda>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Dan,
> ----- Forwarded message from Dan Carpenter<dan.carpenter@oracle.com>  -----
>
> Date: Mon, 20 Feb 2012 12:50:19 +0300
> From: Dan Carpenter<dan.carpenter@oracle.com>
> To: Tom Tucker<tom@ogc.us>
> Cc: "J. Bruce Fields"<bfields@redhat.com>, netdev@vger.kernel.org, linux-nfs@vger.kernel.org
> Subject: question about map_read_chunks()
>
> I had a couple questions about some map_read_chunks().
>
> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>
>     150          ch_bytes = ntohl(ch->rc_target.rs_length);
>                  ^^^^^^^^
> It look like this is 32 bits from the network?

Yes, it is. All these values should be clamped by the wsize/rsize, 
however, I don't think we enforce that. We should add a check to 
svc_rdma_xdr_decode_req().

>
>     151          head->arg.head[0] = rqstp->rq_arg.head[0];
>     152          head->arg.tail[0] = rqstp->rq_arg.tail[0];
>     153          head->arg.pages =&head->pages[head->count];
>     154          head->hdr_count = head->count; /* save count of hdr pages */
>     155          head->arg.page_base = 0;
>     156          head->arg.page_len = ch_bytes;
>     157          head->arg.len = rqstp->rq_arg.len + ch_bytes;
>                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> Can overflow.
Without the proposed check, it can.

>     158          head->arg.buflen = rqstp->rq_arg.buflen + ch_bytes;
>                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> Same.  I didn't follow it through to see if an overflow matters.  Does
> it?

I think it could cause bad things to happen, yes.

>
>     159          head->count++;
>     160          chl_map->ch[0].start = 0;
>     161          while (byte_count) {
>     162                  rpl_map->sge[sge_no].iov_base =
>     163                          page_address(rqstp->rq_arg.pages[page_no]) + page_off;
>     164                  sge_bytes = min_t(int, PAGE_SIZE-page_off, ch_bytes);
>                                            ^^^
> This is the wrong cast to use.  A large ch_bytes would be counted as a
> negative value and get around the cap here.

I suppose, in theory, we could have a r/wsize > 2G, in which case, you are 
correct.

>     165                  rpl_map->sge[sge_no].iov_len = sge_bytes;
>
> regards,
> dan carpenter
>

I think adding a check to svc_rdma_xdr_decode_req() would avoid any 
possibility of overflow. I'll code up a patch.

Thanks,
Tom


