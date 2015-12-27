Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:34436 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338AbbL0ALR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 19:11:17 -0500
Received: by mail-ob0-f177.google.com with SMTP id iw8so213266435obc.1
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 16:11:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <567F29A7.2020906@molgen.mpg.de>
References: <1451046656-26319-1-git-send-email-buczek@molgen.mpg.de>
	<CAHQdGtSCn4bbx4xiyE7FXmWk3SCY81mvWLJz_1VDow9YtB5VgA@mail.gmail.com>
	<567F29A7.2020906@molgen.mpg.de>
Date: Sat, 26 Dec 2015 19:11:16 -0500
Message-ID: <CAHQdGtSUmwVv0Do6Gu5=x+BonsoAi4afo_RzOo8KG+wp75t4aw@mail.gmail.com>
Subject: Re: [PATCH] nfs: do not deny execute access based on outdated mode in inode
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Donald Buczek <buczek@molgen.mpg.de>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 26, 2015 at 6:58 PM, Donald Buczek <buczek@molgen.mpg.de> wrote:
> On 26.12.2015 19:36, Trond Myklebust wrote:
>>
>> On Fri, Dec 25, 2015 at 7:30 AM, Donald Buczek <buczek@molgen.mpg.de>
>> wrote:
>>>
>>> This patch fixes a problem, that a nfs4 client incorrectly denies
>>> execute access based on outdated file mode (missing 'x' bit).
>>> After the mode on the server is 'fixed' (chmod +x) further execution
>>> attempts continue to fail, because the nfs ACCESS call updates
>>> the access parameter but not the mode parameter or the mode in
>>> the inode.
>>>
>>> The access check based on the file mode is not required, because
>>> the server already verified the clients rights.
>>>
>>> Remove the test.
>>>
>>> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=109771
>>> Signed-off-by: Donald Buczek <buczek@molgen.mpg.de>
>>> ---
>>>   fs/nfs/dir.c | 3 ---
>>>   1 file changed, 3 deletions(-)
>>>
>>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>>> index ce5a218..ffc25b0 100644
>>> --- a/fs/nfs/dir.c
>>> +++ b/fs/nfs/dir.c
>>> @@ -2481,9 +2481,6 @@ force_lookup:
>>>                          res = PTR_ERR(cred);
>>>          }
>>>   out:
>>> -       if (!res && (mask & MAY_EXEC) && !execute_ok(inode))
>>> -               res = -EACCES;
>>> -
>>>          dfprintk(VFS, "NFS: permission(%s/%lu), mask=0x%x, res=%d\n",
>>>                  inode->i_sb->s_id, inode->i_ino, mask, res);
>>>          return res;
>>>
>> My main question here is why the client isn't picking up the changed
>> mode bits here? All open() calls should be asking for the full set of
>> attributes as part of the OPEN COMPOUND rpc call.
>>
>> Cheers
>>    Trond
>
>
> Its from fs/namei.c do_last() :
>
>> finish_open_created:
>>         error = may_open(&nd->path, acc_mode, open_flag);
>>         if (error)
>>                 goto out;
>>
>>         BUG_ON(*opened & FILE_OPENED); /* once it's opened, it's opened */
>>         error = vfs_open(&nd->path, file, current_cred());
>
>
>
> may_open() -> inode_permission() -> __inode_permission() ->
> do_inode_permission() ->  inode->i_op->permission() -> nfs_permission()
> first
>
> vfs_open() -> do_dentry_open() -> inode->i_fop->open() -> nfs4_file_open()
> later

Ah... IOW: That so called "fast path" crap in do_last() is screwing us
over by forcing us to to 2 ACCESS calls. The first being done for no
good reason by the VFS, and the second being done in the OPEN call to
the server in the NFS client.

> Merry Christmas

Suggestions Al?

Trond
