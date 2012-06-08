Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:51716 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964922Ab2FHWGo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jun 2012 18:06:44 -0400
MIME-Version: 1.0
In-Reply-To: <20120608220049.GA18024@otc-wbsnb-06>
References: <1339191663-17693-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120608220049.GA18024@otc-wbsnb-06>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 8 Jun 2012 15:06:20 -0700
Message-ID: <CA+55aFxbEk0k0jYtkn-H-sT0m4Fy5pH_OQZiPwCtwMvh22-3-w@mail.gmail.com>
Subject: Re: [RFC, PATCH] fs: push rcu_barrier() from deactivate_locked_super()
 to filesystems
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, Tao Ma <boyu.mt@taobao.com>,
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
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 8, 2012 at 3:00 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> IIUC, moving rcu_barrier() up should help, but I can't say that I fully
> understand SLAB_DESTROY_BY_RCU semantics.

.. hmm. I think you may be right. Even if we do move it up, we
probably shouldn't use it.

We don't even want SLAB_DESTROY_BY_RCU, since we do the delayed RCU
free for other reasons anyway, so it would duplicate the RCU delaying
and cause problems. I forgot about that little complication.

We could have a separate "RCU_BARRIER_ON_DESTROY" thing, but that's
just silly too.

Maybe your patch is the right thing.

            Linus
