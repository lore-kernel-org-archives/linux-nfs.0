From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] fs: push sync_filesystem() down to the file system's
 remount_fs()
Date: Thu, 13 Mar 2014 21:23:00 -0400
Message-ID: <20140314012300.GA8282@thunk.org>
References: <20140313073936.GA14663@infradead.org>
 <1394720456-16629-1-git-send-email-tytso@mit.edu>
 <CAH2r5mvtLZYt=L9HHYOYGBB-kZNXrPiMQL-agzD_VRGCW4vMcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: jfs-discussion@lists.sourceforge.net, Jan Kara <jack@suse.cz>,
 Anders Larsen <al@alarsen.net>, cluster-devel@redhat.com,
 linux-mtd@lists.infradead.org,
 Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
 Petr Vandrovec <petr@vandrovec.name>, codalist@TELEMANN.coda.cs.cmu.edu,
 "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
 linux-fsdevel@thunk.org, Christoph Hellwig <hch@infradead.org>,
 Ext4 Developers List <linux-ext4@vger.kernel.org>,
 Evgeniy Dushistov <dushistov@mail.ru>, Kees Cook <keescook@chromium.org>,
 fuse-devel@lists.sourceforge.net, reiserfs-devel@vger.kernel.org,
 xfs@oss.sgi.com, linux-nilfs@vger.kernel.org,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
 Artem Bityutskiy <dedekind1@gmail.com>, linux-ntfs-dev@lists.sourceforge.net,
 samba-technical <samba-technical@lists.samba.org>,
 Adrian Hunte
To: Steve French <smfrench@gmail.com>
Return-path: <linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org>
In-Reply-To: <CAH2r5mvtLZYt=L9HHYOYGBB-kZNXrPiMQL-agzD_VRGCW4vMcw@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mtd/>
List-Post: <mailto:linux-mtd@lists.infradead.org>
List-Help: <mailto:linux-mtd-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=subscribe>
Sender: "linux-mtd" <linux-mtd-bounces@lists.infradead.org>
Errors-To: linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 13, 2014 at 07:33:02PM -0500, Steve French wrote:
> On Thu, Mar 13, 2014 at 9:20 AM, Theodore Ts'o <tytso@mit.edu> wrote:
> > Previously, the no-op "mount -o mount /dev/xxx" operation when the
> > file system is already mounted read-write causes an implied,
> > unconditional syncfs().  This seems pretty stupid, and it's certainly
> > documented or guaraunteed to do this, nor is it particularly useful,
> > except in the case where the file system was mounted rw and is getting
> > remounted read-only.
> 
> Is there a case where a file system, not mounted read-only,
> would want to skip the syncfs on remount?  I don't know
> of any particular reason to do a syncfs on remount unless
> caching behavior is changing (or moving to read-only mount),
> but if as you say it is documented and guaranteed...

If the file system is mounted read-write, and it is transitioning to
read-only, i.e. "mount -o remount,ro /" then you do want to write out
all dirty data before you transition it to be read-only (otherwise you
would lose data).

It is my belief that this is the _only_ data integrity issue which is
implied by remount (and this is more about not losing work done by
previous system calls).

The background reason for this commit is that a user complained on the
ext4 list that he is using containers in a virtualization environment,
and due to the init scripts which the user doesn't want to change, it
is causing gazillions of no-op remounts, and this is causing ext4 (and
xfs) to do send CACHE FLUSH commands because it is required by the
syncfs(2) system call, which also calls sync_filesystem.  These CACHE
FLUSH commands are unneeded for anything, especially for these no-op
remounts, and so I want them to go away for remounts, but they should
still be there in response to syncfs(2) requests.

Cheers,

					- Ted

______________________________________________________
Linux MTD discussion mailing list
http://lists.infradead.org/mailman/listinfo/linux-mtd/
