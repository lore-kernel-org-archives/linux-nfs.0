Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47591 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753582AbcKIWmh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 17:42:37 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: wireshark's RPC-over-RDMA dissector
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAG53R5WQRCD32iEefGoaRqggAT1hyv_FSpCAN3c3Z7sVspzx1Q@mail.gmail.com>
Date: Wed, 9 Nov 2016 17:42:32 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        List Linux RDMA Mailing <linux-rdma@vger.kernel.org>
Message-Id: <5330C0B9-D42A-4D13-8667-B5BB472E64A3@oracle.com>
References: <2975B49B-2696-4E2A-B9D0-2D6CB607EC59@oracle.com> <CAG53R5WQRCD32iEefGoaRqggAT1hyv_FSpCAN3c3Z7sVspzx1Q@mail.gmail.com>
To: Parav Pandit <pandit.parav@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 9, 2016, at 11:41 AM, Parav Pandit <pandit.parav@gmail.com> wrote:
> 
> Hi Chuck,
> 
> Just FYI.
> I have committed few fixes in wireshark trunk for RoCE and IB
> dissectors which will in general benefit other ULPs as well (primary
> for statefulness of ULPs) last month.
> 
> I have few patches pending in my sandbox in area of RoCE and for other
> ULP that I will push in coming days, likely next week.
> I am currently actively testing them and have made steady progress so far.
> 
> I will try to find sometime to review them next week.
> 
> Regards,
> Parav Pandit

Stateful dissection might be helpful for associating RPC-over-RDMA
headers with RDMA Reads and Writes on the same QP. Thanks Parav,
I'll watch for your work.


> On Wed, Nov 9, 2016 at 9:35 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> Hi-
>> 
>> Thanks to Yan Berman, for a couple of years now we've had a basic
>> RPC-over-RDMA dissector in wireshark that can be used with ibdump
>> captures. There have been some bugs noted, but no-one has had the
>> cycles to dig in and address.
>> 
>> Recently Tom Haynes helped me set up my own wireshark build so I
>> could help address some of the known issues.
>> 
>> http://git.linux-nfs.org/?p=cel/wireshark.git;a=shortlog;h=refs/heads/rpc-rdma-fixes
>> 
>> Posting here for review before I take the next steps to push these
>> to the wireshark community. Constructive critique and other
>> suggestions are welcome.
>> 
>> The fixes so far focus on dissecting transport headers correctly.
>> There continue to be significant open issues with the dissector:
>>        • There does not appear to be any support for dissecting
>>          RPC-over-RDMA on iWARP or RoCE
>>        • The NFS dissector does not handle portions of the XDR
>>          stream that were transmitted via RDMA Read/Write
>>        • RPC messages conveyed via RDMA_NOMSG are not recognized
>>          or dissected
>>        • There is no association between RDMA Reads and Writes
>>          and the RPC-over-RDMA message they go with
>>        • A CREQ / CREP pair are needed to identify which QP
>>          numbers are used for RPC-over-RDMA traffic
>>        • With TCP, the dissector fully outdents the RPC and NFS
>>          dissection results; but with RDMA, the dissector places
>>          the results in the tree under the Infiniband header
>>        • Not enough error detection in the dissector
>> 
>> --
>> Chuck Lever


--
Chuck Lever



