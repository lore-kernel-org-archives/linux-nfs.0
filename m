Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:39921 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934509AbeCGUuU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Mar 2018 15:50:20 -0500
Received: by mail-vk0-f67.google.com with SMTP id f6so2231534vkh.6
        for <linux-nfs@vger.kernel.org>; Wed, 07 Mar 2018 12:50:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180307203834.GB28844@fieldses.org>
References: <20180220164229.65404-1-kolga@netapp.com> <20180220164229.65404-6-kolga@netapp.com>
 <20180307203834.GB28844@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 7 Mar 2018 15:50:18 -0500
Message-ID: <CAN-5tyFGhWTT6ooyDSCqOKHtU8KhhKmm_Yqk8vDJxBgJkPnsiA@mail.gmail.com>
Subject: Re: [PATCH v7 05/10] NFSD introduce asynch copy feature
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 7, 2018 at 3:38 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Feb 20, 2018 at 11:42:24AM -0500, Olga Kornievskaia wrote:
>> +static int nfsd4_init_copy_res(struct nfsd4_copy *copy, bool sync)
>> +{
>> +     memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
>> +             sizeof(copy->cp_dst_stateid));
>> +     copy->cp_res.wr_stable_how = NFS_UNSTABLE;
>> +     copy->cp_consecutive = 1;
>
> The cp_consecutive field was there before you came along, but I don't
> really see the point of it; all we do is ignore it and always set it to
> one.  I'd just hard-code it into the xdr code:
>
> commit f0a45f80333e
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Wed Mar 7 15:37:35 2018 -0500
>
>     nfsd: remove unsused "cp_consecutive" field
>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index a0bed2b2004d..40dfb759d38d 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1106,7 +1106,6 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>         else {
>                 copy->cp_res.wr_bytes_written = bytes;
>                 copy->cp_res.wr_stable_how = NFS_UNSTABLE;
> -               copy->cp_consecutive = 1;
>                 copy->cp_synchronous = 1;
>                 gen_boot_verifier(&copy->cp_res.wr_verifier, SVC_NET(rqstp));
>                 status = nfs_ok;
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index e502fd16246b..9f8ef2c6e508 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1759,7 +1759,7 @@ nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
>         p = xdr_decode_hyper(p, &copy->cp_src_pos);
>         p = xdr_decode_hyper(p, &copy->cp_dst_pos);
>         p = xdr_decode_hyper(p, &copy->cp_count);
> -       copy->cp_consecutive = be32_to_cpup(p++);
> +       p++; /* ca_consecutive: we always do consecutive copies */
>         copy->cp_synchronous = be32_to_cpup(p++);
>         tmp = be32_to_cpup(p); /* Source server list not supported */
>
> @@ -4214,7 +4214,7 @@ nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
>                 return nfserr;
>
>         p = xdr_reserve_space(&resp->xdr, 4 + 4);
> -       *p++ = cpu_to_be32(copy->cp_consecutive);
> +       *p++ = xdr_one; /* cr_consecutive */
>         *p++ = cpu_to_be32(copy->cp_synchronous);
>         return 0;
>  }
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index bc29511b6405..7cbc129092fe 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -518,7 +518,6 @@ struct nfsd4_copy {
>         u64             cp_count;
>
>         /* both */
> -       bool            cp_consecutive;
>         bool            cp_synchronous;
>
>         /* response */

Ok will add this.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
