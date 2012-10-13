Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zep0064f.zk-i.med.uni-muenchen.de ([138.246.162.185]:54419 "HELO
	md.dent.med.uni-muenchen.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1750823Ab2JMRZj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Oct 2012 13:25:39 -0400
Date: 13 Oct 2012 19:18:56 +0200
Message-ID: <20121013171856.10814.qmail@md.dent.med.uni-muenchen.de>
From: Wolfram Gloger <wmglo@dent.med.uni-muenchen.de>
To: chuck.lever@oracle.com
CC: linux-nfs@vger.kernel.org
In-reply-to: <6AB50360-BADE-4544-85CF-700C63A44FDE@oracle.com> (message from
	Chuck Lever on Sat, 13 Oct 2012 12:23:18 -0400)
Subject: Re: [PATCH] nfs-utils: Backgrounding mount broken with NFS versions <4
References: <20121012120030.18411.qmail@md.dent.med.uni-muenchen.de> <6AB50360-BADE-4544-85CF-700C63A44FDE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

> > -	/*
> > -	 * Update option string to be recorded in /etc/mtab.
> > -	 */
> > -	if (po_join(options, mi->extra_opts) == PO_FAILED) {
> > +	if (po_join(options, &extra_opts) == PO_FAILED) {
> 
> This doesn't look right to me, but I haven't had time to test it.  Doesn't this hunk cause the mount system call to ignore what's in mi->extra_opts?
...
> > 	result = nfs_sys_mount(mi, options);

No, nfs_sys_mount() does not use mi->extra_opts at all, only the
binary options.

It would perhaps be clearer to handle the update of mi->extra_opts in
nfs_sys_mount(), but only after a successful mount(2) call.
A more invasive patch.

Regards,
Wolfram.
