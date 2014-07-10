Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:59520 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbaGJPgJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 11:36:09 -0400
Received: by mail-vc0-f179.google.com with SMTP id id10so10749768vcb.24
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 08:36:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <03ba01cf9c52$93b3d000$bb1b7000$@mindspring.com>
References: <1405002343-15802-1-git-send-email-trond.myklebust@primarydata.com>
	<03ba01cf9c52$93b3d000$bb1b7000$@mindspring.com>
Date: Thu, 10 Jul 2014 11:36:08 -0400
Message-ID: <CAHQdGtRmWxNsm59eXfVQGiOXO7cXfoV_R2X2UKqY1kJgST_6Nw@mail.gmail.com>
Subject: Re: [PATCH] NFSv4: Fix OPEN w/create access mode checking
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 11:21 AM, Frank Filz <ffilzlnx@mindspring.com> wrote:
> Ok, that should work, though what about the case where cinfo is not atomic?
> Even if the server is able to do an atomic open/create, the cinfo might
> still not be atomic, thus might give a false indication of file create (it
> doesn't look like the client checks for cinfo.atomic.
>
> The result would be that in a busy directory, you COULD call
> open("some-execute-only-file", O_CREAT | O_RDONLY, 0) to get read access to
> an execute only file...
>
> Ganesha for one can't guarantee atomicity (we can't create a file AND get an
> updated cinfo from the kernel in a single operation...). So if a check for
> cinfo.atomic is put in place, the exception would be skipped. (It looks like
> knfsd may also always set cinfo.atomic to false). Currently, it looks like
> the only use of file_created is to set FILE_CREATED, and it looks like the
> only real use of that is to call fsnotify_create, which if that happens to
> be called for a file that actually already existed, would not be horrendous.
>
> To cut to the chase, this patch should make all of my tests pass (which my
> patch in truth did not do), and also for the cases you suggested is correct,
> suggests this patch is more correct than mine, but might still not be 100%
> correct...

Agreed, but it is a best effort. There is nothing other than the cinfo
available to the client to tell it if the file was just created or
not.


> Frank
>
>> POSIX states that open("foo", O_CREAT|O_RDONLY, 000) should succeed if
>> the file "foo" does not already exist. With the current NFS client, it
> will fail
>> with an EACCES error because of the permissions checks in
>> nfs4_opendata_access().
>>
>> Fix is to turn that test off if the server says that we created the file.
>>
>> Reported-by: "Frank S. Filz" <ffilzlnx@mindspring.com>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  fs/nfs/nfs4proc.c | 18 +++++++++++++-----
>>  1 file changed, 13 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c index
>> d0e0e54fb2b9..70e53a2ac75e 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -1954,6 +1954,14 @@ static int _nfs4_recover_proc_open(struct
>> nfs4_opendata *data)
>>       return status;
>>  }
>>
>> +/*
>> + * Additional permission checks in order to distinguish between an
>> + * open for read, and an open for execute. This works around the
>> + * fact that NFSv4 OPEN treats read and execute permissions as being
>> + * the same.
>> + * Note that in the non-execute case, we want to turn off permission
>> + * checking if we just created a new file (POSIX open() semantics).
>> + */
>>  static int nfs4_opendata_access(struct rpc_cred *cred,
>>                               struct nfs4_opendata *opendata,
>>                               struct nfs4_state *state, fmode_t fmode,
>> @@ -1968,14 +1976,14 @@ static int nfs4_opendata_access(struct rpc_cred
>> *cred,
>>               return 0;
>>
>>       mask = 0;
>> -     /* don't check MAY_WRITE - a newly created file may not have
>> -      * write mode bits, but POSIX allows the creating process to write.
>> -      * use openflags to check for exec, because fmode won't
>> -      * always have FMODE_EXEC set when file open for exec. */
>> +     /*
>> +      * Use openflags to check for exec, because fmode won't
>> +      * always have FMODE_EXEC set when file open for exec.
>> +      */
>>       if (openflags & __FMODE_EXEC) {
>>               /* ONLY check for exec rights */
>>               mask = MAY_EXEC;
>> -     } else if (fmode & FMODE_READ)
>> +     } else if ((fmode & FMODE_READ) && !opendata->file_created)
>>               mask = MAY_READ;
>>
>>       cache.cred = cred;
>> --
>> 1.9.3
>



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
