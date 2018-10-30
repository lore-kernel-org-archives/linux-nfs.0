Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CED50C2BC61
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 13:58:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9FF7B20823
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 13:58:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FF7B20823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727880AbeJ3WwZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 30 Oct 2018 18:52:25 -0400
Received: from szxga06-in.huawei.com ([45.249.212.32]:50444 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727576AbeJ3WwY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 Oct 2018 18:52:24 -0400
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.60])
        by Forcepoint Email with ESMTP id 0EB2B25EC4505;
        Tue, 30 Oct 2018 21:58:46 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS403-HUB.china.huawei.com
 (10.3.19.203) with Microsoft SMTP Server id 14.3.408.0; Tue, 30 Oct 2018
 21:58:43 +0800
Message-ID: <5BD86392.7070200@huawei.com>
Date:   Tue, 30 Oct 2018 21:58:42 +0800
From:   zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To:     Benjamin Coddington <bcodding@redhat.com>,
        <herbert@gondor.apana.org.au>, <trond.myklebust@hammerspace.com>,
        <bfields@redhat.com>
CC:     <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [Qestion] Lots of memory leaks when mounting and unmounting nfs
 client to server continuously.
References: <5BD85266.6000301@huawei.com> <1DEE371C-69EB-4D92-8F78-535AA5203007@redhat.com>
In-Reply-To: <1DEE371C-69EB-4D92-8F78-535AA5203007@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2018/10/30 21:06, Benjamin Coddington wrote:
> Hi zhong jiang,
>
> Try asking in linux-nfs.. but I'll also note that 3.10-stable may be missing a number of fixes to leaks in the NFS GSS code.
>
> I can see a more than a few fixes to memory leaks with:
> git log --grep=leak --oneline net/sunrpc/auth_gss/
>
Thanks for your reply.  I has tested some of them in the upsteam as you have said.  but It fails to solve the issue completely.
hence, I turn to the relevant experts whether they have happened to the issue or  can give some suggestion or not.

Thanks,
zhong jiang
> Ben
>
> On 30 Oct 2018, at 8:45, zhong jiang wrote:
>
>> Hi,   Herbert
>>
>> Recently,  I  hit  a memory leak issue when  mounting and unmounting nfs with  the way of  krb5.
>> The issue happens to the linux-3.10-stable.
>>
>> I find that slab-1024 and slab-512 will take up most of the memory.  And it can not be freed.
>> Meanwhile, it result in rpcsec_gss_krb5 can be unregistered as well.
>>
>> nfs-sve1:/home # cat /proc/modules | grep krb5
>> rpcsec_gss_krb5 31477 239730 - Live 0xffffffffa0334000
>> auth_rpcgss 59314 3 rpcsec_gss_krb5,nfsd, Live 0xffffffffa0123000
>> sunrpc 300546 25 rpcsec_gss_krb5,nfsd,auth_rpcgss,nfs_acl,lockd, Live 0xffffffffa013b000
>>
>> I open the slab-1024 trace by enabling /sys/kernel/slab/:t-0001024/trace and get the following
>>
>> [123420.989831] Call Trace:
>> [123420.989834]  [<ffffffff81642d2a>] dump_stack+0x19/0x1b
>> [123420.989837]  [<ffffffff8163f25e>] alloc_debug_processing+0xc5/0x118
>> [123420.989839]  [<ffffffff8163fd4d>] __slab_alloc+0x400/0x48f
>> [123420.989841]  [<ffffffff812b1795>] ? __crypto_alloc_tfm+0x45/0x170
>> [123420.989845]  [<ffffffff812b2307>] ? setkey+0x57/0x110
>> [123420.989847]  [<ffffffff8118b5fd>] ? kzfree+0x2d/0x30
>> [123420.989850]  [<ffffffff811c6e88>] __kmalloc+0x1c8/0x230
>> [123420.989852]  [<ffffffff812b1795>] __crypto_alloc_tfm+0x45/0x170
>> [123420.989854]  [<ffffffff812b2e45>] crypto_spawn_tfm+0x45/0x80
>> [123420.989857]  [<ffffffff811c6eb3>] ? __kmalloc+0x1f3/0x230
>> [123420.989859]  [<ffffffff812c15c7>] crypto_cbc_init_tfm+0x27/0x40
>> [123420.989864]  [<ffffffff812b1851>] __crypto_alloc_tfm+0x101/0x170
>> [123420.989866]  [<ffffffff812b1ffc>] crypto_alloc_base+0x4c/0xb0
>> [123420.989869]  [<ffffffffa033411b>] context_v2_alloc_cipher.isra.2+0x2b/0xc0 [rpcsec_gss_krb5]
>> [123420.989871]  [<ffffffffa0334da8>] gss_import_sec_context_kerberos+0xbf8/0xf00 [rpcsec_gss_krb5]
>> [123420.989875]  [<ffffffffa0126d5d>] gss_import_sec_context+0x7d/0xb0 [auth_rpcgss]
>> [123420.989878]  [<ffffffffa012b35e>] gss_proxy_save_rsc+0x137/0x1b0 [auth_rpcgss]
>> [123420.989884]  [<ffffffffa012b51e>] svcauth_gss_proxy_init+0x147/0x1e4 [auth_rpcgss]
>> [123420.989886]  [<ffffffff810c2ad6>] ? dequeue_entity+0x106/0x520
>> [123420.989890]  [<ffffffffa0128e2a>] svcauth_gss_accept+0x3da/0xb70 [auth_rpcgss]
>> [123420.989892]  [<ffffffff810b6c25>] ? check_preempt_curr+0x85/0xa0
>> [123420.989894]  [<ffffffff810b6c59>] ? ttwu_do_wakeup+0x19/0xd0
>> [123420.989897]  [<ffffffff810b6ded>] ? ttwu_do_activate.constprop.86+0x5d/0x70
>> [123420.989900]  [<ffffffff810b9422>] ? try_to_wake_up+0x162/0x330
>> [123420.989908]  [<ffffffffa014f490>] svc_authenticate+0xc0/0xe0 [sunrpc]
>> [123420.989914]  [<ffffffffa014c04a>] svc_process_common+0x21a/0x6f0 [sunrpc]
>> [123420.989921]  [<ffffffffa014c623>] svc_process+0x103/0x170 [sunrpc]
>> [123420.989928]  [<ffffffffa01baaaf>] nfsd+0xdf/0x150 [nfsd]
>> [123420.989932]  [<ffffffffa01ba9d0>] ? nfsd_destroy+0x80/0x80 [nfsd]
>> [123420.989934]  [<ffffffff810a648f>] kthread+0xcf/0xe0
>> [123420.989936]  [<ffffffff810a63c0>] ? kthread_create_on_node+0x140/0x140
>> [123420.989939]  [<ffffffff81653318>] ret_from_fork+0x58/0x90
>> [123420.989943]  [<ffffffff810a63c0>] ? kthread_create_on_node+0x140/0x140
>>
>> I am unfamiliar with crypto.   I will be appreciated  if you could give me some suggestion.
>>
>> Thanks,
>> zhong jiang
>
> .
>


