Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:38925 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760Ab1JNWe1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Oct 2011 18:34:27 -0400
Message-ID: <4E98B751.5070006@panasas.com>
Date: Sat, 15 Oct 2011 00:27:29 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Michal Marek <mmarek@suse.cz>, Paul Bolle <pebolle@tiscali.nl>
CC: Randy Dunlap <randy.dunlap@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Problems with Kconfig select across directories
References: <4E9848C1.8040306@panasas.com> <4E98B19B.6020107@suse.cz>
In-Reply-To: <4E98B19B.6020107@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/15/2011 12:03 AM, Michal Marek wrote:
> On 14.10.2011 16:35, Boaz Harrosh wrote:
>> I have this weird problem with Kconfig.
>>
>> In fs/exofs/Kconfig I have:
>>
>> # Library to be selected by users
>> config ORE
>> 	tristate
>>
>> Then
>> config EXOFS_FS
>> 	tristate "exofs: OSD based file system support"
>> 	depends on SCSI_OSD_ULD
>> 	select ORE
>> 	help ...
>>
>> So far so good. Choosing EXOFS_FS in xmenuconfig works fine as expected.
>> But now I add another user say: (It's more complicated but even below does
>> not work)
>>
>> config NFS_FS
>> 	tristate "NFS client support"
>> 	depends on INET && FILE_LOCKING
>> 	select LOCKD
>> 	select SUNRPC
>> 	select NFS_ACL_SUPPORT if NFS_V3_ACL
>> 	select ORE
>> 	help ...
>>
>> This does not work. The ORE is not compiled and MODPOST complains.
>> (Given EXOFS_FS is not selected since then it will work)
> 
> fs/Makefile only visits fs/exofs if CONFIG_EXOFS_FS is set.
> 
> Michal

Bingo. Right on the money. With below patch it works. I'll think
about it some more and submit.

Thanks
---
exofs/ore: Select fs/exofs/ folder in Makefile also for ORE only compilation

If any thing from fs/exofs is set the ORE will be selected. So conditionally
include fs/exofs in fs/Makefile on ORE set and not EXOFS_FS

Boaz
---
git diff --stat -p -M
 fs/Makefile    |    2 +-
 fs/nfs/Kconfig |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/Makefile b/fs/Makefile
index afc1096..d7a88b5 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -120,6 +120,6 @@ obj-$(CONFIG_DEBUG_FS)		+= debugfs/
 obj-$(CONFIG_OCFS2_FS)		+= ocfs2/
 obj-$(CONFIG_BTRFS_FS)		+= btrfs/
 obj-$(CONFIG_GFS2_FS)           += gfs2/
-obj-$(CONFIG_EXOFS_FS)          += exofs/
+obj-$(CONFIG_ORE)		+= exofs/
 obj-$(CONFIG_CEPH_FS)		+= ceph/
 obj-$(CONFIG_PSTORE)		+= pstore/
diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index dbcd821..1c13c34 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -96,6 +96,7 @@ config PNFS_BLOCK
 config PNFS_OBJLAYOUT
 	tristate
 	depends on NFS_FS && NFS_V4_1 && SCSI_OSD_ULD
+	select ORE
 	default m
 
 config ROOT_NFS

