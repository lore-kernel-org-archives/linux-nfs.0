Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f181.google.com ([209.85.212.181]:65032 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbaJWQSy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Oct 2014 12:18:54 -0400
Received: by mail-wi0-f181.google.com with SMTP id n3so2438291wiv.14
        for <linux-nfs@vger.kernel.org>; Thu, 23 Oct 2014 09:18:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtRowHfcy=y656tLGkVBFzSDtx5sLHkvuBTY1=oRX0AqYQ@mail.gmail.com>
References: <1414079771-2960-1-git-send-email-jack@suse.cz>
	<CAHQdGtRowHfcy=y656tLGkVBFzSDtx5sLHkvuBTY1=oRX0AqYQ@mail.gmail.com>
Date: Thu, 23 Oct 2014 19:18:52 +0300
Message-ID: <CAHQdGtRVyjOowVnJNd30HVWT1jjTOmce6bRkjAbVjH_RiZ0VMw@mail.gmail.com>
Subject: Re: [PATCH] nfs: Remove dead case from nfs4_map_errors()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jan Kara <jack@suse.cz>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 23, 2014 at 7:16 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> Hi Jan,
>
> On Thu, Oct 23, 2014 at 6:56 PM, Jan Kara <jack@suse.cz> wrote:
>> NFS4ERR_ACCESS has number 13 and thus is matched and returned
>> immediately at the beginning of nfs4_map_errors() and there's no point
>> in checking it later.
>>
>> Coverity-id: 733891
>> Signed-off-by: Jan Kara <jack@suse.cz>
>> ---
>>  fs/nfs/nfs4proc.c | 2 --
>>  1 file changed, 2 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 405bd95c1f58..f45e6ea1b278 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -158,8 +158,6 @@ static int nfs4_map_errors(int err)
>>                 return -EACCES;
>>         case -NFS4ERR_MINOR_VERS_MISMATCH:
>>                 return -EPROTONOSUPPORT;
>> -       case -NFS4ERR_ACCESS:
>> -               return -EACCES;
>>         case -NFS4ERR_FILE_OPEN:
>>                 return -EBUSY;
>>         default:
>> --
>> 1.8.1.4
>>
>
> Can you guarantee that EACCES will _always_ take the value 13? I don't
> think POSIX lists explicit values.
> The NFSv4 error codes are sometimes based on old Solaris error code
> values, and so often coincide with the Linux values, but I'm not
> comfortable yet with the assumption that will always be the case.
>

D'oh... Never mind. I penetrated the fog of jetlag and now I see what
you are saying...

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
