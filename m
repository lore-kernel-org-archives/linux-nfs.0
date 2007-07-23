From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [RFC:PATCH] How best to handle implicit clearing of
	setuid/setgid bits on NFS?
Date: Mon, 23 Jul 2007 16:33:23 -0400
Message-ID: <1185222803.6582.42.camel@localhost>
References: <20070529124705.a1e70735.jlayton@redhat.com>
	 <1182982555.5311.67.camel@heimdal.trondhjem.org>
	 <20070627221354.02233c58.jlayton@redhat.com>
	 <1183037902.6163.29.camel@heimdal.trondhjem.org>
	 <20070723150548.8f951bf6.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-fsdevel@vger.kernel.org, aviro@redhat.com,
	nfs@lists.sourceforge.net, nhorman@tuxdriver.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070723150548.8f951bf6.jlayton@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, 2007-07-23 at 15:05 -0400, Jeff Layton wrote:
> On Thu, 28 Jun 2007 09:38:22 -0400
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
> > On Wed, 2007-06-27 at 22:13 -0400, Jeff Layton wrote:
> > > Ok. This is a bit more complex now since we remove suid bits on
> > > truncate, but don't set ATTR_FORCE.
> > > 
> > > Here's a patch that should do this. I know there's a general
> > > aversion to adding new flags to vfs structures, but I couldn't think of
> > > a way to cleanly do this without adding one.
> > > 
> > > Note that I've not tested this patch at all so this is just a RFC.
> > > 
> > > CC'ing Al here since he's expressed interest in this problem as well.
> > > 
> > > Thoughts?
> > 
> > We don't really need to do this with extra VFS flags. Here is my
> > preferred approach for dealing with this problem.
> > 
> >         http://article.gmane.org/gmane.linux.nfs/8511/match=attr%5fkill%5fsuid
> > 
> > As you can see, that still allows the filesystem to determine how it
> > should deal with the ATTR_KILL_SUID/ATTR_KILL_SGID flags. The default
> > behaviour is provided by inode_setattr(), and is the same as today. Only
> > filesystems that don't use inode_setattr() will need to be audited for
> > whether or not they need a fix.
> > 
> > Cheers,
> >   Trond
> 
> 
> I had a look at this today, and I have some reservations about this
> approach. Quite a few filesystems define a .setattr inode op, but don't
> call inode_setattr. As a first pass through the current git tree, the
> following setattr ops never seem to call inode_setattr:

> adfs_notify_change
    ^^^ doesn't support setuid/setgid mode bits in the first place.

> afs_setattr
    networked filesystem: may need a solution like nfs. Can band aid
over the problem by calling a helper to translate.
ATTR_KILL_SUID/ATTR_KILL_SGID into the appropriate ATTR_MODE.

> coda_setattr
    ditto

> ecryptfs_setattr
    this is a layered filesystem. The underlying filesystem needs to
deal with the mode.

> fuse_setattr
    fix iattr_to_fattr to call helper to translate
ATTR_KILL_SUID/ATTR_KILL_SGID into ATTR_MODE

> jffs2_setattr
    add call to helper to translate ATTR_KILL_SUID/ATTR_KILL_SGID to
ATTR_MODE.

> nfs_setattr (expected)

> ntfs_setattr
    Returns EOPNOTSUPP if you try to set ATTR_MODE.

> smb_notify_change
    Returns EPERM if you try to set ATTR_MODE

> xfs_vn_setattr
    add call to helper to translate ATTR_KILL_SUID/ATTR_KILL_SGID

> ...some of these won't matter, but some will need to be fixed. There
> may be other situations we'll need to fix as well.

> My concern here is that we'll be moving from a "default safe" model for
> filesystems that define a .setattr op to one where those filesystems
> are expected to make sure that they clear setuid/gid bits. They can do
> this with a simple call to inode_setattr, or on their own, but they
> must do it. Is this really the right thing to do here?

What is so bloody difficult about remembering to support ATTR_KILL_SUID
ATTR_KILL_SGID vs all the other ATTR_* flags if you are choosing to
implement your own .setattr?
As long as there exists a simple VFS helper to do the translation into
an ATTR_MODE request, so that those filesystems that rely on the current
translation by 'notify_change' can easily migrate, then I can't see why
this is such a problem.

Trond

