Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f169.google.com ([209.85.192.169]:54395 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967859Ab3DSDfy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Apr 2013 23:35:54 -0400
Subject: Re: NFS over RDMA benchmark
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
From: Spencer <spencer.shepler@gmail.com>
In-Reply-To: <47A54DE8-EBCF-4CE2-80AC-58415B985FD7@ornl.gov>
Date: Thu, 18 Apr 2013 20:35:51 -0700
Cc: Wendy Cheng <s.wendy.cheng@gmail.com>, Yan Burman <yanb@mellanox.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Message-Id: <3006E759-2578-455B-9647-46B000584E7E@gmail.com>
References: <51703280.03e9440a.06a6.3f9f@mx.google.com> <CABgxfbF2HSYPF=rAjrKjoMAKqMOzUOUxJbNFspKaZ4ykMyaCbw@mail.gmail.com> <47A54DE8-EBCF-4CE2-80AC-58415B985FD7@ornl.gov>
To: "Atchley, Scott" <atchleyes@ornl.gov>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Apr 18, 2013, at 6:03 PM, Atchley, Scott wrote:

> On Apr 18, 2013, at 3:15 PM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
> 
>> On Thu, Apr 18, 2013 at 10:50 AM, Spencer Shepler
>> <spencer.shepler@gmail.com> wrote:
>>> 
>>> Note that SPEC SFS does not support RDMA.
>>> 
>> 
>> IIRC, the benchmark comes with source code - wondering anyone has
>> modified it to run on RDMA ?  Or is there any real user to share the
>> experience ?
> 
> I am not familiar with SpecSFS, but if it exercises the filesystem, it does not know which RPC layer that NFS uses, no? Or does it implement its own client and directly access the RPC layer?


Yes, the SPEC SFS benchmark implements  its own NFSv3 client, RPC layer, etc.

Spencer

> 
>> 
>> -- Wendy
>> 
>>> ________________________________
>>> From: Wendy Cheng
>>> Sent: 4/18/2013 9:16 AM
>>> To: Yan Burman
>>> Cc: Atchley, Scott; J. Bruce Fields; Tom Tucker; linux-rdma@vger.kernel.org;
>>> linux-nfs@vger.kernel.org; Or Gerlitz
>>> 
>>> Subject: Re: NFS over RDMA benchmark
>>> 
>>> On Thu, Apr 18, 2013 at 5:47 AM, Yan Burman <yanb@mellanox.com> wrote:
>>>> 
>>>> 
>>>> What do you suggest for benchmarking NFS?
>>>> 
>>> 
>>> I believe SPECsfs has been widely used by NFS (server) vendors to
>>> position their product lines. Its workload was based on a real life
>>> NFS deployment. I think it is more torward office type of workload
>>> (large client/user count with smaller file sizes e.g. software
>>> development with build, compile, etc).
>>> 
>>> BTW, we're experimenting a similar project and would be interested to
>>> know your findings.
>>> 
>>> -- Wendy
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> 
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

