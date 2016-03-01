Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:33858 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752870AbcCAUqt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Mar 2016 15:46:49 -0500
Received: by mail-ob0-f176.google.com with SMTP id ts10so178789659obc.1
        for <linux-nfs@vger.kernel.org>; Tue, 01 Mar 2016 12:46:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1456855928-29913-4-git-send-email-rgoldwyn@suse.de>
References: <1456855928-29913-1-git-send-email-rgoldwyn@suse.de>
	<1456855928-29913-4-git-send-email-rgoldwyn@suse.de>
Date: Tue, 1 Mar 2016 15:46:48 -0500
Message-ID: <CAHQdGtRu2nd54+tKQLPp2tvf1MpKw4-X8ESqx-8W4_zAov7hFA@mail.gmail.com>
Subject: Re: [PATCH 3/3] nfs: Store and use inode in nfs_open_context
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: miklos@szeredi.hu, linux-unionfs@vger.kernel.org,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Goldwyn Rodrigues <rgoldwyn@suse.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 1, 2016 at 1:12 PM, Goldwyn Rodrigues <rgoldwyn@suse.de> wrote:
>
> From: Goldwyn Rodrigues <rgoldwyn@suse.com>
>
> NFS translates the inode from the dentry and uses sb from the dentry
> parameters. However, using NFS in conjunction with overlayfs, the inodes
> associated with dentries may be associated with overlayfs as opposed
> to NFS. So, store inode in nfs_open_context and use d_select_inode()
> to translate dentry to inode.

I don't see how this helps. The dentry and dentry->d_sb that are
associated with the open context need to be NFS namespace objects,
otherwise all sorts of things, ranging from inode lookup to NFSv4
state recovery are going to break.

Trond
