Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:24370 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934919AbcALMFu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Jan 2016 07:05:50 -0500
Date: Tue, 12 Jan 2016 12:05:48 +0000
From: Wei Liu <wei.liu2@citrix.com>
To: Kojedzinszky =?iso-8859-1?Q?Rich=E1rd?=
	<kojedzinszky.richard@euronetrt.hu>,
        Xen-devel <xen-devel@lists.xenproject.org>
CC: <linux-nfs@vger.kernel.org>, <wei.liu2@citrix.com>,
        Roger Pau =?iso-8859-1?Q?Monn=E9?= <roger.pau@citrix.com>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: blk_update_request: I/O error on NFS  (was: [Xen-users] xen domU
 disk on nfs shared file)
Message-ID: <20160112120548.GB27051@citrix.com>
References: <alpine.DEB.2.20.1601111458420.24727@krichy.tvnetwork.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
In-Reply-To: <alpine.DEB.2.20.1601111458420.24727@krichy.tvnetwork.hu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Drop xen-users@, CC xen-devel@ and blk maintainers, change title.

On Mon, Jan 11, 2016 at 03:08:24PM +0100, Kojedzinszky Richárd wrote:
> Dear all,
> 
> We are facing a regular lockup with our xen setup. We have an nfs share
> mounted on the xen dom0, where the vm images are served, and those files are
> given to xen domUs.
> 
> I was just preparing an experiment, where I created a 100G file on the host:
> # truncate -s 100G /srv/nfs/domU/disk2
> And after added this disk to the instance's configuration.
> 
> On the host this is the mountpoint:
> # mount|grep srv/xen
> 10.1.1.1:/mnt/main/vps on /srv/xen type nfs (rw,relatime,vers=3,rsize=16384,wsize=16384,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.1.1.1,mountvers=3,mountport=4045,mountproto=udp,local_lock=none,addr=10.1.1.1)
> 
> After starting the instance I partitioned the disk with gdisk, and created
> an xfs fs on it. While the fs has been created well, strange messages
> appeared on the console:
> 
> [   23.787504] blk_update_request: I/O error, dev xvdc, sector 2048
> [   23.788904] blk_update_request: I/O error, dev xvdc, sector 8390655
> [   23.789611] blk_update_request: I/O error, dev xvdc, sector 16779262
> [   23.790359] blk_update_request: I/O error, dev xvdc, sector 25167869
> [   23.791148] blk_update_request: I/O error, dev xvdc, sector 33556476
> [   23.791498] blk_update_request: I/O error, dev xvdc, sector 41945083
> [   23.791498] blk_update_request: I/O error, dev xvdc, sector 50333690
> [   23.791498] blk_update_request: I/O error, dev xvdc, sector 58722297
> [   23.791498] blk_update_request: I/O error, dev xvdc, sector 67110904
> [   23.791498] blk_update_request: I/O error, dev xvdc, sector 75499511
> 
> I dont think that this is normal. If I chose a local block device (probably
> lvm) for the domU, this does not appear.
> 
> The host is running xen-4.4 with 3.16.0-4-amd64 kernel (debian jessie
> stock), the domU is running 4.3.0-0.bpo.1-amd64 (jessie backport, 4.4.4).
> 
> I suspect those messages should not be there.
> 
> Regards,
> 
> Kojedzinszky Richárd
> Euronet Magyarorszag Informatika Zrt.

> _______________________________________________
> Xen-users mailing list
> Xen-users@lists.xen.org
> http://lists.xen.org/xen-users

