Return-Path: <SRS0=k36n=QA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C239C282C3
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 16:11:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 336D8217D7
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 16:11:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728056AbfAXQLn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 24 Jan 2019 11:11:43 -0500
Received: from p3plsmtpa12-04.prod.phx3.secureserver.net ([68.178.252.233]:41750
        "EHLO p3plsmtpa12-04.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727649AbfAXQLn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jan 2019 11:11:43 -0500
X-Greylist: delayed 438 seconds by postgrey-1.27 at vger.kernel.org; Thu, 24 Jan 2019 11:11:43 EST
Received: from [10.3.6.161] ([8.25.222.2])
        by :SMTPAUTH: with ESMTPSA
        id mhUOgAKMjwsznmhUOg8GQg; Thu, 24 Jan 2019 09:04:24 -0700
Subject: Re: [PATCH v2] xprtrdma: Make sure Send CQ is allocated on an
 existing compvec
To:     Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.com>,
        linux-rdma@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org, chuck.lever@oracle.com
References: <164839c0-399e-d01b-dafc-5c873e650bdb@suse.com>
From:   Tom Talpey <tom@talpey.com>
Message-ID: <0e2e8737-9ec7-f3b5-ff0c-f178330b826c@talpey.com>
Date:   Thu, 24 Jan 2019 08:04:23 -0800
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <164839c0-399e-d01b-dafc-5c873e650bdb@suse.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CMAE-Envelope: MS4wfNZNmwKjHLXbnJhEq31yb4mNVlO/EpBrm15FZ35ZlE+YBBMRvBZFjPgEYInXZePv0mDTN9IXt6xJJpP3dbKCwNycj7A39rWAxKzRWIRDnXpCwfu2Z21m
 2bxkQW9dlRlGJaCB/H+7MONk0MTKzaBV1unSScvqh00EF+AJGFEdNENshVJe9UHZ9Cuxk1e8ub0KY6X6/qrTBftCSrhIgMJHEgQNIoIbvwdIcYcQavM90+zM
 lmo9Lp3v+BMXMGZYgizW3p7M24V/YdsWAouztc1YAx4=
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 1/23/2019 11:02 PM, Nicolas Morey-Chaisemartin wrote:
> Make sure the device has at least 2 completion vectors before allocating to compvec#1

I agree this fixes the bug, but wouldn't it be better to attempt
to steer the affinity to chosen cores, rather than unconditionally
using static values? At least make some determination that the
device, and the memory that was just allocated, were pointed to
slightly optimal NUMA node to handle its completions.

Does the verbs API not support this? I thought that was discussed
a while back.

Tom.

> Fixes: a4699f5647f3 (xprtrdma: Put Send CQ in IB_POLL_WORKQUEUE mode)
> Signed-off-by: Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.com>
> ---
> Fixes since v1:
>   - Use num_comp_vector instead online_cpus
> 
>   net/sunrpc/xprtrdma/verbs.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index b725911c0f3f..db913bcef984 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -546,7 +546,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>   
>   	sendcq = ib_alloc_cq(ia->ri_device, NULL,
>   			     ep->rep_attr.cap.max_send_wr + 1,
> -			     1, IB_POLL_WORKQUEUE);
> +			     ia->ri_device->num_comp_vectors > 1 ? 1 : 0, IB_POLL_WORKQUEUE);
>   	if (IS_ERR(sendcq)) {
>   		rc = PTR_ERR(sendcq);
>   		dprintk("RPC:       %s: failed to create send CQ: %i\n",
> 
