Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f52.google.com ([209.85.212.52]:57053 "EHLO
	mail-vb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756878Ab3AQAa2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jan 2013 19:30:28 -0500
Received: by mail-vb0-f52.google.com with SMTP id ez10so1940346vbb.39
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jan 2013 16:30:27 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 16 Jan 2013 19:30:26 -0500
Message-ID: <CAEaabxN7RnebVRwj5_QiUk99xHJAxEOOkBDj5j6Zm-Lik_rLOw@mail.gmail.com>
Subject: Re: (Regression?) NFSv3 client not handling all cookies in
 readdirplus reply
From: Jesse Jarzynka <jessejoe@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This issue appears to have been a result of this commit:

NFS: add readdir cache array -
https://github.com/torvalds/linux/commit/d1bacf9eb2fd0e7ef870acf84b9e3b157dcfa7dc

I've compiled the kernel before and after this change. Before the
change, all cookies are handled each readdirplus reply are handled by
the client. After this commit, the NFS client is discarding any
cookies in a readdirplus reply after a page is filled.

I can see each readdirplus call completing successfully and lining up
with all cookies in the replies in my packet capture (rpcdebug):

Jan 16 16:46:11 jesse-centos5-client kernel: NFS: readdir(/mpc)
starting at cookie 0
Jan 16 16:46:11 jesse-centos5-client kernel: NFS: (0:19/8888) data
cache invalidated
Jan 16 16:46:11 jesse-centos5-client kernel: NFS call  readdirplus 0
Jan 16 16:46:11 jesse-centos5-client kernel: NFS:
nfs_update_inode(0:19/8888 ct=1 info=0x7e7f)
Jan 16 16:46:11 jesse-centos5-client kernel: NFS reply readdirplus: 16
Jan 16 16:46:11 jesse-centos5-client kernel: NFS call  readdirplus 16
Jan 16 16:46:11 jesse-centos5-client kernel: NFS:
nfs_update_inode(0:19/8888 ct=1 info=0x7e7f)
Jan 16 16:46:11 jesse-centos5-client kernel: NFS reply readdirplus: 16
Jan 16 16:46:11 jesse-centos5-client kernel: NFS call  readdirplus 32
Jan 16 16:46:11 jesse-centos5-client kernel: NFS:
nfs_update_inode(0:19/8888 ct=1 info=0x7e7f)
Jan 16 16:46:11 jesse-centos5-client kernel: NFS reply readdirplus: 16
Jan 16 16:46:11 jesse-centos5-client kernel: NFS call  readdirplus 48
Jan 16 16:46:11 jesse-centos5-client kernel: NFS:
nfs_update_inode(0:19/8888 ct=1 info=0x7e7f)
Jan 16 16:46:11 jesse-centos5-client kernel: NFS reply readdirplus: 16
Jan 16 16:46:11 jesse-centos5-client kernel: NFS call  readdirplus 64
Jan 16 16:46:11 jesse-centos5-client kernel: NFS:
nfs_update_inode(0:19/8888 ct=1 info=0x7e7f)
Jan 16 16:46:11 jesse-centos5-client kernel: NFS reply readdirplus: 16
Jan 16 16:46:11 jesse-centos5-client kernel: NFS call  readdirplus 80
Jan 16 16:46:11 jesse-centos5-client kernel: NFS:
nfs_update_inode(0:19/8888 ct=1 info=0x7e7f)
Jan 16 16:46:11 jesse-centos5-client kernel: NFS reply readdirplus: 16
Jan 16 16:46:11 jesse-centos5-client kernel: NFS call  readdirplus 96
Jan 16 16:46:11 jesse-centos5-client kernel: NFS:
nfs_update_inode(0:19/8888 ct=1 info=0x7e7f)
Jan 16 16:46:11 jesse-centos5-client kernel: NFS reply readdirplus: 16
Jan 16 16:46:11 jesse-centos5-client kernel: NFS call  readdirplus 112
Jan 16 16:46:11 jesse-centos5-client kernel: NFS:
nfs_update_inode(0:19/8888 ct=1 info=0x7e7f)
Jan 16 16:46:11 jesse-centos5-client kernel: NFS reply readdirplus: 16

At cookie 127, the page is full and nfs_do_filldir() is called:

Jan 16 16:46:11 jesse-centos5-client kernel: NFS: nfs_do_filldir()
filling ended @ cookie 127; returning = 0
Jan 16 16:46:11 jesse-centos5-client kernel: NFS call  readdirplus 127

However in the packet capture, I can see cookie 127 was not the last
cookie returned, cookie 4096 was:

Network File System, READDIRPLUS Reply
        Cookie: 113
        Cookie: 114
        Cookie: 115
        Cookie: 116
        Cookie: 117
        Cookie: 118
        Cookie: 119
        Cookie: 120
        Cookie: 121
        Cookie: 122
        Cookie: 123
        Cookie: 124
        Cookie: 125
        Cookie: 126
        Cookie: 127
        Cookie: 4096
Frame 1695 (238 bytes on wire, 238 bytes captured)
Remote Procedure Call, Type:Call XID:0x9020b79f
    Message Type: Call (0)

So cookie 4096 is ignored, and the next call starts at cookie 127:

Network File System, READDIRPLUS Call FH:0xe3a52499
    cookie: 127

This is not such a big deal with these 512/4096k dircount/maxcounts,
however in the newer kernels with dircount/maxcount set to 4k/32k,
many more cookies are ignored (as described in my original email). In
that case 28 of ~129 cookies were ignored (22%) as a result. I've
confirmed this is even the case in the latest stable kernel v3.7.2.

This seems very inefficient especially in scenarios with higher
latencies between the server and client, such as over a WAN.

Can anyone confirm if this was a unintended side effect or if there is
a benefit to doing it this way?

Thanks,

-Jesse

On Fri, Jan 11, 2013 at 11:56 AM, Jesse Jarzynka <jessejoe@gmail.com> wrote:
> Hi all,
>
> I noticed that when doing a readdirplus on the latest CentOS 6 stable
> kernel (2.6.32-279.19.1), the client, instead of sending the next call
> with the last cookie from the previous reply, is starting with a
> cookie somewhere in the middle of the previous reply. On a slightly
> earlier CentOS 6 kernel (2.6.32-71) I am not seeing this behavior. The
> readdirplus calls are always starting with the last cookie returned.
>
> To reproduce, I have an NFS server mounted at /mnt/jesse with '-o
> nfsvers=3'. I have a directory inside with 1000 empty files. If i run
> a simple 'ls -lh' on the directory and take a packet capture, I can
> see the first readdirplus call start at cookie 0, and end with cookie
> 4096:
>
> $ tshark -r tshark.pcap -V -R 'nfs.procedure_v3 == 17' | egrep -i
> '^frame|cookie'
> Frame 524 (238 bytes on wire, 238 bytes captured)
>     cookie: 0
> Frame 546 (402 bytes on wire, 402 bytes captured)
>         Cookie: 1
>         Cookie: 2
>         Cookie: 3
>         Cookie: 4
>         Cookie: 5
>         Cookie: 6
> <snip>
>         Cookie: 101
>         Cookie: 102
>         Cookie: 103
>         Cookie: 104
>         Cookie: 105
>         Cookie: 106
>         Cookie: 107
>         Cookie: 108
>         Cookie: 109
>         Cookie: 110
>         Cookie: 111
>         Cookie: 112
>         Cookie: 113
>         Cookie: 114
>         Cookie: 115
>         Cookie: 116
>         Cookie: 117
>         Cookie: 118
>         Cookie: 119
>         Cookie: 120
>         Cookie: 121
>         Cookie: 122
>         Cookie: 123
>         Cookie: 124
>         Cookie: 125
>         Cookie: 126
>         Cookie: 127
>         Cookie: 4096
>
> However the next call starts at cookie 102:
>
> Frame 547 (238 bytes on wire, 238 bytes captured)
>     cookie: 102
>
> This cycle repeats itself over and over, with the client seemingly
> disregarding many of the cookies returned at the end of the
> readdirplus replies. Looking at rpcdebug I can see the client thinks
> the filling has ended:
>
> Jan 10 22:36:47 jesse-centos-client kernel: NFS: dentry_delete(mpc/file_99, 8)
> Jan 10 22:36:47 jesse-centos-client kernel: NFS:
> nfs_update_inode(0:14/28512 ct=1 info=0x7e7f)
> Jan 10 22:36:47 jesse-centos-client kernel: NFS: dentry_delete(mpc/file_100, 8)
> Jan 10 22:36:47 jesse-centos-client kernel: NFS:
> nfs_update_inode(0:14/28513 ct=1 info=0x7e7f)
> Jan 10 22:36:47 jesse-centos-client kernel: NFS: dentry_delete(mpc/file_101, 8)
> Jan 10 22:36:47 jesse-centos-client kernel: NFS: nfs_do_filldir()
> filling ended @ cookie 102; returning = 0
> Jan 10 22:36:47 jesse-centos-client kernel: NFS call  readdirplus 102
> Jan 10 22:36:47 jesse-centos-client kernel: NFS:
> nfs_update_inode(0:14/8888 ct=1 info=0x7e7f)
> Jan 10 22:36:47 jesse-centos-client kernel: NFS reply readdirplus: 20488
> Jan 10 22:36:47 jesse-centos-client kernel: NFS:
> nfs_update_inode(0:14/28513 ct=1 info=0x7e7f)
>
> If I boot into an older kernel from CentOS, this behavior does not
> occur, I'm using the exact same mount options and procedure:
>
> $ tshark -r tshark.pcap -V -R 'nfs.procedure_v3 == 17' | egrep -i
> '^frame|cookie'
> Frame 1524 (238 bytes on wire, 238 bytes captured)
>     cookie: 0
> Frame 1526 (1306 bytes on wire, 1306 bytes captured)
>         Cookie: 1
>         Cookie: 2
>         Cookie: 3
>         Cookie: 4
>         Cookie: 5
>         Cookie: 6
>         Cookie: 7
>         Cookie: 8
>         Cookie: 9
>         Cookie: 10
>         Cookie: 11
>         Cookie: 12
>         Cookie: 13
>         Cookie: 14
>         Cookie: 15
>         Cookie: 16
> Frame 1529 (238 bytes on wire, 238 bytes captured)
>     cookie: 16
>
> Obviously many less entries returned (this appears to be as a result
> of dircount and maxcount changing between versions), but the cookie in
> every call is the same as the last cookie of the previous reply.
>
> I'm wondering if this was by design and has some benefit I'm not aware
> of, or if this is a bug?
>
> Thanks,
>
> -Jesse
