Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:33815 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379AbcCBOiE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Mar 2016 09:38:04 -0500
Received: by mail-oi0-f51.google.com with SMTP id m82so154147382oif.1
        for <linux-nfs@vger.kernel.org>; Wed, 02 Mar 2016 06:38:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSd8Sg-X7vGOJoVZZZZQFxfsdeOsHUcS5z09BOVwQ1pUw@mail.gmail.com>
References: <1456855928-29913-1-git-send-email-rgoldwyn@suse.de>
	<1456855928-29913-4-git-send-email-rgoldwyn@suse.de>
	<CAHQdGtRu2nd54+tKQLPp2tvf1MpKw4-X8ESqx-8W4_zAov7hFA@mail.gmail.com>
	<56D6F84B.5040301@suse.de>
	<CAHQdGtSd8Sg-X7vGOJoVZZZZQFxfsdeOsHUcS5z09BOVwQ1pUw@mail.gmail.com>
Date: Wed, 2 Mar 2016 09:38:02 -0500
Message-ID: <CAHQdGtR1Ywp9JnO7mD5-tOy5wngsgp2OZBJyQx1hyaXpTNc54g@mail.gmail.com>
Subject: Re: [PATCH 3/3] nfs: Store and use inode in nfs_open_context
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: miklos@szeredi.hu, linux-unionfs@vger.kernel.org,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 2, 2016 at 9:31 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Wed, Mar 2, 2016 at 9:27 AM, Goldwyn Rodrigues <rgoldwyn@suse.de> wrote:
>>
>>
>>
>> On 03/01/2016 02:46 PM, Trond Myklebust wrote:
>>>
>>> On Tue, Mar 1, 2016 at 1:12 PM, Goldwyn Rodrigues <rgoldwyn@suse.de> wrote:
>>>>
>>>>
>>>> From: Goldwyn Rodrigues <rgoldwyn@suse.com>
>>>>
>>>> NFS translates the inode from the dentry and uses sb from the dentry
>>>> parameters. However, using NFS in conjunction with overlayfs, the inodes
>>>> associated with dentries may be associated with overlayfs as opposed
>>>> to NFS. So, store inode in nfs_open_context and use d_select_inode()
>>>> to translate dentry to inode.
>>>
>>>
>>> I don't see how this helps. The dentry and dentry->d_sb that are
>>> associated with the open context need to be NFS namespace objects,
>>> otherwise all sorts of things, ranging from inode lookup to NFSv4
>>> state recovery are going to break.
>>>
>>
>> dentry evaluations and inode lookups are done by overlayfs, with the help of NFS. NFS becomes a subset of overlayfs. However, you are right. state recovery will break with this patch.
>>
>> Which makes me wonder: Shouldn't nfs_open_context (or any open context) be with respect to an inode as opposed to a dentry?
>
> No. It is designed the way it is precisely because it needs namespace
> information.

IOW: this has never been intended to be an overlayfs object. It needs
to reflect the _real_ NFS namespace for various reasons (including
recovery).
