Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr670072.outbound.protection.outlook.com ([40.107.67.72]:35744
        "EHLO CAN01-TO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726099AbeHUAha (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Aug 2018 20:37:30 -0400
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Tom Haynes <loghyr@gmail.com>,
        "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
CC: linux-nfs <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: Re: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for tightly
 coupled DSes
Date: Mon, 20 Aug 2018 21:16:22 +0000
Message-ID: <YTOPR0101MB1820D440041C1BE87E3190B4DD320@YTOPR0101MB1820.CANPRD01.PROD.OUTLOOK.COM>
References: <20180820065608.11860-1-tigran.mkrtchyan@desy.de>
 <YTOPR0101MB18202768E081C824A96ECC0ADD320@YTOPR0101MB1820.CANPRD01.PROD.OUTLOOK.COM>
 <YTOPR0101MB18201895B73ED2C4BA3B0840DD320@YTOPR0101MB1820.CANPRD01.PROD.OUTLOOK.COM>
 <1195851744.36922369.1534797661849.JavaMail.zimbra@desy.de>,<17A5ECEC-6350-4A8E-B390-C9574848F6F4@gmail.com>
In-Reply-To: <17A5ECEC-6350-4A8E-B390-C9574848F6F4@gmail.com>
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Haynes wrote:
>> On Aug 20, 2018, at 1:41 PM, Mkrtchyan, Tigran <tigran.mkrtchyan@desy.de> wrote:
>>
>> Hi Rick,
>>
>> draft-19 says:
>>
>>   For tight coupling, ffds_stateid provides the stateid to be used by
>>   the client to access the file.  For loose coupling and a NFSv4
>>   storage device, the client will have to use an anonymous stateid to
>>   perform I/O on the storage device.  With no control protocol, the
>>   metadata server stateid can not be used to provide a global stateid
>>   model.  Thus the server MUST set the ffds_stateid to be the anonymous
>>   stateid.
>>
>> To me, the last sentence sounds like a clear statement, that it's server
>> responsibility to provide either global or anonymous stateid and client
>> should just use it as is. IOW,
>>
>> +     stateid = nfs4_ff_layout_select_ds_stateid(lseg, idx);
>> +     if (stateid)
>> +             nfs4_stateid_copy(&hdr->args.stateid, stateid);
>>
If you do this unconditionally, I think you can get rid of the code that looks like:
             if (nfs4_set_rw_stateid(&hdr->args.stateid, hdr->args.context,
                                          hdr->args.lock_context, FMODE_READ) == -EIO)
                            rpc_exit(task, -EIO);  /* lost lock, terminate I/O */
at the end of ff_layout_read_prepare_v4() and similar but with FMODE_WRITE
at the end of ff_layout_write_prepare_v4().

>>
>> must happen independent from ds being loose or tight coupled. As our DSes
>> use the same stateid's as MDS, we did see that provided stateid is not used.
>>
>> Trond, Tom, can you comment on it?
>
>
>Yes, I agree, the server always provides the stateid.
Sure. Since the above states that the loosely coupled server must fill it in as
the anonymous stated, the client will end up using the anonymous stated
for loosely coupled, whether it uses ffds_stateid or just sets it to the
anonymous stated. (Unpatched, the client always use the anonymous stated, including for tightly coupled.)

Doing it unconditionally makes the patch even simpler.

rick

>
> Thanks,
>    Tigran.
>
> ----- Original Message -----
>> From: "Rick Macklem" <rmacklem@uoguelph.ca>
>> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>, "linux-nfs" <linux-nfs@vger.kernel.org>
>> Cc: trondmy@hammerspace.com, "Anna Schumaker" <Anna.Schumaker@Netapp.com>
>> Sent: Monday, August 20, 2018 3:18:00 PM
>> Subject: Re: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for tightly coupled DSes
>
>> I just put a patch for the stated part (stripped out my version of the cred
>> stuff, which I noticed I missed commit in it;) so it might be easier to read.
>> It is here:
>> http://people.freebsd.org/~rmacklem/flexfilestateid.patch
>>
>> Thanks for doing this, rick
>>
>> ________________________________________
>> From: linux-nfs-owner@vger.kernel.org <linux-nfs-owner@vger.kernel.org> on
>> behalf of Rick Macklem <rmacklem@uoguelph.ca>
>> Sent: Monday, August 20, 2018 8:51:14 AM
>> To: Tigran Mkrtchyan; linux-nfs@vger.kernel.org
>> Cc: trondmy@hammerspace.com; Anna.Schumaker@Netapp.com
>> Subject: Re: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for tightly
>> coupled DSes
>>
>> Thanks. I'll test this later to-day. (I did a slightly more complex version
>> of the fix outside of the ff_layout_get_ds_cred() call, but yours is
>> definitely simpler).
>>
>> There is also the "stateid", which I believe is supposed to be the one in
>> the layout for the tightly coupled case (for NFSv4 I/O ops to the DS).
>> My patch is here and has the changes for stated as well as cred.
>>
>> http://people.freebsd.org/~rmacklem/flexfile.patch
>> (Sorry, I don't know git;-)
>>
>> Thanks for doing this and I'll post if my testing finds problems, rick
>>
>>
>> ________________________________________
>> From: linux-nfs-owner@vger.kernel.org <linux-nfs-owner@vger.kernel.org> on
>> behalf of Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>> Sent: Monday, August 20, 2018 2:56:08 AM
>> To: linux-nfs@vger.kernel.org
>> Cc: trondmy@hammerspace.com; Anna.Schumaker@Netapp.com; Tigran Mkrtchyan
>> Subject: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for tightly coupled
>> DSes
>>
>> for tightly coupled DSes client must ignore provided synthetic uid and
>> gid as stated in draft-ietf-nfsv4-flex-files-19#section-5.1.
>>
>> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>> ---
>> fs/nfs/flexfilelayout/flexfilelayoutdev.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> index d62279d3fc5d..290625cfd369 100644
>> --- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> +++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> @@ -452,7 +452,7 @@ ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg, u32
>> ds_idx,
>>       struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, ds_idx);
>>       struct rpc_cred *cred;
>>
>> -       if (mirror) {
>> +       if (mirror && !mirror->mirror_ds->ds_versions[0].tightly_coupled) {
>>               cred = ff_layout_get_mirror_cred(mirror, lseg->pls_range.iomode);
>>               if (!cred)
>>                       cred = get_rpccred(mdscred);
>> --
>> 2.17.1
