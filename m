Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:39530 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753987Ab1HLALC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 20:11:02 -0400
Message-ID: <4E446F63.5080707@panasas.com>
Date: Thu, 11 Aug 2011 17:10:11 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Peng Tao <bergwolf@gmail.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <benny@tonian.com>, <linux-nfs@vger.kernel.org>,
        Peng Tao <peng_tao@emc.com>
Subject: Re: [PATCH 1/5] pNFS: recoalesce when ld write pagelist fails
References: <1312685635-1593-1-git-send-email-bergwolf@gmail.com> <4E42C564.7070504@panasas.com> <CA+a=Yy4WXD64A3anw7f-wSWcs4A4-6W18QQs=YyYC0285_W_qg@mail.gmail.com> <4E442512.7080904@panasas.com> <CA+a=Yy4g09b_AEf2px1Cjfmr_ud3PFuAbEwdez1cbsiYJ0mmgA@mail.gmail.com>
In-Reply-To: <CA+a=Yy4g09b_AEf2px1Cjfmr_ud3PFuAbEwdez1cbsiYJ0mmgA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/11/2011 04:53 PM, Peng Tao wrote:
>>
>> You should see if what I say is possible for write. And then maybe some
>> thing will come up also for read. They do not necessarily need to be the
>> same. (I think)
> I agree that it is possible for write. We can re-dirty the pages and
> rely on next flush to write it out to MDS. This is mentioned by Trond
> before. However, the method won't work for read failures. I don't see
> how we can queue failed read pages and let someone else re-send it
> later.
> 

Lets leave the read patch as is for now. Lets try to do it only for
writes.

It is OK to have write do one way and read do another way, I think.

Maybe later we can find a better solution for reads as well.

Thanks
Boaz
