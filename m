Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61678 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756578Ab0HOA63 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 14 Aug 2010 20:58:29 -0400
Subject: Re: 64bit inodes and IA32 apps over NFS
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100813144703.GP20901@ics.muni.cz>
References: <20100813144703.GP20901@ics.muni.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 14 Aug 2010 20:58:13 -0400
Message-ID: <1281833894.9828.3.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-08-13 at 16:47 +0200, Lukas Hejtmanek wrote:
> Hello,
> 
> is there any workaround for NFSv4 when exporting XFS with 64bit inodes?
> 
> IA32 apps receives:
> getdents(3, 0xb7571008, 1000)           = -1 EOVERFLOW (Value too large for defined data type)
> 
> when compiling on x86_64, I got not error.
> 
> From the XFS man page:
> By default, with 32bit inodes, XFS places inodes only in the first 1TB of
> a disk. If you have a disk with 100TB, all inodes will be stuck in the first
> TB. This can lead to strange things like "disk full" when you still have
> plenty space free, but there's no more place in the first TB to create a new
> inode. Also, performance sucks.
> 
> To come around this, use the inode64 mount options for filesystems >1TB.
> Inodes will then be placed in the location where their data is, minimizing
> disk seeks.
> 
> Beware that some old programs might have problems reading 64bit inodes,
> especially over NFS.
> 
> 
> So, is there any workaround in NFS for IA32 apps?
> 

[trondmy@heimdal linux_nfs-2.6]$ less Documentation/kernel-parameters.txt

        nfs.enable_ino64=
                        [NFS] enable 64-bit inode numbers.
                        If zero, the NFS client will fake up a 32-bit inode
                        number for the readdir() and stat() syscalls instead
                        of returning the full 64-bit number.
                        The default is to return 64-bit inode numbers.

Trond
