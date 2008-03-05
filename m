From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH -v2] NFS/LSM: allow NFS to control all of its own mount
	options
Date: Wed, 05 Mar 2008 09:11:10 -0500
Message-ID: <1204726270.3216.196.camel@localhost.localdomain>
References: <1204573372.3216.42.camel@localhost.localdomain>
	 <20080305084815.4d4f54f8@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, selinux <selinux@tycho.nsa.gov>,
	linux-security-module@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, steved@redhat.com,
	sds@tycho.nsa.gov, jmorris@namei.org, casey@schaufler-ca.com,
	trond.myklebust@fys.uio.no, chuck.lever@oracle.com,
	hch@infradead.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080305084815.4d4f54f8@barsoom.rdu.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-03-05 at 08:48 -0500, Jeff Layton wrote:
> On Mon, 03 Mar 2008 14:42:52 -0500
> Eric Paris <eparis@redhat.com> wrote:
> 
> > In the current code (approved by SELinux and NFS people in 2004) SELinux
> > tries to understand NFS's binary mount data.  This blows up in the face
> > of things like nohide mounts which don't use struct nfs_mount_data and I
> > assume just looking at the code that things don't work since NFS moved
> > to using nfs_parsed_mount_data as its default binary mount data blob.
> > 
> > This patch creates a new LSM interfaces allowing NFS to hand argument
> > processing over to the LSM and get back a binary blob the LSM
> > understands for later user.  There is no specific SELinux knowledge
> > inside NFS and no NFS information left inside SELinux.  NFS now passes
> > either strings or the LSM data blob into the LSM and lets the LSM do its
> > own work.  This means that all LSM mount options are supported by NFS
> > when it uses the text userspace interface.
> > 
> > This patch makes NFS use the new LSM hooks security_sb_set_mnt_opts()
> > and security_sb_clone_mnt_opts() inside the ->get_sb() calls so that
> > security options are set explicitly by NFS before the generic NFS
> > settings used by non binary mount data fs's.  The only sorta
> > 'selinux-ism' in this patch is for the NFS binary mount data interface
> > (which must keep working to stop any regressions) to reattach "context="
> > to the data.  This part of the string will have been removed by the
> > older mount.nfs userspace parser.  That little nugget is well commented
> > and wrapper in CONFIG_SECURITY_SELINUX.
> > 
> > We need this for 2.6.25 since at the moment SELinux (and SMACK) + nohide
> > mounts cause security_sb_copy_mount_data() to copy one page of mount
> > data starting at the struct nfs_clone_mount_data on the stack.  If the
> > stack doesn't span 2 pages we run off the end of the stack and hit a
> > page fault BUG().  This also solves the regression in functionality
> > since all SELinux support was broken with the switch to
> > nfs_parsed_mount_data.
> > 
> > Signed-off-by: Eric Paris <eparis@redhat.com>
> > 
> > ---
> > 
> > This patch was tested with NFSv3 mounts and solves all of the
> > regressions that have been introduced in the NFS code.  It supports both
> > the binary interface and text options without pushing LSM specific
> > parsing into the FS.  It doesn't introduce the new LSM constructs
> > necessary to show these mount options in /proc/mounts suggested by
> > Miklos Szeredi but that will be coming in 2.6.26 (it's not a regression
> > or bug fix).  I also do not have the proper security_sb_set_mnt_opts()
> > call in nfs4_get_sb due to a lack of a testing environment, but will add
> > that in 2.6.26 as well.  SELinux + NFSv4 have never had context mount
> > options so there is no regression nor loss of functionality.
> > 
> > Would the NFS community like to push all of this through their bug fix
> > trees or would they prefer I just push this whole patch up the SELinux
> > trees?
> > 
> 
> I like the basic approach -- seems like a clean way to do this. I'm
> not sure I know enough about the selinux/security internals to give
> that a good review, though I made a quick pass through it. Which brings
> me to a somewhat minor nit...
> 
> Would it be possible to break this patch up while keeping the tree
> cleanly bisectable? Maybe one or more patches that add the new
> interfaces and then another separate NFS patch that changes it to use
> the new interfaces? Not only would that make this easier to review, but
> the separate NFS patch might also help serve as a model for other
> filesystems that want to take advantage of the new interfaces.

Yes, I can cleanly break the fs/nfs/internal.h and fs/nfs/super.c
changes into a seperate patch.  It doesn't really help reviewability
though since they are already clearly segregated.  Originally I was
keeping around the legacy support for git biscect reasons but the switch
to nfs_parsed_mount_data already broke everything so there wouldn't be a
lose to separating them.  I'll send as 2 patches in a moment.

> > @@ -589,6 +582,21 @@ static int selinux_set_mnt_opts(struct super_block *sb, char **mount_options,
> >  	}
> >  
> >  	/*
> > +	 * Binary mount data FS will come through this function twice.  Once
> > +	 * from an explicit call and once from the generic calls from the vfs.
> > +	 * Since the generic VFS calls will not contain any security mount data
> > +	 * we need to skip the double mount verification.
> > +	 *
> > +	 * This does open a hole in which we will not notice if the first
> > +	 * mount using this sb set explict options and a second mount using
> > +	 * this sb does not set any security options.  (The first options
> > +	 * will be used for both mounts)
> > +	 */
> > +	if (sbsec->initialized && (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA)
> > +	    && (num_opts == 0))
> > +	        goto out;
> > +
> 
> I'm not sure I understand this. What purpose does checking num_opts
> serve here?
> 
> > +	/*
> >  	 * parse the mount options, check if they are valid sids.
> >  	 * also check if someone is trying to mount the same sb more
> >  	 * than once with different security options.

Let me explain the 2 mount paths and all the logic going on in here for
the case of NFS.  It is the only interesting FS.

The two call paths to get here both come through vfs_kern_mount()

vfs_kern_mount()
  get_sb()
    nfs_get_sb()
      security_sb_set_mnt_opts()

vfs_kern_mount()
  security_sb_kern_mount()
    superblock_doinit()
      security_sb_set_mnt_opts()

Now in this function we do multiple things (even through the name only
implies one thing.)  1) We set the security options on the superblock
security structure and 2) we make sure that these options don't conflict
with options previously used.

The idea is that some someone might do

mount -o context=context1 /dev/whatever /mnt/whatever1
mount -o context=context2 /dev/whatever /mnt/whatever2

This is going to use the same superblock but the context= needs to the
same.  There is no was to reconcile the 2, so we just reject the second
mount.

Binary FS's like NFS which call into the explicit set function will
still traverse the generic call path.  But on the generic call patch
vfs_kern_mount() is going to pass in null mount data and
superblock_doinit is going to turn that into an empty structure with
num_opts=0.  We don't want the mount to fail here because the mount
options set explicitly a moment ago aren't the same now.  Solutions
meant I either needed to be able to tell that it was the same mount
operation we saw on this code path both time or to just let it through
the second time.  I decided to just allow it through.

The drawback of the approach I took is that someone who does

mount -o context=context1 server1:/export/ /mnt/whatever1
mount                     server1:/export/ /mnt/whatever2

is NOT going to get a failure on the second mount.  It will still mount
just fine and it is going to share the mount options with the first
mount, just the user is not going to be informed that the security
options given were not the same on both.

Too much info?  was I just babbling?  did it make sense?  Let me know if
you still have any questions or problems with the possible outcomes...

-Eric

