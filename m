Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48755 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750902Ab2EJKiK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 06:38:10 -0400
Date: Thu, 10 May 2012 06:38:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: AMIT SAHRAWAT <a.sahrawat@samsung.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "namjae.jeon@samsung.com" <namjae.jeon@samsung.com>
Subject: Re: [Problem]NFS Server =?utf-8?B?4oCTIFVt?=
	=?utf-8?Q?ount?= results in Device Busy.
Message-ID: <20120510103807.GA32608@fieldses.org>
References: <32336989.330131336633170527.JavaMail.weblogic@epml01>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <32336989.330131336633170527.JavaMail.weblogic@epml01>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 10, 2012 at 06:59:32AM +0000, AMIT SAHRAWAT wrote:
> Linux Kernel: 2.6.35.14
>  
> We are using NFS for data transfer from one target to another target.
> On Server we are using 3 mount points – to be used by application. And they are mentioned in /etc/exports
>  
> When initially just NFS Server is started -We can mount and safely un-mount the NFS mount point.
> Now, when NFS client is started and we mount at the client. Without doing any IO – if we do un-mount at the NFS Client –it un-mounts safely.
> But – when tried to un-mount the device at the NFS server – it results in error “Device Busy”
> “umount: can't umount /mnt: Device or resource busy”
>  
> Now , in order to umount the device -  we have to kill the process ‘nfsd’ – and then it un-mounts easily.
>  
> As per our understanding – it should not be an issue with the un-mount when it is not being used and also there should be no dependency to kill ‘nfsd’ to un-mount the device.
>  
> It leads to problem of killing ‘nfsd’ and restarting it – to make other mount points work without issue.
>  
> Is there any method to un-mount the device without getting this ‘BUSY’ error? Or can we kill only nfsd service which was using that mount point?

If all the clients unmount, and then you run "exportfs -f" on the
server, you'll probably find you can then unmount the export.

But stopping nfsd is the most reliable way to ensure you can unmount the
exported filesystems.  I'd recommend doing that using your distro's nfs
scripts (so "service nfs stop" or "systemctl nfs-server.service stop" or
equivalent) rather than killing nfsd yourself.

--b.

> Please share your input on the solution to the above problem. Is this expected behavior?
