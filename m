Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FROM,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36374C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 18:42:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 03462218E0
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 18:42:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ESmibpps"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732413AbeLTSmk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 13:42:40 -0500
Received: from mail-ua1-f68.google.com ([209.85.222.68]:36952 "EHLO
        mail-ua1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731365AbeLTSmk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2018 13:42:40 -0500
Received: by mail-ua1-f68.google.com with SMTP id u19so898108uae.4
        for <linux-nfs@vger.kernel.org>; Thu, 20 Dec 2018 10:42:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WcgU+ZHQXtWCYY3Ax73kUnP8jPoERtsWXMmaPtGvwPY=;
        b=ESmibpps5ZXUwRaPFVvoiXARLpUPjWa0e4aE0vmke/CU4e5QVOler6SC/TAEKAb5+d
         53yJoBlCM+n+a1aqYxyMQwCxKT0m6u3/5ixvPO/yd3Fo16K2zGyfyXydDShmAs34GZOx
         DK0BW9ROq8V0cJU8V9VUJoI3e11x+KmS2SV2CymumcXmQAp94bydL7ZS8glPSb4xL1PC
         O54JzavyeGGcUJmGJ1x7LNUbZBCAeHX7DmrJb8BSiv11ygZ0gmiGgLJ5LW9qYdJsF6y9
         3tAFV59J1o3OyNZhiwtOnK4fakjuxTEEC+hYtd4TX494JRpLSkEipKUukzxxeaVUryNj
         txsQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=WcgU+ZHQXtWCYY3Ax73kUnP8jPoERtsWXMmaPtGvwPY=;
        b=ofwNMkVmLNJoFrnZgWG9IKQcSEm4ueo9f8X9uUZC13+y249ZGWDALqN9U2Of6yXGAM
         NFK4M9XVGisF/kPYe8WQ8/MQxnlwsKgXn1thAgWKcD5WeFUzrOyPaB805svCp54zC1US
         tTVPjoL32ZQv+Pot3SQbvMBb/PbIz5tPJbu7glQeDLnu5IhYEV303XF4bCZbKk7+o8wj
         WYclVtiE/3ZHgr4ACDplMMZjHbhjNByK1pxUmMh799mr5AQoDYv0iE1ky7F+AbT1rHTZ
         YY3vxRHkle+0C8LJM6Zn4jpyH6i8MxY1bJ0OYLIDzWyO8KH6a/8dkCYq7jyhKtiHkr7B
         mdmg==
X-Gm-Message-State: AA+aEWYAHYjEkEAUgB08TLOPmuGajWqhimbsx9H64zakQMBUrp5bIOEo
        cDZGgfjjySwX0aD23XJUJuCfJ2JFDz0eTvXgGnE=
X-Google-Smtp-Source: AFSGD/XOtr8GY1yqsbBZJyqtCuLMCAvUjNUuvwWiEoXtqgdeApxacDc7tgzbV7R/tb38Oe5s8dex9nJOukMExAqwUm8=
X-Received: by 2002:ab0:aa:: with SMTP id 39mr12038439uaj.120.1545331358702;
 Thu, 20 Dec 2018 10:42:38 -0800 (PST)
MIME-Version: 1.0
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
In-Reply-To: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 20 Dec 2018 13:42:27 -0500
Message-ID: <CAN-5tyGBO1CnhkEe9yPXdh4837NYsZc1fyJ4MCuMPM2eSv4C5g@mail.gmail.com>
Subject: Re: [PATCH v2 00/10] server-side support for "inter" SSC copy
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 30, 2018 at 3:03 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> This patch series adds support for NFSv4.2 copy offload feature
> allowing copy between two different NFS servers.
>
> This functionality depends on the VFS ability to support generic
> copy_file_range() where a copy is done between an NFS file and
> a local file system.
>
> This feature is enabled by the kernel module parameter --
> inter_copy_offload_enable -- and by default is disabled. There is
> also a kernel compile configuration of NFSD_V4_2_INTER_SSC that
> adds dependency on the NFS client side functions called from the
> server.
>
> These patches work on top of existing async intra copy offload
> patches. For the "inter" SSC, the implementation only supports
> asynchronous inter copy.
>
> On the source server, upon receiving a COPY_NOTIFY, it generate a
> unique stateid that's kept in the global list. Upon receiving a READ
> with a stateid, the code checks the normal list of open stateid and
> now additionally, it'll check the copy state list as well before
> deciding to either fail with BAD_STATEID or find one that matches.
> The stored stateid is only valid to be used for the first time
> with a choosen lease period (90s currently). When the source server
> received an OFFLOAD_CANCEL, it will remove the stateid from the
> global list. Otherwise, the copy stateid is removed upon the removal
> of its "parent" stateid (open/lock/delegation stateid).
>
> On the destination server, upon receiving a COPY request, the server
> establishes the necessary clientid/session with the source server.
> It calls into the NFS client code to establish the necessary
> open stateid, filehandle, file description (without doing an NFS open).
> Then the server calls into the copy_file_range() to preform the copy
> where the source file will issue NFS READs and then do local file
> system writes (this depends on the VFS ability to do cross device
> copy_file_range().
>
> v2:
> -- in on top of 4.20-rc4 + client side inter patch series
> -- VFS changes to do enable generic copy_file_range() and then NFS
> falls back on generic_copy_file_range() for previous EXDEV/OPNOTSUPP
> errors
> -- hopefully addressed Bruce's review comments (highlights are):
>    --- copy_notify patch: addressed naming, sc_cp_list access is
> now protected by s2s_cp_lock
>    --- fillin netloc4 patch: address the size and added WARN_ON
>    --- add ca_source to COPY: decode only 1 address, dont allocate
> memory (the rest into dummy)
>    --- check stateid against stored: moved the refcount under lock
>    --- allow stale filehandle: adding a loop to go thru the ops in
> the compound, store/manage puttfh if copy is present in the compound
> mark the source putfh as "no verify".
>
> All the patches (client inter) and this patch series is available
> from git://linux-nfs.org/projects/aglo/linux.git under the "linux-ssc"
> branch
>

Bruce,

Do you have comments on this v2? Once VFS has the patches for the
generic copy_file_range() functionality, NFS should be all set to just
used it.

> Olga Kornievskaia (10):
>   VFS generic copy_file_range() support
>   NFS fallback to generic_copy_file_range
>   NFSD fill-in netloc4 structure
>   NFSD add ca_source_server<> to COPY
>   NFSD return nfs4_stid in nfs4_preprocess_stateid_op
>   NFSD add COPY_NOTIFY operation
>   NFSD check stateids against copy stateids
>   NFSD generalize nfsd4_compound_state flag names
>   NFSD: allow inter server COPY to have a STALE source server fh
>   NFSD add nfs4 inter ssc to nfsd4_copy
>
>  fs/nfs/nfs4file.c    |   9 +-
>  fs/nfsd/Kconfig      |  10 ++
>  fs/nfsd/nfs4proc.c   | 406 ++++++++++++++++++++++++++++++++++++++++++++++-----
>  fs/nfsd/nfs4state.c  | 124 ++++++++++++++--
>  fs/nfsd/nfs4xdr.c    | 166 ++++++++++++++++++++-
>  fs/nfsd/nfsd.h       |  32 ++++
>  fs/nfsd/nfsfh.h      |   5 +-
>  fs/nfsd/nfssvc.c     |   6 +
>  fs/nfsd/state.h      |  21 ++-
>  fs/nfsd/xdr4.h       |  37 ++++-
>  fs/read_write.c      |  66 +++++++--
>  include/linux/fs.h   |   7 +
>  include/linux/nfs4.h |   1 +
>  mm/filemap.c         |   6 +-
>  14 files changed, 810 insertions(+), 86 deletions(-)
>
> --
> 1.8.3.1
>
