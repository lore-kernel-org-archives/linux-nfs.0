Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fatmike.marchingcubes.com ([37.230.96.144]:47201 "EHLO
	fatmike.marchingcubes.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752557AbcEMAGZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 May 2016 20:06:25 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: pNFS problem: client writes go through MDS instead of going directly to DS
From: pete@marchingcubes.com
In-Reply-To: <8AE03FE0-3F86-4B0D-AD80-D4720C56F4A4@gmail.com>
Date: Fri, 13 May 2016 11:57:32 +1200
Cc: linux-nfs@vger.kernel.org
Message-Id: <EE03E38B-45C1-4AEC-B767-5D2D2D1A514A@marchingcubes.com>
References: <8AE03FE0-3F86-4B0D-AD80-D4720C56F4A4@gmail.com>
To: "Nathalie D'Amours" <nathalie.damours@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Nathalie,

When i was testing this, my clients had the iSCSI block devices present - that is, the clients must be able to do block IO to the DS device (note the filesystem on this device should not be mounted)

The way it works, as I understand it, is when the NFS client goes to access a blocklayout-exported volume, it will receive a signature from the server, which is then uses to scan all block devices on the system - if it finds a block device with a matching signature) it then does the I/O ops on it.

So, your host3 also needs ISCSI initiator to the target on host1.

Hope that helps

-Pete





