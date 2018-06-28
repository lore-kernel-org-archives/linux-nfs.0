Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-db5eur01on0114.outbound.protection.outlook.com ([104.47.2.114]:28264
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752250AbeF1FuZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Jun 2018 01:50:25 -0400
Date: Wed, 27 Jun 2018 22:50:04 -0700
From: Andrei Vagin <avagin@virtuozzo.com>
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Subject: Re: [12/24] proc: Add fs_context support to procfs [ver #7]
Message-ID: <20180628055003.GA15563@outlook.office365.com>
References: <20180626072736.GA31860@outlook.office365.com>
 <152414474815.23902.6952548431423168966.stgit@warthog.procyon.org.uk>
 <20180619033450.GA11639@outlook.office365.com>
 <20180626061320.GA12548@outlook.office365.com>
 <31831.1530003427@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="EVF5PPMfhYS0aIcm"
In-Reply-To: <31831.1530003427@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline

On Tue, Jun 26, 2018 at 09:57:07AM +0100, David Howells wrote:
> Andrei Vagin <avagin@virtuozzo.com> wrote:
> 
> > > > > -	mnt = kern_mount_data(&proc_fs_type, ns, 0);
> > > 
> > > Here ns->user_ns and get_current_cred()->user_ns are not always equal
> > 
> > What do you think about the attached patch?
> > ...
> > -	fc = vfs_new_fs_context(&proc_fs_type, NULL, 0,
> > -				FS_CONTEXT_FOR_KERNEL_MOUNT);
> > +	fc = vfs_new_fs_context_userns(&proc_fs_type, NULL, 0,
> > +				FS_CONTEXT_FOR_KERNEL_MOUNT, ns->user_ns);
> 
> Or you could just change fc->user_ns immediately after calling
> vfs_new_fs_context().  This is what network filesystems should do with
> fc->net_ns, for example.

Ok, it works for me. The patch is attached.

> 
> > -struct fs_context *vfs_new_fs_context(struct file_system_type *fs_type,
> > +struct fs_context *vfs_new_fs_context_userns(struct file_system_type *fs_type,
> >  				      struct dentry *reference,
> >  				      unsigned int sb_flags,
> > -				      enum fs_context_purpose purpose)
> > +				      enum fs_context_purpose purpose,
> > +				      struct user_namespace *user_ns)
> 
> 
> If you'd really rather add a new parameter, please don't rename the function
> to vfs_new_fs_context_userns() - just add a new parameter.  There don't need
> to be two versions of it.
> 
> 
> This brings me to another thought:  I want to add the ability to let
> namespaces be configured by userspace, for example:

It may be a good feature, but I am not sure about procfs. A procfs
instance is created per pidns, so they should have the same owner
userns.

> 
> 	fd = fsopen("nfs");
> 	sprintf(buf, "ns user %d", my_user_ns_fd);
> 	write(fd, buf);
> 	sprintf(buf, "ns net %d", my_net_ns_fd);
> 	write(fd, buf);
> 	write(fd, "s fedoraproject.org:/pub");
> 	write(fd, "o intr");
> 	...
> 
> I think therefore, I might need to insert another phase between creating the
> context and calling the filesystem initialiser:
> 
> 	fc = vfs_new_fs_context(&afs_fs_type, mntpt, 0,
> 				FS_CONTEXT_FOR_SUBMOUNT);
> 
> followed by:
> 
> 	vfs_sb_set_namespace(fc, THIS_IS_USER_NS, user_ns);
> 	vfs_sb_set_namespace(fc, THIS_IS_NET_NS, net_ns);
> 
> but then we'd need to do:
> 
> 	vfs_begin_options(fc);
> 
> before continuing (unless we made this happen automatically on the receipt of
> the first option):
> 
> 	afs_mntpt_set_params(fc, mntpt);
> 	vfs_get_tree(fc);
> 	mnt = vfs_create_mount(fc, 0);
> 
> Alternatively, we could do the namespace setting after initialisation and let
> the fs apply the changes itself.
> 
> David

--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename="0001-proc-set-a-proper-user-namespace-for-fs_context.patch"


--EVF5PPMfhYS0aIcm--
