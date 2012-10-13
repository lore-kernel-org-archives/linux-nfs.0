Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:40126 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196Ab2JMR2E convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Oct 2012 13:28:04 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH] nfs-utils: Backgrounding mount broken with NFS versions <4
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20121013171856.10814.qmail@md.dent.med.uni-muenchen.de>
Date: Sat, 13 Oct 2012 13:25:57 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <F5C4FA78-A467-4306-BC57-0A50D8F0A8A9@oracle.com>
References: <20121012120030.18411.qmail@md.dent.med.uni-muenchen.de> <6AB50360-BADE-4544-85CF-700C63A44FDE@oracle.com> <20121013171856.10814.qmail@md.dent.med.uni-muenchen.de>
To: Wolfram Gloger <wmglo@dent.med.uni-muenchen.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 13, 2012, at 1:18 PM, Wolfram Gloger <wmglo@dent.med.uni-muenchen.de> wrote:

> Hi,
> 
>>> -	/*
>>> -	 * Update option string to be recorded in /etc/mtab.
>>> -	 */
>>> -	if (po_join(options, mi->extra_opts) == PO_FAILED) {
>>> +	if (po_join(options, &extra_opts) == PO_FAILED) {
>> 
>> This doesn't look right to me, but I haven't had time to test it.  Doesn't this hunk cause the mount system call to ignore what's in mi->extra_opts?
> ...
>>> 	result = nfs_sys_mount(mi, options);
> 
> No, nfs_sys_mount() does not use mi->extra_opts at all, only the
> binary options.

This is the text-based code, which I wrote.  nfs_sys_mount() passes an options string (NUL-terminated C string) to the kernel, not a binary object.  That string contains all the FS-specific mount options specified by the user.

But your patch makes that string empty, by my reading.  I think this is incorrect.

> It would perhaps be clearer to handle the update of mi->extra_opts in
> nfs_sys_mount(), but only after a successful mount(2) call.
> A more invasive patch.
> 
> Regards,
> Wolfram.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



