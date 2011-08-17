Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51102 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752267Ab1HQJpD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Aug 2011 05:45:03 -0400
Received: by vws1 with SMTP id 1so503613vws.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Aug 2011 02:45:02 -0700 (PDT)
In-Reply-To: <4E4AD0CE.3000506@panasas.com>
References: <1312685635-1593-1-git-send-email-bergwolf@gmail.com>
 <4E42C564.7070504@panasas.com> <CA+a=Yy4WXD64A3anw7f-wSWcs4A4-6W18QQs=YyYC0285_W_qg@mail.gmail.com>
 <4E442512.7080904@panasas.com> <CA+a=Yy4g09b_AEf2px1Cjfmr_ud3PFuAbEwdez1cbsiYJ0mmgA@mail.gmail.com>
 <4E446F63.5080707@panasas.com> <F19688880B763E40B28B2B462677FBF805BF0EB0A3@MX09A.corp.emc.com>
 <4E4AD0CE.3000506@panasas.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Wed, 17 Aug 2011 17:44:42 +0800
Message-ID: <CA+a=Yy5jApbUqy+ESZxczZ3N+ixg8ixK9iAe0DWqSZavap18xQ@mail.gmail.com>
Subject: Re: [PATCH 1/5] pNFS: recoalesce when ld write pagelist fails
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: tao.peng@emc.com, Trond.Myklebust@netapp.com, benny@tonian.com,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Boaz,

On Wed, Aug 17, 2011 at 4:19 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 08/16/2011 12:20 AM, tao.peng@emc.com wrote:
>>
>> I tried to rewrite the write patch to handle failures inside
>> mds_ops->rpc_release. However, I get a problem w.r.t. "redirty and
>> rely on next flush". If the failed write is the *last flush*, we end
>> up with relying no one and the dirty pages are simply dropped. Do you
>> have any suggestions how to handle it?
>>
>> Thanks, Tao
>>
>
> Tao Hi.
>
> OK, I see what you mean. That would be a problem
>
> I had a totally different idea You know how today we just do:
>        nfs_initiate_write()
>
> Which is bad because it can actually dead lock because
> we are taking up the only thread that needs to service
> that call. Well I thought, with you thread-for-pnfs patch,
> can it not now work? I think it is worth a try?
The problem w/ directly calling nfs_initiate_write() is that we may
have pagelist length larger than server's rsize/wsize. So if client
sends all the pages in single READ/WRITE rpc, MDS will reject the
READ/WRITE operation. Therefore we need to recoalesce them before
re-sending to MDS.

>
> See if you can advance your thread-for-blocks-objects
> patch to current code and inject some errors. I think
> it will work this time. What do you think?
The thread-for-block-objects patch is to solve the default workqueue
deadlock problem. But it can't solve the too large IO size for MDS
problem. So I think we need all of the three patches to handle LD IO
failures.

Thanks,
Tao
