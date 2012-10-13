Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zep00a03.dent.med.uni-muenchen.de ([138.246.161.8]:54112 "HELO
	md.dent.med.uni-muenchen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754170Ab2JMVqz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Oct 2012 17:46:55 -0400
Date: 13 Oct 2012 23:46:52 +0200
Message-ID: <20121013214652.23089.qmail@md.dent.med.uni-muenchen.de>
From: Wolfram Gloger <wmglo@dent.med.uni-muenchen.de>
To: chuck.lever@oracle.com
CC: linux-nfs@vger.kernel.org
In-reply-to: <F5C4FA78-A467-4306-BC57-0A50D8F0A8A9@oracle.com> (message from
	Chuck Lever on Sat, 13 Oct 2012 13:25:57 -0400)
Subject: Re: [PATCH] nfs-utils: Backgrounding mount broken with NFS versions <4
References: <20121012120030.18411.qmail@md.dent.med.uni-muenchen.de> <6AB50360-BADE-4544-85CF-700C63A44FDE@oracle.com> <20121013171856.10814.qmail@md.dent.med.uni-muenchen.de> <F5C4FA78-A467-4306-BC57-0A50D8F0A8A9@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

> >>> 	result = nfs_sys_mount(mi, options);
> > 
> > No, nfs_sys_mount() does not use mi->extra_opts at all, only the
> > binary options.
> 
> This is the text-based code, which I wrote.  nfs_sys_mount() passes an options string (NUL-terminated C string) to the kernel, not a binary object.  That string contains all the FS-specific mount options specified by the user.
> 
> But your patch makes that string empty, by my reading.  I think this is incorrect.

Ok, I'm happy to go through this line-by-line.

static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
{
        char *options = NULL;
        int result;

        if (mi->fake)
                return 1;

        if (po_join(opts, &options) == PO_FAILED) { // HERE
                errno = EIO;
                return 0;
        }

        result = mount(mi->spec, mi->node, mi->type,
                        mi->flags & ~(MS_USER|MS_USERS), options);
...
}

nfs_sys_mount() constructs the text options _itself_ purely from the
opts (2nd) argument HERE -- po_join has opts as input and options as
output.

My patch only changes the first argument (mi).  So, no functional change
within nfs_sys_mount() at all.

The functional change is that with my patch, mi->extra_opts is kept
unchanged unless the system call is successful.  mi->extra_opts is
actually reused later throughout the mount program, because
nfsmount_string() has extra_opts as an input _and_ output argument,
and propagates mi->extra_opts into the extra_opts variable in main.c.

I have actually tested this patch extensively and it fixes the
problem.

Regards,
Wolfram.
