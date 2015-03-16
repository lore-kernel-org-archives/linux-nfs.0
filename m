Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:33973 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932261AbbCPSPf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Mar 2015 14:15:35 -0400
Date: Mon, 16 Mar 2015 18:15:21 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Omar Sandoval <osandov@osandov.com>
Cc: linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        osd-dev@open-osd.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        fuse-devel@lists.sourceforge.net, cluster-devel@redhat.com,
        jfs-discussion@lists.sourceforge.net, HPDD-discuss@ml01.01.org,
        linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        ocfs2-devel@oss.oracle.com, reiserfs-devel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net, xfs@oss.sgi.com,
        linux-kernel@vger.kernel.org, Chris Mason <clm@fb.com>,
        Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.cz>,
        Yan Zheng <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
        Steve French <sfrench@samba.org>, Boaz Harrosh <ooo@electrozaur.com>,
        Benny Halevy <bhalevy@primarydata.com>, Jan Kara <jack@suse.cz>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Jaegeuk Kim <jaegeuk@kernel.org>, Changman Lee <cm224.lee@samsung.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Dave Kleikamp <shaggy@kernel.org>, Oleg Drokin <oleg.drokin@intel.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 0/5] Remove rw parameter from direct_IO()
Message-ID: <20150316181521.GY29656@ZenIV.linux.org.uk>
References: <cover.1426502566.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1426502566.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 16, 2015 at 04:33:48AM -0700, Omar Sandoval wrote:
> Hi,
> 
> Al, here's some cleanup that you mentioned back in December that I got
> around to (https://lkml.org/lkml/2014/12/15/28).
> 
> In summary, the rw parameter to a_ops->direct_IO() is redundant with
> .type in struct iov_iter. Additionally, rw is inconsistently checked for
> being a WRITE; some filesystems do rw == WRITE, others do rw & WRITE,
> and others do both within the same function :) The distinction is that
> swapout may OR in the ITER_BVEC flag in the rw passed to ->direct_IO(),
> so the two are not equivalent (although this really only happens for
> swap-over-NFS, but it's scary nonetheless). After looking through all of
> these, it definitely looks like every check means for ANY write, not
> just non-kernel writes.
> 
> So, the solution presented here is:
> 
> - Add a helper, iov_iter_rw(), which always returns either READ or
>   WRITE, no ITER_.* or REQ_.* nonsense mixed in. For consistency, the
>   return value is always checked for equality

TBH, I'm not sure I like such calling conventions, but I guess we can
live with that.

> I decided to squish all of the filesystems together in patch 4 to avoid
> inundating the mailing lists with 20+ mostly two-line patches, but I can
> split those out if that's any better. Additionally, patch 1 pulls fs.h
> into uio.h, which seems undesirable.

... and easily avoided if you use a macro instead of inline, without losing
type safety or getting double evaluation, etc.

Look: 0 ? (struct T *)0 : (x) always evaluates to x.  Now look at 6.5.15p3 in
C99: the second and the third arguments are both pointers, so we are left with
p3.4 (both arguments are pointers to qualified or unqualified versions of
compatible types), p3.5 (one operand is a pointer and another null pointer
constant) and p3.6 (one operand is a pointer to an object or incomplete type,
and the other is a pointer to qualified or unqualied version of void.

The first variant means that x is a pointer to qualified or unqualified
struct T; the type of result is, per 6.5.15p6, the same as that of x.

The second variant means that x is a null pointer constant ((struct T *)0 isn't
one) and result is a null pointer to T.

The third one means that x is a pointer to qualified or unqualified void.
The type of result is the same as that of x.

Now note that your variant is no better wrt type safety; worse, actually, since
it does accept any pointer to void.  (0 ? (struct iov_iter *)0 : (x))->type
will reject those.  And we obviously don't have double evaluation here either.
