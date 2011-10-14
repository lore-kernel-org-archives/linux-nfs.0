Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:59424 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367Ab1JNWDJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Oct 2011 18:03:09 -0400
Message-ID: <4E98B19B.6020107@suse.cz>
Date: Sat, 15 Oct 2011 00:03:07 +0200
From: Michal Marek <mmarek@suse.cz>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Problems with Kconfig select across directories
References: <4E9848C1.8040306@panasas.com>
In-Reply-To: <4E9848C1.8040306@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 14.10.2011 16:35, Boaz Harrosh wrote:
> I have this weird problem with Kconfig.
> 
> In fs/exofs/Kconfig I have:
> 
> # Library to be selected by users
> config ORE
> 	tristate
> 
> Then
> config EXOFS_FS
> 	tristate "exofs: OSD based file system support"
> 	depends on SCSI_OSD_ULD
> 	select ORE
> 	help ...
> 
> So far so good. Choosing EXOFS_FS in xmenuconfig works fine as expected.
> But now I add another user say: (It's more complicated but even below does
> not work)
> 
> config NFS_FS
> 	tristate "NFS client support"
> 	depends on INET && FILE_LOCKING
> 	select LOCKD
> 	select SUNRPC
> 	select NFS_ACL_SUPPORT if NFS_V3_ACL
> 	select ORE
> 	help ...
> 
> This does not work. The ORE is not compiled and MODPOST complains.
> (Given EXOFS_FS is not selected since then it will work)

fs/Makefile only visits fs/exofs if CONFIG_EXOFS_FS is set.

Michal
