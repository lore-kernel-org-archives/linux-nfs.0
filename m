Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg1-f196.google.com ([209.85.215.196]:38836 "EHLO
        mail-pg1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726498AbeHUAJY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Aug 2018 20:09:24 -0400
Received: by mail-pg1-f196.google.com with SMTP id k8-v6so3319456pgq.5
        for <linux-nfs@vger.kernel.org>; Mon, 20 Aug 2018 13:52:16 -0700 (PDT)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for tightly
 coupled DSes
From: Tom Haynes <loghyr@gmail.com>
In-Reply-To: <1195851744.36922369.1534797661849.JavaMail.zimbra@desy.de>
Date: Mon, 20 Aug 2018 13:52:14 -0700
Cc: Rick Macklem <rmacklem@uoguelph.ca>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-Id: <17A5ECEC-6350-4A8E-B390-C9574848F6F4@gmail.com>
References: <20180820065608.11860-1-tigran.mkrtchyan@desy.de>
 <YTOPR0101MB18202768E081C824A96ECC0ADD320@YTOPR0101MB1820.CANPRD01.PROD.OUTLOOK.COM>
 <YTOPR0101MB18201895B73ED2C4BA3B0840DD320@YTOPR0101MB1820.CANPRD01.PROD.OUTLOOK.COM>
 <1195851744.36922369.1534797661849.JavaMail.zimbra@desy.de>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Aug 20, 2018, at 1:41 PM, Mkrtchyan, Tigran =
<tigran.mkrtchyan@desy.de> wrote:
>=20
> Hi Rick,
>=20
> draft-19 says:
>=20
>   For tight coupling, ffds_stateid provides the stateid to be used by
>   the client to access the file.  For loose coupling and a NFSv4
>   storage device, the client will have to use an anonymous stateid to
>   perform I/O on the storage device.  With no control protocol, the
>   metadata server stateid can not be used to provide a global stateid
>   model.  Thus the server MUST set the ffds_stateid to be the =
anonymous
>   stateid.
>=20
> To me, the last sentence sounds like a clear statement, that it's =
server
> responsibility to provide either global or anonymous stateid and =
client
> should just use it as is. IOW,
>=20
> +	stateid =3D nfs4_ff_layout_select_ds_stateid(lseg, idx);
> +	if (stateid)
> +		nfs4_stateid_copy(&hdr->args.stateid, stateid);
>=20
>=20
> must happen independent from ds being loose or tight coupled. As our =
DSes
> use the same stateid's as MDS, we did see that provided stateid is not =
used.
>=20
> Trond, Tom, can you comment on it?


Yes, I agree, the server always provides the stateid.


>=20
> Thanks,
>    Tigran.
>=20
> ----- Original Message -----
>> From: "Rick Macklem" <rmacklem@uoguelph.ca>
>> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>, "linux-nfs" =
<linux-nfs@vger.kernel.org>
>> Cc: trondmy@hammerspace.com, "Anna Schumaker" =
<Anna.Schumaker@Netapp.com>
>> Sent: Monday, August 20, 2018 3:18:00 PM
>> Subject: Re: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for =
tightly coupled DSes
>=20
>> I just put a patch for the stated part (stripped out my version of =
the cred
>> stuff, which I noticed I missed commit in it;) so it might be easier =
to read.
>> It is here:
>> http://people.freebsd.org/~rmacklem/flexfilestateid.patch
>>=20
>> Thanks for doing this, rick
>>=20
>> ________________________________________
>> From: linux-nfs-owner@vger.kernel.org =
<linux-nfs-owner@vger.kernel.org> on
>> behalf of Rick Macklem <rmacklem@uoguelph.ca>
>> Sent: Monday, August 20, 2018 8:51:14 AM
>> To: Tigran Mkrtchyan; linux-nfs@vger.kernel.org
>> Cc: trondmy@hammerspace.com; Anna.Schumaker@Netapp.com
>> Subject: Re: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for =
tightly
>> coupled DSes
>>=20
>> Thanks. I'll test this later to-day. (I did a slightly more complex =
version
>> of the fix outside of the ff_layout_get_ds_cred() call, but yours is
>> definitely simpler).
>>=20
>> There is also the "stateid", which I believe is supposed to be the =
one in
>> the layout for the tightly coupled case (for NFSv4 I/O ops to the =
DS).
>> My patch is here and has the changes for stated as well as cred.
>>=20
>> http://people.freebsd.org/~rmacklem/flexfile.patch
>> (Sorry, I don't know git;-)
>>=20
>> Thanks for doing this and I'll post if my testing finds problems, =
rick
>>=20
>>=20
>> ________________________________________
>> From: linux-nfs-owner@vger.kernel.org =
<linux-nfs-owner@vger.kernel.org> on
>> behalf of Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>> Sent: Monday, August 20, 2018 2:56:08 AM
>> To: linux-nfs@vger.kernel.org
>> Cc: trondmy@hammerspace.com; Anna.Schumaker@Netapp.com; Tigran =
Mkrtchyan
>> Subject: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for =
tightly coupled
>> DSes
>>=20
>> for tightly coupled DSes client must ignore provided synthetic uid =
and
>> gid as stated in draft-ietf-nfsv4-flex-files-19#section-5.1.
>>=20
>> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>> ---
>> fs/nfs/flexfilelayout/flexfilelayoutdev.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>=20
>> diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> index d62279d3fc5d..290625cfd369 100644
>> --- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> +++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> @@ -452,7 +452,7 @@ ff_layout_get_ds_cred(struct pnfs_layout_segment =
*lseg, u32
>> ds_idx,
>>       struct nfs4_ff_layout_mirror *mirror =3D FF_LAYOUT_COMP(lseg, =
ds_idx);
>>       struct rpc_cred *cred;
>>=20
>> -       if (mirror) {
>> +       if (mirror && =
!mirror->mirror_ds->ds_versions[0].tightly_coupled) {
>>               cred =3D ff_layout_get_mirror_cred(mirror, =
lseg->pls_range.iomode);
>>               if (!cred)
>>                       cred =3D get_rpccred(mdscred);
>> --
>> 2.17.1
