Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33881 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754223AbdGUPqt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Jul 2017 11:46:49 -0400
Received: by mail-qk0-f194.google.com with SMTP id q66so4472208qki.1
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 08:46:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1500584980.6577.4.camel@primarydata.com>
References: <20170630195201.95597-1-kolga@netapp.com> <1500580582.5457.1.camel@primarydata.com>
 <4C765F1F-4958-4D1B-922A-95AE9CB69288@netapp.com> <1500584980.6577.4.camel@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 21 Jul 2017 11:46:47 -0400
Message-ID: <CAN-5tyEJV6Fq2k95eAEOJKMv2n2HEbJKP3kMpE5xcXu3z85cPA@mail.gmail.com>
Subject: Re: [PATCH v3 1/1] PNFS fix dangling DS mount
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "kolga@netapp.com" <kolga@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 20, 2017 at 5:09 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
> On Thu, 2017-07-20 at 16:14 -0400, Olga Kornievskaia wrote:
>> > On Jul 20, 2017, at 3:56 PM, Trond Myklebust <trondmy@primarydata.c
>> > om> wrote:
>> >
>> > Hi Olga,
>> >
>> > Apologies for missing this patch. It was hiding in my 'linux-
>> > fsdevel'
>> > mailbox, so I didn't recognise it as a NFS patch.
>> >
>>
>> Yeah after I mailed it out I realized I cc-ed fsdevel incorrectly.
>>
>> > On Fri, 2017-06-30 at 15:52 -0400, Olga Kornievskaia wrote:
>> > > There is a regression by commit 8d40b0f14846 ("NFS
>> > > filelayout:call
>> > > GETDEVICEINFO after pnfs_layout_process completes"). It leaves
>> > > the
>> > > DS mount dangling.
>> > >
>> > > Previously, filelayout_alloc_sec() would call
>> > > filelayout_check_layout()
>> > > which would call nfs4_find_get_deviceid which ups the count on
>> > > the
>> > > device_id. It's only called once and it's matched by the
>> > > filelayout_free_lseg() that calls nfs4_fl_put_deviceid().
>> > >
>> > > After that patch, each read/write ends up calling
>> > > nfs4_find_get_deviceid
>> > > and there is no balance for that. Instead, do
>> > > nfs4_fl_put_deviceid()
>> > > in the filelayout's .pg_cleanup and remove it from
>> > > filelayout_free_lseg.
>> > >
>> > > But we still need a reference to hold over the lifetime of the
>> > > segment.
>> > > For every new lseg that's created we need to take a reference on
>> > > deviceid
>> > > that uses it. It will be released in the "free_lseg" routine.
>> >
>> > This is what I'm not understanding. If you have a reference in the
>> > layout segment, then why do you need to call
>> > nfs4_find_get_deviceid()
>> > in the read/write code?
>>
>> I think I=E2=80=99m probably misunderstanding the question. It sounds to=
 me
>> that you asking me for why the commit 8d40b0f14846 was done the way
>> it was done (I=E2=80=99d would say it was done as per your suggestion).
>>
>> I would say the call to nfs4_find_get_deviceid() has always been in
>> the read/write code. It was a part of the pnfs_update_layout() but
>> the commit 8d40b0f14846 moved it out of it (so that the layoutget was
>> complete) and then the call to the getdeviceinfo would be done.
>>
>> > Isn't it sufficient to change the "pg_init" calls to check whether
>> > or
>> > not the struct nfs4_filelayout_segment has set a value for dsaddr
>> > (that
>> > needs to be done with care to avoid races - cmpxchg() is your
>> > friend),
>> > and then rely on that reference being set for the remainder of the
>> > layout segment lifetime?
>>
>> Are you suggesting to change when getdeviceinfo is suppose to be
>> called?
>>
>
> No. Now that I'm looking at filelayout_check_deviceid(), here is what I
>  suggest: we need to ensure that filelayout_check_deviceid() sets the
> deviceid once, and only once!
>
> How about something like the following (untested) patch?
>
> 8<-------------------------------------------------------
> From 1e40ee13950d03ad2a54a0d1dba35f2a04c28ca0 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Thu, 20 Jul 2017 17:00:02 -0400
> Subject: [PATCH] NFS/filelayout: Fix racy setting of fl->dsaddr in
>  filelayout_check_deviceid()
>
> We must set fl->dsaddr once, and once only, even if there are multiple
> processes calling filelayout_check_deviceid() for the same layout
> segment.
>
> Reported-by: Olga Kornievskaia <kolga@netapp.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/filelayout/filelayout.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayou=
t.c
> index 080fc6b278bd..44c638b7876c 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -542,6 +542,10 @@ filelayout_check_deviceid(struct pnfs_layout_hdr *lo=
,
>         struct nfs4_file_layout_dsaddr *dsaddr;
>         int status =3D -EINVAL;
>
> +       /* Is the deviceid already set? If so, we're good. */
> +       if (fl->dsaddr !=3D NULL)
> +               return 0;
> +
>         /* find and reference the deviceid */
>         d =3D nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode), &fl->devi=
ceid,
>                         lo->plh_lc_cred, gfp_flags);
> @@ -553,8 +557,6 @@ filelayout_check_deviceid(struct pnfs_layout_hdr *lo,
>         if (filelayout_test_devid_unavailable(&dsaddr->id_node))
>                 goto out_put;
>
> -       fl->dsaddr =3D dsaddr;
> -
>         if (fl->first_stripe_index >=3D dsaddr->stripe_count) {
>                 dprintk("%s Bad first_stripe_index %u\n",
>                                 __func__, fl->first_stripe_index);
> @@ -570,6 +572,13 @@ filelayout_check_deviceid(struct pnfs_layout_hdr *lo=
,
>                 goto out_put;
>         }
>         status =3D 0;
> +
> +       /*
> +        * Atomic compare and xchange to ensure we don't scribble
> +        * over a non-NULL pointer.
> +        */
> +       if (cmpxchg(&fl->dsaddr, NULL, dsaddr) !=3D NULL)
> +               goto out_put;
>  out:
>         return status;
>  out_put:
> --
> 2.13.3
>

No dangling DS after this patch as well.

Question: do we need to worry about that the checks that are done on
the deviceid done after finding one are skipped with this patch?
