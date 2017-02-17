Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32962 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934026AbdBQOqL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Feb 2017 09:46:11 -0500
Received: by mail-it0-f65.google.com with SMTP id e137so3137815itc.0
        for <linux-nfs@vger.kernel.org>; Fri, 17 Feb 2017 06:46:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1487287688.122266.2.camel@primarydata.com>
References: <20161205004023.40957-1-trond.myklebust@primarydata.com>
 <CAN-5tyGN4AT70mrVKoW652hQmbDocG7_c2haDC=PKpixQsUDJg@mail.gmail.com>
 <1487191695.7993.2.camel@primarydata.com> <CAN-5tyGep3yHXNjMX9QKCS8E2w+HkVw_LoF=pOwgbgcgUNeDyQ@mail.gmail.com>
 <1487197395.7993.4.camel@primarydata.com> <CAN-5tyHHUoy5sVUHO=PXz3iRPD6eEP0t+L8VrWVpuvSd_YzhAA@mail.gmail.com>
 <CAN-5tyFZO4dKG93A71mO37VdHJymMt0f61oLkxMHvRDPEvSa2g@mail.gmail.com>
 <CAN-5tyGb6Gh=k0r1M4UmpM+6fB9nMzi3OGmB_trbSjbCdJjqrQ@mail.gmail.com>
 <D28A97BA-F86E-40D3-A0E3-BB8479136ED9@primarydata.com> <CAN-5tyHe-+PiOnx8U9u-3FPVVAYf9AbbcZUDM6BW+V6930tHtA@mail.gmail.com>
 <1487287688.122266.2.camel@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 17 Feb 2017 09:46:10 -0500
