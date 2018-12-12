Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B366C65BAF
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 18:55:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D5DA920811
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 18:55:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JQcZYLkJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5DA920811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726242AbeLLSzm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 13:55:42 -0500
Received: from mail-ua1-f65.google.com ([209.85.222.65]:45202 "EHLO
        mail-ua1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726232AbeLLSzm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2018 13:55:42 -0500
Received: by mail-ua1-f65.google.com with SMTP id e16so6813257uam.12;
        Wed, 12 Dec 2018 10:55:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Fh6VB1lmm/NyL+Z8o92QFiblNtd7wbC2pnde04yQPOc=;
        b=JQcZYLkJdVi9h/edX7ldOCHFwil4/7MPngjZy4X7Rxu+EF7g3M24mdnYcYt0ecdvJU
         6T39RRjdOH66sL19KSJljRH/8Safs79voWvh5OENSJ1L809oayclvA3JkIZeTus7LU0E
         Mmv0X8kTa/GqA0Wvuhq1YZxUBYS5QiM8yo57K+b0/Ahmz9dOLw7UH05P6Xv/LgPcWfzb
         ZYgkxVIgy8rAakfl9GEo7HKIWZBd95n9domjW1CwHuVCohWTAcjVclCfxBmGRJyeJu9O
         xcMWyQzrChNj3WLWO66a5m6i2TaLMxoM6trq+4e6oypMCYdVbkct/uo1W7FXbqOdN1Um
         /hjw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Fh6VB1lmm/NyL+Z8o92QFiblNtd7wbC2pnde04yQPOc=;
        b=paR5sqHJp2pmO69LyhP1kJsGR7fSJkuvDFbVWEIIHy/d5rrKfb3+nJtcjtOJs4djUS
         i/cjjowk8QeEUlZlpCVvSFLz1sgTiO7piBaHG2punryLOeurqwBnI6umeKk9hmNchfpg
         fTKfCDtLdIAfWDh/9BuSQ8wufxpkCydGSRAKCBtL9K8x/QS3JRkUrpBh0rZaaCb8VLQ9
         Z3lYvOEsg5KMZ+P25GLdxTusxDk8VP9bGNqY67Zi5Hh79fd00rP+5kn7yRRs1qroRYbl
         pPiW5YjjPs9lLXcJwkhUzk8kyI95C5qXfzajB2dY8qzSrq6FXqQbsa5BieSiZUmBxkOr
         mBKw==
X-Gm-Message-State: AA+aEWYdCLHEGANXwJ2v7wjbB94M6NiMX8WDR9FlMRvk6lrpT17lfJC4
        ejJt+S/Vcf1fhNbuL2RsSpbdrrSNixWxB00UQyg=
X-Google-Smtp-Source: AFSGD/WcINbTHFsTsfcCbYnwVsZMvSpoqhUV1NVYbym4L9kOBlY7lf580+L5/jFke4fK5wM2qoa+P+P4U8iJgeSJYVY=
X-Received: by 2002:ab0:60da:: with SMTP id g26mr9642850uam.104.1544640940486;
 Wed, 12 Dec 2018 10:55:40 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-5-david@fromorbit.com>
 <87a7lbrng4.fsf@suse.com>
In-Reply-To: <87a7lbrng4.fsf@suse.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Wed, 12 Dec 2018 13:55:28 -0500
Message-ID: <CAN-5tyHNGtLxeFyEO6qX_+8=K4tpkgYjB11OkfCTdWfokfAyEg@mail.gmail.com>
Subject: Re: [PATCH 04/11] vfs: add missing checks to copy_file_range
To:     lhenriques@suse.com
Cc:     david@fromorbit.com, "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Dec 12, 2018 at 6:31 AM Luis Henriques <lhenriques@suse.com> wrote:
>
> Dave Chinner <david@fromorbit.com> writes:
>
> <snip>
>
> > +int generic_copy_file_checks(struct file *file_in, loff_t pos_in,
> > +                      struct file *file_out, loff_t pos_out,
> > +                      size_t *req_count, unsigned int flags)
> > +{
>
> <snip>
>
> > +     /* Don't allow overlapped copying within the same file. */
> > +     if (inode_in == inode_out &&
> > +         pos_out + count > pos_in &&
> > +         pos_out < pos_in + count)
> > +             return -EINVAL;
>
> I was wondering if, with the above check, it would make sense to also
> have an extra patch changing some filesystems (ceph, nfs and cifs) to
> simply return -EOPNOTSUPP (instead of -EINVAL) when inode_in ==
> inode_out.  Something like the diff below (not tested!).
>
> This caught my attention when I was running the latest generic xfstests
> on ceph and realised that I had some new failures due to the recently
> added copy_file_range support in fsx by Darrick.  The failures were
> caused by the usage of the same fd both as source and destination.
>
> Cheers,
> --
> Luis
>
>
> diff --git a/fs/ceph/file.c b/fs/ceph/file.c
> index 189df668b6a0..c22ac60ec0ba 100644
> --- a/fs/ceph/file.c
> +++ b/fs/ceph/file.c
> @@ -1904,7 +1904,7 @@ static ssize_t ceph_copy_file_range(struct file *src_file, loff_t src_off,
>         bool do_final_copy = false;
>
>         if (src_inode == dst_inode)
> -               return -EINVAL;
> +               return -EOPNOTSUPP;
>         if (ceph_snap(dst_inode) != CEPH_NOSNAP)
>                 return -EROFS;
>
> diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
> index 865706edb307..d4f63eae531e 100644
> --- a/fs/cifs/cifsfs.c
> +++ b/fs/cifs/cifsfs.c
> @@ -1068,7 +1068,7 @@ ssize_t cifs_file_copychunk_range(unsigned int xid,
>         cifs_dbg(FYI, "copychunk range\n");
>
>         if (src_inode == target_inode) {
> -               rc = -EINVAL;
> +               rc = -EOPNOTSUPP;
>                 goto out;
>         }
>
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index 46d691ba04bc..910a2abade92 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -136,7 +136,7 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
>         ssize_t ret;
>
>         if (file_inode(file_in) == file_inode(file_out))
> -               return -EINVAL;
> +               return -EOPNOTSUPP;

Please don't change the NFS bits. This is against the NFS
specifications. RFC 7862 15.2.3

(snippet)
SAVED_FH and CURRENT_FH must be different files.  If SAVED_FH and
   CURRENT_FH refer to the same file, the operation MUST fail with
   NFS4ERR_INVAL.

>  retry:
>         ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
>         if (ret == -EAGAIN)
