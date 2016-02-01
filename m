Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35820 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbcBAKgb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2016 05:36:31 -0500
Received: by mail-wm0-f42.google.com with SMTP id r129so63263746wmr.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Feb 2016 02:36:10 -0800 (PST)
Subject: Re: [LSF/MM TOPIC/ATTEND] RDMA passive target
To: Yigal Korman <yigal@plexistor.com>, Boaz Harrosh <boaz@plexistor.com>
References: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com>
 <56A8F646.5020003@plexistor.com> <56A8FE10.7000309@dev.mellanox.co.il>
 <56AE181A.8030908@plexistor.com>
 <CACTTzNaOChdWN2eS9_kzv6HO_LVib-JVdkmeUn0LDe2eKxPEgA@mail.gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, lsf-pc@lists.linux-foundation.org,
        Dan Williams <dan.j.williams@intel.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>,
        Ric Wheeler <rwheeler@redhat.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <56AF3516.8000909@dev.mellanox.co.il>
Date: Mon, 1 Feb 2016 12:36:06 +0200
MIME-Version: 1.0
In-Reply-To: <CACTTzNaOChdWN2eS9_kzv6HO_LVib-JVdkmeUn0LDe2eKxPEgA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>>>> The almost is because:
>>>> 1. If the target is over a /dev/pmemX then all is fine we have 2M contiguous
>>>>      memory blocks.
>>>> 2. If the target is over an FS, we have a proposal pending for an falloc_2M_flag
>>>>      to ask the FS for a contiguous 2M allocations only. If any of the 2M allocations
>>>>      fail then return ENOSPC from falloc. This way we guaranty that each 2M block can be
>>>>      mapped by a single RDAM handle.
>>>
>>> Umm, you don't need the 2M to be contiguous in order to represent them
>>> as a single RDMA handle. If that was true iSER would have never worked.
>>> Or I misunderstood what you meant...
>>>
>>
>> OK I will let our RDMA guy Yigal Korman answer that, I guess you might be right.
>
> When Boaz says 'RDMA handle', he means the pair [rkey,remote_addr].
> AFAIK the remote_addr describes a continuous memory space on the target.
> So if you want to write to this 'handle' - it must be continuous.
> Please correct me if I'm wrong.

OK, this is definitely wrong. But let's defer this discussion to another
thread as it's not relevant to lsf folks...
