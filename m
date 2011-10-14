Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60220 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752958Ab1JNWpt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Oct 2011 18:45:49 -0400
Message-ID: <4E98BB9B.2080203@suse.cz>
Date: Sat, 15 Oct 2011 00:45:47 +0200
From: Michal Marek <mmarek@suse.cz>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Paul Bolle <pebolle@tiscali.nl>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Problems with Kconfig select across directories
References: <4E9848C1.8040306@panasas.com> <4E98B19B.6020107@suse.cz> <4E98B751.5070006@panasas.com>
In-Reply-To: <4E98B751.5070006@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 15.10.2011 00:27, Boaz Harrosh wrote:
> On 10/15/2011 12:03 AM, Michal Marek wrote:
>> On 14.10.2011 16:35, Boaz Harrosh wrote:
>>> This does not work. The ORE is not compiled and MODPOST complains.
>>> (Given EXOFS_FS is not selected since then it will work)
>>
>> fs/Makefile only visits fs/exofs if CONFIG_EXOFS_FS is set.
> 
> Bingo. Right on the money. With below patch it works. I'll think
> about it some more and submit.
> 
> Thanks
> ---
> exofs/ore: Select fs/exofs/ folder in Makefile also for ORE only compilation
> 
> If any thing from fs/exofs is set the ORE will be selected. So conditionally
> include fs/exofs in fs/Makefile on ORE set and not EXOFS_FS
...
> --- a/fs/Makefile
> +++ b/fs/Makefile
> @@ -120,6 +120,6 @@ obj-$(CONFIG_DEBUG_FS)		+= debugfs/
>  obj-$(CONFIG_OCFS2_FS)		+= ocfs2/
>  obj-$(CONFIG_BTRFS_FS)		+= btrfs/
>  obj-$(CONFIG_GFS2_FS)           += gfs2/
> -obj-$(CONFIG_EXOFS_FS)          += exofs/
> +obj-$(CONFIG_ORE)		+= exofs/

Note that changing it to obj-y is also valid. And perhaps more obvious.

Michal
