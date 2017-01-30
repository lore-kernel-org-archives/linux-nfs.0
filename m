Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35912 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754380AbdA3Vgv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2017 16:36:51 -0500
Received: by mail-io0-f195.google.com with SMTP id q20so15939510ioi.3
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2017 13:36:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170130212321.GF12608@parsley.fieldses.org>
References: <79F89BE0-79A7-46A2-9CB8-E5D25C9E90DB@netapp.com>
 <20170130210237.GE12608@parsley.fieldses.org> <20170130212321.GF12608@parsley.fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 30 Jan 2017 16:36:50 -0500
Message-ID: <CAN-5tyHHEoP8oU=FRLZs24gWapEYY=Y7oW4UQAHgfnL4xyfPow@mail.gmail.com>
Subject: Re: upstream nfsd kernel oops in auth_rpcgss
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 30, 2017 at 4:23 PM, J. Bruce Fields <bfields@redhat.com> wrote=
:
> On Mon, Jan 30, 2017 at 04:02:37PM -0500, J. Bruce Fields wrote:
>> On Mon, Jan 30, 2017 at 03:15:36PM -0500, Olga Kornievskaia wrote:
>> > Hi Bruce,
>> >
>> > I ran into this oops in the nfsd (below) (4.10-rc3 kernel). To trigger=
 this I had a client (unsuccessfully) try to mount the server with krb5 whe=
re the server doesn=E2=80=99t have the rpcsec_gss_krb5 module built.
>>
>> Whoops, thanks for catching that.
>>
>> > Below code seems to fix things:
>> >
>> > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/s=
vcauth_gss.c
>> > index 886e9d38..7faffd8 100644
>> > --- a/net/sunrpc/auth_gss/svcauth_gss.c
>> > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
>> > @@ -1187,9 +1187,9 @@ static int gss_proxy_save_rsc(struct cache_detai=
l *cd,
>> >             status =3D -EOPNOTSUPP;
>> >             /* get mech handle from OID */
>> >             gm =3D gss_mech_get_by_OID(&ud->mech_oid);
>> > +           rsci.cred.cr_gss_mech =3D gm;
>> >             if (!gm)
>> >                     goto out;
>> > -           rsci.cred.cr_gss_mech =3D gm;
>> >
>> >             status =3D -EINVAL;
>> >             /* mech-specific data: */
>> >
>> > I guess the problem is because rsci.cred gets initialed from something=
 that=E2=80=99s passed in that doesn=E2=80=99t have it=E2=80=99s cr_gss_mec=
h initialized to NULL. So when gss_mech_get_by_OID() fails and it calls rsc=
_free() and tries to free a bad pointer.
>>
>> Hm, yes, just above there's:
>>
>>       rsci.cred =3D ud->creds;
>>
>> and it does make me a little nervous if ud->creds isn't completely
>> initialized.
>>
>> The only caller of gss_proxy_save_rsc is svcauth_gss_proxy_init:
>>
>>       status =3D gss_proxy_save_rsc(sn->rsc_cache, &ud, &handle);
>>
>> ud there is on the stack, and initialized by:
>>
>>       memset(&ud, 0, sizeof(ud));
>>
>> Hm, in gssp_accept_sec_context_upcall, there's:
>>
>>       data->creds =3D *(struct svc_cred *)value->data;
>>
>> That looks really weird.  I'm not sure what it should be.
>
> Does this do it?
>
> --b.
>
> diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_=
rpc_xdr.c
> index dc6fb79a361f..25d9a9cf7b66 100644
> --- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
> +++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
> @@ -260,7 +260,7 @@ static int gssx_dec_option_array(struct xdr_stream *x=
dr,
>         if (!oa->data)
>                 return -ENOMEM;
>
> -       creds =3D kmalloc(sizeof(struct svc_cred), GFP_KERNEL);
> +       creds =3D kzalloc(sizeof(struct svc_cred), GFP_KERNEL);
>         if (!creds) {
>                 kfree(oa->data);
>                 return -ENOMEM;

Yes, it does!

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
