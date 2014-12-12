Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:65371 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760048AbaLLPuv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2014 10:50:51 -0500
Received: by mail-vc0-f179.google.com with SMTP id le20so3743457vcb.10
        for <linux-nfs@vger.kernel.org>; Fri, 12 Dec 2014 07:50:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141212095804.675912b9@tlielax.poochiereds.net>
References: <1418395818-22062-1-git-send-email-jlayton@primarydata.com>
	<20141212095804.675912b9@tlielax.poochiereds.net>
Date: Fri, 12 Dec 2014 10:50:50 -0500
Message-ID: <CAHQdGtRVUR9K=phK=kQtMvE+0tStBUhocuzqBGTC2psr6_mhmA@mail.gmail.com>
Subject: Re: [PATCH] nfs: guard fs/nfs/internal.h against multiple inclusion
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Thomas Haynes <thomas.haynes@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 12, 2014 at 9:58 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
> On Fri, 12 Dec 2014 09:50:18 -0500
> Jeff Layton <jlayton@primarydata.com> wrote:
>
>> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
>> Cc: Thomas Haynes <thomas.haynes@primarydata.com>
>> ---
>>  fs/nfs/internal.h | 4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index efaa31c70fbe..ffef459f0b4f 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -1,6 +1,8 @@
>>  /*
>>   * NFS internal definitions
>>   */
>> +#ifndef      __FS_NFS_INTERNAL_H
>
> Gyah...sorry for the whitespace typo above. Want me to resend with that
> tab turned into a space?

That's OK. I'll manage somehow :-)

>> +#define __FS_NFS_INTERNAL_H
>>
>>  #include "nfs4_fs.h"
>>  #include <linux/mount.h>
>> @@ -629,3 +631,5 @@ static inline u32 nfs_fhandle_hash(const struct nfs_fh *fh)
>>       return 0;
>>  }
>>  #endif
>> +
>> +#endif       /* __FS_NFS_INTERNAL_H */
>
>
> --
> Jeff Layton <jlayton@poochiereds.net>



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
