From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH 2.4] SGI 932676 link_path_walk refcount problem allows umount of active filesystem
Date: Fri, 25 Mar 2005 16:58:56 -0300
Message-ID: <20050325195856.GB15383@logos.cnet>
References: <1111454677.1991.766.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux AutoFS Mailing List <autofs@linux.kernel.org>
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1111454677.1991.766.camel@hole.melbourne.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Mar 22, 2005 at 12:24:37PM +1100, Greg Banks wrote:
> G'day,
> 
> The attached patch fixes a bug in the VFS code which causes
> "Busy inodes after unmount" and a subsequent oops.

Applied, thanks.

> 
> Greg.
> -- 
> Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> I don't speak for SGI.
> 

> Following an absolute symlink opens a window during which the
> filesystem containing the symlink has an outstanding dentry count
> and no outstanding vfsmount count.  A umount() of the filesystem can
> (incorrectly) proceed, resulting in the "Busy inodes after unmount"
> message and an oops shortly thereafter.
> 
> Systems using autofs-controlled NFS mounts are especially vulnerable,
> as autofs both increases the number of unmounts happening and does NFS
> mounting in response to lookups which can result in multiple-second
> vulnerability windows.  However the bug could happen on any filesystem.
> 
> This patch adds a mntget()/mntput() pair around the link following code
> (as the 2.6 code does).  Attempts to umount() during link following
> now return EBUSY.
> 
> 
> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
