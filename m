Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:50139 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957Ab2CWRVp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Mar 2012 13:21:45 -0400
Received: by wibhq7 with SMTP id hq7so2273612wib.1
        for <linux-nfs@vger.kernel.org>; Fri, 23 Mar 2012 10:21:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOdHTRB5tfXvdEprnUpfswdr7Afq-cOvsqj2VicLipKc2sOK9w@mail.gmail.com>
References: <CAAJC9VbxAcE+DqjqaZ-9K4HKpAWKgg0_B9_QFk64b5V-QdotQA@mail.gmail.com>
	<CAOdHTRB5tfXvdEprnUpfswdr7Afq-cOvsqj2VicLipKc2sOK9w@mail.gmail.com>
Date: Fri, 23 Mar 2012 14:21:43 -0300
Message-ID: <CAAJC9VbvRm49iW2jFUfVqw4k20hPbLfrUr_Wm=pHLmD_23WJew@mail.gmail.com>
Subject: Re: About pNFS installation process.
From: Bruno Silva <bs@cin.ufpe.br>
To: Lev Solomonov <solo@tonian.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fist of all, thanks for your replies.

I still have a few questions:

1. What file system do you suggest? Why ext4 is not recommended?
2. How know whether the pNFS is correctly set? Follows the blkmapd output:

[bruno@fedora blkmapd]$ sudo ./blkmapd -f
blkmapd: process_deviceinfo: 2 vols  *****   POINT 1    *******
blkmapd: decode_blk_signature: si_comps[0]: bs_length 16, bs_string
%�c,�kkG�+ΉJ�2
blkmapd: read_cmp_blk_sig: /dev/sde sig %�c,�kkG�+ΉJ�2� at 568
blkmapd: decode_blk_volume: simple 0
blkmapd: decode_blk_volume: slice 1
device-mapper: reload ioctl failed: Invalid argument *****   POINT 2    *******
blkmapd: Create device pnfs_vol_0 failed
blkmapd: dm_device_create: 1 pnfs_vol_0 0:0
blkmapd: process_deviceinfo: 2 vols
blkmapd: decode_blk_signature: si_comps[0]: bs_length 16, bs_string
%�c,�kkG�+ΉJ�2
blkmapd: read_cmp_blk_sig: /dev/sde sig %�c,�kkG�+ΉJ�2� at 568
blkmapd: decode_blk_volume: simple 0
blkmapd: decode_blk_volume: slice 1
device-mapper: reload ioctl failed: Invalid argument
blkmapd: Create device pnfs_vol_1 failed
blkmapd: dm_device_create: 1 pnfs_vol_1 0:0
blkmapd: process_deviceinfo: 2 vols
blkmapd: decode_blk_signature: si_comps[0]: bs_length 16, bs_string
%�c,�kkG�+ΉJ�2
blkmapd: read_cmp_blk_sig: /dev/sde sig %�c,�kkG�+ΉJ�2� at 568
blkmapd: decode_blk_volume: simple 0
blkmapd: decode_blk_volume: slice 1
device-mapper: reload ioctl failed: Invalid argument
blkmapd: Create device pnfs_vol_2 failed
blkmapd: dm_device_create: 1 pnfs_vol_2 0:0

*****   POINT 1    ******* I connected with four data servers using
the command iscsiadm-m discovery-t-p SendTargets <IP DATE OF
server>-l. But, note the output blkmapd "blkmapd: process_deviceinfo:
2 vols". I believe that should be listed four volumes, not two;

*****   POINT 2   ******* What means this message? "device-mapper:
reload ioctl failed: Invalid argument"

Follows the output of command of "grep nfs /proc/self/mountstats"

[bruno@fedora ~]$ grep nfs /proc/self/mountstats
device sunrpc mounted on /var/lib/nfs/rpc_pipefs with fstype rpc_pipefs
device 192.168.0.203:/ mounted on /home/bruno/shared with fstype nfs4
statvers=1.0
	nfsv4:	bm0=0xfdffbfff,bm1=0x40f9be3e,acl=0x3,sessions,pnfs=not configured
	RPC iostats version: 1.0  p/v: 100003/4 (nfs)

My question is: How can i add other data servers in the structure and
how do I find out where the problem is?

Thanks in advance.

[]'s

Em 18 de março de 2012 07:51, Lev Solomonov <solo@tonian.com> escreveu:
>
> On Thu, Mar 15, 2012 at 22:23, Bruno Silva <bs@cin.ufpe.br> wrote:
>    <snip>
> > 1      17.4kB  53.7GB  53.7GB  ext3         1     msftres
> > I have tested with ext4 file system, create ext4 file system with
> > 4K block size.
> >
> > # mkfs.ext4 -b 4096 /dev/sdb1
> > -----------------------------------------------------------------
>
> i suspect you might encounter some issues with ext4, once you get past
> the initial setup problems.
>
> > The steps 1, 2 and 3 i did to all machines (data servers, metadata
> > server and client).
>
> assuming iSCSI as the underlying storage model, generally speaking:
> * blkmapd and blocklayoutdriver are client-specific (as jim mentioned).
> * ctl daemon is MDS-specific.
> * iSCSI target is DS-specific.
> * both MDS and client will need iSCSI initiator.
>
> you'll need to discover and login to the iSCSI target on the DS from
> both the MDS and the client for proper pNFS operation.
>
> security often gets in the way, mind the ACLs on the iSCSI targets and
> firewall settings on all three (client/MDS/DS) and between them.
>
> > I adopted the export option in metadata server exports file.
> > /mnt *(rw,sync,fsid=0,insecure,no_subtree_check,no_root_squash,pnfs)
>    <snip>
> > If the data server and metadata server have been run on the same
> > machine everything works normally.
>
> see above. once you set everything up make sure you're actually running
> in pNFS mode, i.e. that client sends/receives file data directly from
> the DS over iSCSI, not as a fallback through MDS.
>
> solo.




--
Bruno Silva
Computer Engineer
Modcs Group
---------------------------------------------------------------------
Facebook goo.gl/QHaZx
Twitter goo.gl/yk4jf
Google+ goo.gl/xIbgk
