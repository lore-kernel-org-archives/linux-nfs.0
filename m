Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:56588 "EHLO
        mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750851AbdKNQtd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Nov 2017 11:49:33 -0500
Received: by mail-vk0-f51.google.com with SMTP id g11so12597384vkd.13
        for <linux-nfs@vger.kernel.org>; Tue, 14 Nov 2017 08:49:33 -0800 (PST)
MIME-Version: 1.0
From: Anders Ossowicki <and@vmn.dk>
Date: Tue, 14 Nov 2017 17:49:32 +0100
Message-ID: <CAOapt6ko9Ue+Vf0TQNNNP+pSdbk09my_b9PjSF21Vg0v0nzAVw@mail.gmail.com>
Subject: nfsd returns NFSERR_STALE when the inode of the rootdir of the nfs
 mount is > 2^32
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If I export a directory that has an inode number > 2^32, the
client-side mount succeeds, but any subsequent action gives a stale
error.

$ sudo mount -t nfs svin:/z/svin/aowitest/foo /mnt
$ ls /mnt
ls: cannot access /mnt: Stale file handle

The underlying filesystem is XFS. The exported directory is not the
root of that filesystem (hence the large inode number).

Server-side debug captures this:

nfsd_dispatch: vers 4 proc 1
nfsv4 compound op #1/3: 22 (OP_PUTFH)
svc: server ffff897ecc64e000, pool 0, transport ffff897eca7fd000, inuse=3
nfsd: fh_verify(28: 00070001 400000c0 00000001 0f52f60a 63438e31 ab541493)
nfsv4 compound op ffff897ecb6e9080 opcnt 3 #1: 22: status 70
nfsv4 compound returned 70

I have worked around this by rmdir/mkdir'ing until I got an inode < 2^32.

This is only an issue with the inode of the / of the NFS exported path.

Have I overlooked a flag somewhere? Is this just impossible to fix
without breaking the world?

-- 
Anders Ossowicki
