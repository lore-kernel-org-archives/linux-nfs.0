Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35721 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932328AbbCQJcA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2015 05:32:00 -0400
Date: Tue, 17 Mar 2015 10:31:51 +0100
From: David Sterba <dsterba@suse.cz>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Omar Sandoval <osandov@osandov.com>, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, osd-dev@open-osd.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
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
Subject: Re: [RFC PATCH 1/5] new helper: iov_iter_rw()
Message-ID: <20150317093151.GS20767@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <cover.1426502566.git.osandov@osandov.com>
 <34dc78b262546e9343e0ed872232a97f5eaa5f15.1426502566.git.osandov@osandov.com>
 <20150316173605.GX29656@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150316173605.GX29656@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 16, 2015 at 05:36:05PM +0000, Al Viro wrote:
> On Mon, Mar 16, 2015 at 04:33:49AM -0700, Omar Sandoval wrote:
> > Get either READ or WRITE out of iter->type.
> 
> Umm...  
> 
> > + * Get one of READ or WRITE out of iter->type without any other flags OR'd in
> > + * with it.
> > + */
> > +static inline int iov_iter_rw(const struct iov_iter *i)
> > +{
> > +	return i->type & RW_MASK;
> > +}
> 
> TBH, I would turn that into a macro.  Reason: indirect includes.

Agreed, but the proposed define is rather cryptic and I was not able to
understand the meaning on the first glance.

> #define iov_iter_rw(i) ((0 ? (struct iov_iter *)0 : (i))->type & RW_MASK)

This worked for me, does not compile with anything else than
'struct iov_iter*' as i:

#define iov_iter_rw(i)	({			\
	struct iov_iter __iter = *(i);		\
	(i)->type & RW_MASK;			\
	})

The assignment is optimized out.
