Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38686 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754937AbcCBP53 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2016 10:57:29 -0500
Subject: Re: [PATCH 3/3] nfs: Store and use inode in nfs_open_context
To: Miklos Szeredi <miklos@szeredi.hu>,
        Trond Myklebust <trond.myklebust@primarydata.com>
References: <1456855928-29913-1-git-send-email-rgoldwyn@suse.de>
 <1456855928-29913-4-git-send-email-rgoldwyn@suse.de>
 <CAHQdGtRu2nd54+tKQLPp2tvf1MpKw4-X8ESqx-8W4_zAov7hFA@mail.gmail.com>
 <56D6F84B.5040301@suse.de>
 <CAHQdGtSd8Sg-X7vGOJoVZZZZQFxfsdeOsHUcS5z09BOVwQ1pUw@mail.gmail.com>
 <CAHQdGtR1Ywp9JnO7mD5-tOy5wngsgp2OZBJyQx1hyaXpTNc54g@mail.gmail.com>
 <CAJfpegvm_E_K6_wwvuWnnm-D=tBEY=dq_frp8UObUysS4_Pixg@mail.gmail.com>
Cc: "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Message-ID: <56D70D64.9010705@suse.de>
Date: Wed, 2 Mar 2016 09:57:24 -0600
MIME-Version: 1.0
In-Reply-To: <CAJfpegvm_E_K6_wwvuWnnm-D=tBEY=dq_frp8UObUysS4_Pixg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/02/2016 08:43 AM, Miklos Szeredi wrote:
<snip>

>
>
> Not sure how any dentry seen by NFS became associated with overlayfs.
> Through ->f_path by any chance?
>

Yes, NFS extracts dentry from filp->f_path.dentry in fs/nfs/inode.c 
nfs_open(). What can it use to evaluate dentry?

-- 
Goldwyn
