Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.22]:46496 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753189Ab2HJNAh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Aug 2012 09:00:37 -0400
Cc: linux-nfs@vger.kernel.org, tao.peng@emc.com
Content-Type: text/plain; charset="utf-8"
Date: Fri, 10 Aug 2012 15:00:34 +0200
From: "Johannes Schild" <JSchild@gmx.de>
In-Reply-To: <20120810121808.GA9817@umich.edu>
Message-ID: <20120810130034.177360@gmx.net>
MIME-Version: 1.0
References: <20120808182622.177380@gmx.net> <20120809084236.177380@gmx.net>
 <5DFC6BE3BA248842867E85C73BF94B050B17B698CF@MX41A.corp.emc.com>
 <20120809152744.149360@gmx.net>
 <CA+a=Yy7rH7kFKJvS3eOae+Mb0C1p+N01h+Zqz7jVzGE+HXHt9g@mail.gmail.com>
 <20120810074818.119500@gmx.net>
 <CA+a=Yy6C-d82MR6Lun4sRcJ0euBBpf0Ra3cHDnQ8eKENi5eU2Q@mail.gmail.com>
 <20120810092016.177360@gmx.net>
 <CA+a=Yy58ZgG1zoUP4633u6uuZ22hnpuqjS1xa4j3S8R=9=zEUA@mail.gmail.com>
 <20120810120635.268340@gmx.net> <20120810121808.GA9817@umich.edu>
Subject: Re: RE: Blocklayout
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jim,

thanks for trying to help me:


>   
>   [root@fedorapnfs2 sbin]# /root/ctl/ctl -u
>   [root@fedorapnfs2 sbin]# Processing: MSG_VERS    : Version: 8
>   Processing: MSG_VERS    : Version: 8
>   Processing: MSG_DMCHK   : DM Volume: True
>   Processing: MSG_DMGET   : Vol info: 0 6291456 striped 2 128 8:17 2048
> 8:33 2048
>       major 8, minor 17
>       major 8, minor 33
>   Processing: MSG_GETSIG  : get_sig: 8:17: get_sig: Got sig at: 1, within
> sector 56, len 16
>       e9 91 e5 1c d7 cb 20 41   ad d1 61 f9 a7 30 5e fb   
>   Processing: MSG_GETSLICE: get_slice: 8:17: Dev: 8:17, Start: 34, Length:
> 4196285
>   Processing: MSG_GETSIG  : get_sig: 8:33: get_sig: Got sig at: 1, within
> sector 56, len 16
>       9b 0d 30 b8 42 68 0a 4c   95 52 ed 5f d7 46 49 ed   
>   Processing: MSG_GETSLICE: get_slice: 8:33: Dev: 8:33, Start: 34, Length:
> 4196285
> 
> I'm not familiar with this server, but all I see here is slices from two
> disks.  The blkmapd output shows the same thing.  Normally these would be
> striped or catenated to form the file system device.  What device topology
> do you think you're exporting?


I use LVM and iSCSI to export my device:
LVM for Striping (because ctl needs it), iSCSI for transport.

i created a volume "testserver":

[root@fedorapnfs2 server]# pvs
  PV         VG              Fmt  Attr PSize  PFree  
  /dev/sda3  vg_createfedora lvm2 a--  19.50g      0 
  /dev/sdb1  testserver      lvm2 a--   2.00g 508.00m
  /dev/sdc1  testserver      lvm2 a--   2.00g 508.00m

[root@fedorapnfs2 server]# dmsetup ls --target striped
testserver-share	(253, 2)

[root@fedorapnfs2 server]# dmsetup table
vg_createfedora-lv_swap: 0 4128768 linear 8:3 2048
vg_createfedora-lv_root: 0 36765696 linear 8:3 4130816
testserver-share: 0 6291456 striped 2 128 8:17 2048 8:33 2048


The following output is from my iSCSI-targets which i export:

[root@fedorapnfs2 server]# tgtadm --lld iscsi --mode target --op show
Target 1: iqn.2012-04.fedorapnfs2:dev01
    System information:
        Driver: iscsi
        State: ready
    I_T nexus information:
        I_T nexus: 2
            Initiator: iqn.1994-05.com.redhat:f1b658ea7af8
            Connection: 0
                IP Address: 192.168.0.13
    LUN information:
        LUN: 0
            Type: controller
            SCSI ID: IET     00010000
            SCSI SN: beaf10
            Size: 0 MB, Block size: 1
            Online: Yes
            Removable media: No
            Readonly: No
            Backing store type: null
            Backing store path: None
            Backing store flags: 
        LUN: 1
            Type: disk
            SCSI ID: IET     00010001
            SCSI SN: beaf11
            Size: 2149 MB, Block size: 512
            Online: Yes
            Removable media: No
            Readonly: No
            Backing store type: rdwr
            Backing store path: /dev/sdb
            Backing store flags: 
        LUN: 2
            Type: disk
            SCSI ID: IET     00010002
            SCSI SN: beaf12
            Size: 2149 MB, Block size: 512
            Online: Yes
            Removable media: No
            Readonly: No
            Backing store type: rdwr
            Backing store path: /dev/sdc
            Backing store flags: 
    Account information:
    ACL information:
        ALL



Thanks for your help.


Johannes
