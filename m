Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:37796 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726099AbeHUApy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Aug 2018 20:45:54 -0400
Received: from smtp-buf-3.desy.de (smtp-buf-3.desy.de [IPv6:2001:638:700:1038::1:a6])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 8B0DB28087C
        for <linux-nfs@vger.kernel.org>; Mon, 20 Aug 2018 23:28:36 +0200 (CEST)
Date: Mon, 20 Aug 2018 23:28:35 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Rick Macklem <rmacklem@uoguelph.ca>
Cc: Tom Haynes <loghyr@gmail.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        trondmy <trondmy@hammerspace.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <377634665.36930927.1534800515611.JavaMail.zimbra@desy.de>
In-Reply-To: <YTOPR0101MB1820D440041C1BE87E3190B4DD320@YTOPR0101MB1820.CANPRD01.PROD.OUTLOOK.COM>
References: <20180820065608.11860-1-tigran.mkrtchyan@desy.de> <YTOPR0101MB18202768E081C824A96ECC0ADD320@YTOPR0101MB1820.CANPRD01.PROD.OUTLOOK.COM> <YTOPR0101MB18201895B73ED2C4BA3B0840DD320@YTOPR0101MB1820.CANPRD01.PROD.OUTLOOK.COM> <1195851744.36922369.1534797661849.JavaMail.zimbra@desy.de> <17A5ECEC-6350-4A8E-B390-C9574848F6F4@gmail.com> <YTOPR0101MB1820D440041C1BE87E3190B4DD320@YTOPR0101MB1820.CANPRD01.PROD.OUTLOOK.COM>
Subject: Re: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for tightly
 coupled DSes
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Rick Macklem" <rmacklem@uoguelph.ca>
> To: "Tom Haynes" <loghyr@gmail.com>, "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>, "trondmy" <trondmy@hammerspace.com>, "Anna Schumaker"
> <Anna.Schumaker@Netapp.com>
> Sent: Monday, August 20, 2018 11:16:22 PM
> Subject: Re: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for tightly coupled DSes

> Tom Haynes wrote:
>>> On Aug 20, 2018, at 1:41 PM, Mkrtchyan, Tigran <tigran.mkrtchyan@desy.de> wrote:
>>>
>>> Hi Rick,
>>>
>>> draft-19 says:
>>>
>>>   For tight coupling, ffds_stateid provides the stateid to be used by
>>>   the client to access the file.  For loose coupling and a NFSv4
>>>   storage device, the client will have to use an anonymous stateid to
>>>   perform I/O on the storage device.  With no control protocol, the
>>>   metadata server stateid can not be used to provide a global stateid
>>>   model.  Thus the server MUST set the ffds_stateid to be the anonymous
>>>   stateid.
>>>
>>> To me, the last sentence sounds like a clear statement, that it's server
>>> responsibility to provide either global or anonymous stateid and client
>>> should just use it as is. IOW,
>>>
>>> +     stateid = nfs4_ff_layout_select_ds_stateid(lseg, idx);
>>> +     if (stateid)
>>> +             nfs4_stateid_copy(&hdr->args.stateid, stateid);
>>>
> If you do this unconditionally, I think you can get rid of the code that looks
> like:
>             if (nfs4_set_rw_stateid(&hdr->args.stateid, hdr->args.context,
>                                          hdr->args.lock_context, FMODE_READ) == -EIO)
>                            rpc_exit(task, -EIO);  /* lost lock, terminate I/O */
> at the end of ff_layout_read_prepare_v4() and similar but with FMODE_WRITE
> at the end of ff_layout_write_prepare_v4().
> 
>>>
>>> must happen independent from ds being loose or tight coupled. As our DSes
>>> use the same stateid's as MDS, we did see that provided stateid is not used.
>>>
>>> Trond, Tom, can you comment on it?
>>
>>
>>Yes, I agree, the server always provides the stateid.
> Sure. Since the above states that the loosely coupled server must fill it in as
> the anonymous stated, the client will end up using the anonymous stated
> for loosely coupled, whether it uses ffds_stateid or just sets it to the
> anonymous stated. (Unpatched, the client always use the anonymous stated,
> including for tightly coupled.)

I am not sure that's true, as our DSes will reject such IO requests. And we
do use flex_files in production:

