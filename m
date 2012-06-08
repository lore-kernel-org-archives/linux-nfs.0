Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:64318 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761647Ab2FHXrL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jun 2012 19:47:11 -0400
MIME-Version: 1.0
In-Reply-To: <20120608163751.7a8ec2bc.akpm@linux-foundation.org>
References: <1339191663-17693-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120608150253.e42464a6.akpm@linux-foundation.org> <20120608221446.GA18250@otc-wbsnb-06>
 <20120608152550.258d6a30.akpm@linux-foundation.org> <20120608222734.GT30000@ZenIV.linux.org.uk>
 <20120608153120.b722d7c3.akpm@linux-foundation.org> <20120608233127.GB18981@otc-wbsnb-06>
 <20120608163751.7a8ec2bc.akpm@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 8 Jun 2012 16:46:47 -0700
Message-ID: <CA+55aFw5k3daxeoZb9H1HGcOCWjPF+d7inSbf0QHmG-atp4reQ@mail.gmail.com>
Subject: Re: [RFC, PATCH, RESEND] fs: push rcu_barrier() from
 deactivate_locked_super() to filesystems
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
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
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 8, 2012 at 4:37 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> So how about open-coding the rcu_barrier() in btrfs and gfs2 for the
> non-inode caches (which is the appropriate place), and hand the inode
> cache over to the vfs for treatment (which is the appropriate place).

The thing is, none of the inode caches are really up to the VFS. They
are per-filesystem caches, that just *embed* an inode as part of the
bigger ext4_inode or whatever. But apart from the fact that the
embedded inode requires them to then use the proper "call_rcu()" stuff
to do the delayed free, they really are pretty much filesystem data
structures. The VFS layer can neither free them or allocate them,
since the VFS layer doesn't even know how big the structures are, or
where the inodes are embedded, or how to initialize them (or even when
to allocate them).

Of course, if you just mean having a VFS wrapper that does

    static void vfs_inode_kmem_cache_destroy(struct kmem_cache *cachep)
    {
        rcu_barrier();
        kmem_cache_destroy(cachep);
    }

then we could do that. Not much better than what Kirill's patch did,
but at least we could have that comment in just one single place.

                Linus
