Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36175 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbcHJSGg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2016 14:06:36 -0400
MIME-Version: 1.0
In-Reply-To: <20160810053947.GG21941@yexl-desktop>
References: <20160810053947.GG21941@yexl-desktop>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 10 Aug 2016 11:06:35 -0700
Message-ID: <CA+55aFxdcG4y4zWTFFT8SekEtxsvx12P+e=11kTCFc=zS__bXQ@mail.gmail.com>
Subject: Re: [lkp] [nfsd] b44061d0b9: BUG: Dentry ffff880027d7c540{i=1846f,n=0a}
 still in use (1) [unmount of btrfs vda]
To: kernel test robot <xiaolong.ye@intel.com>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        linux-btrfs <linux-btrfs@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 9, 2016 at 10:39 PM, kernel test robot
<xiaolong.ye@intel.com> wrote:
>
> [ 1537.558739] nfsd: last server has exited, flushing export cache
> [ 1540.627795] BUG: Dentry ffff880027d7c540{i=1846f,n=0a}  still in use (1) [unmount of btrfs vda]
> [ 1540.633915] ------------[ cut here ]------------
> [ 1540.636551] WARNING: CPU: 0 PID: 20552 at fs/dcache.c:1474 umount_check+0x72/0x80

Hmm. Adding Al and the btrfs people to the cc, and expanding the nfs
list. Unlike the flakey-IO warning, this one sounds like a real issue.
Whether it's some dentry leak by nfsd or a VFS or btrfs issue, I can't
begin to guess. Al, ideas?

More information in the original email on lkml.

                 Linus
