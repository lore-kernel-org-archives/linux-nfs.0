Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:58222 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933301Ab2EPAgB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 20:36:01 -0400
Received: by dady13 with SMTP id y13so221673dad.19
        for <linux-nfs@vger.kernel.org>; Tue, 15 May 2012 17:36:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FB282F7.5090408@panasas.com>
References: <1337096303-2516-1-git-send-email-bergwolf@gmail.com>
 <20120515160855.GA5911@infradead.org> <4FB282F7.5090408@panasas.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Wed, 16 May 2012 08:35:41 +0800
Message-ID: <CA+a=Yy73hqYxgbBhroJmGpvJOkNRPoTiX6uLeSjY1-PXT=t7jQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFS: call block plug around direct write
To: Boaz Harrosh <bharrosh@panasas.com>, Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 16, 2012 at 12:23 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 05/15/2012 07:08 PM, Christoph Hellwig wrote:
>
>> On Tue, May 15, 2012 at 11:38:22PM +0800, Peng Tao wrote:
>>> We bypass generic_file_aio_write() but would want to call block plug.
>>
>> We in this case is the pnfs block driver at most.  Thus these should
>> be pnfs block code.
Agreed. Just that for buffer IO case all call into block plug, so I
thought it might be OK in DIO case as well... Anyway. I will make it
block specific and call it LD()->dio_begin and LD()->dio_end. I am
cooking some dio alignment patches for block layout driver and would
love to put them there as well.

>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
> I thought so too.
>
> But reading the code more closely it might be hard for the blocklayout
> to figure out the right state to call these two. Specially the call to
> blk_finish_plug(). So you might need to add a new LD API such as
> LD()->finish_plug() which is empty for others.
>
> But again inspecting the code it looks like blk_start_plug() is a no-op
> and blk_finish_plug() is specially optimized for the empty case.
>
They are empty only when !CONFIG_BLOCK. I will make it block layout
specific as said above.

Thanks,
Tao
> So is it worth it, the extra effort? I do understand the temptation
> to get lazy here.
>
> Just my $0.017
> Boaz
