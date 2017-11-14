Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:49512 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753018AbdKNSLj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Nov 2017 13:11:39 -0500
Received: by mail-ua0-f195.google.com with SMTP id u13so13521915uaf.6
        for <linux-nfs@vger.kernel.org>; Tue, 14 Nov 2017 10:11:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1E02EBE8-9BB2-4E60-BB4D-92843D5A0941@oracle.com>
References: <CAOapt6ko9Ue+Vf0TQNNNP+pSdbk09my_b9PjSF21Vg0v0nzAVw@mail.gmail.com>
 <1E02EBE8-9BB2-4E60-BB4D-92843D5A0941@oracle.com>
From: Anders Ossowicki <and@vmn.dk>
Date: Tue, 14 Nov 2017 19:11:38 +0100
Message-ID: <CAOapt6=TOF=Q0rCgQEm-EqML1XNDtWJgjcp7Z5_Qenp8RXMZpw@mail.gmail.com>
Subject: Re: nfsd returns NFSERR_STALE when the inode of the rootdir of the
 nfs mount is > 2^32
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 14 November 2017 at 18:12, Chuck Lever <chuck.lever@oracle.com> wrote:
> A fresh XFS file system can be mounted with the "inode32"
> mount option (on the server) to prevent the creation of
> inodes with numbers that cannot be represented in 32 bits.
>
> But since you already have such inodes, NFS clients will
> have to convert the numbers on the fly. You can use a boot
> parameter on your clients:
>
>   nfs.enable_ino64=0
>
> According to comments in fs/nfs/inode.c .

Thanks for the suggestion.

I looked at nfs.enable_ino64 while tracking down this issue, but it
looked like a client-side option to me, and the error happens in the
nfsd code. I'll give a shot tomorrow.

There's no problem accessing files or directories with inodes > 2^32 in
our setup, we've been doing that for years. It's only when the root
directory of the export has a high inode that we trigger this.

-- 
Anders Ossowicki
