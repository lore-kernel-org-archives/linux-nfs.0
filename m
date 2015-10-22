Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:10082 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753338AbbJVQiA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Oct 2015 12:38:00 -0400
Date: Fri, 23 Oct 2015 00:36:55 +0800
From: kbuild test robot <lkp@intel.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: kbuild-all@01.org, Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Latchesar Ionkov <lucho@ionkov.net>, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        devel@driverdev.osuosl.org, Yan Zheng <zyan@redhat.com>,
        cluster-devel@redhat.com, Sage Weil <sage@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Christoph Hellwig <hch@infradead.org>,
        fuse-devel@lists.sourceforge.net,
        Christine Caulfield <ccaulfie@redhat.com>,
        v9fs-developer@lists.sourceforge.net,
        Ilya Dryomov <idryomov@gmail.com>, linux-cifs@vger.kernel.org,
        Eric Van Hensbergen <ericvh@gmail.com>, Mark Fasheh <mfasheh@suse.com>,
        Oleg Drokin <oleg.drokin@intel.com>,
        Julia Lawall <Julia.Lawall@lip6.fr>,
        David Teigland <teigland@redhat.com>, Joel Becker <jlbec@evilplan.org>,
        ceph-devel@vger.kernel.org, Abdul Hussain <habdul@visteon.com>,
        Steven Whitehouse <swhiteho@redhat.com>, linux-nfs@vger.kernel.org,
        Andreas Dilger <andreas.dilger@intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        Steve French <sfrench@samba.org>, Bob Peterson <rpeterso@redhat.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Anna Schumaker <anna.schumaker@netapp.com>, ocfs2-devel@oss.oracle.com,
        lustre-devel@lists.lustre.org
Subject: Re: [PATCH 3/3] locks: cleanup posix_lock_inode_wait and
 flock_lock_inode_wait
Message-ID: <201510230020.vZvDxsE7%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ded792d8fdcba562a1c74fd14fefcb387debc4b1.1445524157.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Benjamin,

[auto build test WARNING on jlayton/linux-next -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Benjamin-Coddington/locks-introduce-locks_lock_inode_wait/20151022-233848
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> fs/locks.c:1176:5: sparse: symbol 'posix_lock_inode_wait' was not declared. Should it be static?
>> fs/locks.c:1863:5: sparse: symbol 'flock_lock_inode_wait' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
