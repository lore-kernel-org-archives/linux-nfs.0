Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51899 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639Ab1HQNmf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Aug 2011 09:42:35 -0400
Received: by vws1 with SMTP id 1so649863vws.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Aug 2011 06:42:35 -0700 (PDT)
In-Reply-To: <4E4AD655.9090305@panasas.com>
References: <1313197213-1651-1-git-send-email-bergwolf@gmail.com> <4E4AD655.9090305@panasas.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Wed, 17 Aug 2011 21:42:15 +0800
Message-ID: <CA+a=Yy6xNFu62nZavt1KnrZWTZGjgR3H=bgF-uERsf=xp7TARg@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] recoalesce when ld read/write fails
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: benny@tonian.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Boaz,

On Wed, Aug 17, 2011 at 4:43 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 08/12/2011 06:00 PM, Peng Tao wrote:
>> Hi,
>>
>> I have moved the error handling inside mds_ops->rpc_release to reuse code
>> as suggested by Boaz.
>>
>> I think we still need to issue the IO even for write because
>> we don't know if current writeback is the last one. So if we re-dirty the
>> pages and this is the last flush (flush at file close), then we don't have
>> a later flusher to writeback the re-dirtied pages. Boaz, please help see if
>> current approach is OK. Thanks.
>>
>> The two cleanup patches (pipe upcall and set_lo_fail) are seperated out of
>> this patchset so they can be merged more easily.
>>
>> Thanks,
>> Tao
>>
>
> Thanks Tao
>
> They look *really* good these patches. But as you said, do they actually work?
>
> Did you test any of this? I mean do you have a facility to inject random
> IO errors and test this out?
I have tested the patchset by forcing all bio to fail so IO will be
re-send to MDS. Also I tested read/write by forcing all IO that
touches pages beyond 16K to fail. Both tests passed.

>
> At the time I had the most dumb patch that would simply start failing IO after
> n writes/reads. Or another one that: if the offset was a magic offset like
> 0x10017 then the IO would fail. Then with a simple dd I could make the IO
> fail and test this out. (Which BTW never worked with pnfs)
>
> The Kernel might be more resilient then we think with regarding to waiting
> for clean pages. Because I know that in a UML it is very easy to get to
> a low-memory condition where the iscsi stack starts to throw OOM messages
> and everything stalls for a while. But I'm always surprised how eventually
> the Kernel picks up and the IO ends successfully. One easy way to do this
> is with a "git clone linux" with a machine that has a fast (iscsi) disk but
> only 256M of memory.
I tried to test "git clone linux" on a 384M memory VM but it hangs as
server is rejecting layoutget with NFS4ERR_LAYOUTTRYLATER.
/proc/self/mountstats shows that client has sent more than 14K
layoutgets but never returns any layout. I checked related code and it
seems client should send layoutreturn for closed files. Will git keep
all files open? Or is there any case that client won't return the
layout even after file close?

This seems to be another issue though.

Thanks,
Tao

>
> I will only have time to test all this at end of next week at the earliest.
> So thanks again for looking into this
>
> Boaz
>
>> Peng Tao (3):
>>   pNFS: recoalesce when ld write pagelist fails
>>   pNFS: recoalesce when ld read pagelist fails
>>   pNFS: introduce pnfs private workqueue
>>
>>  fs/nfs/blocklayout/blocklayout.c |   17 +++++--
>>  fs/nfs/objlayout/objio_osd.c     |    8 +++
>>  fs/nfs/objlayout/objlayout.c     |    4 +-
>>  fs/nfs/pnfs.c                    |   92 +++++++++++++++++++++++++++-----------
>>  fs/nfs/pnfs.h                    |    8 +++-
>>  fs/nfs/read.c                    |   13 +++++-
>>  fs/nfs/write.c                   |   25 ++++++++++-
>>  7 files changed, 129 insertions(+), 38 deletions(-)
>>
>
>



-- 
Thanks,
-Bergwolf
