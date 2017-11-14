Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39100 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753280AbdKNOlo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Nov 2017 09:41:44 -0500
Subject: Re: [PATCH v5 00/13] exit_net checks for objects initialized in
 net_init hook
To: David Miller <davem@davemloft.net>, anna.schumaker@netapp.com
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com
References: <cb06dace-88a8-fecf-92ad-02920920a0d3@virtuozzo.com>
 <a09a38cb-4aa3-ace5-3e0f-759d14cdef71@virtuozzo.com>
 <20171114.154720.1071922306148362515.davem@davemloft.net>
From: Vasily Averin <vvs@virtuozzo.com>
Message-ID: <9f9cddc7-1aea-020a-a8b6-1c62e5ddf0c2@virtuozzo.com>
Date: Tue, 14 Nov 2017 17:41:26 +0300
MIME-Version: 1.0
In-Reply-To: <20171114.154720.1071922306148362515.davem@davemloft.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2017-11-14 09:47, David Miller wrote:
> From: Vasily Averin <vvs@virtuozzo.com>
> Date: Sun, 12 Nov 2017 22:26:44 +0300
> 
>> OpenVz kernel team have a long history of fighting against namespace-related bugs,
>> some of them could be prevented by using simple checks described below.
>>
>> One of typical errors is related to live cycle of namespaces:
>> usually objects created for some namespace should not live longer than namespace itself.
> 
> All applied to net-next except patch #9 and #10 which need to go via the
> NFS maintainer.

As far as I see Anna included them into Anna's linux-nfs work git.

Thank you!
	Vasily Averin
