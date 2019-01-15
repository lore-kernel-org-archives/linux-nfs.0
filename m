Return-Path: <SRS0=7zHz=PX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB3AEC43387
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Jan 2019 22:15:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C212120866
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Jan 2019 22:15:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729724AbfAOWP0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Jan 2019 17:15:26 -0500
Received: from gateway23.websitewelcome.com ([192.185.49.179]:45196 "EHLO
        gateway23.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727984AbfAOWP0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2019 17:15:26 -0500
X-Greylist: delayed 1288 seconds by postgrey-1.27 at vger.kernel.org; Tue, 15 Jan 2019 17:15:25 EST
Received: from cm16.websitewelcome.com (cm16.websitewelcome.com [100.42.49.19])
        by gateway23.websitewelcome.com (Postfix) with ESMTP id 3B8DEC1D3
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jan 2019 15:53:57 -0600 (CST)
Received: from gator4166.hostgator.com ([108.167.133.22])
        by cmsmtp with SMTP
        id jWejgRaIS4FKpjWejgriTc; Tue, 15 Jan 2019 15:53:57 -0600
X-Authority-Reason: nr=8
Received: from [189.250.130.205] (port=45270 helo=[192.168.43.131])
        by gator4166.hostgator.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128)
        (Exim 4.91)
        (envelope-from <gustavo@embeddedor.com>)
        id 1gjWeh-001yZe-Sk; Tue, 15 Jan 2019 15:53:56 -0600
Subject: Re: [PATCH net-next] svcrdma: Use struct_size() in kmalloc()
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20190115211140.GA16131@embeddedor>
 <F652FEF1-0FD7-4FFD-80D4-44DBC2FF47B5@oracle.com>
From:   "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Message-ID: <9e965c53-116d-4aad-63e9-e26264bea9d1@embeddedor.com>
Date:   Tue, 15 Jan 2019 15:53:48 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <F652FEF1-0FD7-4FFD-80D4-44DBC2FF47B5@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - gator4166.hostgator.com
X-AntiAbuse: Original Domain - vger.kernel.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - embeddedor.com
X-BWhitelist: no
X-Source-IP: 189.250.130.205
X-Source-L: No
X-Exim-ID: 1gjWeh-001yZe-Sk
X-Source: 
X-Source-Args: 
X-Source-Dir: 
X-Source-Sender: ([192.168.43.131]) [189.250.130.205]:45270
X-Source-Auth: gustavo@embeddedor.com
X-Email-Count: 27
X-Source-Cap: Z3V6aWRpbmU7Z3V6aWRpbmU7Z2F0b3I0MTY2Lmhvc3RnYXRvci5jb20=
X-Local-Domain: yes
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 1/15/19 3:49 PM, Chuck Lever wrote:
> 
> 
> On Jan 15, 2019, at 4:11 PM, Gustavo A. R. Silva <gustavo@embeddedor.com> wrote:
> 
>> One of the more common cases of allocation size calculations is finding
>> the size of a structure that has a zero-sized array at the end, along
>> with memory for some number of elements for that array. For example:
>>
>> struct foo {
>>     int stuff;
>>     struct boo entry[];
>> };
>>
>> instance = kmalloc(sizeof(struct foo) + count * sizeof(struct boo), GFP_KERNEL);
>>
>> Instead of leaving these open-coded and prone to type mistakes, we can
>> now use the new struct_size() helper:
>>
>> instance = kmalloc(struct_size(instance, entry, count), GFP_KERNEL);
>>
>> This code was detected with the help of Coccinelle.
>>
>> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> 
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> 

Thank you, Chuck.
--
Gustavo

> 
>> ---
>> net/sunrpc/xprtrdma/svc_rdma_rw.c | 3 +--
>> 1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
>> index dc1951759a8e..cad37c2122ab 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
>> @@ -64,8 +64,7 @@ svc_rdma_get_rw_ctxt(struct svcxprt_rdma *rdma, unsigned int sges)
>> 		spin_unlock(&rdma->sc_rw_ctxt_lock);
>> 	} else {
>> 		spin_unlock(&rdma->sc_rw_ctxt_lock);
>> -		ctxt = kmalloc(sizeof(*ctxt) +
>> -			       SG_CHUNK_SIZE * sizeof(struct scatterlist),
>> +		ctxt = kmalloc(struct_size(ctxt, rw_first_sgl, SG_CHUNK_SIZE),
>> 			       GFP_KERNEL);
>> 		if (!ctxt)
>> 			goto out;
>> -- 
>> 2.20.1
> 
> --
> Chuck Lever
> 
> 
> 
