Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:52592 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914Ab3BELyW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2013 06:54:22 -0500
MIME-Version: 1.0
In-Reply-To: <20130130221657.GD15584@fieldses.org>
References: <1358441584-8783-1-git-send-email-piastry@etersoft.ru>
	<1358441584-8783-4-git-send-email-piastry@etersoft.ru>
	<20130130221657.GD15584@fieldses.org>
Date: Tue, 5 Feb 2013 15:54:21 +0400
Message-ID: <CAKywueR0tHyR+o7YV+AGo_AE4AP1b0Xi-TwgemJGwft4HityRA@mail.gmail.com>
Subject: Re: [PATCH v2 4/8] CIFS: Add O_DENY* open flags support
From: Pavel Shilovsky <piastry@etersoft.ru>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/1/31 J. Bruce Fields <bfields@fieldses.org>:
> On Thu, Jan 17, 2013 at 08:53:00PM +0400, Pavel Shilovsky wrote:
>> Make CIFSSMBOpen take share_flags as a parm that allows us
>> to pass new O_DENY* flags to the server.
>>
>> Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
>> ---
>>  fs/cifs/cifsacl.c   | 10 ++++++----
>>  fs/cifs/cifsglob.h  | 12 +++++++++++-
>>  fs/cifs/cifsproto.h |  9 +++++----
>>  fs/cifs/cifssmb.c   | 47 +++++++++++++++++++++++++----------------------
>>  fs/cifs/dir.c       | 13 ++++++++-----
>>  fs/cifs/file.c      | 12 ++++++++----
>>  fs/cifs/inode.c     | 11 ++++++-----
>>  fs/cifs/link.c      | 10 +++++-----
>>  fs/cifs/readdir.c   |  2 +-
>>  fs/cifs/smb1ops.c   | 15 ++++++++-------
>>  fs/cifs/smb2file.c  | 10 +++++-----
>>  fs/cifs/smb2inode.c |  4 ++--
>>  fs/cifs/smb2ops.c   | 10 ++++++----
>>  fs/cifs/smb2pdu.c   |  6 +++---
>>  fs/cifs/smb2proto.h | 14 ++++++++------
>>  15 files changed, 107 insertions(+), 78 deletions(-)
>>
>> diff --git a/fs/cifs/cifsacl.c b/fs/cifs/cifsacl.c
>> index 0fb15bb..a42c77f 100644
>> --- a/fs/cifs/cifsacl.c
>> +++ b/fs/cifs/cifsacl.c
>> @@ -1184,8 +1184,9 @@ static struct cifs_ntsd *get_cifs_acl_by_path(struct cifs_sb_info *cifs_sb,
>>               create_options |= CREATE_OPEN_BACKUP_INTENT;
>>
>>       rc = CIFSSMBOpen(xid, tcon, path, FILE_OPEN, READ_CONTROL,
>> -                     create_options, &fid, &oplock, NULL, cifs_sb->local_nls,
>> -                     cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
>> +                      FILE_SHARE_ALL, create_options, &fid, &oplock,
>> +                      NULL, cifs_sb->local_nls,
>> +                      cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
>>       if (!rc) {
>>               rc = CIFSSMBGetCIFSACL(xid, tcon, fid, &pntsd, pacllen);
>>               CIFSSMBClose(xid, tcon, fid);
>> @@ -1245,8 +1246,9 @@ int set_cifs_acl(struct cifs_ntsd *pnntsd, __u32 acllen,
>>               access_flags = WRITE_DAC;
>>
>>       rc = CIFSSMBOpen(xid, tcon, path, FILE_OPEN, access_flags,
>> -                     create_options, &fid, &oplock, NULL, cifs_sb->local_nls,
>> -                     cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
>> +                      FILE_SHARE_ALL, create_options, &fid, &oplock,
>> +                      NULL, cifs_sb->local_nls,
>> +                      cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
>
> It would be easier to tell what you changed in the above two chunks if
> you didn't change the whitespace at the same time.
>
> --b.

Ok, thank - will fix it in the further version of the patch.

-- 
Best regards,
Pavel Shilovsky.
