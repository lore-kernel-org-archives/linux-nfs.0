Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36120 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751234AbdKNGrY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Nov 2017 01:47:24 -0500
Date: Tue, 14 Nov 2017 15:47:20 +0900 (KST)
Message-Id: <20171114.154720.1071922306148362515.davem@davemloft.net>
To: vvs@virtuozzo.com
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, courmisch@gmail.com,
        linux-ppp@vger.kernel.org, paulus@samba.org,
        herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org
Subject: Re: [PATCH v5 00/13] exit_net checks for objects initialized in
 net_init hook
From: David Miller <davem@davemloft.net>
In-Reply-To: <a09a38cb-4aa3-ace5-3e0f-759d14cdef71@virtuozzo.com>
References: <cb06dace-88a8-fecf-92ad-02920920a0d3@virtuozzo.com>
        <a09a38cb-4aa3-ace5-3e0f-759d14cdef71@virtuozzo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Vasily Averin <vvs@virtuozzo.com>
Date: Sun, 12 Nov 2017 22:26:44 +0300

> OpenVz kernel team have a long history of fighting against namespace-related bugs,
> some of them could be prevented by using simple checks described below.
> 
> One of typical errors is related to live cycle of namespaces:
> usually objects created for some namespace should not live longer than namespace itself.
> 
> Such kind of issues can be invisible on usual systems where additional namespaces
> are not used, because initial namespaces usually lives forever and never destroyed.
> 
> However in systems with namespaces it can lead to memory leaks or to use-after-free.
> Both of them are critical for systems with running containers.
> As you knows it's quite hard to find the reason of such issues,
> especially in rarely-triggered scenarios on production nodes on default kernels
> without specially enabled debug settings. Any additional hints can be useful here.
> 
> This patch set should help to detect some of these issues.
> It is based on assumption that objects initialized in init hook of pernet_operations
> should return to initial state until end of exit hook.
> 
> Many drivers and subsystems already have such checks, however I've found number
> of places where list_empty check would be useful at least as smoke test.
> 
> These checks are useful for long-term stable kernels,
> they allows to detect problems related to incomplete or incorrectly
> backported patches.

All applied to net-next except patch #9 and #10 which need to go via the
NFS maintainer.
