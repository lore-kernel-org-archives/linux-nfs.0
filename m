Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38720 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628Ab0KMLxP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Nov 2010 06:53:15 -0500
In-Reply-To: <20101112184353.GA32745@fieldses.org>
References: <20101112184353.GA32745@fieldses.org>
Date: Sat, 13 Nov 2010 22:53:12 +1100
Message-ID: <AANLkTinOSGtrW1S3LKWXarJF-=ZKgh_GMKuPA2ppu-P4@mail.gmail.com>
Subject: Re: lifetime of DCACHE_DISCONECTED dentries
From: Nick Piggin <npiggin@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Nov 13, 2010 at 5:43 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> DCACHE_DISCONECTED dentries aren't always getting destroyed as soon as
> I'd have expected in the NFSv4 case.
>
> I'm not sure what the right fix is; any ideas?  The below at least
> demonstrates the problem.
>
> --b.
>
> commit bb125ffbe5fc3f80ac7a5b20f51cc542c175cd49
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Thu Nov 11 19:22:00 2010 -0500
>
>    dput: free DCACHE_DISCONNECTED dentries sooner
>
>    DCACHE_DISCONECTED dentries are normally left around for the benefit of
>    future nfsd operations.  But there's no point keeping them around once
>    the inode has been deleted.
>
>    Without this patch
>
>        client$ mount -tnfs4 server:/export/ /mnt/
>        client$ tail -f /mnt/FOO
>        ...
>        server$ df -i /export
>        server$ rm /export/FOO
>        (^C the tail -f)
>        server$ df -i /export
>        server$ echo 2 >/proc/sys/vm/drop_caches
>        server$ df -i /export
>
>    the df's will show that the inode is not freed on the filesystem until
>    the last step, when it could have been freed after killing the client's
>    tail -f.  On-disk data won't be deallocated either, leading to possible
>    spurious ENOSPC.
>
>    This occurs because when the client does the close, it arrives in a
>    compound with a putfh and a close, processed like:
>
>        - putfh: look up the filehandle.  The only alias found for the
>          inode will be DCACHE_UNHASHED alias referenced by the filp
>          associated with the nfsd open.  d_obtain_alias() doesn't like
>          this, so it creates a new DCACHE_DISCONECTED dentry and
>          returns that instead.

This seems to be where the thing goes wrong. It isn't a hashed dentry at
this point here, so d_obtain_alias should not be making one.

I think the inode i_nlink games are much more appropriate on this side of
the equation, rather than the dput side (after all, d_obtain_alias is setting
up an alias for the inode).

Can you even put the link check into __d_find_alias?

-               if (S_ISDIR(inode->i_mode) || !d_unhashed(alias)) {
+               if (S_ISDIR(inode->i_mode) || !inode->i_nlink ||
!d_unhashed(alias)) {

Something like that?
