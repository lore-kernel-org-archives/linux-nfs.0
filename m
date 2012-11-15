Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:59359 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1768345Ab2KOQQc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Nov 2012 11:16:32 -0500
Received: by mail-ee0-f46.google.com with SMTP id b15so1060495eek.19
        for <linux-nfs@vger.kernel.org>; Thu, 15 Nov 2012 08:16:31 -0800 (PST)
Message-ID: <50A51559.9090009@tonian.com>
Date: Thu, 15 Nov 2012 18:16:25 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Giovanni <fattorare@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: PNFS Kernel - CONFIG_SPNFS not found
References: <loom.20121105T154655-381@post.gmane.org>
In-Reply-To: <loom.20121105T154655-381@post.gmane.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Giovanni,
Sorry but support for spnfs was dropped back in pnfs-all-3.2
See http://www.spinics.net/lists/linux-nfs/msg25917.html

Benny

On 2012-11-05 16:49, Giovanni wrote:
> Hi,
> I'm trying to compile the kernel in order to enable pnfs feature present in NFS
> 4.1 following this guide http://linux-
> nfs.org/wiki/index.php/Configuring_pNFS/spnfsd
> I downloaded the git repository for the kernel from git://git.linux-
> nfs.org/projects/bhalevy/linux-pnfs.git
> I didn't found where I can enable the kernel options CONFIG_SPNFS and
> CONFIG_SPNFS_LAYOUTSEGMENT. I have found all the other options required by PNFS.
> I didn't found this two string also in the source code:
> 
> [root@rh62ds1 linux-pnfs]# find .|xargs grep CONFIG_SPNFS
> [root@rh62ds1 linux-pnfs]#
> 
> I have tried using the latest commit and also with the commit id
> cbd09e0fb2b160a06a44aad1c21786b99401823f  as reported in the wiki guide but the
> result is the same.
> If I don't select this two feature, later I obtain a error when I try to execute
> the process spnfsd exit with error because it doesn't found the file
> /proc/fs/spnfs/ctl
> 
> Can you help me?
> 
> Giovanni Sciortino
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
