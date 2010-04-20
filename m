From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH] bug in read_buf
Date: Tue, 20 Apr 2010 15:24:59 -0400
Message-ID: <g2k89c397151004201224wb35ae389g961523bbef23f452@mail.gmail.com>
References: <19405.3732.562014.510508@notabene.brown>
	 <20100420165152.GD28826@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:37002 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754140Ab0DTTZA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Apr 2010 15:25:00 -0400
Received: by gyg13 with SMTP id 13so3355500gyg.19
        for <linux-nfs@vger.kernel.org>; Tue, 20 Apr 2010 12:24:59 -0700 (PDT)
In-Reply-To: <20100420165152.GD28826@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 20, 2010 at 12:51 PM, J. Bruce Fields <bfields@fieldses.org=
> wrote:
> On Tue, Apr 20, 2010 at 12:16:52PM +1000, Neil Brown wrote:
>>
>> Surely this can never have worked... which implies that the code has
>> never been used?
>>
>> When read_buf is called to move over to the next page in the pagelis=
t
>> of an NFSv4 request, it sets argp->end to essentially a random
>> number, certainly not an address within the page which argp->p now
>> points to. =A0So subsequent calls to READ_BUF will think there is mu=
ch
>> more than a page of spare space (the cast to u32 ensures an unsigned
>> comparison) so we can expect to fall off the end of the second
>> page.
>
> Yipes, thanks.
>
>> I guess we never ever receive requests with any operation starting
>> beyond the first page!
>
> putfh-write-getattr, for example, is common enough. =A0The write deco=
ding
> should leave arg->end set correctly. =A0But there are two read_buf()'=
s in
> decode_getattr(), and I can't see why we don't hit this bug on a writ=
e
> that leaves that final getattr exactly straddling a page boundary.

The write data is dumped into the rq_vec which has non-contiguous
pages. So the xdr_buf head only holds the putfh result, the short
write response header (v4 stateid, offset, how, length, etc), and then
the getattr. so there is plenty of space.

-->Andy

>
> --b.
>
>> [[
>> I found this while looking at why fsstress over NFS over RDMA caused
>> a bad memory dereference in READ32, suggesting that 'p' had a bad
>> value. =A0However it was ffff8801299188f0, which is not an "I've fal=
len
>> off the end of the page" sort of value. =A0So I think it must be a
>> different bug :-( =A0It is as if the page is being unmapped undernea=
th
>> us...
>> ]]
>> NeilBrown
>>
>>
>>
>>
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index e170317..34ccf81 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -161,10 +161,10 @@ static __be32 *read_buf(struct nfsd4_compounda=
rgs *argp, u32 nbytes)
>> =A0 =A0 =A0 argp->p =3D page_address(argp->pagelist[0]);
>> =A0 =A0 =A0 argp->pagelist++;
>> =A0 =A0 =A0 if (argp->pagelen < PAGE_SIZE) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 argp->end =3D p + (argp->pagelen>>2);
>> + =A0 =A0 =A0 =A0 =A0 =A0 argp->end =3D argp->p + (argp->pagelen>>2)=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->pagelen =3D 0;
>> =A0 =A0 =A0 } else {
>> - =A0 =A0 =A0 =A0 =A0 =A0 argp->end =3D p + (PAGE_SIZE>>2);
>> + =A0 =A0 =A0 =A0 =A0 =A0 argp->end =3D argp->p + (PAGE_SIZE>>2);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->pagelen -=3D PAGE_SIZE;
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 memcpy(((char*)p)+avail, argp->p, (nbytes - avail));
>> @@ -1426,10 +1426,10 @@ nfsd4_decode_compound(struct nfsd4_compounda=
rgs *argp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->p =3D page_address=
(argp->pagelist[0]);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->pagelist++;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (argp->pagelen < PAGE=
_SIZE) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->end =
=3D p + (argp->pagelen>>2);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->end =
=3D argp->p + (argp->pagelen>>2);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->pa=
gelen =3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->end =
=3D p + (PAGE_SIZE>>2);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->end =
=3D argp->p + (PAGE_SIZE>>2);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->pa=
gelen -=3D PAGE_SIZE;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
