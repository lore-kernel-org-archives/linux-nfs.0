Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47242 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932516Ab1JXPbo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Oct 2011 11:31:44 -0400
Subject: Re: NFS4 BAD_STATEID loop (kernel 3.0.4)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: David Flynn <davidf@rd.bbc.co.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 24 Oct 2011 17:31:42 +0200
In-Reply-To: <20111024145027.GF32587@rd.bbc.co.uk>
References: <20111024104042.GD32587@rd.bbc.co.uk>
	 <1319455367.8505.3.camel@lade.trondhjem.org>
	 <20111024131734.GE32587@rd.bbc.co.uk>
	 <1319463165.2734.1.camel@lade.trondhjem.org>
	 <20111024145027.GF32587@rd.bbc.co.uk>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1319470302.2734.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-10-24 at 14:50 +0000, David Flynn wrote: 
> No.     Time            Source                Destination           Protocol Size  Info
>      39 15:33:59.077143 172.29.190.28         172.29.120.140        NFS      370   V4 COMPOUND Call (Reply In 40) <EMPTY> PUTFH;WRITE;GETATTR
> 
> Frame 39: 370 bytes on wire (2960 bits), 370 bytes captured (2960 bits)
> Ethernet II, Src: ChelsioC_07:49:6f (00:07:43:07:49:6f), Dst: All-HSRP-routers_be (00:00:0c:07:ac:be)
> Internet Protocol, Src: 172.29.190.28 (172.29.190.28), Dst: 172.29.120.140 (172.29.120.140)
> Transmission Control Protocol, Src Port: omginitialrefs (900), Dst Port: nfs (2049), Seq: 40433, Ack: 7449, Len: 304
> Remote Procedure Call, Type:Call XID:0x43ce4e16
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

Do you have an example of the stateid argument's value? Does it change
at all between separate WRITE attempts?

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

