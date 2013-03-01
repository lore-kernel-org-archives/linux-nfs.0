Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:45613 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198Ab3CAGoM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2013 01:44:12 -0500
MIME-Version: 1.0
In-Reply-To: <512FD1D5.3010106@mit.edu>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
	<512FD1D5.3010106@mit.edu>
Date: Fri, 1 Mar 2013 10:44:11 +0400
Message-ID: <CAKywueR_J16BG2j22_Dehs99FVNf=cVKAFUAp7wheJz4HZxyyw@mail.gmail.com>
Subject: Re: [PATCH v3 0/7] Add O_DENY* support for VFS and CIFS/NFS
From: Pavel Shilovsky <piastry@etersoft.ru>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/3/1 Andy Lutomirski <luto@amacapital.net>:
> [possible resend -- sorry]
>
> On 02/28/2013 07:25 AM, Pavel Shilovsky wrote:
>> This patchset adds support of O_DENY* flags for Linux fs layer. These flags can be used by any application that needs share reservations to organize a file access. VFS already has some sort of this capability - now it's done through flock/LOCK_MAND mechanis, but that approach is non-atomic. This patchset build new capabilities on top of the existing one but doesn't bring any changes into the flock call semantic.
>>
>> These flags can be used by NFS (built-in-kernel) and CIFS (Samba) servers and Wine applications through VFS (for local filesystems) or CIFS/NFS modules. This will help when e.g. Samba and NFS server share the same directory for Windows and Linux users or Wine applications use Samba/NFS share to access the same data from different clients.
>>
>> According to the previous discussions the most problematic question is how to prevent situations like DoS attacks where e.g /lib/liba.so file can be open with DENYREAD, or smth like this. That's why one extra flag O_DENYMAND is added. It indicates to underlying layer that an application want to use O_DENY* flags semantic. It allows us not affect native Linux applications (that don't use O_DENYMAND flag) - so, these flags (and the semantic of open syscall that they bring) are used only for those applications that really want it proccessed that way.
>>
>> So, we have four new flags:
>> O_DENYREAD - to prevent other opens with read access,
>> O_DENYWRITE - to prevent other opens with write access,
>> O_DENYDELETE - to prevent delete operations (this flag is not implemented in VFS and NFS part and only suitable for CIFS module),
>> O_DENYMAND - to switch on/off three flags above.
>
> O_DENYMAND doesn't deny anything.  Would a name like O_RESPECT_DENY be
> better?
>
> Other than that, this seems like a sensible mechanism.

I don't mind to rename it. Your suggestion looks ok to me, thanks.

-- 
Best regards,
Pavel Shilovsky.