Message-ID: <CAN-5tyGZb9=oWGLN_ZoNDHd5X5a1DQb2oJVw+9cH66Osmk9_dQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSv4.1: Handle NFS4ERR_BADSESSION/NFS4ERR_DEADSESSION
 replies to OP_SEQUENCE
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 16, 2017 at 6:28 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
> On Thu, 2017-02-16 at 17:14 -0500, Olga Kornievskaia wrote:
>> On Thu, Feb 16, 2017 at 4:45 PM, Trond Myklebust
>> <trondmy@primarydata.com> wrote:
>> >
>> > Olga, all your test is doing is showing that we hit the race more
>> > often. Fair enough, I=E2=80=99ll ask Anna to revert the patch. However
>> > reverting the patch won=E2=80=99t prevent the server from returning
>> > NFS4ERR_BAD_STATEID in any cases where the calls to
>> > nfs4_set_rw_stateid() happen before state recovery. This is why we
>> > have the loop in nfs42_proc_copy().
>>
>> I thought that if retry of the operation waits for the recovery to
>> complete then nfs4_set_rw_stateid() will choose the correct stateid,
>> is that not correct?
>>
>> If that's not correct, then we somehow need to separate the case when
>> BAD_STATEID should indeed mark the locks lost vs this case where the
>> code erroneously used the bad stateid (oops) and it should really
>> ignore this error. This really doesn't sound very plausible to
>> accomplish.
>
> Does this patch fix the problem?
>
> 8<-------------------------------------------------------------
> From bbae95e8f97cad6a91ca8caa50b61cae789632f9 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Thu, 16 Feb 2017 18:14:38 -0500
> Subject: [PATCH] NFSv4: Fix reboot recovery in copy offload
>
> Copy offload code needs to be hooked into the code for handling
> NFS4ERR_BAD_STATEID by ensuring that we set the "stateid" field
> in struct nfs4_exception.
>
> Reported-by: Olga Kornievskaia <aglo@umich.edu>
> Fixes: 2e72448b07dc3 ("NFS: Add COPY nfs operation")
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs42proc.c | 57 +++++++++++++++++++++++++++++++-----------------=
------
>  1 file changed, 33 insertions(+), 24 deletions(-)
>
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index d12ff9385f49..baf1fe2dc296 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -128,20 +128,13 @@ int nfs42_proc_deallocate(struct file *filep, loff_=
t offset, loff_t len)
>         return err;
>  }
>
> -static ssize_t _nfs42_proc_copy(struct file *src, loff_t pos_src,
> +static ssize_t _nfs42_proc_copy(struct file *src,
>                                 struct nfs_lock_context *src_lock,
> -                               struct file *dst, loff_t pos_dst,
> +                               struct file *dst,
>                                 struct nfs_lock_context *dst_lock,
> -                               size_t count)
> +                               struct nfs42_copy_args *args,
> +                               struct nfs42_copy_res *res)
>  {
> -       struct nfs42_copy_args args =3D {
> -               .src_fh         =3D NFS_FH(file_inode(src)),
> -               .src_pos        =3D pos_src,
> -               .dst_fh         =3D NFS_FH(file_inode(dst)),
> -               .dst_pos        =3D pos_dst,
> -               .count          =3D count,
> -       };
> -       struct nfs42_copy_res res;
>         struct rpc_message msg =3D {
>                 .rpc_proc =3D &nfs4_procedures[NFSPROC4_CLNT_COPY],
>                 .rpc_argp =3D &args,
> @@ -149,9 +142,12 @@ static ssize_t _nfs42_proc_copy(struct file *src, lo=
ff_t pos_src,
>         };
>         struct inode *dst_inode =3D file_inode(dst);
>         struct nfs_server *server =3D NFS_SERVER(dst_inode);
> +       loff_t pos_src =3D args->src_pos;
> +       loff_t pos_dst =3D args->dst_pos;
> +       size_t count =3D args->count;
>         int status;
>
> -       status =3D nfs4_set_rw_stateid(&args.src_stateid, src_lock->open_=
context,
> +       status =3D nfs4_set_rw_stateid(&args->src_stateid, src_lock->open=
_context,
>                                      src_lock, FMODE_READ);
>         if (status)
>                 return status;
> @@ -161,7 +157,7 @@ static ssize_t _nfs42_proc_copy(struct file *src, lof=
f_t pos_src,
>         if (status)
>                 return status;
>
> -       status =3D nfs4_set_rw_stateid(&args.dst_stateid, dst_lock->open_=
context,
> +       status =3D nfs4_set_rw_stateid(&args->dst_stateid, dst_lock->open=
_context,
>                                      dst_lock, FMODE_WRITE);
>         if (status)
>                 return status;
> @@ -171,22 +167,22 @@ static ssize_t _nfs42_proc_copy(struct file *src, l=
off_t pos_src,
>                 return status;
>
>         status =3D nfs4_call_sync(server->client, server, &msg,
> -                               &args.seq_args, &res.seq_res, 0);
> +                               &args->seq_args, &res->seq_res, 0);
>         if (status =3D=3D -ENOTSUPP)
>                 server->caps &=3D ~NFS_CAP_COPY;
>         if (status)
>                 return status;
>
> -       if (res.write_res.verifier.committed !=3D NFS_FILE_SYNC) {
> -               status =3D nfs_commit_file(dst, &res.write_res.verifier.v=
erifier);
> +       if (res->write_res.verifier.committed !=3D NFS_FILE_SYNC) {
> +               status =3D nfs_commit_file(dst, &res->write_res.verifier.=
verifier);
>                 if (status)
>                         return status;
>         }
>
>         truncate_pagecache_range(dst_inode, pos_dst,
> -                                pos_dst + res.write_res.count);
> +                                pos_dst + res->write_res.count);
>
> -       return res.write_res.count;
> +       return res->write_res.count;
>  }
>
>  ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
> @@ -196,8 +192,22 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos=
_src,
>         struct nfs_server *server =3D NFS_SERVER(file_inode(dst));
>         struct nfs_lock_context *src_lock;
>         struct nfs_lock_context *dst_lock;
> -       struct nfs4_exception src_exception =3D { };
> -       struct nfs4_exception dst_exception =3D { };
> +       struct nfs42_copy_args args =3D {
> +               .src_fh         =3D NFS_FH(file_inode(src)),
> +               .src_pos        =3D pos_src,
> +               .dst_fh         =3D NFS_FH(file_inode(dst)),
> +               .dst_pos        =3D pos_dst,
> +               .count          =3D count,
> +       };
> +       struct nfs42_copy_res res;
> +       struct nfs4_exception src_exception =3D {
> +               .inode          =3D file_inode(src),
> +               .stateid        =3D &args.src_stateid,
> +       };
> +       struct nfs4_exception dst_exception =3D {
> +               .inode          =3D file_inode(dst),
> +               .stateid        =3D &args.dst_stateid,
> +       };
>         ssize_t err, err2;
>
>         if (!nfs_server_capable(file_inode(dst), NFS_CAP_COPY))
> @@ -207,7 +217,6 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_=
src,
>         if (IS_ERR(src_lock))
>                 return PTR_ERR(src_lock);
>
> -       src_exception.inode =3D file_inode(src);
>         src_exception.state =3D src_lock->open_context->state;
>
>         dst_lock =3D nfs_get_lock_context(nfs_file_open_context(dst));
> @@ -216,13 +225,13 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t po=
s_src,
>                 goto out_put_src_lock;
>         }
>
> -       dst_exception.inode =3D file_inode(dst);
>         dst_exception.state =3D dst_lock->open_context->state;
>
>         do {
>                 inode_lock(file_inode(dst));
> -               err =3D _nfs42_proc_copy(src, pos_src, src_lock,
> -                                      dst, pos_dst, dst_lock, count);
> +               err =3D _nfs42_proc_copy(src, src_lock,
> +                               dst, dst_lock,
> +                               &args, &res);
>                 inode_unlock(file_inode(dst));
>
>                 if (err =3D=3D -ENOTSUPP) {
> --
> 2.9.3

I wish it did but no it does not.
