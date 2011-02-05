Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:37383 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829Ab1BEQr6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Feb 2011 11:47:58 -0500
Received: by iwn9 with SMTP id 9so3197197iwn.19
        for <linux-nfs@vger.kernel.org>; Sat, 05 Feb 2011 08:47:58 -0800 (PST)
In-Reply-To: <AANLkTinxqvGOm0JkPph9zH3FO4EEmfqWZLH2qo+oiovi@mail.gmail.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
	<1296855242-2592-2-git-send-email-andros@netapp.com>
	<1296855242-2592-3-git-send-email-andros@netapp.com>
	<1296855242-2592-4-git-send-email-andros@netapp.com>
	<1296855242-2592-5-git-send-email-andros@netapp.com>
	<1296855242-2592-6-git-send-email-andros@netapp.com>
	<1296855242-2592-7-git-send-email-andros@netapp.com>
	<1296855242-2592-8-git-send-email-andros@netapp.com>
	<1296855242-2592-9-git-send-email-andros@netapp.com>
	<1296855242-2592-10-git-send-email-andros@netapp.com>
	<1296855242-2592-11-git-send-email-andros@netapp.com>
	<1296855242-2592-12-git-send-email-andros@netapp.com>
	<1296855242-2592-13-git-send-email-andros@netapp.com>
	<1296855242-2592-14-git-send-email-andros@netapp.com>
	<1296855242-2592-15-git-send-email-andros@netapp.com>
	<1296855242-2592-16-git-send-email-andros@netapp.com>
	<1296855242-2592-17-git-send-email-andros@netapp.com>
	<1296855242-2592-18-git-send-email-andros@netapp.com>
	<1296855242-2592-19-git-send-email-andros@netapp.com>
	<1296855242-2592-20-git-send-email-andros@netapp.com>
	<AANLkTinxqvGOm0JkPph9zH3FO4EEmfqWZLH2qo+oiovi@mail.gmail.com>
Date: Sat, 5 Feb 2011 11:47:58 -0500
Message-ID: <AANLkTinBv2uMAPu5ykSMNMt3rDjFkr-wABzFdAecYe6=@mail.gmail.com>
Subject: Re: [PATCH 19/40] SQUASHME pnfs-submit wave3 filelayout read pagelist cleanup
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Feb 4, 2011 at 4:44 PM, Fred Isaman <iisaman@netapp.com> wrote:
> On Fri, Feb 4, 2011 at 4:33 PM,  <andros@netapp.com> wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  fs/nfs/nfs4filelayout.c |   19 ++-----------------
>>  1 files changed, 2 insertions(+), 17 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index 3daf351..dce90a0 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -132,14 +132,6 @@ struct rpc_call_ops filelayout_read_call_ops = {
>>        .rpc_release = filelayout_read_release,
>>  };
>>
>> -/* Perform sync or async reads.
>> - *
>> - * An optimization for the NFS file layout driver
>> - * allows the original read/write data structs to be passed in the
>> - * last argument.
>> - *
>> - * TODO: join with write_pagelist?
>> - */
>>  static enum pnfs_try_status
>>  filelayout_read_pagelist(struct nfs_read_data *data, unsigned nr_pages)
>>  {
>> @@ -149,8 +141,8 @@ filelayout_read_pagelist(struct nfs_read_data *data, unsigned nr_pages)
>>        u32 idx;
>>        struct nfs_fh *fh;
>>
>> -       dprintk("--> %s ino %lu nr_pages %d pgbase %u req %Zu@%llu\n",
>> -               __func__, data->inode->i_ino, nr_pages,
>> +       dprintk("--> %s ino %lu pgbase %u req %Zu@%llu\n",
>> +               __func__, data->inode->i_ino,
>>                data->args.pgbase, (size_t)data->args.count, offset);
>>
>
> A nit, but this belongs in the next patch.

Yep :)

>
> Fred
>
>>        /* Retrieve the correct rpc_client for the byte range */
>> @@ -169,13 +161,6 @@ filelayout_read_pagelist(struct nfs_read_data *data, unsigned nr_pages)
>>        if (fh)
>>                data->args.fh = fh;
>>
>> -       /*
>> -        * Now get the file offset on the dserver
>> -        * Set the read offset to this offset, and
>> -        * save the original offset in orig_offset
>> -        * In the case of aync reads, the offset will be reset in the
>> -        * call_ops->rpc_call_done() routine.
>> -        */
>>        data->args.offset = filelayout_get_dserver_offset(lseg, offset);
>>        data->fldata.orig_offset = offset;
>>
>> --
>> 1.6.6
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
