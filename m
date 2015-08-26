Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:35163 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833AbbHZAKJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 20:10:09 -0400
Received: by obbwr7 with SMTP id wr7so157498809obb.2
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 17:10:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55C0973A.5020700@gmail.com>
References: <55BA290B.2020704@gmail.com>
	<55BA2936.4030404@gmail.com>
	<55BA2996.9030804@gmail.com>
	<55C0973A.5020700@gmail.com>
Date: Tue, 25 Aug 2015 20:10:08 -0400
Message-ID: <CAHQdGtQrFEbb7Den1t6Vd9gg4-=ffit6iwVm_SMt7qC9upuE+g@mail.gmail.com>
Subject: Re: [PATCH 3/7 v2] NFS: Check size by inode_newsize_ok in nfs_setattr
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Kinglong,

On Tue, Aug 4, 2015 at 6:43 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
> On 7/30/2015 21:41, Kinglong Mee wrote:
>> Set rlimit for NFS's files is useless right now.
>> For local process's rlimit, it should be checked by nfs client.
>>
>> The same, CIFS also call inode_change_ok checking rlimit at its client
>> in cifs_setattr_nounix() and cifs_setattr_unix().
>>
>> v2, same as v1.
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfs/inode.c | 11 +++++------
>>  1 file changed, 5 insertions(+), 6 deletions(-)
>>
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 0adc7d2..9304dfd 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -513,15 +513,14 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
>>               attr->ia_valid &= ~ATTR_MODE;
>>
>>       if (attr->ia_valid & ATTR_SIZE) {
>> -             loff_t i_size;
>> -
>>               BUG_ON(!S_ISREG(inode->i_mode));
>>
>> -             i_size = i_size_read(inode);
>> -             if (attr->ia_size == i_size)
>> +             error = inode_newsize_ok(inode, attr->ia_size);
>> +             if (error)
>> +                     return error;
>
> So sorry!
>
> Use "error" will cause a bug for the following code of error out.
> I will update it in the new version.

Did you ever send the update for this? I don't seem to have it in my inbox.

Cheers
  Trond
