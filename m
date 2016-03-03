Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:34581 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbcCCIQf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Mar 2016 03:16:35 -0500
Received: by mail-oi0-f42.google.com with SMTP id m82so10246783oif.1
        for <linux-nfs@vger.kernel.org>; Thu, 03 Mar 2016 00:16:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D70D64.9010705@suse.de>
References: <1456855928-29913-1-git-send-email-rgoldwyn@suse.de>
	<1456855928-29913-4-git-send-email-rgoldwyn@suse.de>
	<CAHQdGtRu2nd54+tKQLPp2tvf1MpKw4-X8ESqx-8W4_zAov7hFA@mail.gmail.com>
	<56D6F84B.5040301@suse.de>
	<CAHQdGtSd8Sg-X7vGOJoVZZZZQFxfsdeOsHUcS5z09BOVwQ1pUw@mail.gmail.com>
	<CAHQdGtR1Ywp9JnO7mD5-tOy5wngsgp2OZBJyQx1hyaXpTNc54g@mail.gmail.com>
	<CAJfpegvm_E_K6_wwvuWnnm-D=tBEY=dq_frp8UObUysS4_Pixg@mail.gmail.com>
	<56D70D64.9010705@suse.de>
Date: Thu, 3 Mar 2016 09:16:33 +0100
Message-ID: <CAJfpegtwDD4Qaect-5qzvG80vnn44iKawYCeTqQKneSK-FU3Lg@mail.gmail.com>
Subject: Re: [PATCH 3/3] nfs: Store and use inode in nfs_open_context
From: Miklos Szeredi <miklos@szeredi.hu>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        David Howells <dhowells@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 2, 2016 at 4:57 PM, Goldwyn Rodrigues <rgoldwyn@suse.de> wrote:
> On 03/02/2016 08:43 AM, Miklos Szeredi wrote:

>> Not sure how any dentry seen by NFS became associated with overlayfs.
>> Through ->f_path by any chance?
>>
>
> Yes, NFS extracts dentry from filp->f_path.dentry in fs/nfs/inode.c
> nfs_open(). What can it use to evaluate dentry?

Commit 4bacc9c9234c ("overlayfs: Make f_path always point to the
overlay and f_inode to the underlay") broke this.  Breakage only
affects regular files.  Accessing file->f_path.dentry->d_name (and
"%pD" format etc) is OK for everything.   ->d_fsdata is not OK.

I have no idea what the plan was with filesystems that use
f_path.dentry a separate open file for them.  David?  Al?

My plan was to introduce a file_dentry() helper that MUST be used by
filesystems to get the dentry from the file and that makes sure it's
the right one (check against file_inode()).   If not, then we could
call into overlayfs to return the right one, similar to
->d_select_inode(), except we want to have a dentry and we want to
have *a particular dentry* matching file_inode() (the file could have
been copied up in the mean time).

Thanks,
Miklos

Thanks,
Miklos
