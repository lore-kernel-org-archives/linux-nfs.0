Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f48.google.com ([209.85.212.48]:45105 "EHLO
	mail-vb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753818Ab3AKQ47 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jan 2013 11:56:59 -0500
Received: by mail-vb0-f48.google.com with SMTP id fc21so1624529vbb.35
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jan 2013 08:56:58 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Jan 2013 11:56:58 -0500
Message-ID: <CAEaabxMbRuOeXKa84xyprpq-fiaOZ+jLw_1pt6ZOxoPeDyj6yQ@mail.gmail.com>
Subject: NFSv3 client not handling all cookies in readdirplus reply
From: Jesse Jarzynka <jessejoe@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I noticed that when doing a readdirplus on the latest CentOS 6 stable
kernel (2.6.32-279.19.1), the client, instead of sending the next call
with the last cookie from the previous reply, is starting with a
cookie somewhere in the middle of the previous reply. On a slightly
earlier CentOS 6 kernel (2.6.32-71) I am not seeing this behavior. The
readdirplus calls are always starting with the last cookie returned.

To reproduce, I have an NFS server mounted at /mnt/jesse with '-o
nfsvers=3'. I have a directory inside with 1000 empty files. If i run
a simple 'ls -lh' on the directory and take a packet capture, I can
see the first readdirplus call start at cookie 0, and end with cookie
4096:

$ tshark -r tshark.pcap -V -R 'nfs.procedure_v3 == 17' | egrep -i
'^frame|cookie'
Frame 524 (238 bytes on wire, 238 bytes captured)
    cookie: 0
Frame 546 (402 bytes on wire, 402 bytes captured)
        Cookie: 1
        Cookie: 2
        Cookie: 3
        Cookie: 4
        Cookie: 5
        Cookie: 6
<snip>
        Cookie: 101
        Cookie: 102
        Cookie: 103
        Cookie: 104
        Cookie: 105
        Cookie: 106
        Cookie: 107
        Cookie: 108
        Cookie: 109
        Cookie: 110
        Cookie: 111
        Cookie: 112
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

However the next call starts at cookie 102:

Frame 547 (238 bytes on wire, 238 bytes captured)
    cookie: 102

This cycle repeats itself over and over, with the client seemingly
disregarding many of the cookies returned at the end of the
readdirplus replies. Looking at rpcdebug I can see the client thinks
the filling has ended:

Jan 10 22:36:47 jesse-centos-client kernel: NFS: dentry_delete(mpc/file_99, 8)
Jan 10 22:36:47 jesse-centos-client kernel: NFS:
nfs_update_inode(0:14/28512 ct=1 info=0x7e7f)
Jan 10 22:36:47 jesse-centos-client kernel: NFS: dentry_delete(mpc/file_100, 8)
Jan 10 22:36:47 jesse-centos-client kernel: NFS:
nfs_update_inode(0:14/28513 ct=1 info=0x7e7f)
Jan 10 22:36:47 jesse-centos-client kernel: NFS: dentry_delete(mpc/file_101, 8)
Jan 10 22:36:47 jesse-centos-client kernel: NFS: nfs_do_filldir()
filling ended @ cookie 102; returning = 0
Jan 10 22:36:47 jesse-centos-client kernel: NFS call  readdirplus 102
Jan 10 22:36:47 jesse-centos-client kernel: NFS:
nfs_update_inode(0:14/8888 ct=1 info=0x7e7f)
Jan 10 22:36:47 jesse-centos-client kernel: NFS reply readdirplus: 20488
Jan 10 22:36:47 jesse-centos-client kernel: NFS:
nfs_update_inode(0:14/28513 ct=1 info=0x7e7f)

If I boot into an older kernel from CentOS, this behavior does not
occur, I'm using the exact same mount options and procedure:

$ tshark -r tshark.pcap -V -R 'nfs.procedure_v3 == 17' | egrep -i
'^frame|cookie'
Frame 1524 (238 bytes on wire, 238 bytes captured)
    cookie: 0
Frame 1526 (1306 bytes on wire, 1306 bytes captured)
        Cookie: 1
        Cookie: 2
        Cookie: 3
        Cookie: 4
        Cookie: 5
        Cookie: 6
        Cookie: 7
        Cookie: 8
        Cookie: 9
        Cookie: 10
        Cookie: 11
        Cookie: 12
        Cookie: 13
        Cookie: 14
        Cookie: 15
        Cookie: 16
Frame 1529 (238 bytes on wire, 238 bytes captured)
    cookie: 16

Obviously many less entries returned (this appears to be as a result
of dircount and maxcount changing between versions), but the cookie in
every call is the same as the last cookie of the previous reply.

I'm wondering if this was by design and has some benefit I'm not aware
of, or if this is a bug?

Thanks,

-Jesse
