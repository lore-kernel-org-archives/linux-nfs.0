Return-Path: <SRS0=f8xw=RT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8DC0C43381
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Mar 2019 14:11:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A25CD218FE
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Mar 2019 14:11:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726932AbfCPOLU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 16 Mar 2019 10:11:20 -0400
Received: from out30-42.freemail.mail.aliyun.com ([115.124.30.42]:57492 "EHLO
        out30-42.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726064AbfCPOLU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2019 10:11:20 -0400
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04396;MF=jiufei.xue@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TMs5Fa2_1552745472;
Received: from ali-186590e05fa3.local(mailfrom:jiufei.xue@linux.alibaba.com fp:SMTPD_---0TMs5Fa2_1552745472)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 16 Mar 2019 22:11:12 +0800
Subject: Re: [bug report] task hang while testing xfstests generic/323
To:     Olga Kornievskaia <aglo@umich.edu>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "joseph.qi@linux.alibaba.com" <joseph.qi@linux.alibaba.com>
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
 <3b6597b0-41b4-255a-5ebb-cf34ad95315c@linux.alibaba.com>
 <57796366-0f08-2cfb-6f85-27d5485c07af@linux.alibaba.com>
 <ce839197cb70f3bc75413ed2e54f8baafafc01dd.camel@hammerspace.com>
 <365504c3-d785-7e4b-1dd2-c75f30c85c65@linux.alibaba.com>
 <740c1ad6c5b2afad196af34f48dda7097b5102b7.camel@hammerspace.com>
 <1417d6c8-3602-d895-a036-44031a7c1e98@linux.alibaba.com>
 <b729878b38f32053890a592a91f0645f15caa96f.camel@hammerspace.com>
 <46f5c870-f4fd-b29a-f5eb-eab39c4c1e89@linux.alibaba.com>
 <20190306160934.GB3066@fieldses.org>
 <CAN-5tyEPSDKao=83sW+voU9SPbcszZyR+XfZzcsD2-ozVa22Xg@mail.gmail.com>
 <ace3659edd3efb70d3d978e108ecf1fc22ee3966.camel@hammerspace.com>
 <CAN-5tyH8hFmEsAKDMDL4uey0MXh9+kY43=LEpgjj711eVUubAA@mail.gmail.com>
 <CAN-5tyEAfV_WA3Vyf8LQ-EN4yn99p1sk7fuu7n43t8H8+un2Yw@mail.gmail.com>
 <37b3d7db-0bdf-014a-adff-ea401ea92fc7@linux.alibaba.com>
 <CAN-5tyFHD5ZCqZ59GJzf_CAaJQZ7OXEhaxtYaSDAdXMLSA-xDA@mail.gmail.com>
From:   Jiufei Xue <jiufei.xue@linux.alibaba.com>
Message-ID: <63f00c10-28f5-b1e6-dcf9-f85f5edbfabf@linux.alibaba.com>
Date:   Sat, 16 Mar 2019 22:11:12 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFHD5ZCqZ59GJzf_CAaJQZ7OXEhaxtYaSDAdXMLSA-xDA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


Hi Olga,
On 2019/3/16 上午4:33, Olga Kornievskaia wrote:
> On Fri, Mar 15, 2019 at 2:31 AM Jiufei Xue <jiufei.xue@linux.alibaba.com> wrote:
>>
>> Hi Olga,
>>
>> On 2019/3/11 下午11:13, Olga Kornievskaia wrote:
>>> Let me double check that. I have reproduced the "infinite loop" or
>>> CLOSE on the upstream (I'm looking thru the trace points from friday).
>>
>> Do you try to capture the packages when reproduced this issue on the
>> upstream. I still lost kernel packages after some adjustment according
>> to bfield's suggestion :(
> 
> Hi Jiufei,
> 
> Yes I have network trace captures but they are too big to post to the
> mailing list. I have reproduced the problem on the latest upstream
> origin/testing branch commit "SUNRPC: Take the transport send lock
> before binding+connecting". As you have noted before infinite loops is
> due to client "losing" an update to the seqid.
> 
> one packet would send out an (recovery) OPEN with slot=0 seqid=Y.
> tracepoint (nfs4_open_file) would log that status=ERESTARTSYS. The rpc
> task would be sent and the rpc task would receive a reply but there is
> nobody there to receive it... This open that got a reply has an
> updated stateid seqid which client never updates. When CLOSE is sent,
> it's sent with the "old" stateid and puts the client in an infinite
> loop. Btw, CLOSE is sent on the interrupted slot which should get
> FALSE_RETRY which causes the client to terminate the session. But it
> would still keep sending the CLOSE with the old stateid.
> 
> Some things I've noticed is that TEST_STATE op (as a part of the
> nfs41_test_and _free_expired_stateid()) for some reason always has a
> signal set even before issuing and RPC task so the task never
> completes (ever).
> 
> I always thought that OPEN's can't be interrupted but I guess they are
> since they call rpc_wait_for_completion_task() and that's a killable
> event. But I don't know how to find out what's sending a signal to the
> process. I'm rather stuck here trying to figure out where to go from
> there. So I'm still trying to figure out what's causing the signal or
> also how to recover from it that the client doesn't lose that seqid.
> 
>>
Thank you for you quick relpy.

I have also noticed the ERESTARTSYS status for OPEN op, but I think it
is returned by the open process which is woken in nfs4_run_open_task().
I found that the decode routine nfs4_xdr_dec_open returned -121, which
I thought is the root cause of this problem. Could you please post the
content of the last OPEN message?

Thanks,
Jiufei.



>> Thanks,
>> Jiufei
> 
