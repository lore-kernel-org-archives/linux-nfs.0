From: Jan Kara <jack@suse.cz>
Subject: Re: [Cluster-devel] [PATCH] fs: push sync_filesystem()
 down to the file system's remount_fs()
Date: Fri, 14 Mar 2014 13:13:52 +0100
Message-ID: <20140314121352.GB18583@quack.suse.cz>
References: <20140313073936.GA14663@infradead.org>
	<1394720456-16629-1-git-send-email-tytso@mit.edu>
	<20140313162319.GA504@quack.suse.cz>
	<1394728103.2767.32.camel@menhir>
	<20140313231506.GB16785@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: jfs-discussion@lists.sourceforge.net, Jan Kara <jack@suse.cz>,
	Anders Larsen <al-V9/YLgxv/GvR7s880joybQ@public.gmane.org>, linux-mtd@lists.infradead.org,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	Petr Vandrovec <petr@vandrovec.name>, linux-cifs@vger.kernel.org,
	linux-fsdevel-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org, cluster-devel@redhat.com,
	Ext4 Developers List <linux-ext4@vger.kernel.org>,
	Evgeniy Dushistov <dushistov@mail.ru>, Kees Cook <keescook@chromium.org>,
	fuse-devel@lists.sourceforge.net, reiserfs-devel@vger.kernel.org,
	xfs@oss.sgi.com, linux-nilfs@vger.kernel.org,
	Steven Whitehouse <swhiteho@redhat.com>,
	OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
	codalist@TELEMANN.coda.cs.cmu.edu, linux-nfs@vger.kernel.org,
	Artem Bityutskiy <dedekind1@gmail.com>,
	linux-ntfs-dev@lists.sourceforge.net, samba-technical@lists.samba.org,
	Adrian Hunter <adrian.hunter@intel.com>,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-b
To: Theodore Ts'o <tytso@mit.edu>
Return-path: <fuse-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20140313231506.GB16785-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/fuse-devel>,
	<mailto:fuse-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=fuse-devel>
List-Post: <mailto:fuse-devel@lists.sourceforge.net>
List-Help: <mailto:fuse-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/fuse-devel>,
	<mailto:fuse-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: fuse-devel-bounces@lists.sourceforge.net
List-ID: <linux-nfs.vger.kernel.org>

On Thu 13-03-14 19:15:06, Ted Tso wrote:
> On Thu, Mar 13, 2014 at 04:28:23PM +0000, Steven Whitehouse wrote:
> > 
> > I guess the same is true for other file systems which are mounted ro
> > too. So maybe a check for MS_RDONLY before doing the sync in those
> > cases?
> 
> My original patch moved the sync_filesystem into the check for
> MS_RDONLY in the core VFS code.  The objection was raised that there
> might be some file system out there that might depend on this
> behaviour.  I can't imagine why, but I suppose it's at least
> theoretically possible.
  Well, syncfs() in RO->RW transition clearly isn't needed. In RW->RO
transition basically everybody needs it. What is disputable is the case of
RW->RW remounts and I could imagine someone relying on syncfs() there
although 99% of filesystems don't need it. So I agree in principle with
moving the responsibility for syncfs() to ->remount so that each filesystem
can decide.

> So the idea is that this particular patch is *guaranteed* not to make
> any difference.  That way there can be no question about the patch'es
> correctness.
> 
> I'm going to follow up with a patch for ext4 that does exactly that,
> but the idea is to allow each file system maintainer to do that for
> their own file system.
> 
> I could do that as well for file systems that are "obviously"
> read-only, but then I'll find out that there's some wierd case where
> the file system can be used in a read-write fashion.  (Example: UDF is
> normally used for DVD's, but at least in theory it can be used
> read/write --- I'm told that Windows supports read-write UDF file
> systems on USB sticks, and at least in theory it could be used as a
> inter-OS exchange format in situations where VFAT and exFAT might not
> be appropriate for various reasons.)
  Yes, some people do use UDF for USB sticks - Linux supports it in
read-write mode as well (although with somewhat limited set of features).
But the filesystem's I've named are those which clearly either bail with
error if RW mount is attempted or silently change it to RO mount. In these
cases, I'd just patch away the unnecessary sync_fs().

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
