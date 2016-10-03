Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35060 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751554AbcJCVEK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Oct 2016 17:04:10 -0400
MIME-Version: 1.0
In-Reply-To: <D21EA8F8-0A7A-4275-8D4C-E9CFCC2A7293@dilger.ca>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
 <20160429125813.23636.49830.stgit@warthog.procyon.org.uk> <D21EA8F8-0A7A-4275-8D4C-E9CFCC2A7293@dilger.ca>
From: Steve French <smfrench@gmail.com>
Date: Mon, 3 Oct 2016 16:03:49 -0500
Message-ID: <CAH2r5mv4WSM==ACMO2OZxF-GJgMqKE2Y0T08f3JoWCX5SM0VmQ@mail.gmail.com>
Subject: Re: [PATCH 5/6] statx: Make windows attributes available for CIFS,
 NTFS and FAT to use
To: Andreas Dilger <adilger@dilger.ca>
Cc: David Howells <dhowells@redhat.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-afs@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        samba-technical <samba-technical@lists.samba.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 2, 2016 at 5:52 PM, Andreas Dilger <adilger@dilger.ca> wrote:
> On Apr 29, 2016, at 6:58 AM, David Howells <dhowells@redhat.com> wrote:
>>
>> Make windows attributes available for CIFS, NTFS and FAT to use in the
>> statx struct.  The attribute flags map directly by value to those in the
>> CIFS PDU flags.  Some of these bits can also be used by JFS, UFS and HPFS.
>>
>> The statx struct acquires:
>>
>>       __u32   st_win_attrs;
>
> It seems some of these flags are duplicated with the st_information field,
> and some are duplicate with FS_IOC_GETFLAGS values, and returning the same
> information in multiple ways is confusing.
>
> If these flags are part of the CIFS protocol, and are directly usable by
> Samba then I can understand we wouldn't want to change them once in the
> kernel and then convert them back in userspace, but I'm a bit reluctant
> to have flags only for CIFS/NTFS/FAT that might also be useful for other filesystems.  Would we want to be able to get translated st_win_attrs
> flags in ext4 attrs when it is being exported by Samba?

It could be useful to have them in statx in an fs neutral way (and
could be implemented by CIFS/NTFS/FAT and probably NFS), but I am ok
with doing this via file system specific xattrs as we do now: NTFS has
an ntfs specific pseudo-xattr for these and for birth time (and now
cifs with recent patches can return the SMB3 inode attributes,
including the older DOS attributes noted below).  Samba server also
stores them in an xattr (although they ndr encode them so it is not
useful to us in the kernel) in local file systems.  NFS v4 (and later)
can also return (in theory) some of these flags but they are optional.

>> The value in this is present if STATX_WIN_ATTRS is set.
>>
>> The defined flags in this are:
>>
>>       STATX_WIN_ATTR_READONLY
>>       STATX_WIN_ATTR_HIDDEN
>>       STATX_WIN_ATTR_SYSTEM
>>       STATX_WIN_ATTR_DIRECTORY
>
> How does this differ from (st_mode & S_IFMT) == S_IFDIR)?
>
>>       STATX_WIN_ATTR_ARCHIVE
>>       STATX_WIN_ATTR_NORMAL
>
> How does this differ from (st_mode & S_IFMT) == S_IFREG)?
>
>>       STATX_WIN_ATTR_TEMPORARY
>
> How does this differ from STATX_INFO_TEMPORARY?
>
>>       STATX_WIN_ATTR_SPARSE_FILE
>>       STATX_WIN_ATTR_REPARSE_POINT
>>       STATX_WIN_ATTR_COMPRESSED
>>       STATX_WIN_ATTR_OFFLINE
>>       STATX_WIN_ATTR_NOT_CONTENT_INDEXED
>>       STATX_WIN_ATTR_ENCRYPTED
>
> How does this differ from STATX_INFO_ENCRYPTED?

As you noted, directory, compressed, encrypted overlap with existing
posix file type (directory vs. file) and FS_IOC_FLAGS (although
cifs.ko does not allow you to set encrypted yet as we do with
compressed through the IOC flags, I could add a patch for setting the
encrypted flag since it should be trivial as it does not affect
reads/writes/open/close over the network fs since the file would be
only encrypted at rest on the server fs)



-- 
Thanks,

Steve
