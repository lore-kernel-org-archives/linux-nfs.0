Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39974 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080AbbDEQ3G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Apr 2015 12:29:06 -0400
Date: Sun, 5 Apr 2015 17:27:59 +0100
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
Message-ID: <20150405162758.GI889@ZenIV.linux.org.uk>
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

Applied.  See #for-next