> On 13/05/2016, at 11:33 AM, Nathalie D'Amours <nathalie.damours@gmail.com> wrote:
> 
> Hi,
> 
> I am using pNFS (blocklayout) to mount an XFS file system (on top of iSCSI) on a client. Everything works except that the write data goes through the MDS first instead of going directly to the DS.  I don’t know what I am doing wrong.  Any help or pointer would be very appreciated.
> 
> Here is the configuration:
> 
> host1: DS with one ISCSI target
> host2: MDS: ISCSI initiator to target on host1, XFS built on the iSCSI device (initiator) and exported through NFS
> host3: NFS client mounts the XFS file system using NFS 4.1.
> 
> I am using Fedora 23 (linux kernel 4.4.8) on all hosts.
> 
> NFS Server (host2):
> ------------------
> 
> $ journalctl --since "2016-05-12" -t iscsiadm
> -- Logs begin at Wed 2016-05-04 19:17:25 UTC, end at Thu 2016-05-12 22:42:53 UTC. --
> May 12 18:30:04 ip-172-31-28-138.us-west-2.compute.internal iscsiadm[851]: Logging in to [iface: default, target: iqn.2015-10.com.agylstor:logicalcard3, portal: 172.31.36.18,3260] (multiple)
> May 12 18:30:04 ip-172-31-28-138.us-west-2.compute.internal iscsiadm[851]: Login to [iface: default, target: iqn.2015-10.com.agylstor:logicalcard3, portal: 172.31.36.18,3260] successful.
> 
> From /etc/fstab:
> 
> /dev/sda1       /brick      xfs     _netdev,inode64   0 2
> 
> $ df -h
> Filesystem      Size  Used Avail Use% Mounted on
> /dev/sda1       8.0G   33M  8.0G   1% /brick
> 
> From /etc/exports:
> 
> /brick	*(rw,pnfs)
> 
> NFS Client (host3):
> ------------------
> 
> From /etc/fstab:
> 
> 172.31.28.138:/brick	/brick		nfs4	defaults,minorversion=1 	0 2
> 
> $ df -h
> Filesystem            Size  Used Avail Use% Mounted on
> 172.31.28.138:/brick  8.0G   32M  8.0G   1% /brick
> 
> From /proc/self/mountstats:
> 
> device 172.31.28.138:/brick mounted on /brick with fstype nfs4 statvers=1.1
> 	opts:	rw,vers=4.1,rsize=524288,wsize=524288,namlen=255,acregmin=3,acregmax=60,acdirmin=30,acdirmax=60,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=172.31.25.156,local_lock=none
> 	age:	3272
> 	impl_id:	name='',domain='',date='0,0'
> 	caps:	caps=0x3ffdf,wtmult=512,dtsize=32768,bsize=0,namlen=255
> 	nfsv4:	bm0=0xfdffbfff,bm1=0x40f9be3e,bm2=0x803,acl=0x3,sessions,pnfs=LAYOUT_BLOCK_VOLUME
> 
> Version of nfs-utils:
> 
> $ rpm -qa | grep nfs-utils
> nfs-utils-1.3.3-7.rc4.fc23.x86_64
> 
> The blocklayoutdriver is loaded:
> 
> $ lsmod | grep block
> blocklayoutdriver      28672  1
> nfsv4                 503808  2 blocklayoutdriver
> nfs                   241664  3 nfsv4,blocklayoutdriver
> sunrpc                315392  16 nfs,nfsd,rpcsec_gss_krb5,auth_rpcgss,lockd,nfsv4,blocklayoutdriver,nfs_acl
> 
> The nfs-blkmap service is running:
> 
> $ ps -ef | grep blkmapd
> root       410     1  0 20:34 ?        00:00:00 /usr/sbin/blkmapd
> fedora    2525  2416  0 22:20 pts/3    00:00:00 grep --color=auto blkmapd
> 
> $ journalctl -t blkmapd --since "2016-05-12" -l
> -- Reboot --
> May 12 20:34:49 ip-172-31-25-156.us-west-2.compute.internal blkmapd[410]: open pipe file /var/lib/nfs/rpc_pipefs/nfs/blocklayout failed: No such file or directory
> May 12 20:34:56 ip-172-31-25-156.us-west-2.compute.internal blkmapd[410]: blocklayout pipe file created
> 
> I can login the to iSCSI target from the client but I don’t.  I believe blkmapd is supposed to do this.
> 
> Here is what I see in wireshark between the client and the MDS:
> 
> The flags in the EXCHANGE_ID from the client to the MDS don’t seem right:
> 
> 
> No.     Time           Source                Destination           Protocol Length Info
> 21945 517.514810000  172.31.25.156         172.31.28.138         NFS      378    V4 Call (Reply In 21946) EXCHANGE_ID
> 
> Frame 21945: 378 bytes on wire (3024 bits), 378 bytes captured (3024 bits) on interface 0
> Ethernet II, Src: 02:b3:dd:2e:c1:8f (02:b3:dd:2e:c1:8f), Dst: 02:cd:2b:84:b0:7d (02:cd:2b:84:b0:7d)
> Internet Protocol Version 4, Src: 172.31.25.156 (172.31.25.156), Dst: 172.31.28.138 (172.31.28.138)
> Transmission Control Protocol, Src Port: 732 (732), Dst Port: 2049 (2049), Seq: 45, Ack: 29, Len: 312
> Remote Procedure Call, Type:Call XID:0x49dc5041
> Network File System, Ops(1): EXCHANGE_ID
>   [Program Version: 4]
>   [V4 Procedure: COMPOUND (1)]
>   Tag: <EMPTY>
>       length: 0
>       contents: <EMPTY>
>   minorversion: 1
>   Operations (count: 1): EXCHANGE_ID
>       Opcode: EXCHANGE_ID (42)
>           eia_clientowner
>           flags: 0x00000101
>               0... .... .... .... .... .... .... .... = EXCHGID4_FLAG_CONFIRMED_R: Not set
>               .0.. .... .... .... .... .... .... .... = EXCHGID4_FLAG_UPD_CONFIRMED_REC_A: Not set
>               .... .... .... .0.. .... .... .... .... = EXCHGID4_FLAG_USE_PNFS_DS: Not set
>               .... .... .... ..0. .... .... .... .... = EXCHGID4_FLAG_USE_PNFS_MDS: Not set
>               .... .... .... ...0 .... .... .... .... = EXCHGID4_FLAG_USE_NON_PNFS: Not set
>               .... .... .... .... .... ...1 .... .... = EXCHGID4_FLAG_BIND_PRINC_STATEID: Set
>               .... .... .... .... .... .... .... ..0. = EXCHGID4_FLAG_SUPP_MOVED_MIGR: Not set
>               .... .... .... .... .... .... .... ...1 = EXCHGID4_FLAG_SUPP_MOVED_REFER: Set
>           eia_state_protect: SP4_NONE (0)
>           eia_client_impl_id
>   [Main Opcode: EXCHANGE_ID (42)]
> 
> 
> The flags in the EXCHANGE_ID reply don’t seem right either:
> 
> 
> No.     Time           Source                Destination           Protocol Length Info
> 21946 517.514863000  172.31.28.138         172.31.25.156         NFS      242    V4 Reply (Call In 21945) EXCHANGE_ID
> 
> Frame 21946: 242 bytes on wire (1936 bits), 242 bytes captured (1936 bits) on interface 0
> Ethernet II, Src: 02:cd:2b:84:b0:7d (02:cd:2b:84:b0:7d), Dst: 02:b3:dd:2e:c1:8f (02:b3:dd:2e:c1:8f)
> Internet Protocol Version 4, Src: 172.31.28.138 (172.31.28.138), Dst: 172.31.25.156 (172.31.25.156)
> Transmission Control Protocol, Src Port: 2049 (2049), Dst Port: 732 (732), Seq: 29, Ack: 357, Len: 176
> Remote Procedure Call, Type:Reply XID:0x49dc5041
> Network File System, Ops(1): EXCHANGE_ID
>   [Program Version: 4]
>   [V4 Procedure: COMPOUND (1)]
>   Status: NFS4_OK (0)
>   Tag: <EMPTY>
>       length: 0
>       contents: <EMPTY>
>   Operations (count: 1)
>       Opcode: EXCHANGE_ID (42)
>           Status: NFS4_OK (0)
>           clientid: 0x9acb345701000000
>           seqid: 0x00000001
>           flags: 0x00020001
>               0... .... .... .... .... .... .... .... = EXCHGID4_FLAG_CONFIRMED_R: Not set
>               .0.. .... .... .... .... .... .... .... = EXCHGID4_FLAG_UPD_CONFIRMED_REC_A: Not set
>               .... .... .... .0.. .... .... .... .... = EXCHGID4_FLAG_USE_PNFS_DS: Not set
>               .... .... .... ..1. .... .... .... .... = EXCHGID4_FLAG_USE_PNFS_MDS: Set
>               .... .... .... ...0 .... .... .... .... = EXCHGID4_FLAG_USE_NON_PNFS: Not set
>               .... .... .... .... .... ...0 .... .... = EXCHGID4_FLAG_BIND_PRINC_STATEID: Not set
>               .... .... .... .... .... .... .... ..0. = EXCHGID4_FLAG_SUPP_MOVED_MIGR: Not set
>               .... .... .... .... .... .... .... ...1 = EXCHGID4_FLAG_SUPP_MOVED_REFER: Set
>           eia_state_protect: SP4_NONE (0)
>           eir_server_owner
>           server scope: <DATA>
>               length: 43
>               contents: <DATA>
>               fill bytes: opaque data
>           eir_server_impl_id
>   [Main Opcode: EXCHANGE_ID (42)]
> 
> The MDS replies to GETDEVICEINFO with NFS4ERR_INVAL and we then see the write data coming into the MDS:
> 
> No.     Time           Source                Destination           Protocol Length Info
> 71189 813.804207000  172.31.28.138         172.31.25.156         NFS      160    V4 Reply (Call In 71188) GETDEVINFO Status: NFS4ERR_INVAL
> 
> Frame 71189: 160 bytes on wire (1280 bits), 160 bytes captured (1280 bits) on interface 1
> Linux cooked capture
> Internet Protocol Version 4, Src: 172.31.28.138 (172.31.28.138), Dst: 172.31.25.156 (172.31.25.156)
> Transmission Control Protocol, Src Port: 2049 (2049), Dst Port: 732 (732), Seq: 10705, Ack: 8469, Len: 92
> Remote Procedure Call, Type:Reply XID:0x71dc5041
> Network File System, Ops(2): SEQUENCE GETDEVINFO(NFS4ERR_INVAL)
>   [Program Version: 4]
>   [V4 Procedure: COMPOUND (1)]
>   Status: NFS4ERR_INVAL (22)
>   Tag: <EMPTY>
>       length: 0
>       contents: <EMPTY>
>   Operations (count: 2)
>       Opcode: SEQUENCE (53)
>       Opcode: GETDEVINFO (47)
>           Status: NFS4ERR_INVAL (22)
>   [Main Opcode: GETDEVINFO (47)]
> 
> 
> Thanks,
> 
> Nathalie--
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

