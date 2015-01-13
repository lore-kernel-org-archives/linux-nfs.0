Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f170.google.com ([74.125.82.170]:43162 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbbAMKFp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 05:05:45 -0500
Received: by mail-we0-f170.google.com with SMTP id w61so1910933wes.1
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jan 2015 02:05:33 -0800 (PST)
Message-ID: <54B4EDE9.2050300@dev.mellanox.co.il>
Date: Tue, 13 Jan 2015 12:05:29 +0200
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Steve Wise <swise@opengridcomputing.com>,
        "'Chuck Lever'" <chuck.lever@oracle.com>
CC: linux-rdma@vger.kernel.org,
        "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 06/10] svcrdma: Plant reader function in struct svcxprt_rdma
References: <20150109191910.4901.29548.stgit@klimt.1015granger.net> <20150109192245.4901.89614.stgit@klimt.1015granger.net> <54B2B69E.2010503@dev.mellanox.co.il> <6A78707C-A371-412F-8E9A-24937318A01D@oracle.com> <002201d02e82$08d16070$1a742150$@opengridcomputing.com> <A84D07C5-1879-49ED-A181-6FFC76B4864B@oracle.com> <006b01d02e84$907f5890$b17e09b0$@opengridcomputing.com> <54B3FA35.4030003@opengridcomputing.com>
In-Reply-To: <54B3FA35.4030003@opengridcomputing.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/12/2015 6:45 PM, Steve Wise wrote:
> On 1/12/2015 10:26 AM, Steve Wise wrote:
>>
>>> -----Original Message-----
>>> From: Chuck Lever [mailto:chuck.lever@oracle.com]
>>> Sent: Monday, January 12, 2015 10:20 AM
>>> To: Steve Wise
>>> Cc: Sagi Grimberg; linux-rdma@vger.kernel.org; Linux NFS Mailing List
>>> Subject: Re: [PATCH v1 06/10] svcrdma: Plant reader function in
>>> struct svcxprt_rdma
>>>
>>>
>>> On Jan 12, 2015, at 11:08 AM, Steve Wise
>>> <swise@opengridcomputing.com> wrote:
>>>
>>>>
>>>>> -----Original Message-----
>>>>> From: Chuck Lever [mailto:chuck.lever@oracle.com]
>>>>> Sent: Sunday, January 11, 2015 6:41 PM
>>>>> To: Sagi Grimberg; Steve Wise
>>>>> Cc: linux-rdma@vger.kernel.org; Linux NFS Mailing List
>>>>> Subject: Re: [PATCH v1 06/10] svcrdma: Plant reader function in
>>>>> struct svcxprt_rdma
>>>>>
>>>>>
>>>>> On Jan 11, 2015, at 12:45 PM, Sagi Grimberg
>>>>> <sagig@dev.mellanox.co.il> wrote:
>>>>>
>>>>>> On 1/9/2015 9:22 PM, Chuck Lever wrote:
>>>>>>> The RDMA reader function doesn't change once an svcxprt is
>>>>>>> instantiated. Instead of checking sc_devcap during every incoming
>>>>>>> RPC, set the reader function once when the connection is accepted.
>>>>>> General question(s),
>>>>>>
>>>>>> Any specific reason why to use FRMR in the server side? And why only
>>>>>> for reads and not writes? Sorry if these are dumb questions...
>>>>> Steve Wise presented patches a few months back to add FRMR, he
>>>>> would have to answer this. Steve has a selection of iWARP adapters
>>>>> and maybe could provide some idea of performance impact. I have
>>>>> only CX-[23] here.
>>>>>
>>>> The rdma rpc server has always tried to use FRMR for rdma reads as
>>>> far as I recall.  The patch I submitted refactored the design
>> in
>>>> order to make it more efficient and to fix some bugs.   Unlike IB,
>>>> the iWARP  protocol only allows 1 target/sink SGE in an rdma
>> read
>>>> request message, so an FRMR is used to create that single
>>>> target/sink SGE allowing 1 read to be submitted instead of many.
>>> How does this work when the client uses PHYSICAL memory registration?
>> Each page would require a separate rdma read WR.  That is why we use
>> FRMRs. :)
>
> Correction, each physical scatter gather entry would require a separate
> read WR.  There may be contiguous chunks of physical mem that can be
> described with one RDMA SGE...


OK, thanks for clarifying that for me.

 From the code, I think that FRMR is used also if the buffer can
fit in a single SGE. Wouldn't it be better to skip the Fastreg WR in
this case?

Sagi.
