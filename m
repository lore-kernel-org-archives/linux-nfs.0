Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:60150 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932239AbbEMUiy convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 May 2015 16:38:54 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "=?utf-8?Q?'Andreas_Gr=C3=BCnbacher'?="
	<andreas.gruenbacher@gmail.com>
Cc: <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <cover.1429868795.git.agruenba@redhat.com>	<28e2cd75064ff56bad897b6f69356f4fb15b8128.1429868795.git.agruenba@redhat.com>	<0b2401d08da6$dad0d0f0$907272d0$@mindspring.com> <CAHpGcMLBb+s7iSv9SN1eRX-46VU_wnbGX1nXrNkuaYVp8v0jYw@mail.gmail.com>
In-Reply-To: <CAHpGcMLBb+s7iSv9SN1eRX-46VU_wnbGX1nXrNkuaYVp8v0jYw@mail.gmail.com>
Subject: RE: [RFC v3 20/45] richacl: Automatic Inheritance
Date: Wed, 13 May 2015 13:38:51 -0700
Message-ID: <0b2f01d08dbc$d3418940$79c49bc0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Andreas Grünbacher [mailto:andreas.gruenbacher@gmail.com]
> Sent: Wednesday, May 13, 2015 1:22 PM
> To: Frank Filz
> Cc: linux-kernel@vger.kernel.org; linux-fsdevel@vger.kernel.org; linux-
> nfs@vger.kernel.org
> Subject: Re: [RFC v3 20/45] richacl: Automatic Inheritance
> 
> 2015-05-13 20:01 GMT+02:00 Frank Filz <ffilzlnx@mindspring.com>:
> > You might want to edit your commit message to use RICHACL_ instead of
> > ACL4_ constants...
> 
> Indeed, thanks.
> 
> >> Linux does not have a way of creating files without setting the file
> >> permission bits, so all files created inside a directory with
> >> ACL4_AUTO_INHERIT set will also have the ACL4_PROTECTED flag set.
> >> This effectively disables Automatic Inheritance.
> >>
> >> Protocols which support creating files without specifying permissions
> >> can explicitly clear the ACL4_PROTECTED flag after creating a file
> >> and reset the file masks to "undo" applying the create mode; see
> >> richacl_compute_max_masks().
> >> This is a workaround; a mechanism that would allow a process to
> >> indicate to the kernel to ignore the create mode when there are
> >> inherited permissions would fix this problem.
> >
> > I'm unclear what will actually be supported for inherited ACLs here.
> > Is this saying that on a pure-Linux system even with Linux NFS client
> > and Linux NFS server, we still would not see inheritance since the
> > mode will always be present on create?
> 
> What do you mean by "we still would not see inheritance"? Inheritance at file
> create time will still happen; a few extra flags will be set when Automatic
> Inheritance is "on" in the parent directory as indicated by the
> RICHACL_AUTO_INHERIT flag.
> 
> Files are inevitably created with defined permissions (the mode parameter
> to system calls like creat and mkdir), which means that the
> RICHACL_PROTECTED flag needs to be set, though. When someone changes
> the permissions of an entire directory tree, that change will not propagate to
> or below files with the protected flag set.
> 
> That being said, a daemon like Samba can "fake" full Automatic Inheritance
> by creating files and then updating the inherited acls appropriately. This will
> inevitably be racy, but unless someone implements a way to create files
> without a mode, that's the closest Samba can get.
> 
> Creating files atomically with explicitly defined acls is another operation
> which NFSv4 does but the Linux kernel does not support.
> 
> > My interest here is in how we will tie the Ganesha user space NFS
> > server into this feature.
> 
> I don't know, what do you currently do when somebody creates a file
> without defining the permissions (mode, acl or dacl)? That's the relevant
> case. The kernel nfs daemon currently creates a file with mode 0 --- which
> doesn't seem right.

Ok, I think I'm beginning to understand...

So inheritance will happen, but there is also a mode set as part of the create that I assume is effectively handled the same as a subsequent chmod() on the file?

Any chance we could add a system call to do a open/create and pass an ACL (and heck, if we go there, why not a system call that allows creating with mtime, atime, owner, etc. also...).

Is there a mode that we could pass that would cause the least amount of damage to the inherited ACL?

Frank

