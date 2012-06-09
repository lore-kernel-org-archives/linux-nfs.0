Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linuxfoundation.org ([140.211.169.12]:35630 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932112Ab2FIA16 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jun 2012 20:27:58 -0400
Date: Fri, 8 Jun 2012 17:28:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
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
Subject: Re: [RFC, PATCH, RESEND] fs: push rcu_barrier() from
 deactivate_locked_super() to filesystems
Message-Id: <20120608172842.9826b5cd.akpm@linux-foundation.org>
In-Reply-To: <CA+55aFw5k3daxeoZb9H1HGcOCWjPF+d7inSbf0QHmG-atp4reQ@mail.gmail.com>
References: <1339191663-17693-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20120608150253.e42464a6.akpm@linux-foundation.org>
	<20120608221446.GA18250@otc-wbsnb-06>
	<20120608152550.258d6a30.akpm@linux-foundation.org>
	<20120608222734.GT30000@ZenIV.linux.org.uk>
	<20120608153120.b722d7c3.akpm@linux-foundation.org>
	<20120608233127.GB18981@otc-wbsnb-06>
	<20120608163751.7a8ec2bc.akpm@linux-foundation.org>
	<CA+55aFw5k3daxeoZb9H1HGcOCWjPF+d7inSbf0QHmG-atp4reQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 8 Jun 2012 16:46:47 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> Of course, if you just mean having a VFS wrapper that does
> 
>     static void vfs_inode_kmem_cache_destroy(struct kmem_cache *cachep)
>     {
>         rcu_barrier();
>         kmem_cache_destroy(cachep);
>     }
> 
> then we could do that. Not much better than what Kirill's patch did,
> but at least we could have that comment in just one single place.

That's conceptually what I meant.  But it has the problem that new and
out-of-tree filesystems might forget to do it.  Which is why I suggest
adding a kmem_cache* argument to unregister_filesystem() for this.

It's a bit awkward, and the fs can pass in NULL if it knows what it's
doing.  But it's reliable.
