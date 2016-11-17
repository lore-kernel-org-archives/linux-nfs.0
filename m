Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50156 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933728AbcKQRJc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Nov 2016 12:09:32 -0500
Date: Thu, 17 Nov 2016 11:31:01 -0500
To: Jason L Tibbitts III <tibbs@math.uh.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
Message-ID: <20161117163101.GA19161@fieldses.org>
References: <ufafuwhlr72.fsf@epithumia.math.uh.edu>
 <20160225195827.GC23315@fieldses.org>
 <ufaegbvdslg.fsf@epithumia.math.uh.edu>
 <20160301004844.GA11952@fieldses.org>
 <ufay4a3c938.fsf@epithumia.math.uh.edu>
 <20160301010120.GB11952@fieldses.org>
 <ufapovfc8m4.fsf@epithumia.math.uh.edu>
 <ufa1syb402e.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ufa1syb402e.fsf@epithumia.math.uh.edu>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 16, 2016 at 02:55:05PM -0600, Jason L Tibbitts III wrote:
> I'm replying to a rather old message, but the issue has just now popped
> back up again.
> 
> To recap, a client stops being able to access _any_ mount on a
> particular server, and "NFS: nfs4_reclaim_open_state: Lock reclaim
> failed!" appears several hundred times per second in the kernel log.
> The load goes up by one for ever process attempting to access any mount
> from that particular server.  Mounts to other servers are fine, and
> other clients can mount things from that one server without problems.
> 
> When I kill every process keeping that particular mount active and then
> umount it, I see:
> 
> NFS: nfs4_reclaim_open_state: unhandled error -10068

NFS4ERR_RETRY_UNCACHED_REP.

So, you're using NFSv4.1 or 4.2, and the server thinks that the client
has reused a (slot, sequence number) pair, but the server doesn't have a
cached response to return.

Hard to know how that happened, and it's not shown in the below.
Sounds like a bug, though.

> The server in this case is running Centos 7: 3.10.0-327.36.3.el7.x86_64
> The client is one of the last I have that's still running Fedora 23:
> 4.7.10-100.fc23.x86_64
> 
> The big difference now, besides the updated kernel versions, is that
> fact that no kerberos is involved.  It's a sec=sys mount.  There are
> kerberized exports on the same server, but the client wasn't accessing
> any of them.  There were other kerberized mounts on the client, but they
> were to different servers and they remained accessible.

Recent clients will use sec=krb5 for certain state-related operations
even if you mount with sec=sys, so it's still possible it could be
involved here.

> Here's ten frames from a packet capture.  I think it's all repeating at
> that point so maybe it will be enough, but I can provide a more complete
> capture log on request.

The SEQ4_STATUS_RECALLABLE_STATE_REVOKED flag set in the OPEN replies is
also a sign something's gone wrong.  Apparently the server thinks the
client has failed to return a delegation.

--b.

