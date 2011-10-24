Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:32019 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932478Ab1JXNna convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Oct 2011 09:43:30 -0400
Subject: Re: NFS4 BAD_STATEID loop (kernel 3.0)
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111024104042.GD32587@rd.bbc.co.uk>
Date: Mon, 24 Oct 2011 09:43:03 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <953FE009-0B12-4FB0-BFF0-397B322DC5C9@oracle.com>
References: <20111024104042.GD32587@rd.bbc.co.uk>
To: David Flynn <davidf@rd.bbc.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 24, 2011, at 6:40 AM, David Flynn wrote:

> Dear All,
> 
> On a system running kernel 3.0, mounting a Solaris NFS4 export, we
> observe a continuous 20Mbit/sec exchange between client and server that had
> been occurring for 10 days.

Can you tell us a little more about the server?  Which release of Solaris?  What hardware?

> From /proc/mounts:
> home:/home/ /home nfs4 rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=172.29.190.21,minorversion=0,local_lock=none,addr=172.29.120.140 0 0
> 
> Reconciling logs, we find that around the time the exchange started,
> the kernel reports a process having blocked:
> 
> [787321.680029] INFO: task bash:17799 blocked for more than 120 seconds.
> [787321.680067] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [787321.680104] bash            D 0000000000000002     0 17799      1 0x00000000
> [787321.680131]  ffff880173ad9ca8 0000000000000086 ffff88017216b008 0000000000012a40
> [787321.680171]  ffff880173ad9fd8 0000000000012a40 ffff880173ad8000 0000000000012a40
> [787321.680211]  0000000000012a40 0000000000012a40 ffff880173ad9fd8 0000000000012a40
> [787321.680251] Call Trace:
> [787321.680275]  [<ffffffff8110e900>] ? __lock_page+0x70/0x70
> [787321.680299]  [<ffffffff815fea2c>] io_schedule+0x8c/0xd0
> [787321.680321]  [<ffffffff8110e90e>] sleep_on_page+0xe/0x20
> [787321.680344]  [<ffffffff815ff2af>] __wait_on_bit+0x5f/0x90
> [787321.680366]  [<ffffffff8110ead3>] wait_on_page_bit+0x73/0x80
> [787321.680390]  [<ffffffff81085980>] ? autoremove_wake_function+0x40/0x40
> [787321.680416]  [<ffffffff8111aeb5>] ? pagevec_lookup_tag+0x25/0x40
> [787321.680439]  [<ffffffff8110ed06>] filemap_fdatawait_range+0xf6/0x1a0
> [787321.680483]  [<ffffffffa022e740>] ? nfs_destroy_directcache+0x20/0x20 [nfs]
> [787321.680507]  [<ffffffff8111a3b1>] ? do_writepages+0x21/0x40
> [787321.680530]  [<ffffffff8110ff8b>] ? __filemap_fdatawrite_range+0x5b/0x60
> [787321.680555]  [<ffffffff81110000>] filemap_write_and_wait_range+0x70/0x80
> [787321.680580]  [<ffffffff8119b45a>] vfs_fsync_range+0x5a/0x90
> [787321.680602]  [<ffffffff8119b4fc>] vfs_fsync+0x1c/0x20
> [787321.680628]  [<ffffffffa0222be4>] nfs_file_flush+0x54/0x80 [nfs]
> [787321.680653]  [<ffffffff8116d66f>] filp_close+0x3f/0x90
> [787321.680675]  [<ffffffff8116e097>] sys_close+0xb7/0x120
> [787321.680698]  [<ffffffff816090c2>] system_call_fastpath+0x16/0x1b
> 
> A network trace showed the following exchange below being continually
> repeated.  Unfortunately this system too has since been rebooted.
> 
> Any thoughts on the matter would be most welcome,
> 
> Kind regards,
> 
> ..david
> 
> 
> No.     Time            Source                Destination           Protocol Size  Info
>   9880 11:40:12.833617 172.29.190.21         172.29.120.140        NFS      1122  V4 COMPOUND Call (Reply In 9881) <EMPTY> PUTFH;WRITE;GETATTR
> 
> Frame 9880: 1122 bytes on wire (8976 bits), 1122 bytes captured (8976 bits)
>    Arrival Time: Oct 17, 2011 11:40:12.833617000 BST
>    Frame Length: 1122 bytes (8976 bits)
>    Capture Length: 1122 bytes (8976 bits)
> Ethernet II, Src: ChelsioC_06:68:f9 (00:07:43:06:68:f9), Dst: All-HSRP-routers_be (00:00:0c:07:ac:be)
> Internet Protocol, Src: 172.29.190.21 (172.29.190.21), Dst: 172.29.120.140 (172.29.120.140)
> Transmission Control Protocol, Src Port: 816 (816), Dst Port: nfs (2049), Seq: 5199745, Ack: 275801, Len: 1056
> Remote Procedure Call, Type:Call XID:0x5daa6e93
> Network File System
>    [Program Version: 4]
>    [V4 Procedure: COMPOUND (1)]
>    Tag: <EMPTY>
>        length: 0
>        contents: <EMPTY>
>    minorversion: 0
>    Operations (count: 3)
>        Opcode: PUTFH (22)
>            filehandle
>                length: 36
>                [hash (CRC-32): 0x6e4b15f3]
>                decode type as: unknown
>                filehandle: 7df3a75d5e1cd908000ab44c5b000000efc80200000a0300...
>        Opcode: WRITE (38)
>            stateid
>                seqid: 0x00000000
>                Data: 4e06f15b800f82e300000000
>            offset: 11392
>            stable: FILE_SYNC4 (2)
>            Write length: 814
>            Data: <DATA>
>                length: 814
>                contents: <DATA>
>                fill bytes: opaque data
>        Opcode: GETATTR (9)
>            GETATTR4args
>                attr_request
>                    bitmap[0] = 0x00000018
>                        [2 attributes requested]
>                        mand_attr: FATTR4_CHANGE (3)
>                        mand_attr: FATTR4_SIZE (4)
>                    bitmap[1] = 0x00300000
>                        [2 attributes requested]
>                        recc_attr: FATTR4_TIME_METADATA (52)
>                        recc_attr: FATTR4_TIME_MODIFY (53)
> 
> No.     Time            Source                Destination           Protocol Size  Info
>   9881 11:40:12.833956 172.29.120.140        172.29.190.21         NFS      122   V4 COMPOUND Reply (Call In 9880) <EMPTY> PUTFH;WRITE
> 
> Frame 9881: 122 bytes on wire (976 bits), 122 bytes captured (976 bits)
>    Arrival Time: Oct 17, 2011 11:40:12.833956000 BST
>    [Time delta from previous captured frame: 0.000339000 seconds]
>    Frame Length: 122 bytes (976 bits)
>    Capture Length: 122 bytes (976 bits)
> Ethernet II, Src: Cisco_1e:f7:80 (00:13:5f:1e:f7:80), Dst: ChelsioC_06:68:f9 (00:07:43:06:68:f9)
> Internet Protocol, Src: 172.29.120.140 (172.29.120.140), Dst: 172.29.190.21 (172.29.190.21)
> Transmission Control Protocol, Src Port: nfs (2049), Dst Port: 816 (816), Seq: 275801, Ack: 5200801, Len: 56
> Remote Procedure Call, Type:Reply XID:0x5daa6e93
> Network File System
>    [Program Version: 4]
>    [V4 Procedure: COMPOUND (1)]
>    Status: NFS4ERR_BAD_STATEID (10025)
>    Tag: <EMPTY>
>        length: 0
>        contents: <EMPTY>
>    Operations (count: 2)
>        Opcode: PUTFH (22)
>            Status: NFS4_OK (0)
>        Opcode: WRITE (38)
>            Status: NFS4ERR_BAD_STATEID (10025)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



