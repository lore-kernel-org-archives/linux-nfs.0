Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout1.thls.bbc.co.uk ([132.185.240.36]:45564 "EHLO
	mailout1.thls.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932589Ab1JXOu5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Oct 2011 10:50:57 -0400
Date: Mon, 24 Oct 2011 14:50:27 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Flynn <davidf@rd.bbc.co.uk>, linux-nfs@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS4 BAD_STATEID loop (kernel 3.0.4)
Message-ID: <20111024145027.GF32587@rd.bbc.co.uk>
References: <20111024104042.GD32587@rd.bbc.co.uk>
 <1319455367.8505.3.camel@lade.trondhjem.org>
 <20111024131734.GE32587@rd.bbc.co.uk>
 <1319463165.2734.1.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1319463165.2734.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Chuck Lever (chuck.lever@oracle.com) wrote:
> Can you tell us a little more about the server?  Which release of
> Solaris?  What hardware?

SunOS 5.10 Generic_141444-09
(sparc)

* Trond Myklebust (Trond.Myklebust@netapp.com) wrote:
> I'm assuming then that your network trace showed no sign of any OPEN
> calls of that particular file, just retries of the WRITE?

Correct.

However, the good news is that it has just happened again (certainly
not quota related)

The blocked task:
[179068.773206] INFO: task bash:3293 blocked for more than 120 seconds.
[179068.779660] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[179068.787701] bash            D 0000000000000004     0  3293      1 0x00000000
[179068.795173]  ffff88001f97fca8 0000000000000086 ffff880426876008 0000000000012a40
[179068.802992]  ffff88001f97ffd8 0000000000012a40 ffff88001f97e000 0000000000012a40
[179068.810745]  0000000000012a40 0000000000012a40 ffff88001f97ffd8 0000000000012a40
[179068.818810] Call Trace:
[179068.821496]  [<ffffffff81110030>] ? __lock_page+0x70/0x70
[179068.827204]  [<ffffffff8160007c>] io_schedule+0x8c/0xd0
[179068.832952]  [<ffffffff8111003e>] sleep_on_page+0xe/0x20
[179068.838823]  [<ffffffff816008ff>] __wait_on_bit+0x5f/0x90
[179068.844734]  [<ffffffff81110203>] wait_on_page_bit+0x73/0x80
[179068.850798]  [<ffffffff81085bf0>] ? autoremove_wake_function+0x40/0x40
[179068.857879]  [<ffffffff8111c5e5>] ? pagevec_lookup_tag+0x25/0x40
[179068.864173]  [<ffffffff81110436>] filemap_fdatawait_range+0xf6/0x1a0
[179068.870721]  [<ffffffffa02167d0>] ? nfs_destroy_directcache+0x20/0x20 [nfs]
[179068.877963]  [<ffffffff8111bae1>] ? do_writepages+0x21/0x40
[179068.883744]  [<ffffffff811116bb>] ? __filemap_fdatawrite_range+0x5b/0x60
[179068.890867]  [<ffffffff81111730>] filemap_write_and_wait_range+0x70/0x80
[179068.898025]  [<ffffffff8119cc6a>] vfs_fsync_range+0x5a/0x90
[179068.904197]  [<ffffffff8119cd0c>] vfs_fsync+0x1c/0x20
[179068.909721]  [<ffffffffa020ac74>] nfs_file_flush+0x54/0x80 [nfs]
[179068.916069]  [<ffffffff8116ee7f>] filp_close+0x3f/0x90
[179068.921611]  [<ffffffff8116f8a7>] sys_close+0xb7/0x120
[179068.927328]  [<ffffffff8160a702>] system_call_fastpath+0x16/0x1b

$ echo 0 >/proc/sys/sunrpc/rpc_debug
[180179.009328] -pid- flgs status -client- --rqstp- -timeout ---ops--
[180179.015540] 40304 0801      0 ffff8804241ae800   (null)        0 ffffffffa023cd40 nfsv4 WRITE a:call_start q:NFS client

and our pingpong (more details at end):
14:07:07.307191 IP vc-fs1.rd.bbc.co.uk.1837702678 > home.rd.bbc.co.uk.nfs: 300 getattr fh 0,0/22
14:07:07.307471 IP home.rd.bbc.co.uk.nfs > vc-fs1.rd.bbc.co.uk.1837702678: reply ok 52 getattr ERROR: unk 10025

This system is up at the moment, if there is further detail you require
i can provide that.

NB, the system this occurred on is running kernel 3.0.4
Mount options as per earlier.

Kind regards,

..david

No.     Time            Source                Destination           Protocol Size  Info
     39 15:33:59.077143 172.29.190.28         172.29.120.140        NFS      370   V4 COMPOUND Call (Reply In 40) <EMPTY> PUTFH;WRITE;GETATTR

Frame 39: 370 bytes on wire (2960 bits), 370 bytes captured (2960 bits)
Ethernet II, Src: ChelsioC_07:49:6f (00:07:43:07:49:6f), Dst: All-HSRP-routers_be (00:00:0c:07:ac:be)
Internet Protocol, Src: 172.29.190.28 (172.29.190.28), Dst: 172.29.120.140 (172.29.120.140)
Transmission Control Protocol, Src Port: omginitialrefs (900), Dst Port: nfs (2049), Seq: 40433, Ack: 7449, Len: 304
Remote Procedure Call, Type:Call XID:0x43ce4e16
Network File System
    [Program Version: 4]
    [V4 Procedure: COMPOUND (1)]
    Tag: <EMPTY>
        length: 0
        contents: <EMPTY>
    minorversion: 0
    Operations (count: 3)
        Opcode: PUTFH (22)
            filehandle
                length: 36
                [hash (CRC-32): 0x6e4b15f3]
                decode type as: unknown
                filehandle: 7df3a75d5e1cd908000ab44c5b000000efc80200000a0300...
        Opcode: WRITE (38)
            stateid
            offset: 11474
            stable: FILE_SYNC4 (2)
            Write length: 68
            Data: <DATA>
                length: 68
                contents: <DATA>
        Opcode: GETATTR (9)
            GETATTR4args
                attr_request
                    bitmap[0] = 0x00000018
                        [2 attributes requested]
                        mand_attr: FATTR4_CHANGE (3)
                        mand_attr: FATTR4_SIZE (4)
                    bitmap[1] = 0x00300000
                        [2 attributes requested]
                        recc_attr: FATTR4_TIME_METADATA (52)
                        recc_attr: FATTR4_TIME_MODIFY (53)

No.     Time            Source                Destination           Protocol Size  Info
     40 15:33:59.077433 172.29.120.140        172.29.190.28         NFS      122   V4 COMPOUND Reply (Call In 39) <EMPTY> PUTFH;WRITE

Frame 40: 122 bytes on wire (976 bits), 122 bytes captured (976 bits)
Ethernet II, Src: Cisco_1e:f7:80 (00:13:5f:1e:f7:80), Dst: ChelsioC_07:49:6f (00:07:43:07:49:6f)
Internet Protocol, Src: 172.29.120.140 (172.29.120.140), Dst: 172.29.190.28 (172.29.190.28)
Transmission Control Protocol, Src Port: nfs (2049), Dst Port: omginitialrefs (900), Seq: 7449, Ack: 40737, Len: 56
Remote Procedure Call, Type:Reply XID:0x43ce4e16
Network File System
    [Program Version: 4]
    [V4 Procedure: COMPOUND (1)]
    Status: NFS4ERR_BAD_STATEID (10025)
    Tag: <EMPTY>
        length: 0
        contents: <EMPTY>
    Operations (count: 2)
        Opcode: PUTFH (22)
            Status: NFS4_OK (0)
        Opcode: WRITE (38)
            Status: NFS4ERR_BAD_STATEID (10025)

