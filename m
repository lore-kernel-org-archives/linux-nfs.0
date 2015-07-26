Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37133 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754216AbbGZJ65 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 05:58:57 -0400
Received: by wibud3 with SMTP id ud3so80484501wib.0
        for <linux-nfs@vger.kernel.org>; Sun, 26 Jul 2015 02:58:56 -0700 (PDT)
Subject: Re: [PATCH V6 4/9] svcrdma: Use max_sge_rd for destination read
 depths
To: Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161837.25617.48584.stgit@build2.ogc.int>
 <00d301d0c641$c2fcb6a0$48f623e0$@opengridcomputing.com>
Cc: infinipath@intel.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55B4AF63.3040108@dev.mellanox.co.il>
Date: Sun, 26 Jul 2015 12:58:59 +0300
MIME-Version: 1.0
In-Reply-To: <00d301d0c641$c2fcb6a0$48f623e0$@opengridcomputing.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> @@ -1059,6 +1062,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>>   		ntohs(((struct sockaddr_in *)&newxprt->sc_cm_id->
>>   		       route.addr.dst_addr)->sin_port),
>>   		newxprt->sc_max_sge,
>> +		newxprt->sc_max_sge_rd,
>>   		newxprt->sc_sq_depth,
>>   		newxprt->sc_max_requests,
>>   		newxprt->sc_ord);
>>
>
> With the above patch change, we have no more users of the recently created rdma_cap_read_multi_sge().  Should I add a patch to remove it?

Yes please.
