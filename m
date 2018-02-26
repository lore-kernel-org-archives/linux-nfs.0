Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:45744 "EHLO
        mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752714AbeBZNvE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Feb 2018 08:51:04 -0500
MIME-Version: 1.0
In-Reply-To: <4b9de5cb-1366-a95c-118c-7b57042bf32e@suse.com>
References: <1519141810.8586.4.camel@venev.name> <2ce8eab1-8951-a1c7-d4fa-5f4f3201923d@suse.com>
 <1519646493.12248.7.camel@venev.name> <4b9de5cb-1366-a95c-118c-7b57042bf32e@suse.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 26 Feb 2018 15:51:03 +0200
Message-ID: <CAOQ4uxgnsXy7vOeVFzE0+x7amjzR20XMm-D_rT8hWfFPvz0pxQ@mail.gmail.com>
Subject: Re: btrfs_clone_files and bind mounts
To: Nikolay Borisov <nborisov@suse.com>
Cc: Hristo Venev <hristo@venev.name>,
        Linux Btrfs <linux-btrfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 26, 2018 at 3:01 PM, Nikolay Borisov <nborisov@suse.com> wrote:
> [CCing Amir since he touched precisely the code responsible for this
> semantics]

[CCing fsdevel and NFS list since there is already a long standing attempt
 to relax the copy_file_range() API for cross server copy]

>
> On 26.02.2018 14:01, Hristo Venev wrote:
>> On Tue, 2018-02-20 at 18:41 +0200, Nikolay Borisov wrote:
>>>
>>> On 20.02.2018 17:50, Hristo Venev wrote:
>>>> What is the problem with cloning files between different
>>>> (vfs)mounts of
>>>> the same filesystem?
>>>>
>>>
>>> The "problem" is not really a problem, but rather a well-imposed
>>> restriction:
>>>
>>> From  http://man7.org/linux/man-pages/man2/ioctl_ficlonerange.2.html
>>>
>>> "Both files must reside within the same filesystem."
>>>
>>> And as a matter of fact this is enforced in the generic
>>> vfs_clone_file_range. Of course if we were to do this across
>>> filesystem
>>> then we'd have all the problems associated with not being able to
>>> ensure
>>> atomicity of operations.
>>
>> My question was about doing this within the same filesystem. In my case
>> (and I think it's relatively common), subvolumes of the same filesystem
>> are mounted separately, and I can't think of a good reason why
>> FICLONERANGE can't be made to work (it works if the subvolumes are
>> accessed within the same mount point).
>>
>
> So Amir,
>
> In 913b86e92e1f ("vfs: allow vfs_clone_file_range() across mount
> points") you did relax the requirements of vfs_clone_file_range by
> moving the mount point check into ioctl_file_clone.

[...]
>
>
> Shouldn't reflinking be allowed in this case? ftrace shows that we are
> failing "if (src_file.file->f_path.mnt != dst_file->f_path.mnt)" in
> ioctl_file_clone
>
>
> In your commit you state:
>
> FICLONE/FICLONERANGE ioctls enforce that src and dest files are on
>  the same mount.
>
> Whereas the man page says they should be on the same filesystem (not
> necessarily on the same mount?)

See, all I did was avoid the flames involved with changing application
behavior, because I had no reason to change it.
Not that the man page is what matters, its what applications expect that
matter, but the man page also says this open for interpretation phrase:
EXDEV  dest_fd and src_fd are not on the same *mounted* filesystem.

NFS folks have been trying to change the behavior of copy_file_range()
for over two years now, we little success as far as I can tell:
https://marc.info/?l=linux-fsdevel&m=149971144627690&w=2

Semi-interesting point - it looks like this commit has changed behavior
of clone file range on CIFS:
04b38d601239 vfs: pull btrfs clone API to vfs layer

I don't see that CIFS has the "same mount" restriction before the
generalized VFS API, but btrfs had the restriction in-place and it still exists
in the btrfs implementation btrfs_clone_files().

So I think you will have no way around this other than proposing a new
ioctl FICLONERANGE2 with flags argument to opt-in for the new required
behavior. I you do that please CC linux-api and expect the flames.

Thanks,
Amir.
