Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:18507 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412Ab2JNTMh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Oct 2012 15:12:37 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH] nfs-utils: Backgrounding mount broken with NFS versions <4
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20121013214652.23089.qmail@md.dent.med.uni-muenchen.de>
Date: Sun, 14 Oct 2012 15:10:29 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <6C61B43F-7A32-47E3-B81D-70CD991D9CDF@oracle.com>
References: <20121012120030.18411.qmail@md.dent.med.uni-muenchen.de> <6AB50360-BADE-4544-85CF-700C63A44FDE@oracle.com> <20121013171856.10814.qmail@md.dent.med.uni-muenchen.de> <F5C4FA78-A467-4306-BC57-0A50D8F0A8A9@oracle.com> <20121013214652.23089.qmail@md.dent.med.uni-muenchen.de>
To: Wolfram Gloger <wmglo@dent.med.uni-muenchen.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 13, 2012, at 5:46 PM, Wolfram Gloger <wmglo@dent.med.uni-muenchen.de> wrote:

> Hi,
> 
>>>>> 	result = nfs_sys_mount(mi, options);
>>> 
>>> No, nfs_sys_mount() does not use mi->extra_opts at all, only the
>>> binary options.
>> 
>> This is the text-based code, which I wrote.  nfs_sys_mount() passes an options string (NUL-terminated C string) to the kernel, not a binary object.  That string contains all the FS-specific mount options specified by the user.
>> 
>> But your patch makes that string empty, by my reading.  I think this is incorrect.
> 
> Ok, I'm happy to go through this line-by-line.
> 
> static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
> {
>        char *options = NULL;
>        int result;
> 
>        if (mi->fake)
>                return 1;
> 
>        if (po_join(opts, &options) == PO_FAILED) { // HERE
>                errno = EIO;
>                return 0;
>        }
> 
>        result = mount(mi->spec, mi->node, mi->type,
>                        mi->flags & ~(MS_USER|MS_USERS), options);
> ...
> }
> 
> nfs_sys_mount() constructs the text options _itself_ purely from the
> opts (2nd) argument HERE -- po_join has opts as input and options as
> output.
> 
> My patch only changes the first argument (mi).  So, no functional change
> within nfs_sys_mount() at all.

Agreed.

> The functional change is that with my patch, mi->extra_opts is kept
> unchanged unless the system call is successful.  mi->extra_opts is
> actually reused later throughout the mount program, because
> nfsmount_string() has extra_opts as an input _and_ output argument,
> and propagates mi->extra_opts into the extra_opts variable in main.c.
> 
> I have actually tested this patch extensively and it fixes the
> problem.

Unfortunately there are a rather unimaginable number of use cases for mount.nfs, which is why it is so complicated.  "Extensively" could mean you've tested it for a long time but with just a few use cases.

In any event:

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



