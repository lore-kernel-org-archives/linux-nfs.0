Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f179.google.com ([209.85.210.179]:56053 "EHLO
	mail-ia0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754255Ab3CKS7R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Mar 2013 14:59:17 -0400
MIME-Version: 1.0
In-Reply-To: <20130311143507.737f2ab0@corrin.poochiereds.net>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
	<1362065133-9490-6-git-send-email-piastry@etersoft.ru>
	<20130311143507.737f2ab0@corrin.poochiereds.net>
Date: Mon, 11 Mar 2013 22:59:16 +0400
Message-ID: <CAKywueQV7sc9OzOb7=d=48BaosKDoiGsGPjMt5wvW35yjhuCQw@mail.gmail.com>
Subject: Re: [PATCH v3 5/7] CIFS: Translate SHARING_VIOLATION to -ETXTBSY
 error code for SMB2
From: Pavel Shilovsky <piastry@etersoft.ru>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org, sprabhu@redhat.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/3/11 Jeff Layton <jlayton@redhat.com>:
> On Thu, 28 Feb 2013 19:25:31 +0400
> Pavel Shilovsky <piastry@etersoft.ru> wrote:
>
>> to make it match CIFS and VFS variants.
>>
>> Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
>> ---
>>  fs/cifs/smb2maperror.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/cifs/smb2maperror.c b/fs/cifs/smb2maperror.c
>> index 494c912..11e589e 100644
>> --- a/fs/cifs/smb2maperror.c
>> +++ b/fs/cifs/smb2maperror.c
>> @@ -356,7 +356,7 @@ static const struct status_to_posix_error smb2_error_map_table[] = {
>>       {STATUS_PORT_CONNECTION_REFUSED, -ECONNREFUSED,
>>       "STATUS_PORT_CONNECTION_REFUSED"},
>>       {STATUS_INVALID_PORT_HANDLE, -EIO, "STATUS_INVALID_PORT_HANDLE"},
>> -     {STATUS_SHARING_VIOLATION, -EBUSY, "STATUS_SHARING_VIOLATION"},
>> +     {STATUS_SHARING_VIOLATION, -ETXTBSY, "STATUS_SHARING_VIOLATION"},
>>       {STATUS_QUOTA_EXCEEDED, -EDQUOT, "STATUS_QUOTA_EXCEEDED"},
>>       {STATUS_INVALID_PAGE_PROTECTION, -EIO,
>>       "STATUS_INVALID_PAGE_PROTECTION"},
>
> Actually, I think Sachin is converting the CIFS
> STATUS_SHARING_VIOLATION to translate to EBUSY, since that seems to
> better reflect the situation. I'd suggest dropping this patch, unless
> you have a specific need for this error return here.

Yes, I am ok to drop this patch - accoring to the previous discussion
in linux-cifs@ it is no suitable.

-- 
Best regards,
Pavel Shilovsky.
