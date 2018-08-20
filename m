Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr660045.outbound.protection.outlook.com ([40.107.66.45]:59897
        "EHLO CAN01-QB1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726498AbeHUBEL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Aug 2018 21:04:11 -0400
From: Rick Macklem <rmacklem@uoguelph.ca>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
CC: Tom Haynes <loghyr@gmail.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        trondmy <trondmy@hammerspace.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: Re: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for tightly
 coupled DSes
Date: Mon, 20 Aug 2018 21:46:49 +0000
Message-ID: <YTOPR0101MB182054F5F31B22AECD557B91DD320@YTOPR0101MB1820.CANPRD01.PROD.OUTLOOK.COM>
References: <20180820065608.11860-1-tigran.mkrtchyan@desy.de>
 <YTOPR0101MB18202768E081C824A96ECC0ADD320@YTOPR0101MB1820.CANPRD01.PROD.OUTLOOK.COM>
 <YTOPR0101MB18201895B73ED2C4BA3B0840DD320@YTOPR0101MB1820.CANPRD01.PROD.OUTLOOK.COM>
 <1195851744.36922369.1534797661849.JavaMail.zimbra@desy.de>
 <17A5ECEC-6350-4A8E-B390-C9574848F6F4@gmail.com>
 <YTOPR0101MB1820D440041C1BE87E3190B4DD320@YTOPR0101MB1820.CANPRD01.PROD.OUTLOOK.COM>,<377634665.36930927.1534800515611.JavaMail.zimbra@desy.de>
In-Reply-To: <377634665.36930927.1534800515611.JavaMail.zimbra@desy.de>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mkrtchyan, Tigran wrote:
[stuff snipped for brevity]
>Rick Macklem wrote:
>> Sure. Since the above states that the loosely coupled server must fill it in as
>> the anonymous stated, the client will end up using the anonymous stated
>> for loosely coupled, whether it uses ffds_stateid or just sets it to the
>> anonymous stated. (Unpatched, the client always use the anonymous stated,
>> including for tightly coupled.)
>
>I am not sure that's true, as our DSes will reject such IO requests. And we
>do use flex_files in production:
Oops, yes, you are correct. (It has been a while since I did this.)
The unpatched driver uses whatever it would use for the MDS (an open/lock/…
stated). If the server sends the same stateid in the layout, then you wouldn't notice.
(I'd guess Primary Data is using NFSv3 data servers, so they wouldn't notice either.)

Oh, and ignore my comment about taking out the code at the end of
ff_layout_read_prepare_v4() and ff_layout_write_prepare_v4() unless you know
of a better way to handle the failure case than filling in the stateid that would
be used against the MDS when it can't get the ffds_stateid.

rick

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
