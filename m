Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:46982 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932146AbcHKCT1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2016 22:19:27 -0400
Date: Thu, 11 Aug 2016 03:19:09 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Josef Bacik <jbacik@fb.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        kernel test robot <xiaolong.ye@intel.com>, Chris Mason <clm@fb.com>,
        David Sterba <dsterba@suse.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        linux-btrfs <linux-btrfs@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [lkp] [nfsd] b44061d0b9: BUG: Dentry
 ffff880027d7c540{i=1846f,n=0a} still in use (1) [unmount of btrfs vda]
Message-ID: <20160811021909.GR2356@ZenIV.linux.org.uk>
References: <20160810053947.GG21941@yexl-desktop>
 <CA+55aFxdcG4y4zWTFFT8SekEtxsvx12P+e=11kTCFc=zS__bXQ@mail.gmail.com>
 <dc406145-b465-b7e9-e370-91910abb8e6a@fb.com>
 <CA+55aFzdTMBc7f5=bQLRUtceu-Kg-MGmzWrAv1r96_ra8yutJA@mail.gmail.com>
 <e6fb50d4-2a27-13cd-02c8-5b8439a16b3f@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <e6fb50d4-2a27-13cd-02c8-5b8439a16b3f@fb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 10, 2016 at 02:46:27PM -0400, Josef Bacik wrote:
> On 08/10/2016 02:25 PM, Linus Torvalds wrote:
> > On Wed, Aug 10, 2016 at 11:22 AM, Josef Bacik <jbacik@fb.com> wrote:
> > > On 08/10/2016 02:06 PM, Linus Torvalds wrote:
> > > > 
> > > > More information in the original email on lkml.
> > > 
> > > I'm not subscribed to lkml and for some reason I can't find the original
> > > email in any of the lkml/linux-nfs archives.  Could you forward more of the
> > > details?
> > 
> > Done.
> > 
> 
> So my naive fix would be something like this
> 
> 
> From: Josef Bacik <jbacik@fb.com>
> Date: Wed, 10 Aug 2016 14:43:08 -0400
> Subject: [PATCH] nfsd: fix dentry refcounting problem
> 
> b44061d0b9 introduced a dentry ref counting bug, previously we were grabbing one
> ref to dchild in nfsd_create(), but with the creation of nfsd_create_locked() we
> have a ref for dchild from the lookup in nfsd_create(), and then another ref in
> nfsd_create_locked().  The ref from the lookup in nfsd_create() is never dropped
> and results in dentries still in use at unmount.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

[sorry, had been off-line since yesterday]

Patch looks sane; feel free to slap Acked-by: Al Viro <viro@zeniv.linux.org.uk>
on it.  I think it should go through nfsd tree.
