Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:41341 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387AbbBLJUX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2015 04:20:23 -0500
Received: by mail-qc0-f181.google.com with SMTP id p6so7404252qcv.12
        for <linux-nfs@vger.kernel.org>; Thu, 12 Feb 2015 01:20:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1423732041-18082-1-git-send-email-tao.peng@primarydata.com>
References: <1423732041-18082-1-git-send-email-tao.peng@primarydata.com>
From: Peng Tao <tao.peng@primarydata.com>
Date: Thu, 12 Feb 2015 17:20:02 +0800
Message-ID: <CAKVebiU06hZVkVQ+Q5v9GoaFK861PzDL3hHTeEqP03QvA3qAig@mail.gmail.com>
Subject: Re: [PATCH] nfsstat: update client op to match latest kernel
To: Steve Dickson <steved@redhat.com>
Cc: Peng Tao <tao.peng@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sorry, forgot to cc Steve...

Cheers,
Tao

On Thu, Feb 12, 2015 at 5:07 PM, Peng Tao <tao.peng@primarydata.com> wrote:
> We've added a bunch of ops and removed getdevicelist.
>
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  utils/nfsstat/nfsstat.c | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
> index 9f481db..de57109 100644
> --- a/utils/nfsstat/nfsstat.c
> +++ b/utils/nfsstat/nfsstat.c
> @@ -31,7 +31,7 @@ enum {
>         SRVPROC3_SZ = 22,
>         CLTPROC3_SZ = 22,
>         SRVPROC4_SZ = 2,
> -       CLTPROC4_SZ = 49,
> +       CLTPROC4_SZ = 55,
>         SRVPROC4OPS_SZ = 59,
>  };
>
> @@ -127,7 +127,7 @@ static const char * nfscltproc4name[CLTPROC4_SZ] = {
>         "remove",    "rename",    "link",    "symlink",     "create",      "pathconf",
>         "statfs",    "readlink",  "readdir", "server_caps", "delegreturn", "getacl",
>         "setacl",    "fs_locations",
> -       "rel_lkowner", "secinfo",
> +       "rel_lkowner", "secinfo", "fsid_present",
>         /* nfsv4.1 client ops */
>         "exchange_id",
>         "create_ses",
> @@ -139,7 +139,12 @@ static const char *        nfscltproc4name[CLTPROC4_SZ] = {
>         "getdevinfo",
>         "layoutcommit",
>         "layoutreturn",
> -       "getdevlist",
> +       "secinfo_no_n",
> +       "test_stateid",
> +       "free_stateid",
> +       "bind_con_ses",
> +       "destroy_clid",
> +       "seek",
>  };
>
>  static const char *     nfssrvproc4opname[SRVPROC4OPS_SZ] = {
> --
> 1.9.1
>
