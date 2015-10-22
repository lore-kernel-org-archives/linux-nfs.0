Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53065 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964880AbbJVP7r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Oct 2015 11:59:47 -0400
Date: Thu, 22 Oct 2015 23:59:12 +0800
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
Subject: Re: [PATCH 1/3] locks: introduce locks_lock_inode_wait()
Message-ID: <201510222318.nNtSfkKO%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
In-Reply-To: <daf0d3941f34438c1fbdc94a5f3a47c2b22f3ee8.1445524157.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Benjamin,

[auto build test ERROR on jlayton/linux-next -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Benjamin-Coddington/locks-introduce-locks_lock_inode_wait/20151022-233848
config: x86_64-allnoconfig (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All errors (new ones prefixed by >>):

   In file included from include/linux/cgroup.h:17:0,
                    from include/linux/memcontrol.h:22,
                    from include/linux/swap.h:8,
                    from include/linux/suspend.h:4,
                    from arch/x86/kernel/asm-offsets.c:12:
>> include/linux/fs.h:1234:19: error: redefinition of 'locks_lock_file_wait'
    static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
                      ^
   include/linux/fs.h:1181:19: note: previous definition of 'locks_lock_file_wait' was here
    static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
                      ^
   include/linux/fs.h: In function 'locks_lock_file_wait':
>> include/linux/fs.h:1236:9: error: implicit declaration of function 'locks_lock_inode_wait' [-Werror=implicit-function-declaration]
     return locks_lock_inode_wait(file_inode(filp), fl);
            ^
   cc1: some warnings being treated as errors
   make[2]: *** [arch/x86/kernel/asm-offsets.s] Error 1
   make[2]: Target '__build' not remade because of errors.
   make[1]: *** [prepare0] Error 2
   make[1]: Target 'prepare' not remade because of errors.
   make: *** [sub-make] Error 2

vim +/locks_lock_file_wait +1234 include/linux/fs.h

  1228	
  1229	static inline int flock_lock_file_wait(struct file *filp, struct file_lock *fl)
  1230	{
  1231		return flock_lock_inode_wait(file_inode(filp), fl);
  1232	}
  1233	
> 1234	static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
  1235	{
> 1236		return locks_lock_inode_wait(file_inode(filp), fl);
  1237	}
  1238	
  1239	struct fasync_struct {

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--2oS5YaxWCcQjTEyO
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--2oS5YaxWCcQjTEyO--
