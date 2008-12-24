From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [PATCH 1/1] nfsd(v2/v3): fix the failure of creation from HPUX
 client
Date: Wed, 24 Dec 2008 14:47:08 +0530
Message-ID: <4951FE14.9010504@suse.de>
References: <200812240537.mBO5blpr005502@acsinet13.oracle.com> <4951E169.40809@suse.de> <4951EF80.1050209@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: wengang wang <wen.gang.wang@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:35702 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbYLXJRl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2008 04:17:41 -0500
In-Reply-To: <4951EF80.1050209@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

wengang wang wrote:
> Suresh Jayaraman wrote:
>> wengang wang wrote:
>>  
>>> sometimes HPUX nfs client sends a create request to linux nfs
>>> server(v2/v3).
>>> the dump of the request is like:
>>>     obj_attributes
>>>         mode: value follows
>>>             set_it: value follows (1)
>>>             mode: 00
>>>         uid: no value
>>>             set_it: no value (0)
>>>         gid: value follows
>>>             set_it: value follows (1)
>>>             gid: 8030
>>>         size: value follows
>>>             set_it: value follows (1)
>>>             size: 0
>>>         atime: don't change
>>>             set_it: don't change (0)
>>>         mtime: don't change
>>>             set_it: don't change (0)
>>>
>>> note that mode is 00(havs no rwx privilege even for the owner) and it
>>> requires
>>> to set size to 0.
>>>     
>>
>>
>> What's the Create Mode in this case? EXCLUSIVE or UNCHECKED?
>>   
> it's UNCHECKED.
>> What's the error the server is returning without this patch -
>> ERR_NOTSUPP?
>>
>>   
> permission deny, that is NFS3ERR_ACCES.
>> I tested this on 2.6.27.7 with a small program which does this:
>>         fd = open("file", O_CREAT, 0000);
>>
>> The file creation succeeded with file size set to 0 and the subsequent
>> chmod too.
>>
>>   
> tcpdump available for your test?
> just after the creation, is the file mode 0000?

Here are the relevant packets (both server and client are running 2.6.27.7)


<snip>
V3 LOOKUP Call (Reply In 153), DH:0x83dc449c/myfile

Frame 152 (186 bytes on wire, 186 bytes captured)
Ethernet II, Src: Foxconn_ca:9d:29 (00:15:58:ca:9d:29), Dst:
HewlettP_06:50:f9 (00:14:c2:06:50:f9)
Internet Protocol, Src: 164.99.138.53 (164.99.138.53), Dst:
164.99.138.52 (164.99.138.52)
Transmission Control Protocol, Src Port: 882 (882), Dst Port: nfs
(2049), Seq: 1, Ack: 1, Len: 120
Remote Procedure Call, Type:Call XID:0x3eb00345
Network File System, LOOKUP Call DH:0x83dc449c/myfile
    [Program Version: 3]
    [V3 Procedure: LOOKUP (3)]
    what
        dir
        Name: myfile

V3 LOOKUP Reply (Call In 152) Error:NFS3ERR_NOENT

Frame 153 (186 bytes on wire, 186 bytes captured)
Ethernet II, Src: HewlettP_06:50:f9 (00:14:c2:06:50:f9), Dst:
Foxconn_ca:9d:29 (00:15:58:ca:9d:29)
Internet Protocol, Src: 164.99.138.52 (164.99.138.52), Dst:
164.99.138.53 (164.99.138.53)
Transmission Control Protocol, Src Port: nfs (2049), Dst Port: 882
(882), Seq: 1, Ack: 121, Len: 120
Remote Procedure Call, Type:Reply XID:0x3eb00345
Network File System, LOOKUP Reply  Error:NFS3ERR_NOENT
    [Program Version: 3]
    [V3 Procedure: LOOKUP (3)]
    Status: NFS3ERR_NOENT (2)
    dir_attributes  Directory mode:0777 uid:0 gid:0
        attributes_follow: value follows (1)
        attributes  Directory mode:0777 uid:0 gid:0
            Type: Directory (2)
            mode: 040777
                0... .... .... = not SUID
                .0.. .... .... = not SGID
                ..0. .... .... = not save swapped text
                ...1 .... .... = Read permission for owner
                .... 1... .... = Write permission for owner
                .... .1.. .... = Execute permission for owner
                .... ..1. .... = Read permission for group
                .... ...1 .... = Write permission for group
                .... .... 1... = Execute permission for group
                .... .... .1.. = Read permission for others
                .... .... ..1. = Write permission for others
                .... .... ...1 = Execute permission for others
            nlink: 2
            uid: 0
            gid: 0
            size: 4096
            used: 4096
            rdev: 0,0
            fsid: 0xd6aa5ceb9647d2e8
            fileid: 2970241
            atime: Dec 24, 2008 12:06:42.000000000
            mtime: Dec 24, 2008 12:06:42.000000000
            ctime: Dec 24, 2008 12:06:42.000000000