> 
>  - J<
> 
> Frame 1: 390 bytes on wire (3120 bits), 390 bytes captured (3120 bits) on interface 0
> Ethernet II, Src: SuperMic_19:8e:6e (00:25:90:19:8e:6e), Dst: AsrockIn_84:34:e7 (d0:50:99:84:34:e7)
> Internet Protocol Version 4, Src: 172.21.86.74, Dst: 172.21.86.141
> Transmission Control Protocol, Src Port: 2049, Dst Port: 997, Seq: 1, Ack: 1, Len: 324
> Remote Procedure Call
> 
> Frame 2: 322 bytes on wire (2576 bits), 322 bytes captured (2576 bits) on interface 0
> Ethernet II, Src: AsrockIn_84:34:e7 (d0:50:99:84:34:e7), Dst: SuperMic_19:8e:6e (00:25:90:19:8e:6e)
> Internet Protocol Version 4, Src: 172.21.86.141, Dst: 172.21.86.74
> Transmission Control Protocol, Src Port: 997, Dst Port: 2049, Seq: 1, Ack: 325, Len: 256
> Remote Procedure Call, Type:Call XID:0x29009a8c
> Network File System, Ops(5): SEQUENCE, PUTFH, OPEN, ACCESS, GETATTR
>     [Program Version: 4]
>     [V4 Procedure: COMPOUND (1)]
>     Tag: <EMPTY>
>         length: 0
>         contents: <EMPTY>
>     minorversion: 1
>     Operations (count: 5): SEQUENCE, PUTFH, OPEN, ACCESS, GETATTR
>         Opcode: SEQUENCE (53)
>             sessionid: f0f40f58bd020000e002000000000000
>             seqid: 0x002b3189
>             slot id: 0
>             high slot id: 0
>             cache this?: Yes
>         Opcode: PUTFH (22)
>             filehandle
>                 length: 28
>                 [hash (CRC-32): 0xdcaec4f7]
>                 filehandle: 010006016aeda54305f66ede000000000000000096484800...
>         Opcode: OPEN (18)
>             seqid: 0x00000000
>             share_access: OPEN4_SHARE_ACCESS_BOTH (3)
>             share_deny: OPEN4_SHARE_DENY_NONE (0)
>             clientid: 0xf0f40f58bd020000
>             owner: <DATA>
>                 length: 24
>                 contents: <DATA>
>             Open Type: OPEN4_NOCREATE (0)
>             Claim Type: CLAIM_FH (4)
>         Opcode: ACCESS (3), [Check: RD MD XT XE]
>             Check access: 0x2d
>                 .... ...1 = 0x01 READ: allowed?
>                 .... .1.. = 0x04 MODIFY: allowed?
>                 .... 1... = 0x08 EXTEND: allowed?
>                 ..1. .... = 0x20 EXECUTE: allowed?
>         Opcode: GETATTR (9)
>             Attr mask[0]: 0x0010011a (Type, Change, Size, FSID, FileId)
>                 reqd_attr: Type (1)
>                 reqd_attr: Change (3)
>                 reqd_attr: Size (4)
>                 reqd_attr: FSID (8)
>                 reco_attr: FileId (20)
>             Attr mask[1]: 0x00b0a23a (Mode, NumLinks, Owner, Owner_Group, RawDev, Space_Used, Time_Access, Time_Metadata, Time_Modify, Mounted_on_FileId)
>                 reco_attr: Mode (33)
>                 reco_attr: NumLinks (35)
>                 reco_attr: Owner (36)
>                 reco_attr: Owner_Group (37)
>                 reco_attr: RawDev (41)
>                 reco_attr: Space_Used (45)
>                 reco_attr: Time_Access (47)
>                 reco_attr: Time_Metadata (52)
>                 reco_attr: Time_Modify (53)
>                 reco_attr: Mounted_on_FileId (55)
>     [Main Opcode: OPEN (18)]
> 
> Frame 3: 390 bytes on wire (3120 bits), 390 bytes captured (3120 bits) on interface 0
> Ethernet II, Src: SuperMic_19:8e:6e (00:25:90:19:8e:6e), Dst: AsrockIn_84:34:e7 (d0:50:99:84:34:e7)
> Internet Protocol Version 4, Src: 172.21.86.74, Dst: 172.21.86.141
> Transmission Control Protocol, Src Port: 2049, Dst Port: 997, Seq: 325, Ack: 257, Len: 324
> Remote Procedure Call, Type:Reply XID:0x29009a8c
> Network File System, Ops(5): SEQUENCE PUTFH OPEN ACCESS GETATTR
>     [Program Version: 4]
>     [V4 Procedure: COMPOUND (1)]
>     Status: NFS4_OK (0)
>     Tag: <EMPTY>
>         length: 0
>         contents: <EMPTY>
>     Operations (count: 5)
>         Opcode: SEQUENCE (53)
>             Status: NFS4_OK (0)
>             sessionid: f0f40f58bd020000e002000000000000
>             seqid: 0x002b3189
>             slot id: 0
>             high slot id: 30
>             target high slot id: 30
>             status flags: 0x00000040, SEQ4_STATUS_RECALLABLE_STATE_REVOKED
>                 .... .... .... .... .... .... .... ...0 = SEQ4_STATUS_CB_PATH_DOWN: Not set
>                 .... .... .... .... .... .... .... ..0. = SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING: Not set
>                 .... .... .... .... .... .... .... .0.. = SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED: Not set
>                 .... .... .... .... .... .... .... 0... = SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED: Not set
>                 .... .... .... .... .... .... ...0 .... = SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED: Not set
>                 .... .... .... .... .... .... ..0. .... = SEQ4_STATUS_ADMIN_STATE_REVOKED: Not set
>                 .... .... .... .... .... .... .1.. .... = SEQ4_STATUS_RECALLABLE_STATE_REVOKED: Set
>                 .... .... .... .... .... .... 0... .... = SEQ4_STATUS_LEASE_MOVED: Not set
>                 .... .... .... .... .... ...0 .... .... = SEQ4_STATUS_RESTART_RECLAIM_NEEDED: Not set
>                 .... .... .... .... .... ..0. .... .... = SEQ4_STATUS_CB_PATH_DOWN_SESSION: Not set
>                 .... .... .... .... .... .0.. .... .... = SEQ4_STATUS_BACKCHANNEL_FAULT: Not set
>                 .... .... .... .... .... 0... .... .... = SEQ4_STATUS_DEVID_CHANGED: Not set
>                 .... .... .... .... ...0 .... .... .... = SEQ4_STATUS_DEVID_DELETED: Not set
>         Opcode: PUTFH (22)
>             Status: NFS4_OK (0)
>         Opcode: OPEN (18)
>             Status: NFS4_OK (0)
>             stateid
>                 [StateID Hash: 0xb207]
>                 seqid: 0x00158249
>                 Data: f0f40f58bd02000092000000
>                 [Data hash (CRC-32): 0xf3e67f06]
>             change_info
>                 Atomic: No
>                 changeid (before): 0
>                 changeid (after): 0
>             result flags: 0x00000004, locktype posix
>                 .... .... .... .... .... .... .... ..0. = confirm: False
>                 .... .... .... .... .... .... .... .1.. = locktype posix: True
>                 .... .... .... .... .... .... .... 0... = preserve unlinked: False
>                 .... .... .... .... .... .... ..0. .... = may notify lock: False
>             Delegation Type: OPEN_DELEGATE_NONE (0)
>         Opcode: ACCESS (3), [Access Denied: XE], [Allowed: RD MD XT]
>             Status: NFS4_OK (0)
>             Supported types (of requested): 0x2d
>                 .... ...1 = 0x01 READ: supported
>                 .... .1.. = 0x04 MODIFY: supported
>                 .... 1... = 0x08 EXTEND: supported
>                 ..1. .... = 0x20 EXECUTE: supported
>             Access rights (of requested): 0x0d
>                 .... ...1 = 0x01 READ: allowed
>                 .... .1.. = 0x04 MODIFY: allowed
>                 .... 1... = 0x08 EXTEND: allowed
>                 ..0. .... = 0x20 EXECUTE: *Access Denied*
>         Opcode: GETATTR (9)
>             Status: NFS4_OK (0)
>             Attr mask[0]: 0x0010011a (Type, Change, Size, FSID, FileId)
>                 reqd_attr: Type (1)
>                     ftype4: NF4REG (1)
>                 reqd_attr: Change (3)
>                     changeid: 6353654913397708009
>                 reqd_attr: Size (4)
>                     size: 32768
>                 reqd_attr: FSID (8)
>                     fattr4_fsid
>                         fsid4.major: 7704996244782214878
>                         fsid4.minor: 0
>                 reco_attr: FileId (20)
>                     fileid: 4737174
>             Attr mask[1]: 0x00b0a23a (Mode, NumLinks, Owner, Owner_Group, RawDev, Space_Used, Time_Access, Time_Metadata, Time_Modify, Mounted_on_FileId)
>                 reco_attr: Mode (33)
>                     mode: 0644, Name: Unknown, Read permission for owner, Write permission for owner, Read permission for group, Read permission for others
>                         .... .... .... .... 000. .... .... .... = Name: Unknown (0)
>                         .... .... .... .... .... 0... .... .... = Set user id on exec: No
>                         .... .... .... .... .... .0.. .... .... = Set group id on exec: No
>                         .... .... .... .... .... ..0. .... .... = Save swapped text even after use: No
>                         .... .... .... .... .... ...1 .... .... = Read permission for owner: Yes
>                         .... .... .... .... .... .... 1... .... = Write permission for owner: Yes
>                         .... .... .... .... .... .... .0.. .... = Execute permission for owner: No
>                         .... .... .... .... .... .... ..1. .... = Read permission for group: Yes
>                         .... .... .... .... .... .... ...0 .... = Write permission for group: No
>                         .... .... .... .... .... .... .... 0... = Execute permission for group: No
>                         .... .... .... .... .... .... .... .1.. = Read permission for others: Yes
>                         .... .... .... .... .... .... .... ..0. = Write permission for others: No
>                         .... .... .... .... .... .... .... ...0 = Execute permission for others: No
>                 reco_attr: NumLinks (35)
>                     numlinks: 1
>                 reco_attr: Owner (36)
>                     fattr4_owner: 7143
>                         length: 4
>                         contents: 7143
>                 reco_attr: Owner_Group (37)
>                     fattr4_owner_group: 1112
>                         length: 4
>                         contents: 1112
>                 reco_attr: RawDev (41)
>                     specdata1: 0
>                     specdata2: 0
>                 reco_attr: Space_Used (45)
>                     space_used: 32768
>                 reco_attr: Time_Access (47)
>                     seconds: 1479318517
>                     nseconds: 593359867
>                 reco_attr: Time_Metadata (52)
>                     seconds: 1479325563
>                     nseconds: 175920361
>                 reco_attr: Time_Modify (53)
>                     seconds: 1479325563
>                     nseconds: 175920361
>                 reco_attr: Mounted_on_FileId (55)
>                     fileid: 0x0000000000484896
>     [Main Opcode: OPEN (18)]
> 
> Frame 4: 322 bytes on wire (2576 bits), 322 bytes captured (2576 bits) on interface 0
> Ethernet II, Src: AsrockIn_84:34:e7 (d0:50:99:84:34:e7), Dst: SuperMic_19:8e:6e (00:25:90:19:8e:6e)
> Internet Protocol Version 4, Src: 172.21.86.141, Dst: 172.21.86.74
> Transmission Control Protocol, Src Port: 997, Dst Port: 2049, Seq: 257, Ack: 649, Len: 256
> Remote Procedure Call, Type:Call XID:0x2a009a8c
> Network File System, Ops(5): SEQUENCE, PUTFH, OPEN, ACCESS, GETATTR
>     [Program Version: 4]
>     [V4 Procedure: COMPOUND (1)]
>     Tag: <EMPTY>
>         length: 0
>         contents: <EMPTY>
>     minorversion: 1
>     Operations (count: 5): SEQUENCE, PUTFH, OPEN, ACCESS, GETATTR
>         Opcode: SEQUENCE (53)
>             sessionid: f0f40f58bd020000e002000000000000
>             seqid: 0x002b318a
>             slot id: 0
>             high slot id: 0
>             cache this?: Yes
>         Opcode: PUTFH (22)
>             filehandle
>                 length: 28
>                 [hash (CRC-32): 0x26ab9d8d]
>                 filehandle: 010006016aeda54305f66ede00000000000000009a424800...
>         Opcode: OPEN (18)
>             seqid: 0x00000000
>             share_access: OPEN4_SHARE_ACCESS_BOTH (3)
>             share_deny: OPEN4_SHARE_DENY_NONE (0)
>             clientid: 0xf0f40f58bd020000
>             owner: <DATA>
>                 length: 24
>                 contents: <DATA>
>             Open Type: OPEN4_NOCREATE (0)
>             Claim Type: CLAIM_FH (4)
>         Opcode: ACCESS (3), [Check: RD MD XT XE]
>             Check access: 0x2d
>                 .... ...1 = 0x01 READ: allowed?
>                 .... .1.. = 0x04 MODIFY: allowed?
>                 .... 1... = 0x08 EXTEND: allowed?
>                 ..1. .... = 0x20 EXECUTE: allowed?
>         Opcode: GETATTR (9)
>             Attr mask[0]: 0x0010011a (Type, Change, Size, FSID, FileId)
>                 reqd_attr: Type (1)
>                 reqd_attr: Change (3)
>                 reqd_attr: Size (4)
>                 reqd_attr: FSID (8)
>                 reco_attr: FileId (20)
>             Attr mask[1]: 0x00b0a23a (Mode, NumLinks, Owner, Owner_Group, RawDev, Space_Used, Time_Access, Time_Metadata, Time_Modify, Mounted_on_FileId)
>                 reco_attr: Mode (33)
>                 reco_attr: NumLinks (35)
>                 reco_attr: Owner (36)
>                 reco_attr: Owner_Group (37)
>                 reco_attr: RawDev (41)
>                 reco_attr: Space_Used (45)
>                 reco_attr: Time_Access (47)
>                 reco_attr: Time_Metadata (52)
>                 reco_attr: Time_Modify (53)
>                 reco_attr: Mounted_on_FileId (55)
>     [Main Opcode: OPEN (18)]
> 
> Frame 5: 322 bytes on wire (2576 bits), 322 bytes captured (2576 bits) on interface 0
> Ethernet II, Src: AsrockIn_84:34:e7 (d0:50:99:84:34:e7), Dst: SuperMic_19:8e:6e (00:25:90:19:8e:6e)
> Internet Protocol Version 4, Src: 172.21.86.141, Dst: 172.21.86.74
> Transmission Control Protocol, Src Port: 997, Dst Port: 2049, Seq: 769, Ack: 1297, Len: 256
> Remote Procedure Call, Type:Call XID:0x2c009a8c
> Network File System, Ops(5): SEQUENCE, PUTFH, OPEN, ACCESS, GETATTR
>     [Program Version: 4]
>     [V4 Procedure: COMPOUND (1)]
>     Tag: <EMPTY>
>         length: 0
>         contents: <EMPTY>
>     minorversion: 1
>     Operations (count: 5): SEQUENCE, PUTFH, OPEN, ACCESS, GETATTR
>         Opcode: SEQUENCE (53)
>             sessionid: f0f40f58bd020000e002000000000000
>             seqid: 0x002b318c
>             slot id: 0
>             high slot id: 0
>             cache this?: Yes
>         Opcode: PUTFH (22)
>             filehandle
>                 length: 28
>                 [hash (CRC-32): 0x26ab9d8d]
>                 filehandle: 010006016aeda54305f66ede00000000000000009a424800...
>         Opcode: OPEN (18)
>             seqid: 0x00000000
>             share_access: OPEN4_SHARE_ACCESS_BOTH (3)
>             share_deny: OPEN4_SHARE_DENY_NONE (0)
>             clientid: 0xf0f40f58bd020000
>             owner: <DATA>
>                 length: 24
>                 contents: <DATA>
>             Open Type: OPEN4_NOCREATE (0)
>             Claim Type: CLAIM_FH (4)
>         Opcode: ACCESS (3), [Check: RD MD XT XE]
>             Check access: 0x2d
>                 .... ...1 = 0x01 READ: allowed?
>                 .... .1.. = 0x04 MODIFY: allowed?
>                 .... 1... = 0x08 EXTEND: allowed?
>                 ..1. .... = 0x20 EXECUTE: allowed?
>         Opcode: GETATTR (9)
>             Attr mask[0]: 0x0010011a (Type, Change, Size, FSID, FileId)
>                 reqd_attr: Type (1)
>                 reqd_attr: Change (3)
>                 reqd_attr: Size (4)
>                 reqd_attr: FSID (8)
>                 reco_attr: FileId (20)
>             Attr mask[1]: 0x00b0a23a (Mode, NumLinks, Owner, Owner_Group, RawDev, Space_Used, Time_Access, Time_Metadata, Time_Modify, Mounted_on_FileId)
>                 reco_attr: Mode (33)
>                 reco_attr: NumLinks (35)
>                 reco_attr: Owner (36)
>                 reco_attr: Owner_Group (37)
>                 reco_attr: RawDev (41)
>                 reco_attr: Space_Used (45)
>                 reco_attr: Time_Access (47)
>                 reco_attr: Time_Metadata (52)
>                 reco_attr: Time_Modify (53)
>                 reco_attr: Mounted_on_FileId (55)
>     [Main Opcode: OPEN (18)]
> 
> Frame 6: 390 bytes on wire (3120 bits), 390 bytes captured (3120 bits) on interface 0
> Ethernet II, Src: SuperMic_19:8e:6e (00:25:90:19:8e:6e), Dst: AsrockIn_84:34:e7 (d0:50:99:84:34:e7)
> Internet Protocol Version 4, Src: 172.21.86.74, Dst: 172.21.86.141
> Transmission Control Protocol, Src Port: 2049, Dst Port: 997, Seq: 1297, Ack: 1025, Len: 324
> Remote Procedure Call, Type:Reply XID:0x2c009a8c
> Network File System, Ops(5): SEQUENCE PUTFH OPEN ACCESS GETATTR
>     [Program Version: 4]
>     [V4 Procedure: COMPOUND (1)]
>     Status: NFS4_OK (0)
>     Tag: <EMPTY>
>         length: 0
>         contents: <EMPTY>
>     Operations (count: 5)
>         Opcode: SEQUENCE (53)
>             Status: NFS4_OK (0)
>             sessionid: f0f40f58bd020000e002000000000000
>             seqid: 0x002b318c
>             slot id: 0
>             high slot id: 30
>             target high slot id: 30
>             status flags: 0x00000040, SEQ4_STATUS_RECALLABLE_STATE_REVOKED
>                 .... .... .... .... .... .... .... ...0 = SEQ4_STATUS_CB_PATH_DOWN: Not set
>                 .... .... .... .... .... .... .... ..0. = SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING: Not set
>                 .... .... .... .... .... .... .... .0.. = SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED: Not set
>                 .... .... .... .... .... .... .... 0... = SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED: Not set
>                 .... .... .... .... .... .... ...0 .... = SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED: Not set
>                 .... .... .... .... .... .... ..0. .... = SEQ4_STATUS_ADMIN_STATE_REVOKED: Not set
>                 .... .... .... .... .... .... .1.. .... = SEQ4_STATUS_RECALLABLE_STATE_REVOKED: Set
>                 .... .... .... .... .... .... 0... .... = SEQ4_STATUS_LEASE_MOVED: Not set
>                 .... .... .... .... .... ...0 .... .... = SEQ4_STATUS_RESTART_RECLAIM_NEEDED: Not set
>                 .... .... .... .... .... ..0. .... .... = SEQ4_STATUS_CB_PATH_DOWN_SESSION: Not set
>                 .... .... .... .... .... .0.. .... .... = SEQ4_STATUS_BACKCHANNEL_FAULT: Not set
>                 .... .... .... .... .... 0... .... .... = SEQ4_STATUS_DEVID_CHANGED: Not set
>                 .... .... .... .... ...0 .... .... .... = SEQ4_STATUS_DEVID_DELETED: Not set
>         Opcode: PUTFH (22)
>             Status: NFS4_OK (0)
>         Opcode: OPEN (18)
>             Status: NFS4_OK (0)
>             stateid
>                 [StateID Hash: 0xb9c3]
>                 seqid: 0x0015824c
>                 Data: f0f40f58bd0200009e000000
>                 [Data hash (CRC-32): 0xb930c0be]
>             change_info
>                 Atomic: No
>                 changeid (before): 0
>                 changeid (after): 0
>             result flags: 0x00000004, locktype posix
>                 .... .... .... .... .... .... .... ..0. = confirm: False
>                 .... .... .... .... .... .... .... .1.. = locktype posix: True
>                 .... .... .... .... .... .... .... 0... = preserve unlinked: False
>                 .... .... .... .... .... .... ..0. .... = may notify lock: False
>             Delegation Type: OPEN_DELEGATE_NONE (0)
>         Opcode: ACCESS (3), [Access Denied: XE], [Allowed: RD MD XT]
>             Status: NFS4_OK (0)
>             Supported types (of requested): 0x2d
>                 .... ...1 = 0x01 READ: supported
>                 .... .1.. = 0x04 MODIFY: supported
>                 .... 1... = 0x08 EXTEND: supported
>                 ..1. .... = 0x20 EXECUTE: supported
>             Access rights (of requested): 0x0d
>                 .... ...1 = 0x01 READ: allowed
>                 .... .1.. = 0x04 MODIFY: allowed
>                 .... 1... = 0x08 EXTEND: allowed
>                 ..0. .... = 0x20 EXECUTE: *Access Denied*
>         Opcode: GETATTR (9)
>             Status: NFS4_OK (0)
>             Attr mask[0]: 0x0010011a (Type, Change, Size, FSID, FileId)
>                 reqd_attr: Type (1)
>                     ftype4: NF4REG (1)
>                 reqd_attr: Change (3)
>                     changeid: 6310935438380194724
>                 reqd_attr: Size (4)
>                     size: 24576
>                 reqd_attr: FSID (8)
>                     fattr4_fsid
>                         fsid4.major: 7704996244782214878
>                         fsid4.minor: 0
>                 reco_attr: FileId (20)
>                     fileid: 4735642
>             Attr mask[1]: 0x00b0a23a (Mode, NumLinks, Owner, Owner_Group, RawDev, Space_Used, Time_Access, Time_Metadata, Time_Modify, Mounted_on_FileId)
>                 reco_attr: Mode (33)
>                     mode: 0644, Name: Unknown, Read permission for owner, Write permission for owner, Read permission for group, Read permission for others
>                         .... .... .... .... 000. .... .... .... = Name: Unknown (0)
>                         .... .... .... .... .... 0... .... .... = Set user id on exec: No
>                         .... .... .... .... .... .0.. .... .... = Set group id on exec: No
>                         .... .... .... .... .... ..0. .... .... = Save swapped text even after use: No
>                         .... .... .... .... .... ...1 .... .... = Read permission for owner: Yes
>                         .... .... .... .... .... .... 1... .... = Write permission for owner: Yes
>                         .... .... .... .... .... .... .0.. .... = Execute permission for owner: No
>                         .... .... .... .... .... .... ..1. .... = Read permission for group: Yes
>                         .... .... .... .... .... .... ...0 .... = Write permission for group: No
>                         .... .... .... .... .... .... .... 0... = Execute permission for group: No
>                         .... .... .... .... .... .... .... .1.. = Read permission for others: Yes
>                         .... .... .... .... .... .... .... ..0. = Write permission for others: No
>                         .... .... .... .... .... .... .... ...0 = Execute permission for others: No
>                 reco_attr: NumLinks (35)
>                     numlinks: 1
>                 reco_attr: Owner (36)
>                     fattr4_owner: 7143
>                         length: 4
>                         contents: 7143
>                 reco_attr: Owner_Group (37)
>                     fattr4_owner_group: 1112
>                         length: 4
>                         contents: 1112
>                 reco_attr: RawDev (41)
>                     specdata1: 0
>                     specdata2: 0
>                 reco_attr: Space_Used (45)
>                     space_used: 24576
>                 reco_attr: Time_Access (47)
>                     seconds: 1479325563
>                     nseconds: 305919836
>                 reco_attr: Time_Metadata (52)
>                     seconds: 1469379160
>                     nseconds: 756243364
>                 reco_attr: Time_Modify (53)
>                     seconds: 1469379160
>                     nseconds: 756243364
>                 reco_attr: Mounted_on_FileId (55)
>                     fileid: 0x000000000048429a
>     [Main Opcode: OPEN (18)]
> 
> Frame 7: 322 bytes on wire (2576 bits), 322 bytes captured (2576 bits) on interface 0
> Ethernet II, Src: AsrockIn_84:34:e7 (d0:50:99:84:34:e7), Dst: SuperMic_19:8e:6e (00:25:90:19:8e:6e)
> Internet Protocol Version 4, Src: 172.21.86.141, Dst: 172.21.86.74
> Transmission Control Protocol, Src Port: 997, Dst Port: 2049, Seq: 1025, Ack: 1621, Len: 256
> Remote Procedure Call, Type:Call XID:0x2d009a8c
> Network File System, Ops(5): SEQUENCE, PUTFH, OPEN, ACCESS, GETATTR
>     [Program Version: 4]
>     [V4 Procedure: COMPOUND (1)]
>     Tag: <EMPTY>
>         length: 0
>         contents: <EMPTY>
>     minorversion: 1
>     Operations (count: 5): SEQUENCE, PUTFH, OPEN, ACCESS, GETATTR
>         Opcode: SEQUENCE (53)
>             sessionid: f0f40f58bd020000e002000000000000
>             seqid: 0x002b318d
>             slot id: 0
>             high slot id: 0
>             cache this?: Yes
>         Opcode: PUTFH (22)
>             filehandle
>                 length: 28
>                 [hash (CRC-32): 0xdcaec4f7]
>                 filehandle: 010006016aeda54305f66ede000000000000000096484800...
>         Opcode: OPEN (18)
>             seqid: 0x00000000
>             share_access: OPEN4_SHARE_ACCESS_BOTH (3)
>             share_deny: OPEN4_SHARE_DENY_NONE (0)
>             clientid: 0xf0f40f58bd020000
>             owner: <DATA>
>                 length: 24
>                 contents: <DATA>
>             Open Type: OPEN4_NOCREATE (0)
>             Claim Type: CLAIM_FH (4)
>         Opcode: ACCESS (3), [Check: RD MD XT XE]
>             Check access: 0x2d
>                 .... ...1 = 0x01 READ: allowed?
>                 .... .1.. = 0x04 MODIFY: allowed?
>                 .... 1... = 0x08 EXTEND: allowed?
>                 ..1. .... = 0x20 EXECUTE: allowed?
>         Opcode: GETATTR (9)
>             Attr mask[0]: 0x0010011a (Type, Change, Size, FSID, FileId)
>                 reqd_attr: Type (1)
>                 reqd_attr: Change (3)
>                 reqd_attr: Size (4)
>                 reqd_attr: FSID (8)
>                 reco_attr: FileId (20)
>             Attr mask[1]: 0x00b0a23a (Mode, NumLinks, Owner, Owner_Group, RawDev, Space_Used, Time_Access, Time_Metadata, Time_Modify, Mounted_on_FileId)
>                 reco_attr: Mode (33)
>                 reco_attr: NumLinks (35)
>                 reco_attr: Owner (36)
>                 reco_attr: Owner_Group (37)
>                 reco_attr: RawDev (41)
>                 reco_attr: Space_Used (45)
>                 reco_attr: Time_Access (47)
>                 reco_attr: Time_Metadata (52)
>                 reco_attr: Time_Modify (53)
>                 reco_attr: Mounted_on_FileId (55)
>     [Main Opcode: OPEN (18)]
> 
> Frame 8: 390 bytes on wire (3120 bits), 390 bytes captured (3120 bits) on interface 0
> Ethernet II, Src: SuperMic_19:8e:6e (00:25:90:19:8e:6e), Dst: AsrockIn_84:34:e7 (d0:50:99:84:34:e7)
> Internet Protocol Version 4, Src: 172.21.86.74, Dst: 172.21.86.141
> Transmission Control Protocol, Src Port: 2049, Dst Port: 997, Seq: 1621, Ack: 1281, Len: 324
> Remote Procedure Call, Type:Reply XID:0x2d009a8c
> Network File System, Ops(5): SEQUENCE PUTFH OPEN ACCESS GETATTR
>     [Program Version: 4]
>     [V4 Procedure: COMPOUND (1)]
>     Status: NFS4_OK (0)
>     Tag: <EMPTY>
>         length: 0
>         contents: <EMPTY>
>     Operations (count: 5)
>         Opcode: SEQUENCE (53)
>             Status: NFS4_OK (0)
>             sessionid: f0f40f58bd020000e002000000000000
>             seqid: 0x002b318d
>             slot id: 0
>             high slot id: 30
>             target high slot id: 30
>             status flags: 0x00000040, SEQ4_STATUS_RECALLABLE_STATE_REVOKED
>                 .... .... .... .... .... .... .... ...0 = SEQ4_STATUS_CB_PATH_DOWN: Not set
>                 .... .... .... .... .... .... .... ..0. = SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING: Not set
>                 .... .... .... .... .... .... .... .0.. = SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED: Not set
>                 .... .... .... .... .... .... .... 0... = SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED: Not set
>                 .... .... .... .... .... .... ...0 .... = SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED: Not set
>                 .... .... .... .... .... .... ..0. .... = SEQ4_STATUS_ADMIN_STATE_REVOKED: Not set
>                 .... .... .... .... .... .... .1.. .... = SEQ4_STATUS_RECALLABLE_STATE_REVOKED: Set
>                 .... .... .... .... .... .... 0... .... = SEQ4_STATUS_LEASE_MOVED: Not set
>                 .... .... .... .... .... ...0 .... .... = SEQ4_STATUS_RESTART_RECLAIM_NEEDED: Not set
>                 .... .... .... .... .... ..0. .... .... = SEQ4_STATUS_CB_PATH_DOWN_SESSION: Not set
>                 .... .... .... .... .... .0.. .... .... = SEQ4_STATUS_BACKCHANNEL_FAULT: Not set
>                 .... .... .... .... .... 0... .... .... = SEQ4_STATUS_DEVID_CHANGED: Not set
>                 .... .... .... .... ...0 .... .... .... = SEQ4_STATUS_DEVID_DELETED: Not set
>         Opcode: PUTFH (22)
>             Status: NFS4_OK (0)
>         Opcode: OPEN (18)
>             Status: NFS4_OK (0)
>             stateid
>                 [StateID Hash: 0x1925]
>                 seqid: 0x0015824b
>                 Data: f0f40f58bd02000092000000
>                 [Data hash (CRC-32): 0xf3e67f06]
>             change_info
>                 Atomic: No
>                 changeid (before): 0
>                 changeid (after): 0
>             result flags: 0x00000004, locktype posix
>                 .... .... .... .... .... .... .... ..0. = confirm: False
>                 .... .... .... .... .... .... .... .1.. = locktype posix: True
>                 .... .... .... .... .... .... .... 0... = preserve unlinked: False
>                 .... .... .... .... .... .... ..0. .... = may notify lock: False
>             Delegation Type: OPEN_DELEGATE_NONE (0)
>         Opcode: ACCESS (3), [Access Denied: XE], [Allowed: RD MD XT]
>             Status: NFS4_OK (0)
>             Supported types (of requested): 0x2d
>                 .... ...1 = 0x01 READ: supported
>                 .... .1.. = 0x04 MODIFY: supported
>                 .... 1... = 0x08 EXTEND: supported
>                 ..1. .... = 0x20 EXECUTE: supported
>             Access rights (of requested): 0x0d
>                 .... ...1 = 0x01 READ: allowed
>                 .... .1.. = 0x04 MODIFY: allowed
>                 .... 1... = 0x08 EXTEND: allowed
>                 ..0. .... = 0x20 EXECUTE: *Access Denied*
>         Opcode: GETATTR (9)
>             Status: NFS4_OK (0)
>             Attr mask[0]: 0x0010011a (Type, Change, Size, FSID, FileId)
>                 reqd_attr: Type (1)
>                     ftype4: NF4REG (1)
>                 reqd_attr: Change (3)
>                     changeid: 6353654913397708009
>                 reqd_attr: Size (4)
>                     size: 32768
>                 reqd_attr: FSID (8)
>                     fattr4_fsid
>                         fsid4.major: 7704996244782214878
>                         fsid4.minor: 0
>                 reco_attr: FileId (20)
>                     fileid: 4737174
>             Attr mask[1]: 0x00b0a23a (Mode, NumLinks, Owner, Owner_Group, RawDev, Space_Used, Time_Access, Time_Metadata, Time_Modify, Mounted_on_FileId)
>                 reco_attr: Mode (33)
>                     mode: 0644, Name: Unknown, Read permission for owner, Write permission for owner, Read permission for group, Read permission for others
>                         .... .... .... .... 000. .... .... .... = Name: Unknown (0)
>                         .... .... .... .... .... 0... .... .... = Set user id on exec: No
>                         .... .... .... .... .... .0.. .... .... = Set group id on exec: No
>                         .... .... .... .... .... ..0. .... .... = Save swapped text even after use: No
>                         .... .... .... .... .... ...1 .... .... = Read permission for owner: Yes
>                         .... .... .... .... .... .... 1... .... = Write permission for owner: Yes
>                         .... .... .... .... .... .... .0.. .... = Execute permission for owner: No
>                         .... .... .... .... .... .... ..1. .... = Read permission for group: Yes
>                         .... .... .... .... .... .... ...0 .... = Write permission for group: No
>                         .... .... .... .... .... .... .... 0... = Execute permission for group: No
>                         .... .... .... .... .... .... .... .1.. = Read permission for others: Yes
>                         .... .... .... .... .... .... .... ..0. = Write permission for others: No
>                         .... .... .... .... .... .... .... ...0 = Execute permission for others: No
>                 reco_attr: NumLinks (35)
>                     numlinks: 1
>                 reco_attr: Owner (36)
>                     fattr4_owner: 7143
>                         length: 4
>                         contents: 7143
>                 reco_attr: Owner_Group (37)
>                     fattr4_owner_group: 1112
>                         length: 4
>                         contents: 1112
>                 reco_attr: RawDev (41)
>                     specdata1: 0
>                     specdata2: 0
>                 reco_attr: Space_Used (45)
>                     space_used: 32768
>                 reco_attr: Time_Access (47)
>                     seconds: 1479318517
>                     nseconds: 593359867
>                 reco_attr: Time_Metadata (52)
>                     seconds: 1479325563
>                     nseconds: 175920361
>                 reco_attr: Time_Modify (53)
>                     seconds: 1479325563
>                     nseconds: 175920361
>                 reco_attr: Mounted_on_FileId (55)
>                     fileid: 0x0000000000484896
>     [Main Opcode: OPEN (18)]
> 
> Frame 9: 322 bytes on wire (2576 bits), 322 bytes captured (2576 bits) on interface 0
> Ethernet II, Src: AsrockIn_84:34:e7 (d0:50:99:84:34:e7), Dst: SuperMic_19:8e:6e (00:25:90:19:8e:6e)
> Internet Protocol Version 4, Src: 172.21.86.141, Dst: 172.21.86.74
> Transmission Control Protocol, Src Port: 997, Dst Port: 2049, Seq: 1281, Ack: 1945, Len: 256
> Remote Procedure Call, Type:Call XID:0x2e009a8c
> Network File System, Ops(5): SEQUENCE, PUTFH, OPEN, ACCESS, GETATTR
>     [Program Version: 4]
>     [V4 Procedure: COMPOUND (1)]
>     Tag: <EMPTY>
>         length: 0
>         contents: <EMPTY>
>     minorversion: 1
>     Operations (count: 5): SEQUENCE, PUTFH, OPEN, ACCESS, GETATTR
>         Opcode: SEQUENCE (53)
>             sessionid: f0f40f58bd020000e002000000000000
>             seqid: 0x002b318e
>             slot id: 0
>             high slot id: 0
>             cache this?: Yes
>         Opcode: PUTFH (22)
>             filehandle
>                 length: 28
>                 [hash (CRC-32): 0x26ab9d8d]
>                 filehandle: 010006016aeda54305f66ede00000000000000009a424800...
>         Opcode: OPEN (18)
>             seqid: 0x00000000
>             share_access: OPEN4_SHARE_ACCESS_BOTH (3)
>             share_deny: OPEN4_SHARE_DENY_NONE (0)
>             clientid: 0xf0f40f58bd020000
>             owner: <DATA>
>                 length: 24
>                 contents: <DATA>
>             Open Type: OPEN4_NOCREATE (0)
>             Claim Type: CLAIM_FH (4)
>         Opcode: ACCESS (3), [Check: RD MD XT XE]
>             Check access: 0x2d
>                 .... ...1 = 0x01 READ: allowed?
>                 .... .1.. = 0x04 MODIFY: allowed?
>                 .... 1... = 0x08 EXTEND: allowed?
>                 ..1. .... = 0x20 EXECUTE: allowed?
>         Opcode: GETATTR (9)
>             Attr mask[0]: 0x0010011a (Type, Change, Size, FSID, FileId)
>                 reqd_attr: Type (1)
>                 reqd_attr: Change (3)
>                 reqd_attr: Size (4)
>                 reqd_attr: FSID (8)
>                 reco_attr: FileId (20)
>             Attr mask[1]: 0x00b0a23a (Mode, NumLinks, Owner, Owner_Group, RawDev, Space_Used, Time_Access, Time_Metadata, Time_Modify, Mounted_on_FileId)
>                 reco_attr: Mode (33)
>                 reco_attr: NumLinks (35)
>                 reco_attr: Owner (36)
>                 reco_attr: Owner_Group (37)
>                 reco_attr: RawDev (41)
>                 reco_attr: Space_Used (45)
>                 reco_attr: Time_Access (47)
>                 reco_attr: Time_Metadata (52)
>                 reco_attr: Time_Modify (53)
>                 reco_attr: Mounted_on_FileId (55)
>     [Main Opcode: OPEN (18)]
> 
> Frame 10: 390 bytes on wire (3120 bits), 390 bytes captured (3120 bits) on interface 0
> Ethernet II, Src: SuperMic_19:8e:6e (00:25:90:19:8e:6e), Dst: AsrockIn_84:34:e7 (d0:50:99:84:34:e7)
> Internet Protocol Version 4, Src: 172.21.86.74, Dst: 172.21.86.141
> Transmission Control Protocol, Src Port: 2049, Dst Port: 997, Seq: 1945, Ack: 1537, Len: 324
> Remote Procedure Call, Type:Reply XID:0x2e009a8c
> Network File System, Ops(5): SEQUENCE PUTFH OPEN ACCESS GETATTR
>     [Program Version: 4]
>     [V4 Procedure: COMPOUND (1)]
>     Status: NFS4_OK (0)
>     Tag: <EMPTY>
>         length: 0
>         contents: <EMPTY>
>     Operations (count: 5)
>         Opcode: SEQUENCE (53)
>             Status: NFS4_OK (0)
>             sessionid: f0f40f58bd020000e002000000000000
>             seqid: 0x002b318e
>             slot id: 0
>             high slot id: 30
>             target high slot id: 30
>             status flags: 0x00000040, SEQ4_STATUS_RECALLABLE_STATE_REVOKED
>                 .... .... .... .... .... .... .... ...0 = SEQ4_STATUS_CB_PATH_DOWN: Not set
>                 .... .... .... .... .... .... .... ..0. = SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING: Not set
>                 .... .... .... .... .... .... .... .0.. = SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED: Not set
>                 .... .... .... .... .... .... .... 0... = SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED: Not set
>                 .... .... .... .... .... .... ...0 .... = SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED: Not set
>                 .... .... .... .... .... .... ..0. .... = SEQ4_STATUS_ADMIN_STATE_REVOKED: Not set
>                 .... .... .... .... .... .... .1.. .... = SEQ4_STATUS_RECALLABLE_STATE_REVOKED: Set
>                 .... .... .... .... .... .... 0... .... = SEQ4_STATUS_LEASE_MOVED: Not set
>                 .... .... .... .... .... ...0 .... .... = SEQ4_STATUS_RESTART_RECLAIM_NEEDED: Not set
>                 .... .... .... .... .... ..0. .... .... = SEQ4_STATUS_CB_PATH_DOWN_SESSION: Not set
>                 .... .... .... .... .... .0.. .... .... = SEQ4_STATUS_BACKCHANNEL_FAULT: Not set
>                 .... .... .... .... .... 0... .... .... = SEQ4_STATUS_DEVID_CHANGED: Not set
>                 .... .... .... .... ...0 .... .... .... = SEQ4_STATUS_DEVID_DELETED: Not set
>         Opcode: PUTFH (22)
>             Status: NFS4_OK (0)
>         Opcode: OPEN (18)
>             Status: NFS4_OK (0)
>             stateid
>                 [StateID Hash: 0xec52]
>                 seqid: 0x0015824d
>                 Data: f0f40f58bd0200009e000000
>                 [Data hash (CRC-32): 0xb930c0be]
>             change_info
>                 Atomic: No
>                 changeid (before): 0
>                 changeid (after): 0
>             result flags: 0x00000004, locktype posix
>                 .... .... .... .... .... .... .... ..0. = confirm: False
>                 .... .... .... .... .... .... .... .1.. = locktype posix: True
>                 .... .... .... .... .... .... .... 0... = preserve unlinked: False
>                 .... .... .... .... .... .... ..0. .... = may notify lock: False
>             Delegation Type: OPEN_DELEGATE_NONE (0)
>         Opcode: ACCESS (3), [Access Denied: XE], [Allowed: RD MD XT]
>             Status: NFS4_OK (0)
>             Supported types (of requested): 0x2d
>                 .... ...1 = 0x01 READ: supported
>                 .... .1.. = 0x04 MODIFY: supported
>                 .... 1... = 0x08 EXTEND: supported
>                 ..1. .... = 0x20 EXECUTE: supported
>             Access rights (of requested): 0x0d
>                 .... ...1 = 0x01 READ: allowed
>                 .... .1.. = 0x04 MODIFY: allowed
>                 .... 1... = 0x08 EXTEND: allowed
>                 ..0. .... = 0x20 EXECUTE: *Access Denied*
>         Opcode: GETATTR (9)
>             Status: NFS4_OK (0)
>             Attr mask[0]: 0x0010011a (Type, Change, Size, FSID, FileId)
>                 reqd_attr: Type (1)
>                     ftype4: NF4REG (1)
>                 reqd_attr: Change (3)
>                     changeid: 6310935438380194724
>                 reqd_attr: Size (4)
>                     size: 24576
>                 reqd_attr: FSID (8)
>                     fattr4_fsid
>                         fsid4.major: 7704996244782214878
>                         fsid4.minor: 0
>                 reco_attr: FileId (20)
>                     fileid: 4735642
>             Attr mask[1]: 0x00b0a23a (Mode, NumLinks, Owner, Owner_Group, RawDev, Space_Used, Time_Access, Time_Metadata, Time_Modify, Mounted_on_FileId)
>                 reco_attr: Mode (33)
>                     mode: 0644, Name: Unknown, Read permission for owner, Write permission for owner, Read permission for group, Read permission for others
>                         .... .... .... .... 000. .... .... .... = Name: Unknown (0)
>                         .... .... .... .... .... 0... .... .... = Set user id on exec: No
>                         .... .... .... .... .... .0.. .... .... = Set group id on exec: No
>                         .... .... .... .... .... ..0. .... .... = Save swapped text even after use: No
>                         .... .... .... .... .... ...1 .... .... = Read permission for owner: Yes
>                         .... .... .... .... .... .... 1... .... = Write permission for owner: Yes
>                         .... .... .... .... .... .... .0.. .... = Execute permission for owner: No
>                         .... .... .... .... .... .... ..1. .... = Read permission for group: Yes
>                         .... .... .... .... .... .... ...0 .... = Write permission for group: No
>                         .... .... .... .... .... .... .... 0... = Execute permission for group: No
>                         .... .... .... .... .... .... .... .1.. = Read permission for others: Yes
>                         .... .... .... .... .... .... .... ..0. = Write permission for others: No
>                         .... .... .... .... .... .... .... ...0 = Execute permission for others: No
>                 reco_attr: NumLinks (35)
>                     numlinks: 1
>                 reco_attr: Owner (36)
>                     fattr4_owner: 7143
>                         length: 4
>                         contents: 7143
>                 reco_attr: Owner_Group (37)
>                     fattr4_owner_group: 1112
>                         length: 4
>                         contents: 1112
>                 reco_attr: RawDev (41)
>                     specdata1: 0
>                     specdata2: 0
>                 reco_attr: Space_Used (45)
>                     space_used: 24576
>                 reco_attr: Time_Access (47)
>                     seconds: 1479325563
>                     nseconds: 305919836
>                 reco_attr: Time_Metadata (52)
>                     seconds: 1469379160
>                     nseconds: 756243364
>                 reco_attr: Time_Modify (53)
>                     seconds: 1469379160
>                     nseconds: 756243364
>                 reco_attr: Mounted_on_FileId (55)
>                     fileid: 0x000000000048429a
>     [Main Opcode: OPEN (18)]
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
