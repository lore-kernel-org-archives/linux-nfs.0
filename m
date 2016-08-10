Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35756 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932601AbcHJTPO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2016 15:15:14 -0400
MIME-Version: 1.0
In-Reply-To: <20160810190915.GA22411@pad>
References: <20160810053947.GG21941@yexl-desktop> <CA+55aFxdcG4y4zWTFFT8SekEtxsvx12P+e=11kTCFc=zS__bXQ@mail.gmail.com>
 <dc406145-b465-b7e9-e370-91910abb8e6a@fb.com> <CA+55aFzdTMBc7f5=bQLRUtceu-Kg-MGmzWrAv1r96_ra8yutJA@mail.gmail.com>
 <e6fb50d4-2a27-13cd-02c8-5b8439a16b3f@fb.com> <CA+55aFw5DczMkEYP47h=-9f6U2V5aQUhSxqPjtTbNp1Dd=gZwQ@mail.gmail.com>
 <20160810190915.GA22411@pad>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 10 Aug 2016 12:15:13 -0700
Message-ID: <CA+55aFxft5RGiJMyZjS6BQmz-LpdSAnZEBwdhWi45wopo2t8OA@mail.gmail.com>
Subject: Re: [lkp] [nfsd] b44061d0b9: BUG: Dentry ffff880027d7c540{i=1846f,n=0a}
 still in use (1) [unmount of btrfs vda]
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Josef Bacik <jbacik@fb.com>, kernel test robot <xiaolong.ye@intel.com>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        David Sterba <dsterba@suse.com>, LKML <linux-kernel@vger.kernel.org>,
        LKP <lkp@01.org>, linux-btrfs <linux-btrfs@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 10, 2016 at 12:09 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>
> OK with me if you want to take it, otherwise I'll run it through my
> usual tests and send you a pull request probably today or tomorrow.

I'll let it go through your tree and your usual tests - it's not like
this seems to be a "needs to be in my tree *IMMEDIATELY* or the world
will end!!!11!" kind of issue.

Thanks everybody,

                 Linus
