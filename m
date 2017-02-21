Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:53471 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753218AbdBUTpx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Feb 2017 14:45:53 -0500
From: Weston Andros Adamson <dros@primarydata.com>
To: Bruce Fields <bfields@redhat.com>
CC: Andreas Gruenbacher <agruenba@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@netapp.com>
Subject: Re: [PATCH 6/6] NFSv4: allow getacl rpc to allocate pages on demand
Date: Tue, 21 Feb 2017 19:45:45 +0000
Message-ID: <9768B61C-12EE-420F-9DFC-43DD00E477BD@primarydata.com>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-7-git-send-email-bfields@redhat.com>
 <CAHc6FU6FGPBXv0tu30wbChwdw3L7C7+aCjVxLrNfDB2N=MWk6w@mail.gmail.com>
 <20170221183506.GI2355@parsley.fieldses.org>
In-Reply-To: <20170221183506.GI2355@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Feb 21, 2017, at 1:35 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>=20
> On Mon, Feb 20, 2017 at 11:38:22PM +0100, Andreas Gruenbacher wrote:
>> On Sun, Feb 19, 2017 at 3:07 AM, J. Bruce Fields <bfields@redhat.com> wr=
ote:
>>> @@ -5079,32 +5080,22 @@ static ssize_t nfs4_do_get_acl(struct inode *in=
ode, void *buf, size_t buflen)
>>>                .rpc_argp =3D &args,
>>>                .rpc_resp =3D &res,
>>>        };
>>> -       unsigned int npages =3D DIV_ROUND_UP(buflen, PAGE_SIZE) + 1;
>>> -       int ret =3D -ENOMEM, i;
>>> -
>>> -       if (npages > ARRAY_SIZE(pages))
>>> -               return -ERANGE;
>>> -
>>> -       for (i =3D 0; i < npages; i++) {
>>> -               pages[i] =3D alloc_page(GFP_KERNEL);
>>> -               if (!pages[i])
>>> -                       goto out_free;
>>> -       }
>>> +       int ret, i;
>>>=20
>>>        /* for decoding across pages */
>>>        res.acl_scratch =3D alloc_page(GFP_KERNEL);
>>>        if (!res.acl_scratch)
>>> -               goto out_free;
>>> +               return -ENOMEM;
>>>=20
>>> -       args.acl_len =3D npages * PAGE_SIZE;
>>> +       args.acl_len =3D ARRAY_SIZE(pages) << PAGE_SHIFT;
>>=20
>> Define acl_len directly in the args initializer instead of here.
>=20
> Got it, thanks.  I'll send another revision of the series.

Thanks Bruce,

You can add:

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>

on the next revision.

-dros

>=20
> --b.
>=20
>>=20
>>> -       dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
>>> -               __func__, buf, buflen, npages, args.acl_len);
>>> +       dprintk("%s  buf %p buflen %zu args.acl_len %zu\n",
>>> +               __func__, buf, buflen, args.acl_len);
>>>        ret =3D nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(ino=
de),
>>>                             &msg, &args.seq_args, &res.seq_res, 0);
>>>        if (ret =3D=3D 0)
>>>                ret =3D res.acl_len;
>>> -out_free:
>>> +
>>>        for (i =3D 0; i < ARRAY_SIZE(pages) && pages[i]; i++)
>>>                __free_page(pages[i]);
>>>        __free_page(res.acl_scratch);
>>> --
>>> 2.9.3
>>>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

