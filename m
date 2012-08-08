Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:64270 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758663Ab2HHOtU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 10:49:20 -0400
Received: by pbbrr13 with SMTP id rr13so1570424pbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 07:49:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5022605D.6060901@netapp.com>
References: <1344390577-1602-1-git-send-email-bergwolf@gmail.com>
 <1344390577-1602-2-git-send-email-bergwolf@gmail.com> <5022605D.6060901@netapp.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Wed, 8 Aug 2012 22:48:59 +0800
Message-ID: <CA+a=Yy6HYkLRSr+qB+cK8xrf7Wy8BKc3RyYbzhrkGjAyvWkHAg@mail.gmail.com>
Subject: Re: [PATCH 2/2] NFS41: fix error of setting blocklayoutdriver
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 8, 2012 at 8:49 PM, Bryan Schumaker <bjschuma@netapp.com> wrote:
> On 08/07/2012 09:49 PM, Peng Tao wrote:
>> After commit e38eb650 (NFS: set_pnfs_layoutdriver() from
>> nfs4_proc_fsinfo()), set_pnfs_layoutdriver() is called inside
>> nfs4_proc_fsinfo(), but pnfs_blksize is not set. It causes setting
>> blocklayoutdriver failure and pnfsblock mount failure.
>>
>> Cc: Bryan Schumaker <bjschuma@netapp.com>
>> Signed-off-by: Peng Tao <bergwolf@gmail.com>
>> ---
>>  fs/nfs/nfs4proc.c |    5 ++++-
>>  1 files changed, 4 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 78b2163..299c311 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -3362,8 +3362,11 @@ static int nfs4_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, s
>>
>>       nfs_fattr_init(fsinfo->fattr);
>>       error = nfs4_do_fsinfo(server, fhandle, fsinfo);
>> -     if (error == 0)
>> +     if (error == 0) {
>> +             /* block layout checks this! */
>> +             server->pnfs_blksize = fsinfo->blksize;
>
> fs/nfs/client.c:nfs_server_set_fsinfo() also sets this field, so I'm surprised there was a problem.  You should remove the same line from nfs_server_set_fsinfo() if you're going to set it here.
Before commit e38eb650, nfs_server_set_fsinfo() is called before
setting layoutdriver. And now it is called after. And block layout
driver checks pnfs_blksize so it gets broken.

I will remove the line in nfs_server_set_fsinfo() and resend the patch.

-- 
Thanks,
Tao
