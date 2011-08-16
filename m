Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:55122 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719Ab1HPUU0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 16:20:26 -0400
Message-ID: <4E4AD0CE.3000506@panasas.com>
Date: Tue, 16 Aug 2011 13:19:26 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: <tao.peng@emc.com>
CC: <bergwolf@gmail.com>, <Trond.Myklebust@netapp.com>, <benny@tonian.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/5] pNFS: recoalesce when ld write pagelist fails
References: <1312685635-1593-1-git-send-email-bergwolf@gmail.com> <4E42C564.7070504@panasas.com> <CA+a=Yy4WXD64A3anw7f-wSWcs4A4-6W18QQs=YyYC0285_W_qg@mail.gmail.com> <4E442512.7080904@panasas.com> <CA+a=Yy4g09b_AEf2px1Cjfmr_ud3PFuAbEwdez1cbsiYJ0mmgA@mail.gmail.com> <4E446F63.5080707@panasas.com> <F19688880B763E40B28B2B462677FBF805BF0EB0A3@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805BF0EB0A3@MX09A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/16/2011 12:20 AM, tao.peng@emc.com wrote:
> 
> I tried to rewrite the write patch to handle failures inside
> mds_ops->rpc_release. However, I get a problem w.r.t. "redirty and
> rely on next flush". If the failed write is the *last flush*, we end
> up with relying no one and the dirty pages are simply dropped. Do you
> have any suggestions how to handle it?
> 
> Thanks, Tao
> 

Tao Hi.

OK, I see what you mean. That would be a problem

I had a totally different idea You know how today we just do:
	nfs_initiate_write()

Which is bad because it can actually dead lock because
we are taking up the only thread that needs to service
that call. Well I thought, with you thread-for-pnfs patch,
can it not now work? I think it is worth a try?

See if you can advance your thread-for-blocks-objects
patch to current code and inject some errors. I think
it will work this time. What do you think?

Thanks
Boaz
