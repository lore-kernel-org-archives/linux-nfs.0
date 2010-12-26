Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:53692 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604Ab0LZI1x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Dec 2010 03:27:53 -0500
Message-ID: <4D16FC82.9070704@panasas.com>
Date: Sun, 26 Dec 2010 10:27:46 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: wolf0805 <wolf0805@163.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Errors on pNFS
References: <4D0E2E01.5020609@panasas.com> <fed0592.55ef.12cfee2b158.Coremail.wolf0805@163.com> <18c0c0f3.1adea.12d0e4252bd.Coremail.wolf0805@163.com>
In-Reply-To: <18c0c0f3.1adea.12d0e4252bd.Coremail.wolf0805@163.com>
Content-Type: text/plain; charset=x-gbk
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

[Adding the linux-nfs mailing list to the Cc
please keep the folks on the list posted as they are interested
in the issues you encounter as well as the solutions]

On 2010-12-22 15:26, wolf0805 wrote:
> Hi Benny,
> 
> I have installed pNFS kernel and pnfs-nfs-utils on three machines(client,mds,ds).
> But when I tried to load the layoutdriver, it gives error : "Fatal - module nfslayoutdriver not found."

Sorry, the layout driver was renamed to nfs_layout_nfsv41_files.
I've updated http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd
to reflect that.

Benny

> I am using Fedora 14 with the uname -a saying "Linux localhost.localdomain 
> 2.6.36-1.pnfs_all_2010_11_03.fc15.i686.PAE #1 SMP Tue Nov 9 18:32:20 UTC 2010 i686 i686 i386 GNU/Linux".
> It seems the kernel is pnfs enabled, but where is the problem?
> 
> The ds ip-addr is XX.YY.ZZ.AA, mds's is XX.YY.ZZ.BB, and client's is XX.YY.ZZ.CC. 
> 
> The /etc/exports on ds looks as: /export/spnfs *(rw,sync,fsid=0,insecure,no_subtree_check,pnfs,no_root_squash)
> 
> The /etc/exports on mds : /export *(rw,sync,fsid=0,insecure,no_subtree_check,pnfs,no_root_!
>  squash)
> 
> /etc/fstab on mds:  XX.YY.ZZ.AA:/       /spnfs/XX.YY.ZZ.A   nfs4    minorversion=1        0 0
> 
> Then I mounted MDS from client using : mount -t nfs4 -o minorversion=1 XX.YY.ZZ.BB:/ /mnt
> 
> I found that only mds and client are mounted, it seems ds is left alone. Is there any mistakes in these configure files? 
> 
> I hope these helps.
> 
> Best regards,
> 
> Yu Zhang
> 
> 
> 
