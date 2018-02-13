Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mgwkm03.jp.fujitsu.com ([202.219.69.170]:37095 "EHLO
        mgwkm03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933323AbeBMDby (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Feb 2018 22:31:54 -0500
Received: from g01jpfmpwyt02.exch.g01.fujitsu.local (g01jpfmpwyt02.exch.g01.fujitsu.local [10.128.193.56])
        by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id A05B2AC00FB
        for <linux-nfs@vger.kernel.org>; Tue, 13 Feb 2018 12:20:34 +0900 (JST)
Subject: Re: Questions about pynfs:testLargeData-WRT5
To: <bfields@redhat.com>
CC: <trondmy@primarydata.com>, <luxy.fnst@cn.fujitsu.com>,
        <linux-nfs@vger.kernel.org>
References: <20180209183112.GC30030@parsley.fieldses.org>
 <6c3159af-17c5-5556-d416-574968bb5e14@cn.fujitsu.com>
From: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Message-ID: <738139ab-6a55-4c93-008d-56a2332774c9@jp.fujitsu.com>
Date: Tue, 13 Feb 2018 12:19:58 +0900
MIME-Version: 1.0
In-Reply-To: <6c3159af-17c5-5556-d416-574968bb5e14@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 9 Feb 2018 13:31:12 -0500, J. Bruce Fields wrote:

>> For NFSv4, you would have the option of returning NFS4ERR_RESOURCE or
>> possibly NFS4ERR_INVAL (personally, I'd prefer the latter, since
>> NFS4ERR_RESOURCE is too wooly).
>>
>> For NFSv4.1 or above, you probably have a choice of NFS4ERR_REQ_TOO_BIG
>> (if the size is greater than ca_maxrequestsize) or NFS4ERR_INVAL.
> 
> I think this sort of problem is typically found early in the rpc code
> (probably the check against sv_max_mesg in
> net/sunrpc/svcsock.c:svc_tcp_recv_record()).  It drops the connection.
> I'm not sure why.

It looks implemented long time ago.

[PATCH] PATCH 11/16: NFSD: TCP: close bad connections
https://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git/commit/?id=84e9f22a623a

Regards,
Ikarashi

