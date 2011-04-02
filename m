Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:26648 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756300Ab1DBTJM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Apr 2011 15:09:12 -0400
Message-ID: <4D977456.1040303@panasas.com>
Date: Sat, 02 Apr 2011 12:09:10 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Phil C <philc@impliedspaces.com>, NFS list <linux-nfs@vger.kernel.org>,
        Jim Rees <rees@umich.edu>
CC: linux-scsi@vger.kernel.org
Subject: Re: pNFS Block layout issues / questions
References: <loom.20110328T230906-552@post.gmane.org>
In-Reply-To: <loom.20110328T230906-552@post.gmane.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Forward to the correct mailing list.

jim is the most qualified for any pnfs-blocks issues

cheer
Boaz

On 03/28/2011 03:35 PM, Phil C wrote:
> 
> I was able to get the pNFS file-layout code functioning with 1 DS, and a MDS and
> 1 Client.  I need to get block layout working for a research project I am
> working on, however have so far been unable to get this working.
> 
> I would very much appreciate help or suggestions (or a kick in the head if I'm
> doing something stupid).
> 
> I referenced the wiki pages on client and DS setup and referenced the two
> threads I saw on this topic, however cannot get block-layout working.  
> 
> Below I have shown the steps I have taken to try and get this working (sorry for
> the long list).  
> 
> I have also shown the testing and troubleshooting I have undertaken, and the
> results there-of.
> 
> Data Server: 192.168.1.2 MDS: 192.168.1.1 Client: 192.168.1.3
> 
> On Data-server(s) create folder with mkdir /pnfs 
> 
> On Data-server(s) Edit /etc/exports.  Add the string: 
>    /pnfs  *(rw, sync,fsid=0,insecure,no_subtree_check,pnfs,no_root_squash)
> 
> On Data-server(s) type parted /dev/sdb 
>    (parted) mklabel gpt
>    (parted) mklabel 1 <Provide ext4 file-system, and partition start and end>
>    (parted> print
>    Model: ATA SSDSA2SH06… (scsi)
>    Disk /dev/sdb: 64.0GB
>    Sector size (logical/physical): 512B/512B
>    Partition Table: gpt
>    Number Start	   End		size	File system	Name	Flags
>        1  1049kB  64.0GB       64.0GB	      ext4         1
> 	
> On Data-server(s) type mkfs.ext4 –b 4096 /dev/sdb1
> 
> On Data-server(s) type /etc/init.d/iptables stop
> 
> On Data-server(s) type /etc/init.d/tgtd start
> 
> On Data-server(s) type:
>      tgtadm –lld iscsi –op new –mode target –tid 1 –T
> iqn.2011-03.com.intel:openblock
> 
> On Data-server(s) type 
>   tgtadm –lld iscsi –mode logicalunit –op new –tid 1 –lun 1 –backing-store /dev/sdb1
> 
> On Data-server(s) type 
>    tgtadm –lld iscsi –mode target –op bind –tid 1 –initiator-address ALL
> 
> On Data-server(s) type tgtadm –lld iscsi –op show –mode target
> 
> On Data-server(s) type mount /dev/sdb1 /pnfs
> 
> On Data-server(s) type service nfs restart
> 
> On Data-server(s) cd to the ctl directory and type ./ctl –u & 
>    See: “Processing: MSG_VERS	: Version: 8
> 
> On MDS copy the spnfsd.conf file from pNFS_Packages/pnfs-nfs-utils/utils to
> /etc/spnfsd.conf and edit it for 1 DS and the proper DS-Mount-Directory, DS1_IP,
> and DS1_Root.
>    [General]
>    Verbosity = 1
>    Stripe-size = 8192
>    Dense-striping = 0
>    Pipefs-Directory = /var/lib/nfs/rpc_pipefs
>    DS-Mount-Directory = /spnfs
>    [DataServers]
>    NumDS = 1
>    DS1_IP=	192.168.1.2
>    DS1_PORT=	2049
>    DS1_ROOT = /pnfs
>    DS1_ID = 1
> 
> On MDS create the /spnfs/192.168.1.2 folder
> 
> On MDS edit /etc/exports and add below string:
>    /	*(rw, sync,fsid=0,insecure,no_subtree_check,pnfs,no_root_squash)
>    
> On MDS type mount 192.168.1.2:/pnfs /spnfs/192.168.1.2
>    See on the DS – the ctl application prints out:
>    Processing: MSG_VERS	:	Version: 	8
> 
> On MDS disable iptables with /etc/init.d/iptables stop
> 
> On MDS type service nfs restart – See:
>    Starting NFS services:	[	OK	]
>    Starting NFS quotas:	[	OK	]
>    Starting NFS daemon:	[	OK	]
>    Starting NFS mountd:	[	OK	]
>   
> On MDS type modprobe nfsd to start the NFS daemon
> 
> On MDS type spnfsd to start service on MDS server.  
>    See recapitulation of /etc/spnfsd.conf’; 
>    
> On the Client disable iptables with /etc/init.d/iptables stop
> 
> On the Client log onto the Data-Server iSCSI target by typing:
>    iscsi –m discovery –t st –p 192.168.1.2 –l
> 
> On the Client start the blkmapd service by typing service blkmapd start
> 
> On the Client run /usr/sbin/blkmapd –f 
> 
> On the Client mount MDS server by typing:
>    mount –t nfs4 –o minorversion =1 192.168.1.1:/spnfs /mnt
> 
> TESTING:
> On the Client generate some activity in /mnt (copy file from local client disk
> to /mnt)
> 
> On the Client cat /proc/self/mountstats and look for LAYOUT and see:
>    nfsv4: bm0=0xfdffbfff,bm1=0x40f9be3e,acl=0x3,sessions,pnfs=not configured
>    LAYOUTGET:	0 0 0 0 0 0 0 0
>    LAYTOUTCOMMIT: 0 0 0 0 0 0 0 0
>    LAYOUTRETURN: 0 0 0 0 0 0 0 0
> 
>    On the Client I see in /mnt the file I copied
>    On the MDS I see in /spnfs (note: not /spnfs/192.168.1.2) the file I copied
> from the Client
>    On the MDS I see in /spnfs/192.168.1.2 a file called 2359299.1868952557
>    On the DS I see in /pnfs a file called 2359299.1868952557
> 
> TROUBLESHOOTING:
> Read the new-ish trouble shooting information on the wiki-page.
> 
> 1 – Ran more traffic and still see the same information from the client’s 
> /proc/self/mountstats
> 
> 2 – Ran /usr/sbin/blkmapd –f on the Client and saw no output
> 
> 3 – Looked at /var/log/messages on all 3 machines.  
>    Saw nothing on either the MDS or the DS.  
>    On the Client I see the innocuous: 
>       “FS-Cache: Loaded”
>       Registering the id_resolver key type
>       FS-Cache: Netfs ‘nfs’ registered for caching
> 
> 4 – On the Client I ran ‘mount’ and see I have:
>    192.168.1.1:/spnf on /mnt type nfs4  
> (rw,minorversion=1,addr192.168.1.1,clientaddr=192.168.1.3)
> 
> <Note: no output from the running ‘/usr/sbin/blkmapd –f’ when I ran the mount
> command>
> 
> 5 – On the Client I verified I have an iSCSI target attached.
> 
> 6 – On the Client I did an lsmod|grep bllock to see I had blocklayoutdriver
> loaded and used by nfs and sunrpc
> 
> QUESTIONS:
> 1 – do you see anything missing or wrong about my procedure?
> 
> 2 – The MDS mounts the DS using “mount 192.168.1.2:/pnfs /spnfs/192.168.1.2”. 
> Does the MDS also/instead need to act as an iSCSI initiator and discover/logon 
> to the DS iSCSI target?
> 
> 3 – from /proc/self/mountstats on the client I see I do NOT in fact have
> pnfs=LAYOUT_BLOCK_VOLUEM so I assume we can suspect we do not have a pNFS mount.
>  What does this mean and how can I address the issue?
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

