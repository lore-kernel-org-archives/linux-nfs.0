Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:50469 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755941Ab1K2XhN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 18:37:13 -0500
Message-ID: <4ED56B1C.7040407@panasas.com>
Date: Tue, 29 Nov 2011 15:30:36 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Randy Dunlap <rdunlap@xenotime.net>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@tonian.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>, <linux-next@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Michal Marek <mmarek@suse.cz>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: ore: FIX breakage when MISC_FILESYSTEMS is not set
References: <20111124174358.d88f11c0ff700e5e6b3bf73b@canb.auug.org.au>  <4ECE91F3.9010007@xenotime.net> <4ED422CC.60706@panasas.com>  <4ED4238F.4090407@panasas.com> <4ED4CE58.8090107@tonian.com> <1322588023.4174.28.camel@lade.trondhjem.org> <4ED55B3B.9050207@panasas.com> <4ED56D2E.6050405@xenotime.net>
In-Reply-To: <4ED56D2E.6050405@xenotime.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2011 03:39 PM, Randy Dunlap wrote:
> On 11/29/2011 02:22 PM, Boaz Harrosh wrote:
>> On 11/29/2011 09:33 AM, Trond Myklebust wrote:
>>> On Tue, 2011-11-29 at 14:21 +0200, Benny Halevy wrote: 
>>>> On 2011-11-29 02:13, Boaz Harrosh wrote:
>>
>>>>>
>>>>> The solution is to force all users of ORE (exofs, nfs) to manually
>>>>> select everything auto-magically selected before.
>>>>
>>>> How about using "depend ORE" rather than "select ORE"?
>>>
>>> Right. Make PNFS_OBJLAYOUT and EXOFS_FS depend on ASYNC_XOR (or select
>>> it) and then make ORE depend on EXOFS_FS || PNFS_OBJLAYOUT.
>>>
>>> There should be no need to add the 'select ORE'...
>>>
>>
>> No! guys!
>>
>> One it will not solve my problem because any
>> solution that needs to inspect exofs/Kconfig file will
>> not work if MISC_FILESYSTEMS is not selected and your
>> solutions involve that.
>>
>> And two:
>> All the user needs to do is Select NFS4.1 everything
>> else should be done automatically. He should not need
>> to go to misc-filesystems and select ORE so he can have
>> pnfs-objects. That's a nightmare.
>>
>> And anyway the current Kernel rule is that a user of a library
>> needs to select it and all it's dependencies, because select
>> is not recursive. Now I devised a little skim that can avoid
> 
> Since 'select' is not recursive, how does the "select ASYNC_XOR"
> handle ensuring that what it selects (ASYNC_CORE and XOR_BLOCKS)
> have been enabled?
> 

Not sure why it works than. I looked at config MD_RAID456
and from it's selects I only need ASYNC_XOR.
In later Kernels I will also need the RAID6_** stuff.

>> that, which is not conventional but works very nice. It was
>> almost good enough only we have the problem that exofs is under
>> that big MISC_FILESYSTEMS nub.
>>
>> So It's the regular Kernel way, for now.
>>
>> (The real solution is to move ORE to lib/ which would enable my
>>  clever trick. But I don't want to go there only because of that)
>>
>> I'll fix the typos though
> 
> With the patch applied, I am still seeing this kconfig warning:
> 
> warning: (PNFS_OBJLAYOUT) selects ORE which has unmet direct dependencies (MISC_FILESYSTEMS)
> 

OK So I guess I need a much deeper change and move ORE to lib/ or I can do the
below change.

Please advise what you think is the best for now?

Thanks Randy for yur help
---
From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH] ore: FIX breakage when MISC_FILESYSTEMS is not set

As Reported by Randy Dunlap

When MISC_FILESYSTEMS is not enabled:

fs/built-in.o: In function `objio_alloc_io_state':
objio_osd.c:(.text+0xcb525): undefined reference to `ore_get_rw_state'
fs/built-in.o: In function `_write_done':
objio_osd.c:(.text+0xcb58d): undefined reference to `ore_check_io'
fs/built-in.o: In function `_read_done':
...

When MISC_FILESYSTEMS, which is more of a GUI thing then anything else,
is not selected. exofs/Kconfig is never examined during Kconfig,
and it can not do it's magic stuff to automatically select everything
needed.

We must split exofs/Kconfig in two the ore one is
always included and the exofs one is left in it's
old place in the menu.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/Kconfig           |    2 ++
 fs/exofs/Kconfig     |   11 -----------
 fs/exofs/ore.Kconfig |   12 ++++++++++++
 3 files changed, 14 insertions(+), 11 deletions(-)
 create mode 100644 fs/exofs/ore.Kconfig

diff --git a/fs/Kconfig b/fs/Kconfig
index 5f4c45d..fd7bfef 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -218,6 +218,8 @@ source "fs/exofs/Kconfig"
 
 endif # MISC_FILESYSTEMS
 
+source "fs/exofs/ore.Kconfig"
+
 menuconfig NETWORK_FILESYSTEMS
 	bool "Network File Systems"
 	default y
diff --git a/fs/exofs/Kconfig b/fs/exofs/Kconfig
index da42f32..86194b2 100644
--- a/fs/exofs/Kconfig
+++ b/fs/exofs/Kconfig
@@ -1,14 +1,3 @@
-# Note ORE needs to "select ASYNC_XOR". So Not to force multiple selects
-# for every ORE user we do it like this. Any user should add itself here
-# at the "depends on EXOFS_FS || ..." with an ||. The dependencies are
-# selected here, and we default to "ON". So in effect it is like been
-# selected by any of the users.
-config ORE
-	tristate
-	depends on EXOFS_FS || PNFS_OBJLAYOUT
-	select ASYNC_XOR
-	default SCSI_OSD_ULD
-
 config EXOFS_FS
 	tristate "exofs: OSD based file system support"
 	depends on SCSI_OSD_ULD
diff --git a/fs/exofs/ore.Kconfig b/fs/exofs/ore.Kconfig
new file mode 100644
index 0000000..1ca7fb7
--- /dev/null
+++ b/fs/exofs/ore.Kconfig
@@ -0,0 +1,12 @@
+# ORE - Objects Raid Engine (libore.ko)
+#
+# Note ORE needs to "select ASYNC_XOR". So Not to force multiple selects
+# for every ORE user we do it like this. Any user should add itself here
+# at the "depends on EXOFS_FS || ..." with an ||. The dependencies are
+# selected here, and we default to "ON". So in effect it is like been
+# selected by any of the users.
+config ORE
+	tristate
+	depends on EXOFS_FS || PNFS_OBJLAYOUT
+	select ASYNC_XOR
+	default SCSI_OSD_ULD
-- 
1.7.6.4
