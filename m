Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:52613 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751686AbcLESZs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Dec 2016 13:25:48 -0500
Subject: Re: [PATCH] overlayfs: ignore empty NFSv4 ACLs in ext4 upperdir
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Miklos Szeredi <miklos@szeredi.hu>
References: <5a6862bd-924d-25e4-2a8e-ba4f51e66604@web.de>
 <CAJfpeguwUtRWRGmNmimNp-FXzWqMCCQMb24iWPu0w_J0_rOnnw@mail.gmail.com>
 <20161205151933.GA17517@fieldses.org>
 <CAJfpegtpkavseTFLspaC7svbvHRq-0-7jvyh63+DK5iWHTGnaQ@mail.gmail.com>
 <20161205162559.GB17517@fieldses.org>
Cc: "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
From: Patrick Plagwitz <Patrick_Plagwitz@web.de>
Message-ID: <acfea369-ad43-8e8e-baf9-4c7d4e74efd4@web.de>
Date: Mon, 5 Dec 2016 19:25:34 +0100
MIME-Version: 1.0
In-Reply-To: <20161205162559.GB17517@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/05/2016 05:25 PM, J. Bruce Fields wrote:
> On Mon, Dec 05, 2016 at 04:36:03PM +0100, Miklos Szeredi wrote:
>> On Mon, Dec 5, 2016 at 4:19 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>> Can NFS people comment on this?  Where does the nfs4_acl come from?
>>>
>>> This is the interface the NFS client provides for applications to modify
>>> NFSv4 ACLs on servers that support them.
>>
>> Fine, but why are we seeing this xattr on exports where no xattrs are
>> set on the exported fs?
> 
> I don't know.  I took another look at the original patch and don't see
> any details on the server setup: which server is it (knfsd, ganesha,
> netapp, ...)?  How is it configured?
> 
The server is the one in the kernel (knfsd, I assume), with completely default
configuration. /etc/exports is

/srv/nfsv4 localhost(fsid=root)

Adding rw, or various other options, does not change the observations in the
original mail. As far as I know, there are no options for controlling ACLs.

>>>> What can overlayfs do if it's a non-empty ACL?
>>>
>>> As little as possible.  You can't copy it up, can you?  So any attempt
>>> to support it is going to be incomplete.
>>
>> Right.
>>
>>>
>>>> Does knfsd translate posix ACL into NFS acl?  If so, we can translate
>>>> back.  Should we do a generic POSIX<->NFS acl translator?
>>>
>>> knsd does translate between POSIX and NFSv4 ACLs.  It's a complicated
>>
>> This does explain the nfs4_acl xattr on the client.  Question: if it's
>> empty, why have it at all?
> 
> I'm honestly not sure what's going on there.  I'd be curious to see a
> network trace if possible.
> 
Just make folders like in the original mail, start the NFS server with the
exports from above and touch merged/folder/file to reproduce the problem.
I don't know anything about the NFS protocol but here you have a tshark
packet summary as well as the details from the folder/ lookup reply (51).
As far as I can tell, no ACL information is in there.

 22 NFS 286 V4 Call CREATE_SESSION
 23 NFS 214 V4 Reply (Call In 22) CREATE_SESSION
 24 NFS 214 V4 Call RECLAIM_COMPLETE
 26 NFS 178 V4 Reply (Call In 24) RECLAIM_COMPLETE
 27 NFS 218 V4 Call SECINFO_NO_NAME
 29 NFS 194 V4 Reply (Call In 27) SECINFO_NO_NAME
 30 NFS 230 V4 Call PUTROOTFH | GETATTR
 31 NFS 350 V4 Reply (Call In 30) PUTROOTFH | GETATTR
 32 NFS 242 V4 Call GETATTR FH: 0x62d40c52
 33 NFS 254 V4 Reply (Call In 32) GETATTR
 34 NFS 242 V4 Call GETATTR FH: 0x62d40c52
 35 NFS 254 V4 Reply (Call In 34) GETATTR
 36 NFS 242 V4 Call GETATTR FH: 0x62d40c52
 37 NFS 254 V4 Reply (Call In 36) GETATTR
 38 NFS 242 V4 Call GETATTR FH: 0x62d40c52
 39 NFS 254 V4 Reply (Call In 38) GETATTR
 40 NFS 234 V4 Call GETATTR FH: 0x62d40c52
 41 NFS 206 V4 Reply (Call In 40) GETATTR
 42 NFS 242 V4 Call GETATTR FH: 0x62d40c52
 43 NFS 254 V4 Reply (Call In 42) GETATTR
 44 NFS 238 V4 Call GETATTR FH: 0x62d40c52
 45 NFS 330 V4 Reply (Call In 44) GETATTR
 46 NFS 246 V4 Call ACCESS FH: 0x62d40c52, [Check: RD LU MD XT DL]
 47 NFS 258 V4 Reply (Call In 46) ACCESS, [Access Denied: MD XT DL], [Allowed: RD LU]
 48 NFS 238 V4 Call GETATTR FH: 0x62d40c52
 49 NFS 250 V4 Reply (Call In 48) GETATTR
 50 NFS 258 V4 Call LOOKUP DH: 0x62d40c52/folder
 51 NFS 366 V4 Reply (Call In 50) LOOKUP
 52 NFS 254 V4 Call ACCESS FH: 0x96d0c04a, [Check: RD LU MD XT DL]
 53 NFS 258 V4 Reply (Call In 52) ACCESS, [Access Denied: MD XT DL], [Allowed: RD LU]
 54 NFS 262 V4 Call LOOKUP DH: 0x96d0c04a/file
 55 NFS 186 V4 Reply (Call In 54) LOOKUP Status: NFS4ERR_NOENT
 56 NFS 246 V4 Call GETATTR FH: 0x96d0c04a
 57 NFS 278 V4 Reply (Call In 56) GETATTR

