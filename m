Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:49211 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757816Ab2FHWZj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jun 2012 18:25:39 -0400
Date: Fri, 8 Jun 2012 23:25:33 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Boaz Harrosh <bharrosh@panasas.com>, Tao Ma <boyu.mt@taobao.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Nick Piggin <npiggin@kernel.dk>, "Dmitry V. Levin" <ldv@altlinux.org>,
        v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        codalist@TELEMANN.coda.cs.cmu.edu, ecryptfs@vger.kernel.org,
        osd-dev@open-osd.org, linux-ext4@vger.kernel.org,
        fuse-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        jfs-discussion@lists.sourceforge.net, logfs@logfs.org,
        linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        linux-ntfs-dev@lists.sourceforge.net, ocfs2-devel@oss.oracle.com,
        reiserfs-devel@vger.kernel.org
Subject: Re: [RFC, PATCH] fs: push rcu_barrier() from
 deactivate_locked_super() to filesystems
Message-ID: <20120608222533.GS30000@ZenIV.linux.org.uk>
References: <1339191663-17693-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120608220049.GA18024@otc-wbsnb-06>
 <CA+55aFxbEk0k0jYtkn-H-sT0m4Fy5pH_OQZiPwCtwMvh22-3-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFxbEk0k0jYtkn-H-sT0m4Fy5pH_OQZiPwCtwMvh22-3-w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 08, 2012 at 03:06:20PM -0700, Linus Torvalds wrote:
> .. hmm. I think you may be right. Even if we do move it up, we
> probably shouldn't use it.
> 
> We don't even want SLAB_DESTROY_BY_RCU, since we do the delayed RCU
> free for other reasons anyway, so it would duplicate the RCU delaying
> and cause problems. I forgot about that little complication.
> 
> We could have a separate "RCU_BARRIER_ON_DESTROY" thing, but that's
> just silly too.

Why not make that rcu_barrier() in there unconditional?  Where are
we creating/destroying caches often enough for that to become a problem?
