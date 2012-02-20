Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:30917 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519Ab2BTJua (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2012 04:50:30 -0500
Date: Mon, 20 Feb 2012 12:50:19 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Tom Tucker <tom@ogc.us>
Cc: "J. Bruce Fields" <bfields@redhat.com>, netdev@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: question about map_read_chunks()
Message-ID: <20120220095019.GA21338@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I had a couple questions about some map_read_chunks().

net/sunrpc/xprtrdma/svc_rdma_recvfrom.c

   150          ch_bytes = ntohl(ch->rc_target.rs_length);
                ^^^^^^^^
It look like this is 32 bits from the network?

   151          head->arg.head[0] = rqstp->rq_arg.head[0];
   152          head->arg.tail[0] = rqstp->rq_arg.tail[0];
   153          head->arg.pages = &head->pages[head->count];
   154          head->hdr_count = head->count; /* save count of hdr pages */
   155          head->arg.page_base = 0;
   156          head->arg.page_len = ch_bytes;
   157          head->arg.len = rqstp->rq_arg.len + ch_bytes;
                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Can overflow.
   158          head->arg.buflen = rqstp->rq_arg.buflen + ch_bytes;
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Same.  I didn't follow it through to see if an overflow matters.  Does
it?

   159          head->count++;
   160          chl_map->ch[0].start = 0;
   161          while (byte_count) {
   162                  rpl_map->sge[sge_no].iov_base =
   163                          page_address(rqstp->rq_arg.pages[page_no]) + page_off;
   164                  sge_bytes = min_t(int, PAGE_SIZE-page_off, ch_bytes);
                                          ^^^
This is the wrong cast to use.  A large ch_bytes would be counted as a
negative value and get around the cap here.

   165                  rpl_map->sge[sge_no].iov_len = sge_bytes;

regards,
dan carpenter
