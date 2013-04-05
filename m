Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:63121 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162306Ab3DESLu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2013 14:11:50 -0400
MIME-Version: 1.0
In-Reply-To: <1365181075-22540-1-git-send-email-piastry@etersoft.ru>
References: <1365181075-22540-1-git-send-email-piastry@etersoft.ru>
Date: Fri, 5 Apr 2013 22:11:50 +0400
Message-ID: <CAKywueQc9h-BiYvNRZsXEY9FNCx1Xbh25q0KNbMHn9KWMMSyjA@mail.gmail.com>
Subject: Re: [PATCH v4 0/7] Add O_DENY* support for VFS and CIFS/NFS
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs <linux-cifs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        wine-devel@winehq.org
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/4/5 Pavel Shilovsky <piastry@etersoft.ru>:
> Main changes from the previous one:
> 1) O_DENYMAND is removed, sharelock mount option is introduced.
> 2) Patch fcntl.h and VFS patches are united into one.
> 3) flock/LOCK_MAND is disabled for sharelock mounts.
>
> This patchset adds support of O_DENY* flags for Linux fs layer. These flags can be used by any application that needs share reservations to organize a file access. VFS already has some sort of this capability - now it's done through flock/LOCK_MAND mechanis, but that approach is non-atomic. This patchset build new capabilities on top of the existing one but doesn't bring any changes into the flock call semantic.
>
> These flags can be used by NFS (built-in-kernel) and CIFS (Samba) servers and Wine applications through VFS (for local filesystems) or CIFS/NFS modules. This will help when e.g. Samba and NFS server share the same directory for Windows and Linux users or Wine applications use Samba/NFS share to access the same data from different clients.
>
> According to the previous discussions the most problematic question is how to prevent situations like DoS attacks where e.g /lib/liba.so file can be open with DENYREAD, or smth like this. That's why extra mount option 'sharelock' is added for switching on/off O_DENY* flags processing. It allows us to avoid use of these flags on critical places (like /, /lib) and turn them on if we really want it proccessed that way.
>
> So, we have 3 new flags:
> O_DENYREAD - to prevent other opens with read access,
> O_DENYWRITE - to prevent other opens with write access,
> O_DENYDELETE - to prevent delete operations (this flag is not implemented in VFS and NFS part and only suitable for CIFS module),
>
> The patchset avoid data races problem on newely created files: open with O_CREAT can return the -ETXTBSY error for a successfully created file if this files was locked with a deny lock by another task. Also, it turns flock/LOCK_MAND capability off for mounts with 'sharelock' option. This let us not mix one share reservation approach with another.
>
> The #1 patch adds flags to fcntl and implements VFS part. The patches #3, #4, #5 are related to CIFS-specific changes, #6 and #7 describe NFS and NFSD parts.
>
> The preliminary patch for Samba that replaces the existing use of flock/LOCK_MAND mechanism with O_DENY* flags:
> http://git.etersoft.ru/people/piastry/packages/?p=samba.git;a=commitdiff;h=173070262b7f29134ad6b2e49a760017c11aec4a
>
> The future part of open man page patch:
>
> -----
> O_DENYREAD, O_DENYWRIYE, O_DENYDELETE - used to inforce a mandatory share reservation scheme of the file access. If these flag is passed, the open fails with -EBUSY in following cases:
> 1) if O_DENYREAD flag is specified and there is another open with O_DENYMAND flag and READ access to the file;
> 2) if O_DENYWRITE flag is specified and there is another open with O_DENYMAND flag and WRITE access to the file;
> 3) if READ access is requested and there is another open with O_DENYMAND and O_DENYREAD flags;
> 4) if WRITE access is requested and there is another open with O_DENYMAND and O_DENYWRITE flags.

Should be without O_DENYMAND (copy-and-paste issue, sorry):
1) if O_DENYREAD flag is specified and there is another open with READ
access to the file;
2) if O_DENYWRITE flag is specified and there is another open with
WRITE access to the file;
3) if READ access is requested and there is another open with O_DENYREAD flags;
4) if WRITE access is requested and there is another open with
O_DENYWRITE flags.

--
Best regards,
Pavel Shilovsky.
