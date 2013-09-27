Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:59478 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752643Ab3I0PXN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Sep 2013 11:23:13 -0400
Message-ID: <5245A2DE.9020307@opengridcomputing.com>
Date: Fri, 27 Sep 2013 10:23:10 -0500
From: Tom Tucker <tom@opengridcomputing.com>
MIME-Version: 1.0
To: Dan Carpenter <dan.carpenter@oracle.com>
CC: Tom Tucker <tom@ogc.us>, "J. Bruce Fields" <bfields@redhat.com>,
        netdev@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: question about map_read_chunks()
References: <20120220095019.GA21338@elgon.mountain> <20130927122108.GF6247@mwanda>
In-Reply-To: <20130927122108.GF6247@mwanda>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Dan,

On 9/27/13 7:21 AM, Dan Carpenter wrote:
> I have looked at this again, and I still worry that it looks like a bug.
> (remote security related blah blah blah).
>
> regards,
> dan carpenter
>
> On Mon, Feb 20, 2012 at 12:50:19PM +0300, Dan Carpenter wrote:
>> I had a couple questions about some map_read_chunks().
>>
>> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>
>>     150          ch_bytes = ntohl(ch->rc_target.rs_length);
>>                  ^^^^^^^^
>> It look like this is 32 bits from the network?
>>
>>     151          head->arg.head[0] = rqstp->rq_arg.head[0];
>>     152          head->arg.tail[0] = rqstp->rq_arg.tail[0];
>>     153          head->arg.pages = &head->pages[head->count];
>>     154          head->hdr_count = head->count; /* save count of hdr pages */
>>     155          head->arg.page_base = 0;
>>     156          head->arg.page_len = ch_bytes;
>>     157          head->arg.len = rqstp->rq_arg.len + ch_bytes;
>>                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>> Can overflow.
>>     158          head->arg.buflen = rqstp->rq_arg.buflen + ch_bytes;
agreed.
>>                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>> Same.  I didn't follow it through to see if an overflow matters.  Does
>> it?
>>
>>     159          head->count++;
>>     160          chl_map->ch[0].start = 0;
>>     161          while (byte_count) {
>>     162                  rpl_map->sge[sge_no].iov_base =
>>     163                          page_address(rqstp->rq_arg.pages[page_no]) + page_off;
>>     164                  sge_bytes = min_t(int, PAGE_SIZE-page_off, ch_bytes);
>>                                            ^^^
>> This is the wrong cast to use.  A large ch_bytes would be counted as a
>> negative value and get around the cap here.
True, but if we validate the wire data like we should, that's probably 
not an issue.

>>     165                  rpl_map->sge[sge_no].iov_len = sge_bytes;
>>
>> regards,
>> dan carpenter
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

