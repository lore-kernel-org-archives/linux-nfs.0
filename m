Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54658 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752989AbcCBO13 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2016 09:27:29 -0500
Subject: Re: [PATCH 3/3] nfs: Store and use inode in nfs_open_context
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Goldwyn Rodrigues <rgoldwyn@suse.de>
References: <1456855928-29913-1-git-send-email-rgoldwyn@suse.de>
 <1456855928-29913-4-git-send-email-rgoldwyn@suse.de>
 <CAHQdGtRu2nd54+tKQLPp2tvf1MpKw4-X8ESqx-8W4_zAov7hFA@mail.gmail.com>
Cc: miklos@szeredi.hu, linux-unionfs@vger.kernel.org,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Message-ID: <56D6F84B.5040301@suse.de>
Date: Wed, 2 Mar 2016 08:27:23 -0600
MIME-Version: 1.0
In-Reply-To: <CAHQdGtRu2nd54+tKQLPp2tvf1MpKw4-X8ESqx-8W4_zAov7hFA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/01/2016 02:46 PM, Trond Myklebust wrote:
> On Tue, Mar 1, 2016 at 1:12 PM, Goldwyn Rodrigues <rgoldwyn@suse.de> wrote:
>>
>> From: Goldwyn Rodrigues <rgoldwyn@suse.com>
>>
>> NFS translates the inode from the dentry and uses sb from the dentry
>> parameters. However, using NFS in conjunction with overlayfs, the inodes
>> associated with dentries may be associated with overlayfs as opposed
>> to NFS. So, store inode in nfs_open_context and use d_select_inode()
>> to translate dentry to inode.
>
> I don't see how this helps. The dentry and dentry->d_sb that are
> associated with the open context need to be NFS namespace objects,
> otherwise all sorts of things, ranging from inode lookup to NFSv4
> state recovery are going to break.
>

dentry evaluations and inode lookups are done by overlayfs, with the 
help of NFS. NFS becomes a subset of overlayfs. However, you are right. 
state recovery will break with this patch.

Which makes me wonder: Shouldn't nfs_open_context (or any open context) 
be with respect to an inode as opposed to a dentry?

-- 
Goldwyn