Frame 96: 264 bytes on wire (2112 bits), 264 bytes captured (2112 bits) on interface 0
Linux cooked capture
Internet Protocol Version 4, Src: 131.169.xx, Dst: 131.169.xx
Transmission Control Protocol, Src Port: 946, Dst Port: 32049, Seq: 925, Ack: 569, Len: 196
Remote Procedure Call, Type:Call XID:0xa09b9261
Network File System, Ops(3): SEQUENCE, PUTFH, READ
    [Program Version: 4]
    [V4 Procedure: COMPOUND (1)]
    Tag: <EMPTY>
        length: 0
        contents: <EMPTY>
    minorversion: 1
    Operations (count: 3): SEQUENCE, PUTFH, READ
        Opcode: SEQUENCE (53)
            sessionid: 5b7b31b9000000060000000000000001
            seqid: 0x00000002
            slot id: 0
            high slot id: 0
            cache this?: No
        Opcode: PUTFH (22)
            FileHandle
                length: 27
                [hash (CRC-32): 0x4c4a3909]
                FileHandle: 01caffee000000008d61f80c000d00000800000000002887...
        Opcode: READ (25)
            StateID
                [StateID Hash: 0x71b8]
                StateID seqid: 0
                StateID Other: 5b7b31b60000000500000001
                [StateID Other hash: 0xbecf]
            offset: 0
            count: 1015
    [Main Opcode: READ (25)]


Tigran.

> 
> Doing it unconditionally makes the patch even simpler.
> 
> rick
> 
>>
>> Thanks,
>>    Tigran.
>>
>> ----- Original Message -----
>>> From: "Rick Macklem" <rmacklem@uoguelph.ca>
>>> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>, "linux-nfs"
>>> <linux-nfs@vger.kernel.org>
>>> Cc: trondmy@hammerspace.com, "Anna Schumaker" <Anna.Schumaker@Netapp.com>
>>> Sent: Monday, August 20, 2018 3:18:00 PM
>>> Subject: Re: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for tightly
>>> coupled DSes
>>
>>> I just put a patch for the stated part (stripped out my version of the cred
>>> stuff, which I noticed I missed commit in it;) so it might be easier to read.
>>> It is here:
>>> http://people.freebsd.org/~rmacklem/flexfilestateid.patch
>>>
>>> Thanks for doing this, rick
>>>
>>> ________________________________________
>>> From: linux-nfs-owner@vger.kernel.org <linux-nfs-owner@vger.kernel.org> on
>>> behalf of Rick Macklem <rmacklem@uoguelph.ca>
>>> Sent: Monday, August 20, 2018 8:51:14 AM
>>> To: Tigran Mkrtchyan; linux-nfs@vger.kernel.org
>>> Cc: trondmy@hammerspace.com; Anna.Schumaker@Netapp.com
>>> Subject: Re: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for tightly
>>> coupled DSes
>>>
>>> Thanks. I'll test this later to-day. (I did a slightly more complex version
>>> of the fix outside of the ff_layout_get_ds_cred() call, but yours is
>>> definitely simpler).
>>>
>>> There is also the "stateid", which I believe is supposed to be the one in
>>> the layout for the tightly coupled case (for NFSv4 I/O ops to the DS).
>>> My patch is here and has the changes for stated as well as cred.
>>>
>>> http://people.freebsd.org/~rmacklem/flexfile.patch
>>> (Sorry, I don't know git;-)
>>>
>>> Thanks for doing this and I'll post if my testing finds problems, rick
>>>
>>>
>>> ________________________________________
>>> From: linux-nfs-owner@vger.kernel.org <linux-nfs-owner@vger.kernel.org> on
>>> behalf of Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>>> Sent: Monday, August 20, 2018 2:56:08 AM
>>> To: linux-nfs@vger.kernel.org
>>> Cc: trondmy@hammerspace.com; Anna.Schumaker@Netapp.com; Tigran Mkrtchyan
>>> Subject: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for tightly coupled
>>> DSes
>>>
>>> for tightly coupled DSes client must ignore provided synthetic uid and
>>> gid as stated in draft-ietf-nfsv4-flex-files-19#section-5.1.
>>>
>>> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>>> ---
>>> fs/nfs/flexfilelayout/flexfilelayoutdev.c | 2 +-
>>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>>> b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>>> index d62279d3fc5d..290625cfd369 100644
>>> --- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>>> +++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>>> @@ -452,7 +452,7 @@ ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg, u32
>>> ds_idx,
>>>       struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, ds_idx);
>>>       struct rpc_cred *cred;
>>>
>>> -       if (mirror) {
>>> +       if (mirror && !mirror->mirror_ds->ds_versions[0].tightly_coupled) {
>>>               cred = ff_layout_get_mirror_cred(mirror, lseg->pls_range.iomode);
>>>               if (!cred)
>>>                       cred = get_rpccred(mdscred);
>>> --
> >> 2.17.1