V3 CREATE Call (Reply In 156), DH:0x83dc449c/myfile Mode:UNCHECKED

Frame 155 (218 bytes on wire, 218 bytes captured)
Ethernet II, Src: Foxconn_ca:9d:29 (00:15:58:ca:9d:29), Dst:
HewlettP_06:50:f9 (00:14:c2:06:50:f9)
Internet Protocol, Src: 164.99.138.53 (164.99.138.53), Dst:
164.99.138.52 (164.99.138.52)
Transmission Control Protocol, Src Port: 882 (882), Dst Port: nfs
(2049), Seq: 121, Ack: 121, Len: 152
Remote Procedure Call, Type:Call XID:0x3fb00345
Network File System, CREATE Call DH:0x83dc449c/myfile Mode:UNCHECKED
    [Program Version: 3]
    [V3 Procedure: CREATE (8)]
    where
        dir
        Name: myfile
    Create Mode: UNCHECKED (0)
    obj_attributes
        mode: value follows
            set_it: value follows (1)
            mode: 00
                0... .... .... = not SUID
                .0.. .... .... = not SGID
                ..0. .... .... = not save swapped text
                ...0 .... .... = no Read permission for owner
                .... 0... .... = no Write permission for owner
                .... .0.. .... = no Execute permission for owner
                .... ..0. .... = no Read permission for group
                .... ...0 .... = no Write permission for group
                .... .... 0... = no Execute permission for group
                .... .... .0.. = no Read permission for others
                .... .... ..0. = no Write permission for others
                .... .... ...0 = no Execute permission for others
        uid: no value
        gid: no value
        size: no value
        atime: don't change
        mtime: don't change

V3 CREATE Reply (Call In 155)

Frame 156 (346 bytes on wire, 346 bytes captured)
Ethernet II, Src: HewlettP_06:50:f9 (00:14:c2:06:50:f9), Dst:
Foxconn_ca:9d:29 (00:15:58:ca:9d:29)
Internet Protocol, Src: 164.99.138.52 (164.99.138.52), Dst:
164.99.138.53 (164.99.138.53)
Transmission Control Protocol, Src Port: nfs (2049), Dst Port: 882
(882), Seq: 121, Ack: 273, Len: 280
Remote Procedure Call, Type:Reply XID:0x3fb00345
Network File System, CREATE Reply
    [Program Version: 3]
    [V3 Procedure: CREATE (8)]
    Status: NFS3_OK (0)
    obj
    obj_attributes  Regular File mode:0000 uid:0 gid:0
        attributes_follow: value follows (1)
        attributes  Regular File mode:0000 uid:0 gid:0
            Type: Regular File (1)
            mode: 0100000
                0... .... .... = not SUID
                .0.. .... .... = not SGID
                ..0. .... .... = not save swapped text
                ...0 .... .... = no Read permission for owner
                .... 0... .... = no Write permission for owner
                .... .0.. .... = no Execute permission for owner
                .... ..0. .... = no Read permission for group
                .... ...0 .... = no Write permission for group
                .... .... 0... = no Execute permission for group
                .... .... .0.. = no Read permission for others
                .... .... ..0. = no Write permission for others
                .... .... ...0 = no Execute permission for others
            nlink: 1
            uid: 0
            gid: 0
            size: 0
            used: 0
            rdev: 0,0
            fsid: 0xd6aa5ceb9647d2e8
            fileid: 1615722
            atime: Dec 24, 2008 12:07:03.000000000
            mtime: Dec 24, 2008 12:07:03.000000000
            ctime: Dec 24, 2008 12:07:03.000000000
    dir_wcc
</snip>



Thanks,

--
Suresh Jayaraman
