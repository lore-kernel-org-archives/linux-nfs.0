Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933Ab1CUTEO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2011 15:04:14 -0400
Message-ID: <4D87A12A.60209@RedHat.com>
Date: Mon, 21 Mar 2011 15:04:10 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Karel Zak <kzak@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: mount.nfs libmount support (v3)
References: <1300111108-13137-1-git-send-email-kzak@redhat.com>
In-Reply-To: <1300111108-13137-1-git-send-email-kzak@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Karel,

On 03/14/2011 09:58 AM, Karel Zak wrote:
> This is the third version of the mount.nfs with libmount support. The code
> depends on util-linux >= v2.19 (e.g. Fedora 15).
> 
> v3:
>   - call umount_error() on mount(2) error
> 
> v2:
>   - move nfs_umount_do_umnt() to network.c
>   - use union nfs_sockaddr
>   - add missing GPL address paragraph
>   - use abstract function the storing and retrieval mount options
>   - use "static const" for struct option
>   - use "strncmp() == 0" everywhere
> 
> 
Looking at unmounting a non-existent fs I get:

# umount.nfs /mnt/home
umount.nfs: remote share not in 'host:dir' format
umount.nfs: /mnt/home: not mounted
#
I took a quick look as to why that incorrect "remote share...." 
is message is being generated and why it wasn't in the
previous code.

The message is being generated because nfs_umount23() is
is passed an invalid devname ('/mnt/home' in my case).
The reason the message was not being generated before
is because nfs_umount23() was not called when the devname
did not exist in the mtab.

Now, I understand the umount(2) system call still has to
occur when the devname is not found in the mtab. This happen
the previous code because del_mtab() was called  (which calls 
umount(2)) even when the devname was not in the mtab.

I also notice that the libmount code does indeed  know the devname 
is not in the mtab. The lookup_umount_fs() call fails which is in 
the mnt_context_prepare_umount() call... But, rightly so, you continue 
to process the umount. Plus the umount(2) is done during the 
mnt_context_do_umount() call which ends up generating the correct
"not mounted" message.

So my question is, is there some why I can tell, using the libmount
API, that the fs was not in either /proc/mounts or /etc/mtab?

Basically I do not want to call nfs_umount23() but I do want
to call mnt_context_do_umount() when the file system is not
in the mtab, similar to how it worked in the previous code.

steved.

