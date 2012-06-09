Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linuxfoundation.org ([140.211.169.12]:37263 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250Ab2FIHZO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Jun 2012 03:25:14 -0400
Date: Sat, 9 Jun 2012 00:25:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Marco Stornelli <marco.stornelli@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Al Viro <viro@zeniv.linux.org.uk>, Boaz Harrosh <bharrosh@panasas.com>,
        Tao Ma <boyu.mt@taobao.com>, Nick Piggin <npiggin@kernel.dk>,
        "Dmitry V. Levin" <ldv@altlinux.org>,
        v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        codalist@telemann.coda.cs.cmu.edu, ecryptfs@vger.kernel.org,
        osd-dev@open-osd.org, linux-ext4@vger.kernel.org,
        fuse-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        jfs-discussion@lists.sourceforge.net, logfs@logfs.org,
        linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        linux-ntfs-dev@lists.sourceforge.net, ocfs2-devel@oss.oracle.com,
        reiserfs-devel@vger.kernel.org
Subject: Re: [RFC, PATCH, RESEND] fs: push rcu_barrier() from
 deactivate_locked_super() to filesystems
Message-Id: <20120609002557.b8aba759.akpm@linux-foundation.org>
In-Reply-To: <4FD2F5F4.1000106@gmail.com>
References: <1339191663-17693-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20120608150253.e42464a6.akpm@linux-foundation.org>
	<20120608221446.GA18250@otc-wbsnb-06>
	<20120608152550.258d6a30.akpm@linux-foundation.org>
	<20120608222734.GT30000@ZenIV.linux.org.uk>
	<20120608153120.b722d7c3.akpm@linux-foundation.org>
	<20120608233127.GB18981@otc-wbsnb-06>
	<20120608163751.7a8ec2bc.akpm@linux-foundation.org>
	<CA+55aFw5k3daxeoZb9H1HGcOCWjPF+d7inSbf0QHmG-atp4reQ@mail.gmail.com>
	<20120608172842.9826b5cd.akpm@linux-foundation.org>
	<4FD2F5F4.1000106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 09 Jun 2012 09:06:28 +0200 Marco Stornelli <marco.stornelli@gmail.com> wrote:

> Il 09/06/2012 02:28, Andrew Morton ha scritto:
> > On Fri, 8 Jun 2012 16:46:47 -0700 Linus Torvalds<torvalds@linux-foundation.org>  wrote:
> >
> >> Of course, if you just mean having a VFS wrapper that does
> >>
> >>      static void vfs_inode_kmem_cache_destroy(struct kmem_cache *cachep)
> >>      {
> >>          rcu_barrier();
> >>          kmem_cache_destroy(cachep);
> >>      }
> >>
> >> then we could do that. Not much better than what Kirill's patch did,
> >> but at least we could have that comment in just one single place.
> >
> > That's conceptually what I meant.  But it has the problem that new and
> > out-of-tree filesystems might forget to do it.  Which is why I suggest
> > adding a kmem_cache* argument to unregister_filesystem() for this.
> >
> > It's a bit awkward, and the fs can pass in NULL if it knows what it's
> > doing.  But it's reliable.
> > --
> 
> The call of rcu_barrier should be mandatory for the "unload fs module" 
> problem, right? If the fs is compiled statically maybe we could avoid 
> it, but (eventually) this kind of decision is per-fs, so this could be a 
> clue that the call of rcu_barrier maybe is inside each fs not in VFS.
> 

No, this is unrelated to module unloading and the problem affects
statically linked filesystems also.  The requirement is that all inodes
which are pending rcu freeing be flushed (and freed) before their cache
is destroyed in kmem_cache_destroy().

And...  it seems that I misread what's going on.  The individual
filesystems are doing the rcu freeing of their inodes, so it is
appropriate that they also call rcu_barrier() prior to running
kmem_cache_free().  Which is what Kirill's patch does.  oops.

