From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH] bug in read_buf
Date: Thu, 22 Apr 2010 11:41:48 -0400
Message-ID: <j2q89c397151004220841s7fb7a002h61b64449d4d69b2@mail.gmail.com>
References: <19405.3732.562014.510508@notabene.brown>
	 <20100420165152.GD28826@fieldses.org>
	 <g2k89c397151004201224wb35ae389g961523bbef23f452@mail.gmail.com>
	 <20100420193944.GB31901@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:41234 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755839Ab0DVPlu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Apr 2010 11:41:50 -0400
Received: by vws20 with SMTP id 20so355935vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 22 Apr 2010 08:41:49 -0700 (PDT)
In-Reply-To: <20100420193944.GB31901@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 20, 2010 at 3:39 PM, J. Bruce Fields <bfields@fieldses.org>=
 wrote:
> On Tue, Apr 20, 2010 at 03:24:59PM -0400, William A. (Andy) Adamson w=
rote:
>> On Tue, Apr 20, 2010 at 12:51 PM, J. Bruce Fields <bfields@fieldses.=
org> wrote:
>> > On Tue, Apr 20, 2010 at 12:16:52PM +1000, Neil Brown wrote:
>> >>
>> >> Surely this can never have worked... which implies that the code =
has
>> >> never been used?
>> >>
>> >> When read_buf is called to move over to the next page in the page=
list
>> >> of an NFSv4 request, it sets argp->end to essentially a random
>> >> number, certainly not an address within the page which argp->p no=
w
>> >> points to. =A0So subsequent calls to READ_BUF will think there is=
 much
>> >> more than a page of spare space (the cast to u32 ensures an unsig=
ned
>> >> comparison) so we can expect to fall off the end of the second
>> >> page.
>> >
>> > Yipes, thanks.
>> >
>> >> I guess we never ever receive requests with any operation startin=
g
>> >> beyond the first page!
>> >
>> > putfh-write-getattr, for example, is common enough. =A0The write d=
ecoding
>> > should leave arg->end set correctly. =A0But there are two read_buf=
()'s in
>> > decode_getattr(), and I can't see why we don't hit this bug on a w=
rite
>> > that leaves that final getattr exactly straddling a page boundary.
>>
>> The write data is dumped into the rq_vec which has non-contiguous
>> pages. So the xdr_buf head only holds the putfh result, the short
>> write response header (v4 stateid, offset, how, length, etc), and th=
en
>> the getattr. so there is plenty of space.
>
> This is the server-side write-decoding, so you could see:
>
>
> =A0 =A0 =A0 =A0rpc header | putfh | write ... data ... | getattr
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ^
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0page boundary here


ulp - you're right.

-->Andy

>
> --b.
>
>>
>> -->Andy
>>
>> >
>> > --b.
>> >
>> >> [[
>> >> I found this while looking at why fsstress over NFS over RDMA cau=
sed
>> >> a bad memory dereference in READ32, suggesting that 'p' had a bad
>> >> value. =A0However it was ffff8801299188f0, which is not an "I've =
fallen
>> >> off the end of the page" sort of value. =A0So I think it must be =
a
>> >> different bug :-( =A0It is as if the page is being unmapped under=
neath
>> >> us...
>> >> ]]
>> >> NeilBrown
>> >>
>> >>
>> >>
>> >>
>> >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> >> index e170317..34ccf81 100644
>> >> --- a/fs/nfsd/nfs4xdr.c
>> >> +++ b/fs/nfsd/nfs4xdr.c
>> >> @@ -161,10 +161,10 @@ static __be32 *read_buf(struct nfsd4_compou=
ndargs *argp, u32 nbytes)
>> >> =A0 =A0 =A0 argp->p =3D page_address(argp->pagelist[0]);
>> >> =A0 =A0 =A0 argp->pagelist++;
>> >> =A0 =A0 =A0 if (argp->pagelen < PAGE_SIZE) {
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 argp->end =3D p + (argp->pagelen>>2);
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 argp->end =3D argp->p + (argp->pagelen>=
>2);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->pagelen =3D 0;
>> >> =A0 =A0 =A0 } else {
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 argp->end =3D p + (PAGE_SIZE>>2);
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 argp->end =3D argp->p + (PAGE_SIZE>>2);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->pagelen -=3D PAGE_SIZE;
>> >> =A0 =A0 =A0 }
>> >> =A0 =A0 =A0 memcpy(((char*)p)+avail, argp->p, (nbytes - avail));
>> >> @@ -1426,10 +1426,10 @@ nfsd4_decode_compound(struct nfsd4_compou=
ndargs *argp)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->p =3D page_addr=
ess(argp->pagelist[0]);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->pagelist++;
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (argp->pagelen < P=
AGE_SIZE) {
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->e=
nd =3D p + (argp->pagelen>>2);
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->e=
nd =3D argp->p + (argp->pagelen>>2);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp-=
>pagelen =3D 0;
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->e=
nd =3D p + (PAGE_SIZE>>2);
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp->e=
nd =3D argp->p + (PAGE_SIZE>>2);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argp-=
>pagelen -=3D PAGE_SIZE;
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> >>
>> >>
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-nf=
s" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at =A0http://vger.kernel.org/majordomo-info.ht=
ml
>> >
>
