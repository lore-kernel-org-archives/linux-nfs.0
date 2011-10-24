Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755257Ab1JXLWs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Oct 2011 07:22:48 -0400
Subject: Re: NFS4 BAD_STATEID loop (kernel 3.0)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: David Flynn <davidf@rd.bbc.co.uk>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 24 Oct 2011 13:22:47 +0200
In-Reply-To: <20111024104042.GD32587@rd.bbc.co.uk>
References: <20111024104042.GD32587@rd.bbc.co.uk>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1319455367.8505.3.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-10-24 at 10:40 +0000, David Flynn wrote: 
> Dear All,
> 
> On a system running kernel 3.0, mounting a Solaris NFS4 export, we
> observe a continuous 20Mbit/sec exchange between client and server that had
> been occurring for 10 days.
<snip> 
> No.     Time            Source                Destination           Protocol Size  Info
>    9880 11:40:12.833617 172.29.190.21         172.29.120.140        NFS      1122  V4 COMPOUND Call (Reply In 9881) <EMPTY> PUTFH;WRITE;GETATTR
> 
> Frame 9880: 1122 bytes on wire (8976 bits), 1122 bytes captured (8976 bits)
>     Arrival Time: Oct 17, 2011 11:40:12.833617000 BST
>     Frame Length: 1122 bytes (8976 bits)
>     Capture Length: 1122 bytes (8976 bits)
> Ethernet II, Src: ChelsioC_06:68:f9 (00:07:43:06:68:f9), Dst: All-HSRP-routers_be (00:00:0c:07:ac:be)
> Internet Protocol, Src: 172.29.190.21 (172.29.190.21), Dst: 172.29.120.140 (172.29.120.140)
> Transmission Control Protocol, Src Port: 816 (816), Dst Port: nfs (2049), Seq: 5199745, Ack: 275801, Len: 1056
> Remote Procedure Call, Type:Call XID:0x5daa6e93
> Network File System
>     [Program Version: 4]
>     [V4 Procedure: COMPOUND (1)]
>     Tag: <EMPTY>
>         length: 0
>         contents: <EMPTY>
>     minorversion: 0
>     Operations (count: 3)
>         Opcode: PUTFH (22)
>             filehandle
>                 length: 36
>                 [hash (CRC-32): 0x6e4b15f3]
>                 decode type as: unknown
>                 filehandle: 7df3a75d5e1cd908000ab44c5b000000efc80200000a0300...
>         Opcode: WRITE (38)
>             stateid
>                 seqid: 0x00000000
>                 Data: 4e06f15b800f82e300000000
>             offset: 11392
>             stable: FILE_SYNC4 (2)
>             Write length: 814
>             Data: <DATA>
>                 length: 814
>                 contents: <DATA>
>                 fill bytes: opaque data
>         Opcode: GETATTR (9)
>             GETATTR4args
>                 attr_request
>                     bitmap[0] = 0x00000018
>                         [2 attributes requested]
>                         mand_attr: FATTR4_CHANGE (3)
>                         mand_attr: FATTR4_SIZE (4)
>                     bitmap[1] = 0x00300000
>                         [2 attributes requested]
>                         recc_attr: FATTR4_TIME_METADATA (52)
>                         recc_attr: FATTR4_TIME_MODIFY (53)
> 
> No.     Time            Source                Destination           Protocol Size  Info
>    9881 11:40:12.833956 172.29.120.140        172.29.190.21         NFS      122   V4 COMPOUND Reply (Call In 9880) <EMPTY> PUTFH;WRITE
> 
> Frame 9881: 122 bytes on wire (976 bits), 122 bytes captured (976 bits)
>     Arrival Time: Oct 17, 2011 11:40:12.833956000 BST
>     [Time delta from previous captured frame: 0.000339000 seconds]
>     Frame Length: 122 bytes (976 bits)
>     Capture Length: 122 bytes (976 bits)
> Ethernet II, Src: Cisco_1e:f7:80 (00:13:5f:1e:f7:80), Dst: ChelsioC_06:68:f9 (00:07:43:06:68:f9)
> Internet Protocol, Src: 172.29.120.140 (172.29.120.140), Dst: 172.29.190.21 (172.29.190.21)
> Transmission Control Protocol, Src Port: nfs (2049), Dst Port: 816 (816), Seq: 275801, Ack: 5200801, Len: 56
> Remote Procedure Call, Type:Reply XID:0x5daa6e93
> Network File System
>     [Program Version: 4]
>     [V4 Procedure: COMPOUND (1)]
>     Status: NFS4ERR_BAD_STATEID (10025)
>     Tag: <EMPTY>
>         length: 0
>         contents: <EMPTY>
>     Operations (count: 2)
>         Opcode: PUTFH (22)
>             Status: NFS4_OK (0)
>         Opcode: WRITE (38)
>             Status: NFS4ERR_BAD_STATEID (10025)

We should in principle be able to recover a BAD_STATEID error by running
the state recovery thread. It's a shame that the machine was rebooted,
but does your syslog trace perhaps show any state recovery thread
errors?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

