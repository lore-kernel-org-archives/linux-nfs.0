Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:64319 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481Ab1HKXxl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 19:53:41 -0400
Received: by vws1 with SMTP id 1so2094947vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 11 Aug 2011 16:53:41 -0700 (PDT)
In-Reply-To: <4E442512.7080904@panasas.com>
References: <1312685635-1593-1-git-send-email-bergwolf@gmail.com>
 <4E42C564.7070504@panasas.com> <CA+a=Yy4WXD64A3anw7f-wSWcs4A4-6W18QQs=YyYC0285_W_qg@mail.gmail.com>
 <4E442512.7080904@panasas.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Fri, 12 Aug 2011 07:53:21 +0800
Message-ID: <CA+a=Yy4g09b_AEf2px1Cjfmr_ud3PFuAbEwdez1cbsiYJ0mmgA@mail.gmail.com>
Subject: Re: [PATCH 1/5] pNFS: recoalesce when ld write pagelist fails
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <benny@tonian.com>, linux-nfs@vger.kernel.org,
        Peng Tao <peng_tao@emc.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 12, 2011 at 2:53 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 08/10/2011 05:03 PM, Peng Tao wrote:
>> On Thu, Aug 11, 2011 at 1:52 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>> On 08/06/2011 07:53 PM, Peng Tao wrote:
>>>> For pnfs pagelist write failure, we need to pg_recoalesce and resend
>>>> IO to mds.
>>>>
>>>
>>> I have not given this subject any thought or investigation, so I don't
>>> know what we should do, but the gut feeling is that I have seen all this
>>> code else where and we could be having a bigger re-use of existing code.
>>>
>>> What if we dig into:
>>>        data->mds_ops->rpc_call_done(&data->task, data);
>>>        data->mds_ops->rpc_release(data);
>>>
>>> And do all the pages tear-down and unlocks but if there is an error
>>> not set them as clean. That is keep them dirty. Then mark the layout
>>> as error and let the normal code choose an MDS write_out. (Just a wild
>>> thought)
>> This may work only for write failures. But for read, we will have to
>> recoalesce and send to MDS. So I prefer to let read and write have
>> similar retry code path like this.
>>
>
> I disagree. Look even now the read path is very different then the write
> path. (See your two patches: write-patch is 3 times bigger the read-patch)
I mean their logic is the same: if pnfs_error is set, recoalesce the
pages and re-send to MDS :)

>
> You should see if what I say is possible for write. And then maybe some
> thing will come up also for read. They do not necessarily need to be the
> same. (I think)
I agree that it is possible for write. We can re-dirty the pages and
rely on next flush to write it out to MDS. This is mentioned by Trond
before. However, the method won't work for read failures. I don't see
how we can queue failed read pages and let someone else re-send it
later.

-- 
Thanks,
Tao
