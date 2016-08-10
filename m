Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35240 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965113AbcHJS4R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2016 14:56:17 -0400
MIME-Version: 1.0
In-Reply-To: <e6fb50d4-2a27-13cd-02c8-5b8439a16b3f@fb.com>
References: <20160810053947.GG21941@yexl-desktop> <CA+55aFxdcG4y4zWTFFT8SekEtxsvx12P+e=11kTCFc=zS__bXQ@mail.gmail.com>
 <dc406145-b465-b7e9-e370-91910abb8e6a@fb.com> <CA+55aFzdTMBc7f5=bQLRUtceu-Kg-MGmzWrAv1r96_ra8yutJA@mail.gmail.com>
 <e6fb50d4-2a27-13cd-02c8-5b8439a16b3f@fb.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 10 Aug 2016 11:56:15 -0700
Message-ID: <CA+55aFw5DczMkEYP47h=-9f6U2V5aQUhSxqPjtTbNp1Dd=gZwQ@mail.gmail.com>
Subject: Re: [lkp] [nfsd] b44061d0b9: BUG: Dentry ffff880027d7c540{i=1846f,n=0a}
 still in use (1) [unmount of btrfs vda]
To: Josef Bacik <jbacik@fb.com>
Cc: kernel test robot <xiaolong.ye@intel.com>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        David Sterba <dsterba@suse.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        linux-btrfs <linux-btrfs@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 10, 2016 at 11:46 AM, Josef Bacik <jbacik@fb.com> wrote:
>
> So my naive fix would be something like this

Bruce? Josef's patch looks ObviouslyCorrect(tm) to me now that I look
at it - all the other callers of fh_compose() also seem to just drop
the dentry unconditionally, knowing that fh_compose() took a ref to it
if needed.

In fact, the only thing I'd do differently would be to not even put
the comment there at all, since this call site isn't any different
from any of the others. If anything, it could go on fh_compose() if we
want to add comments.

             Linus
