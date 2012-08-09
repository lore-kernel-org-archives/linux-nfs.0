Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50443 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964Ab2HICYj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 22:24:39 -0400
Received: by pbbrr13 with SMTP id rr13so83450pbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 19:24:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344451818.8925.27.camel@lade.trondhjem.org>
References: <1344391392-1948-1-git-send-email-bergwolf@gmail.com>
 <1344391392-1948-3-git-send-email-bergwolf@gmail.com> <1344451818.8925.27.camel@lade.trondhjem.org>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 9 Aug 2012 10:24:19 +0800
Message-ID: <CA+a=Yy5FkO93xjA2VFa7eGP=CEb3QuM+6frL5cTLnwhQHdr5Ag@mail.gmail.com>
Subject: Re: [PATCH RFC 2/3] NFS41: send real write size in layoutget
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "bharrosh@panasas.com" <bharrosh@panasas.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 9, 2012 at 2:50 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2012-08-08 at 10:03 +0800, Peng Tao wrote:
>> From: Peng Tao <tao.peng@emc.com>
>>
>> For bufferred write, scan dirty pages to find out longest continuous
>> dirty pages. In this case, also allow layout driver to specify a
>> maximum layoutget size which is useful to avoid busy scanning dirty pages
>> for block layout client.
>
> This is _really_ ugly, and is a source of potential deadlocks if
> multiple threads are scanning+locking pages at the same time.
Multiple threads won't be able to scan into the same region as borders
are protected by page writeback bit.

>
> Why not simplify this by dropping the complicated tests for whether or
> not the pages are dirty? That gets rid of the deadlock-prone lock_page()
> calls, and would enable you to just use radix_tree_next_hole().
>
OK. I will cook a patch to drop the complicated page dirty/writeback
checks and just use radix_tree_next_hole.

-- 
Thanks,
Tao
