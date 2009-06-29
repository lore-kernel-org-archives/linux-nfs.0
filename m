From: Tao Guo <glorioustao@gmail.com>
Subject: Re: [pnfs] [PATCH]pnfsd: make pnfs server return layout_blksize when
	the client asks for it
Date: Mon, 29 Jun 2009 10:09:53 +0800
Message-ID: <318b7ac70906281909j1fc015a9m41a96662dcbaf53d@mail.gmail.com>
References: <318b7ac70906252004q61cfd571h1788e8fb448c46f5@mail.gmail.com>
	 <4A464079.3090805@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fredric Isaman <iisaman@citi.umich.edu>, bfields@citi.umich.edu,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f226.google.com ([209.85.217.226]:50477 "EHLO
	mail-gx0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbZF2CJw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jun 2009 22:09:52 -0400
Received: by gxk26 with SMTP id 26so3371195gxk.13
        for <linux-nfs@vger.kernel.org>; Sun, 28 Jun 2009 19:09:54 -0700 (PDT)
In-Reply-To: <4A464079.3090805@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for comments and sorry for the mistakes, I already removed
the auto rich formatting in gmail settings.

At the moment, only the blocklayoutdriver will ask for the layout_blksi=
ze,
but I think it is necessary for blocklayoutdriver will check and use it=
=2E

I already resend the patches, you can checkout it out.

On Sat, Jun 27, 2009 at 11:53 PM, Benny Halevy<bhalevy@panasas.com> wro=
te:
> Tao,
>
> I'd appreciate if you could send patches in plain text, otherwise
> they are much harder to apply.
>
> Fred: can you please verify this in your environment since I think th=
at
> only the block layout relies on that at the moment.
>
> Please see comments below.
>
> On Jun. 26, 2009, 6:04 +0300, Tao Guo <glorioustao@gmail.com> wrote:
>> commit 717f53b333a8c4c5238b1192640ad5078c683f5f
>> Author: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org <mailto:guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>>
>> Date: =C2=A0 Fri Jun 26 10:46:13 2009 +0800
>>
>> =C2=A0 =C2=A0 pnfsd: make pnfs server return layout_blksize when the=
 client asks
>> for it.
>>
>> =C2=A0 =C2=A0 pnfs: replace lease_bitmap to length 3, instead of 2.
>>
>> =C2=A0 =C2=A0 Referred to commit 3e8c8312e4b...
>>
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index 95b7387..f264c15 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -2573,7 +2573,7 @@ static int nfs4_xdr_enc_setclientid_confirm(st=
ruct
>> rpc_rqst *req, __be32 *p, str
>> =C2=A0 =C2=A0 =C2=A0struct compound_hdr hdr =3D {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.nops =C2=A0 =C2=A0=3D 0,
>> =C2=A0 =C2=A0 =C2=A0};
>> - =C2=A0 =C2=A0const u32 lease_bitmap[2] =3D { FATTR4_WORD0_LEASE_TI=
ME, 0 };
>> + =C2=A0 =C2=A0const u32 lease_bitmap[3] =3D { FATTR4_WORD0_LEASE_TI=
ME, 0, 0 };
>>
>> =C2=A0 =C2=A0 =C2=A0xdr_init_encode(&xdr, &req->rq_snd_buf, p);
>> =C2=A0 =C2=A0 =C2=A0encode_compound_hdr(&xdr, req, &hdr);
>
> a. same should also be done in nfs4_xdr_enc_get_lease_time
> b. please submit as separate patch as it fixes a bug independently.
>
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 6959787..2854576 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -2345,6 +2345,13 @@ out_acl:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0WRITE32(0); =C2=A0/*=
 length */
>> =C2=A0 =C2=A0 =C2=A0}
>> =C2=A0#endif /* CONFIG_PNFSD */
>> +
>> + =C2=A0 =C2=A0if (bmval2 & FATTR4_WORD2_LAYOUT_BLKSIZE) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((buflen -=3D 4) < 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out_resource;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0WRITE32(stat.blksize);
>> + =C2=A0 =C2=A0}
>> +
>
> let's put this inside the #ifdef CONFIG_PNFSD block for now.
> I'm not 100% sure about returning stat.blksize for the layout_blksize
> but that will do for now.
>
> Thanks!
>
> Benny
>
>> =C2=A0 =C2=A0 =C2=A0if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0WRITE32(3);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0WRITE32(NFSD_SUPPATTR_EXCLCREAT_WO=
RD0);
>> diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
>> index 5177c54..056e012 100644
>> --- a/include/linux/nfsd/nfsd.h
>> +++ b/include/linux/nfsd/nfsd.h
>> @@ -382,7 +382,8 @@ extern struct timeval =C2=A0 =C2=A0nfssvc_boot;
>> =C2=A0#endif /* CONFIG_PNFSD */
>>
>> =C2=A0#define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
>> - =C2=A0 =C2=A0(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_=
EXCLCREAT)
>> + =C2=A0 =C2=A0(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_=
EXCLCREAT | \
>> + =C2=A0 =C2=A0 FATTR4_WORD2_LAYOUT_BLKSIZE)
>>
>> =C2=A0static inline u32 nfsd_suppattrs0(u32 minorversion)
>> =C2=A0{
>> --
>> tao.
>>
>>
>> --------------------------------------------------------------------=
----
>>
>> _______________________________________________
>> pNFS mailing list
>> pNFS@linux-nfs.org
>> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>



--=20
tao.
