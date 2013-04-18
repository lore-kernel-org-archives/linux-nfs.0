Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:50680 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754236Ab3DRTPm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Apr 2013 15:15:42 -0400
MIME-Version: 1.0
In-Reply-To: <51703280.03e9440a.06a6.3f9f@mx.google.com>
References: <51703280.03e9440a.06a6.3f9f@mx.google.com>
Date: Thu, 18 Apr 2013 12:15:41 -0700
Message-ID: <CABgxfbF2HSYPF=rAjrKjoMAKqMOzUOUxJbNFspKaZ4ykMyaCbw@mail.gmail.com>
Subject: Re: NFS over RDMA benchmark
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: Spencer Shepler <spencer.shepler@gmail.com>
Cc: Yan Burman <yanb@mellanox.com>, "Atchley, Scott" <atchleyes@ornl.gov>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 18, 2013 at 10:50 AM, Spencer Shepler
<spencer.shepler@gmail.com> wrote:
>
> Note that SPEC SFS does not support RDMA.
>

IIRC, the benchmark comes with source code - wondering anyone has
modified it to run on RDMA ?  Or is there any real user to share the
experience ?

-- Wendy

> ________________________________
> From: Wendy Cheng
> Sent: 4/18/2013 9:16 AM
> To: Yan Burman
> Cc: Atchley, Scott; J. Bruce Fields; Tom Tucker; linux-rdma@vger.kernel.org;
> linux-nfs@vger.kernel.org; Or Gerlitz
>
> Subject: Re: NFS over RDMA benchmark
>
> On Thu, Apr 18, 2013 at 5:47 AM, Yan Burman <yanb@mellanox.com> wrote:
>>
>>
>> What do you suggest for benchmarking NFS?
>>
>
> I believe SPECsfs has been widely used by NFS (server) vendors to
> position their product lines. Its workload was based on a real life
> NFS deployment. I think it is more torward office type of workload
> (large client/user count with smaller file sizes e.g. software
> development with build, compile, etc).
>
> BTW, we're experimenting a similar project and would be interested to
> know your findings.
>
> -- Wendy
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
