Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F329C04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 11:54:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1D1D8206B7
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 11:54:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D1D8206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726199AbeLCLyq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 06:54:46 -0500
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:35536 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725883AbeLCLyp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Dec 2018 06:54:45 -0500
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
        by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AAFF9165C;
        Mon,  3 Dec 2018 03:54:01 -0800 (PST)
Received: from [10.1.197.50] (e120937-lin.cambridge.arm.com [10.1.197.50])
        by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 10ED63F59C;
        Mon,  3 Dec 2018 03:54:00 -0800 (PST)
Subject: Re: [PATCH v3 40/44] SUNRPC: Simplify TCP receive code by switching
 to using iterators
To:     Catalin Marinas <catalin.marinas@arm.com>,
        Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <20180917130335.112832-38-trond.myklebust@hammerspace.com>
 <20180917130335.112832-39-trond.myklebust@hammerspace.com>
 <20180917130335.112832-40-trond.myklebust@hammerspace.com>
 <20180917130335.112832-41-trond.myklebust@hammerspace.com>
 <20181109111930.idve77thgcnsg5u3@localhost>
 <e85fe63f-b142-5075-edb6-da6c9e2609fd@arm.com>
 <356631f8d49b5d0698d769ab9c916c84fadd3be6.camel@hammerspace.com>
 <a23d0c18-1030-82f3-a046-41497dc7725b@arm.com>
 <92a750b72255c6a91fd5606668f26b2d492ec43f.camel@hammerspace.com>
 <7d58a5dc7f62117245c824fc63bce62ba99e5b44.camel@hammerspace.com>
 <20181203114555.GF49865@arrakis.emea.arm.com>
From:   Cristian Marussi <cristian.marussi@arm.com>
Message-ID: <d5e4eac9-d7ad-2390-116b-e1f0fc814c7e@arm.com>
Date:   Mon, 3 Dec 2018 11:53:59 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <20181203114555.GF49865@arrakis.emea.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi

On 03/12/2018 11:45, Catalin Marinas wrote:
> Hi Trond,
> 
> On Sun, Dec 02, 2018 at 04:44:49PM +0000, Trond Myklebust wrote:
>> On Fri, 2018-11-30 at 14:31 -0500, Trond Myklebust wrote:
>>> On Fri, 2018-11-30 at 16:19 +0000, Cristian Marussi wrote:
>>>> On 29/11/2018 19:56, Trond Myklebust wrote:
>>>>> On Thu, 2018-11-29 at 19:28 +0000, Cristian Marussi wrote:
>>>>> Question to you both: when this happens, does /proc/*/stack show
>>>>> any of the processes hanging in the socket or sunrpc code? If
>>>>> so, can you please send me examples of those stack traces (i.e.
>>>>> the contents of /proc/<pid>/stack for the processes that are
>>>>> hanging)
>>>>
>>>> (using a reverse shell since starting ssh causes a lot of pain and
>>>> traffic)
>>>>
>>>> Looking at NFS traffic holes(30-40 secs) to detect Client side
>>>> various HANGS
>>
>> Chuck and I have identified a few issues that might have an effect on
>> the hangs you report. Could you please give the linux-next branch in my
>> repository on git.linux-nfs.org (
>> https://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=shortlog;h=refs/heads/linux-next
>> ) a try?
>>
>> git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
> 
> I tried, unfortunately there's no difference for me (I merged the above
> branch on top of 4.20-rc5).
> 

same for me. Issue still there.

Beside I saw some differences in the dbench result which I used for testing.

From the dbench (comparing with previous mail) it seems that
Unlink and Qpathinfo MaxLat has normalized.

 Operation      Count    AvgLat    MaxLat
 ----------------------------------------
 NTCreateX      90820    13.613 13855.620
 Close          66565    18.075 13853.289
 Rename          3845    23.668   326.642
 Unlink         18450     4.581   186.062
 Qpathinfo      82068     2.677   280.203
 Qfileinfo      14235    10.357   176.373
 Qfsinfo        15156     2.822   242.794
 Sfileinfo       7400    17.018   240.546
 Find           31812     5.988   277.332
 WriteX         44735     0.155    14.685
 ReadX         141872     0.741 13817.870
 LockX            288    10.558    96.179
 UnlockX          288     3.307    57.939
 Flush           6389    20.427   187.429


> Is there anything else blocked in the RPC layer? The above are all
> standard tasks waiting for the rpciod/xprtiod workqueues to complete
> the calls to the server.
cat  /proc/692/stack
[<0>] __switch_to+0x6c/0x90
[<0>] rescuer_thread+0x2e8/0x360
[<0>] kthread+0x134/0x138
[<0>] ret_from_fork+0x10/0x1c
[<0>] 0xffffffffffffffff

I was now trying to collect more evidence ftracing during the quiet-stuck-period
till the restart happens.

Thanks

Cristian
