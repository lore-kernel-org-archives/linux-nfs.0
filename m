Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33746 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbcADQhP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 11:37:15 -0500
Received: by mail-oi0-f41.google.com with SMTP id y66so258332982oig.0
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 08:37:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAKVebiUoY1a9_fkyC1TTZegYXMEbigYL-Ww0HWJBowC1w78LXQ@mail.gmail.com>
References: <1451325918-33544-1-git-send-email-trond.myklebust@primarydata.com>
	<1451325918-33544-2-git-send-email-trond.myklebust@primarydata.com>
	<1451325918-33544-3-git-send-email-trond.myklebust@primarydata.com>
	<1451325918-33544-4-git-send-email-trond.myklebust@primarydata.com>
	<1451325918-33544-5-git-send-email-trond.myklebust@primarydata.com>
	<1451325918-33544-6-git-send-email-trond.myklebust@primarydata.com>
	<CAKVebiUoY1a9_fkyC1TTZegYXMEbigYL-Ww0HWJBowC1w78LXQ@mail.gmail.com>
Date: Mon, 4 Jan 2016 11:37:14 -0500
Message-ID: <CAHQdGtRbK5ZhQOhXRCmzOVyJQu-UhzaKQthvs9csUY-tU=0TyQ@mail.gmail.com>
Subject: Re: [PATCH v2 6/6] NFSv4.1/pNFS: Don't return NFS4ERR_DELAY
 unnecessarily in CB_LAYOUTRECALL
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Peng Tao <bergwolf@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tao,

On Mon, Jan 4, 2016 at 10:13 AM, Peng Tao <bergwolf@primarydata.com> wrote:
> On Tue, Dec 29, 2015 at 2:05 AM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> If the client is promising to return the layout ASAP, then there is no
>> need to return DELAY and have the server retry. Instead default to the
>> normal procedure described in RFC5661.
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  fs/nfs/callback_proc.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
>> index 1b24ad07d4f5..724a9b756ab0 100644
>> --- a/fs/nfs/callback_proc.c
>> +++ b/fs/nfs/callback_proc.c
>> @@ -214,7 +214,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>>                 pnfs_mark_matching_lsegs_return(lo,
>>                                 &free_me_list,
>>                                 &args->cbl_range);
>> -               rv = NFS4ERR_DELAY;
>> +               rv = NFS4_OK;
> It is possible that we've cleared all outstanding layout segments of
> the file and returns NFS4_OK to CB_LAYOUTRECALL. Then server would be
> expecting LAYOUTRETURN while client will not send one. IMO we'd better
> re-check list_empty(&lo->plh_segs) to decide what to return here.
>

Thanks! I'll fix this up in v3...

Cheers
  Trond