Network File System, Ops(5): SEQUENCE PUTFH LOOKUP GETFH GETATTR
    [Program Version: 4]
    [V4 Procedure: COMPOUND (1)]
    Status: NFS4_OK (0)
    Tag: <EMPTY>
        length: 0
        contents: <EMPTY>
    Operations (count: 5)
        Opcode: SEQUENCE (53)
            Status: NFS4_OK (0)
            sessionid: 50a245584a819c9a0a00000000000000
            seqid: 0x0000000d
            slot id: 0
            high slot id: 30
            target high slot id: 30
            status flags: 0x00000000
                .... .... .... .... .... .... .... ...0 = SEQ4_STATUS_CB_PATH_DOWN: Not set
                .... .... .... .... .... .... .... ..0. = SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING: Not set
                .... .... .... .... .... .... .... .0.. = SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED: Not set
                .... .... .... .... .... .... .... 0... = SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED: Not set
                .... .... .... .... .... .... ...0 .... = SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED: Not set
                .... .... .... .... .... .... ..0. .... = SEQ4_STATUS_ADMIN_STATE_REVOKED: Not set
                .... .... .... .... .... .... .0.. .... = SEQ4_STATUS_RECALLABLE_STATE_REVOKED: Not set
                .... .... .... .... .... .... 0... .... = SEQ4_STATUS_LEASE_MOVED: Not set
                .... .... .... .... .... ...0 .... .... = SEQ4_STATUS_RESTART_RECLAIM_NEEDED: Not set
                .... .... .... .... .... ..0. .... .... = SEQ4_STATUS_CB_PATH_DOWN_SESSION: Not set
                .... .... .... .... .... .0.. .... .... = SEQ4_STATUS_BACKCHANNEL_FAULT: Not set
                .... .... .... .... .... 0... .... .... = SEQ4_STATUS_DEVID_CHANGED: Not set
                .... .... .... .... ...0 .... .... .... = SEQ4_STATUS_DEVID_DELETED: Not set
        Opcode: PUTFH (22)
            Status: NFS4_OK (0)
        Opcode: LOOKUP (15)
            Status: NFS4_OK (0)
        Opcode: GETFH (10)
            Status: NFS4_OK (0)
            Filehandle
                length: 16
                [hash (CRC-32): 0x96d0c04a]
                filehandle: 0100010100000000790f04000762a435
        Opcode: GETATTR (9)
            Status: NFS4_OK (0)
            Attr mask[0]: 0x0010011a (Type, Change, Size, FSID, FileId)
                reqd_attr: Type (1)
                    ftype4: NF4DIR (2)
                reqd_attr: Change (3)
                    changeid: 6360241138682687914
                reqd_attr: Size (4)
                    size: 4096
                reqd_attr: FSID (8)
                    fattr4_fsid
                        fsid4.major: 0
                        fsid4.minor: 0
                reco_attr: FileId (20)
                    fileid: 266105
            Attr mask[1]: 0x00b0a23a (Mode, NumLinks, Owner, Owner_Group, RawDev, Space_Used, Time_Access, Time_Metadata, Time_Modify, Mounted_on_FileId)
                reco_attr: Mode (33)
                    mode: 0755, Name: Unknown, Read permission for owner, Write permission for owner, Execute permission for owner, Read permission for group, Execute
permission for group, Read permission for others, Execute permission for others
                        .... .... .... .... 000. .... .... .... = Name: Unknown (0)
                        .... .... .... .... .... 0... .... .... = Set user id on exec: No
                        .... .... .... .... .... .0.. .... .... = Set group id on exec: No
                        .... .... .... .... .... ..0. .... .... = Save swapped text even after use: No
                        .... .... .... .... .... ...1 .... .... = Read permission for owner: Yes
                        .... .... .... .... .... .... 1... .... = Write permission for owner: Yes
                        .... .... .... .... .... .... .1.. .... = Execute permission for owner: Yes
                        .... .... .... .... .... .... ..1. .... = Read permission for group: Yes
                        .... .... .... .... .... .... ...0 .... = Write permission for group: No
                        .... .... .... .... .... .... .... 1... = Execute permission for group: Yes
                        .... .... .... .... .... .... .... .1.. = Read permission for others: Yes
                        .... .... .... .... .... .... .... ..0. = Write permission for others: No
                        .... .... .... .... .... .... .... ...1 = Execute permission for others: Yes
                reco_attr: NumLinks (35)
                    numlinks: 2
                reco_attr: Owner (36)
                    fattr4_owner: 0
                        length: 1
                        contents: 0
                        fill bytes: opaque data
                reco_attr: Owner_Group (37)
                    fattr4_owner_group: 0
                        length: 1
                        contents: 0
                        fill bytes: opaque data
                reco_attr: RawDev (41)
                    specdata1: 0
                    specdata2: 0
                reco_attr: Space_Used (45)
                    space_used: 4096
                reco_attr: Time_Access (47)
                    seconds: 1480888617
                    nseconds: 513333330
                reco_attr: Time_Metadata (52)
                    seconds: 1480859038
                    nseconds: 486666666
                reco_attr: Time_Modify (53)
                    seconds: 1480859038
                    nseconds: 486666666
                reco_attr: Mounted_on_FileId (55)
                    fileid: 0x0000000000040f79
    [Main Opcode: LOOKUP (15)]
