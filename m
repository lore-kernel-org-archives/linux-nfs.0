Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:44000 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052Ab3BELpc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2013 06:45:32 -0500
MIME-Version: 1.0
In-Reply-To: <20130130221602.GC15584@fieldses.org>
References: <1358441584-8783-1-git-send-email-piastry@etersoft.ru>
	<1358441584-8783-3-git-send-email-piastry@etersoft.ru>
	<20130130221602.GC15584@fieldses.org>
Date: Tue, 5 Feb 2013 15:45:31 +0400
Message-ID: <CAKywueRh++TBazK8_kRN7AUb=EFhGv=Sv2CV0BESkfLFy+g5wA@mail.gmail.com>
Subject: Re: [PATCH v2 3/8] vfs: Add O_DENYREAD/WRITE flags support for open syscall
From: Pavel Shilovsky <piastry@etersoft.ru>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/1/31 J. Bruce Fields <bfields@fieldses.org>:
> On Thu, Jan 17, 2013 at 08:52:59PM +0400, Pavel Shilovsky wrote:
>> If O_DENYMAND flag is specified, O_DENYREAD/WRITE/MAND flags are
>> translated to flock's flags:
>>
>> !O_DENYREAD  -> LOCK_READ
>> !O_DENYWRITE -> LOCK_WRITE
>> O_DENYMAND   -> LOCK_MAND
>>
>> and set through flock_lock_file on a file.
>>
>> This change only affects opens that use O_DENYMAND flag - all other
>> native Linux opens don't care about these flags. It allow us to
>> enable this feature for applications that need it (e.g. NFS and
>> Samba servers that export the same directory for Windows clients,
>> or Wine applications that access the same files simultaneously).
>
> The use of an is_conflict callback seems unnecessarily convoluted.
>
> If we need two different behaviors, let's just use another flag (or an
> extra boolean argument if we need to, or something).

Ok, we can pass "bool is_mand" to flock_lock_file that will pass it
further to flock_locks_conflict.

>
> The only caller for this new deny_lock_file is in the nfs code--I'm a
> little unclear why that is.

deny_lock_file is called not only in the nfs code but also in 2 places
of fs/namei.c -- that enable this logic for VFS.

-- 
Best regards,
Pavel Shilovsky.
