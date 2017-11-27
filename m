Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.nwra.com ([72.52.192.72]:33840 "EHLO mail.nwra.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752993AbdK0Xdy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 27 Nov 2017 18:33:54 -0500
Received: from barry.cora.nwra.com (inferno.cora.nwra.com [208.187.183.84])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.nwra.com (Postfix) with ESMTPS id 923713404BB
        for <linux-nfs@vger.kernel.org>; Mon, 27 Nov 2017 15:28:14 -0800 (PST)
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Orion Poplawski <orion@nwra.com>
Subject: Strange NFS4 permission problem
Message-ID: <c2dadd74-4981-5069-84f1-325ff2babd03@nwra.com>
Date: Mon, 27 Nov 2017 16:28:13 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a kerberized NFS4 setup using EL7.4 that has been working for quite a
long time.  Today I started having trouble with permissions from some clients.
 I haven't been able to figure out what changed.

It appears though that some requests are being sent as root as so permission
to access is denied.

$ id
uid=22603(orion) gid=22603(orion) groups=22603(orion)
 ls -l .Xauthority
-rw-------. 1 orion orion 130 Nov 27 12:59 .Xauthority
$ cat .Xauthority
cat: .Xauthority: Operation not permitted

I tried reverting to sec=sys, but still had problems.  Here is a tshark -V
decode of the open request:

Remote Procedure Call, Type:Call XID:0x1379e0da
    Fragment header: Last fragment, 236 bytes
        1... .... .... .... .... .... .... .... = Last Fragment: Yes
        .000 0000 0000 0000 0000 0000 1110 1100 = Fragment Length: 236
    XID: 0x1379e0da (326754522)
    Message Type: Call (0)
    RPC Version: 2
    Program: NFS (100003)
    Program Version: 4
    Procedure: COMPOUND (1)
    Credentials
        Flavor: AUTH_UNIX (1)
        Length: 40
        Stamp: 0x00418e08
        Machine Name: client
            length: 17
            contents: client
            fill bytes: opaque data
        UID: 0
        GID: 0
        Auxiliary GIDs (0)
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
Network File System, Ops(5): PUTFH, OPEN, GETFH, ACCESS, GETATTR
    [Program Version: 4]
    [V4 Procedure: COMPOUND (1)]
    Tag: <EMPTY>
        length: 0
        contents: <EMPTY>
    minorversion: 0
    Operations (count: 5): PUTFH, OPEN, GETFH, ACCESS, GETATTR
        Opcode: PUTFH (22)
            filehandle
                length: 32
                [hash (CRC-32): 0x6fd1a280]
                decode type as: unknown
                filehandle: 01000681c370d9f027664f269d1025f51329966086b50420...
        Opcode: OPEN (18)
            seqid: 0x00000000
            share_access: OPEN4_SHARE_ACCESS_READ (1)
            share_deny: OPEN4_SHARE_DENY_NONE (0)
            clientid: 0x69531c5aaefd36d7
            owner: <DATA>
                length: 24
                contents: <DATA>
            Open Type: OPEN4_NOCREATE (0)
            Claim Type: CLAIM_NULL (0)
                Name: .Xauthority
                    length: 11
                    contents: .Xauthority
                    fill bytes: opaque data
        Opcode: GETFH (10)
        Opcode: ACCESS (3), [Check: RD MD XT XE]
            Check access: 0x2d
                .... ...1 = 0x01 READ: allowed?
                .... .1.. = 0x04 MODIFY: allowed?
                .... 1... = 0x08 EXTEND: allowed?
                ..1. .... = 0x20 EXECUTE: allowed?
        Opcode: GETATTR (9)
            Attr mask[0]: 0x0010011a (TYPE, CHANGE, SIZE, FSID, FILEID)
                reqd_attr: TYPE (1)
                reqd_attr: CHANGE (3)
                reqd_attr: SIZE (4)
                reqd_attr: FSID (8)
                reco_attr: FILEID (20)
            Attr mask[1]: 0x00b0a23a (MODE, NUMLINKS, OWNER, OWNER_GROUP,
RAWDEV, SPACE_USED, TIME_ACCESS, TIME_METADATA, TIME_MODIFY, MOUNTED_ON_FILEID)
                reco_attr: MODE (33)
                reco_attr: NUMLINKS (35)
                reco_attr: OWNER (36)
                reco_attr: OWNER_GROUP (37)
                reco_attr: RAWDEV (41)
                reco_attr: SPACE_USED (45)
                reco_attr: TIME_ACCESS (47)
                reco_attr: TIME_METADATA (52)
                reco_attr: TIME_MODIFY (53)
                reco_attr: MOUNTED_ON_FILEID (55)
    [Main Opcode: OPEN (18)]

the server responds with permission denied.  Setting no_root_squash allows the
file to catted, though not locked.

I'm at a loss.  Some essentially identical clients work fine, some do not.
I've rebooted the server once and the clients many times.

3.10.0-693.5.2.el7.x86_64
nfs-utils-1.3.0-0.48.el7_4.x86_64


-- 
Orion Poplawski
Manager of NWRA Technical Systems          720-772-5637
NWRA, Boulder/CoRA Office             FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                 https://www.nwra.com/
