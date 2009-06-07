From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] module_init not called in RPM
Date: Sun, 07 Jun 2009 11:51:39 +0300
Message-ID: <4A2B7F9B.5070907@panasas.com>
References: <b493f8670906040151w2e0fd2afpd8f645b0a5bfcbc4@mail.gmail.com> <4A27BEA5.8070905@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs <pnfs@linux-nfs.org>, NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>,
	Fred Isaman <iisaman@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:16503
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751461AbZFGIvk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Jun 2009 04:51:40 -0400
In-Reply-To: <4A27BEA5.8070905@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 04, 2009, 15:31 +0300, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 06/04/2009 11:51 AM, Fred Isaman wrote:
>> People were having problems with the fedora RPMs, and investigation
>> shows that the problem is related to the fact that  CONFIG_NFS_FS is
>> set to "m" while CONFIG_PNFS_BLOCK is set to "y".  In this case the
>> driver never registers (via module_init) with the NFS code.  The
>> problem is fixed by setting CONFIG_PNFS_BLOCK to "m".
>>
>> Is there anyway (simple) way this could be expected to work?  Because
>> as is, my understanding is that the block-layout tries to register
>> with (the yet unloaded) NFS module, and once the NFS module is loaded,
>> the block-layout code is never called again.
>>
>> Steve, would it be possible in the meantime to change to "CONFIG_PNFS_BLOCK=m"?
>>
>> Benny, does the PANLAYOUT driver have the same problem?

I believe so. When I try to configure panlayout as 'y' rather than 'm'
it looks like it does not even link properly with neither the nfs module
nor the kernel.

>>
>> Fred
> 
> 
> Below little trick will default the layout driver to be the same as the CONFIG_NFS_FS
> that is if CONFIG_NFS_FS=y then CONFIG_PNFS_BLOCK will be y and so for =m.
> 
> config PNFS_OBJLAYOUT
> 	tristate "Provide a pNFS block client (EXPERIMENTAL)"
> 	depends on NFS_FS && PNFS
> 	help
> 	  Say M or Y here if you want your pNfs client to support the block protocol.
> 	  Note if CONFIG_NFS_FS==M then this must also be ==M.
> 
> User can select them apart manually but if CONFIG_NFS_FS changes then CONFIG_PNFS_BLOCK
> will automatically change also. Only by first changing CONFIG_NFS_FS then manually
> changing CONFIG_PNFS_BLOCK they can separate. In which case the prompt should warn about
> CONFIG_NFS_FS=m CONFIG_PNFS_BLOCK=y does not work.
> (Experiment with this in make xconfig and see)
> 
> ---
> This works because Kconfig is not very recursive. the dependency chain figures out that
> CONFIG_PNFS_BLOCK is eventually dependent on CONFIG_NFS_FS, but the default value is taken
> from the direct parent which is CONFIG_PNFS, which is "bool", therefor the =Y default.
> Above though redundant for dependency will select the correct default value dependent
> on the NFS setting.
> 
> I'll send a patch upstream

Thanks!
Besides a short term work around I think we may want to rethink the way
layout drivers are being used...

Today the layout driver registers its layout type and it must be explicitly
loaded to do that, so you may need to manually modprobe it to get it to work.
Thereafter, the admin / user has no choice or control when to use on a
per-filesystem basis.  It's all or nothing.

I think that a more practical way would be to identify the layout driver
as a mount option and then dynamically discover and load it at mount time.
With this mechanism we can also have a default setting for this mount
option to be layout=auto, in which case, the nfs client will load predefined
layout drivers it knows about, based on the layout type attribute it sees
in run time.  layout=none will disable pnfs for this mount.

Benny

> Boaz
> 
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
