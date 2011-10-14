Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:58052 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933055Ab1JNOmr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Oct 2011 10:42:47 -0400
Message-ID: <4E9848C1.8040306@panasas.com>
Date: Fri, 14 Oct 2011 16:35:45 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Michal Marek <mmarek@suse.cz>, Randy Dunlap <randy.dunlap@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Problems with Kconfig select across directories
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have this weird problem with Kconfig.

In fs/exofs/Kconfig I have:

# Library to be selected by users
config ORE
	tristate

Then
config EXOFS_FS
	tristate "exofs: OSD based file system support"
	depends on SCSI_OSD_ULD
	select ORE
	help ...

So far so good. Choosing EXOFS_FS in xmenuconfig works fine as expected.
But now I add another user say: (It's more complicated but even below does
not work)

config NFS_FS
	tristate "NFS client support"
	depends on INET && FILE_LOCKING
	select LOCKD
	select SUNRPC
	select NFS_ACL_SUPPORT if NFS_V3_ACL
	select ORE
	help ...

This does not work. The ORE is not compiled and MODPOST complains.
(Given EXOFS_FS is not selected since then it will work)

What am I doing wrong? Why can't I "select" in fs/nfs/Kconfig
an option in fs/exofs/Kconfig? What can I do different?

Thanks
Boaz
