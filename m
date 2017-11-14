Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30503 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754291AbdKNRMV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Nov 2017 12:12:21 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: nfsd returns NFSERR_STALE when the inode of the rootdir of the nfs mount is > 2^32
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAOapt6ko9Ue+Vf0TQNNNP+pSdbk09my_b9PjSF21Vg0v0nzAVw@mail.gmail.com>
Date: Tue, 14 Nov 2017 12:12:17 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1E02EBE8-9BB2-4E60-BB4D-92843D5A0941@oracle.com>
References: <CAOapt6ko9Ue+Vf0TQNNNP+pSdbk09my_b9PjSF21Vg0v0nzAVw@mail.gmail.com>
To: Anders Ossowicki <and@vmn.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 14, 2017, at 11:49 AM, Anders Ossowicki <and@vmn.dk> wrote:
> 
> If I export a directory that has an inode number > 2^32, the
> client-side mount succeeds, but any subsequent action gives a stale
> error.
> 
> $ sudo mount -t nfs svin:/z/svin/aowitest/foo /mnt
> $ ls /mnt
> ls: cannot access /mnt: Stale file handle
> 
> The underlying filesystem is XFS. The exported directory is not the
> root of that filesystem (hence the large inode number).
> 
> Server-side debug captures this:
> 
> nfsd_dispatch: vers 4 proc 1
> nfsv4 compound op #1/3: 22 (OP_PUTFH)
> svc: server ffff897ecc64e000, pool 0, transport ffff897eca7fd000, inuse=3
> nfsd: fh_verify(28: 00070001 400000c0 00000001 0f52f60a 63438e31 ab541493)
> nfsv4 compound op ffff897ecb6e9080 opcnt 3 #1: 22: status 70
> nfsv4 compound returned 70
> 
> I have worked around this by rmdir/mkdir'ing until I got an inode < 2^32.
> 
> This is only an issue with the inode of the / of the NFS exported path.
> 
> Have I overlooked a flag somewhere? Is this just impossible to fix
> without breaking the world?

A fresh XFS file system can be mounted with the "inode32"
mount option (on the server) to prevent the creation of
inodes with numbers that cannot be represented in 32 bits.

But since you already have such inodes, NFS clients will
have to convert the numbers on the fly. You can use a boot
parameter on your clients:

  nfs.enable_ino64=0

According to comments in fs/nfs/inode.c .


--
Chuck Lever



