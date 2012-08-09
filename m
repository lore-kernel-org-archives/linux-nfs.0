Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.23]:58827 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756562Ab2HIP1t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 11:27:49 -0400
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="utf-8"
Date: Thu, 09 Aug 2012 17:27:44 +0200
From: "Johannes Schild" <JSchild@gmx.de>
In-Reply-To: <5DFC6BE3BA248842867E85C73BF94B050B17B698CF@MX41A.corp.emc.com>
Message-ID: <20120809152744.149360@gmx.net>
MIME-Version: 1.0
References: <20120808155829.177400@gmx.net> <20120808163916.GA24539@umich.edu>
 <20120808182622.177380@gmx.net> <20120809084236.177380@gmx.net>
 <5DFC6BE3BA248842867E85C73BF94B050B17B698CF@MX41A.corp.emc.com>
Subject: Re: RE: Blocklayout
To: "Peng, Tao" <tao.peng@emc.com>, rees@umich.edu
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


-------- Original-Nachricht --------
> Datum: Thu, 9 Aug 2012 04:56:07 -0400
> Von: "Peng, Tao" <tao.peng@emc.com>
> An: Johannes Schild <JSchild@gmx.de>, "rees@umich.edu" <rees@umich.edu>
> CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
> Betreff: RE: Blocklayout

> 
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org
> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Johannes
> > Schild
> > Sent: Thursday, August 09, 2012 4:43 PM
> > To: Johannes Schild; rees@umich.edu
> > Cc: linux-nfs@vger.kernel.org
> > Subject: Re: Blocklayout
> > 
> > Hi Guys,
> > 
> > some additional Information,
> > 
> > [ 1644.874549] FS-Cache: Loaded
> > [ 1644.895122] NFS: Registering the id_resolver key type
> > [ 1644.895158] FS-Cache: Netfs 'nfs' registered for caching
> > [ 1644.920204] blkmapd: sending ioctl 2285 to a partition!
> > [ 1644.920207] blkmapd: sending ioctl 2285 to a partition!
> > [ 1644.920208] blkmapd: sending ioctl 2285 to a partition!
> > [ 1644.920263] blkmapd: sending ioctl 2285 to a partition!
> > [ 1644.920264] blkmapd: sending ioctl 2285 to a partition!
> > [ 1644.920265] blkmapd: sending ioctl 2285 to a partition!
> > [ 1653.129460] blkmapd: sending ioctl 2285 to a partition!
> > [ 1653.129463] blkmapd: sending ioctl 2285 to a partition!
> > [ 1653.129464] blkmapd: sending ioctl 2285 to a partition!
> > [ 1653.129528] blkmapd: sending ioctl 2285 to a partition!
> > [ 1653.129530] blkmapd: sending ioctl 2285 to a partition!
> > [ 1653.129531] blkmapd: sending ioctl 2285 to a partition!
> > [ 1653.136682] NFS: set_pnfs_layoutdriver: Error initializing pNFS
> layout driver 3.
> > 
> > someone any ideas whats going wrong? The above output is from dmesg.
> > Iam using 3.4.7-1.fc16.x86_64 Kernel from Fedora. The utils are from
> > http://steved.fedorapeople.org/repos/pnfs.
> > 
> There is a regression about saving proper pnfs_blksize before setting
> block layout driver by commit e38eb650 (NFS: set_pnfs_layoutdriver() from
> nfs4_proc_fsinfo()).
> If your client includes the specific commit (although I don't think the
> commit is in 3.4 kernel), please retry after applying the fix at
> http://www.spinics.net/lists/linux-nfs/msg31868.html	

The patch doesn't fit my kernel. My cliet.c looks a little bit different from the client.c in the patch:

if (server->wsize > NFS_MAX_FILE_IO_SIZE)
                server->wsize = NFS_MAX_FILE_IO_SIZE;
        server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
        server->pnfs_blksize = fsinfo->blksize;
        set_pnfs_layoutdriver(server, mntfh, fsinfo->layouttype);

        server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);

The same thing on nfs4proc.c:
{
        nfs_fattr_init(fsinfo->fattr);
        return nfs4_do_fsinfo(server, fhandle, fsinfo);
}

there is no error routine or if-statement like in the patch.
that was a different kernel i tried, kernel-3.3.0-0.rc2.git1.1.pnfsd.fc17.src.rpm from http://steved.fedorapeople.org/repos/pnfs




> If you still see same error, please enable client debug by
> echo 65535 > /proc/sys/sunrpc/nfs_debug
> 

Thats the complete output from dmesg after mounting and try to create a file (i think thats only nfsv4):

[    4.026472] iscsi: registered transport (bnx2i)
[    4.029122] iscsi: registered transport (be2iscsi)
[   81.340654] pcnet32 0000:02:05.0: eth1: link up
[   92.600159] eth1: no IPv6 routers present
[  107.568142] scsi3 : iSCSI Initiator over TCP/IP
[  107.831688] scsi 3:0:0:0: RAID              IET      Controller       0001 PQ: 0 ANSI: 5
[  107.833425] scsi 3:0:0:0: Attached scsi generic sg4 type 12
[  107.836869] scsi 3:0:0:1: Direct-Access     IET      VIRTUAL-DISK     0001 PQ: 0 ANSI: 5
[  107.837494] sd 3:0:0:1: Attached scsi generic sg5 type 0
[  107.838664] sd 3:0:0:1: [sdd] 4196352 512-byte logical blocks: (2.14 GB/2.00 GiB)
[  107.838750] scsi 3:0:0:2: Direct-Access     IET      VIRTUAL-DISK     0001 PQ: 0 ANSI: 5
[  107.838843] sd 3:0:0:2: Attached scsi generic sg6 type 0
[  107.843793] sd 3:0:0:1: [sdd] Write Protect is off
[  107.843796] sd 3:0:0:1: [sdd] Mode Sense: 49 00 00 08
[  107.844193] sd 3:0:0:2: [sde] 4196352 512-byte logical blocks: (2.14 GB/2.00 GiB)
[  107.844814] sd 3:0:0:1: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  107.845943] sd 3:0:0:2: [sde] Write Protect is off
[  107.845945] sd 3:0:0:2: [sde] Mode Sense: 49 00 00 08
[  107.846699] sd 3:0:0:2: [sde] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  107.856535]  sdd: sdd1
[  107.859230]  sde: sde1
[  107.859941] sd 3:0:0:1: [sdd] Attached SCSI disk
[  107.861468] sd 3:0:0:2: [sde] Attached SCSI disk
[  179.557893] FS-Cache: Loaded
[  179.563310] NFS: Registering the id_resolver key type
[  179.563339] FS-Cache: Netfs 'nfs' registered for caching
[  207.222318] NFS: set_pnfs_layoutdriver: Error initializing pNFS layout driver 3.


> And redo mount and send the log.
> 
> Thanks,
> Tao
> 

Thanks

Johannes
