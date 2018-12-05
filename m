Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2A51C04EB9
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 10:13:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7350C20645
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 10:13:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7350C20645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728015AbeLEKNQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 05:13:16 -0500
Received: from foss.arm.com ([217.140.101.70]:51194 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727838AbeLEKNQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Dec 2018 05:13:16 -0500
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
        by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A501780D;
        Wed,  5 Dec 2018 02:13:15 -0800 (PST)
Received: from [10.1.197.50] (e120937-lin.cambridge.arm.com [10.1.197.50])
        by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DA7C03F575;
        Wed,  5 Dec 2018 02:13:14 -0800 (PST)
Subject: Re: [PATCH] SUNRPC: Fix RPC receive hangs
From:   Cristian Marussi <cristian.marussi@arm.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <20181204192439.39259-1-trond.myklebust@hammerspace.com>
 <70cd2493391a24e5f92a36622f588cdc463dfe4c.camel@hammerspace.com>
 <871ff105-7dce-04ba-4c1f-ac724d348f9b@arm.com>
Message-ID: <d6121368-8aa4-4fc7-71c1-7fedfb7eff95@arm.com>
Date:   Wed, 5 Dec 2018 10:13:13 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <871ff105-7dce-04ba-4c1f-ac724d348f9b@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi

On 05/12/2018 09:14, Cristian Marussi wrote:
> Hi
> 
> On 04/12/2018 19:31, Trond Myklebust wrote:
>> On Tue, 2018-12-04 at 14:24 -0500, Trond Myklebust wrote:
>>> The RPC code is occasionally hanging when the receive code fails to
>>> empty the socket buffer due to a partial read of the data. When we
>>> convert that to an EAGAIN, it appears we occasionally leave data in
>>> the
>>> socket. The fix is to just keep reading until the socket returns
>>> EAGAIN/EWOULDBLOCK.
>>>
>>> Reported-by: Catalin Marinas <catalin.marinas@arm.com>
>>> Reported-by: Cristian Marussi <cristian.marussi@arm.com>
>>> Reported-by: Chuck Lever <chuck.lever@oracle.com>
>>> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
>>> ---
>>
[snip]

Applying the patch on top of your linux-nfs next:

8739cbe10efb (HEAD -> linux-next) SUNRPC: Fix RPC receive hangs
0a9a4304f361 (origin/linux-next) SUNRPC: Fix a potential race in xprt_connect()
71700bb96047 SUNRPC: Fix a memory leak in call_encode()
8dae5398ab1a SUNRPC: Fix leak of krb5p encode pages

and testing on arm64 64k pages without rsize workaround.

SOLVES for me. No hang or slowdown launching LKP/LTP.

dbench results seems fine again.(as with rsize workaround)

 Operation      Count    AvgLat    MaxLat
 ----------------------------------------
 NTCreateX     106349    11.479   400.908
 Close          78111    16.508   414.883
 Rename          4500    19.722   246.805
 Unlink         21475     3.625   196.797
 Qpathinfo      96460     1.786   278.724
 Qfileinfo      16829    10.044   233.708
 Qfsinfo        17615     2.119   319.131
 Sfileinfo       8700    16.819   145.051
 Find           37251     3.389   264.889
 WriteX         52509     0.048     6.663
 ReadX         166675     0.655   189.954
 LockX            348    11.840   227.481
 UnlockX          348     2.563    72.949
 Flush           7470    20.296   274.855

Throughput 5.50353 MB/sec  6 clients  6 procs  max_latency=414.902 ms

Thanks

Cristian
