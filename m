Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:54874 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726605AbeJSXY6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Oct 2018 19:24:58 -0400
From: Punit Agrawal <punit.agrawal@arm.com>
To: Cristian Marussi <cristian.marussi@arm.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Subject: Re: [aarch64] refcount_t: use-after-free in NFS with 64k pages
References: <c8b0e53b-eccf-5914-af8d-ee47dccd3bcd@arm.com>
Date: Fri, 19 Oct 2018 16:18:23 +0100
In-Reply-To: <c8b0e53b-eccf-5914-af8d-ee47dccd3bcd@arm.com> (Cristian
        Marussi's message of "Fri, 19 Oct 2018 15:48:36 +0100")
Message-ID: <87va5yvubk.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Cristian,

Thanks for digging into this.

Cristian Marussi <cristian.marussi@arm.com> writes:

> Hi all,
>
> I'm recently chasing a bug that frequently appears during our internal
> LTP test-runs when performed on aarch64 HW (Juno) systems with an
> NFS-mounted root.
>
> The failure is NOT related to any specific LTP testcase and this issue
> has been observed only when Kernel is configured to use 64KB pages.
> (on the latest LTP Sept18 TAG test suite a Kernel crash happened in 4
> out of 5 test runs...always on a different random test case)
>
> I'm testing on Linus branch on 4.19-rc6 (but I can see it up to
> 4.19-rc8 and also on next) and it is reported since 4.17 at least (not
> sure about this...anyway it was NOT happening)

The stacktrace suggests it's the same issue that I'd reported earlier -

    https://lkml.org/lkml/2018/6/29/209

though without the analysis below.

[...]

> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index bb5476a6d264..171813f9a291 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -432,6 +432,15 @@ void nfs_free_request(struct nfs_page *req)
>
>  void nfs_release_request(struct nfs_page *req)
>  {
> +       /* WORKAROUND */
> +       if ((kref_read(&req->wb_kref) == 1) &&
> +           (req->wb_list.prev != &req->wb_list ||
> +            req->wb_list.next != &req->wb_list)) {

Are the last two conditions just checking that wb_list is not empty?

Thanks for looking at this.

Punit

> +               pr_warn("%s -- Forcing REFCOUNT++ on dirty req[%u]:%px
> ->prev:%px  ->next:%px\n",
> +                       __func__, kref_read(&req->wb_kref), req,
> +                       req->wb_list.prev, req->wb_list.next);
> +               kref_get(&req->wb_kref);
> +       }
>         kref_put(&req->wb_kref, nfs_page_group_destroy);
>  }
>  EXPORT_SYMBOL_GPL(nfs_release_request);
>
> I still have to figure out WHY this is happening when the system is
> loaded AND only with 64kb pages. (so basically the root cause...:<)
>
> What I could see is that the refcount bad-accounting seems to
> originate during the early phase of nfs_page allocation:
>
> - OK: nfs_create_request creates straight away an nfs_page wb_kref +2
>
> - OK: nfs_create_request creates a nfs_page with wb_kref +1 AND then
> wb_kref is immediately after incremented to +2 by an
> nfs_inode_add_request() before being moved across wb_list
>
> - FAIL: nfs_create_request creates a nfs_page with wb_kref +1 and it
> remains to +1 till when it starts being moved across lists.
>
> Any ideas or suggestions to triage why this condition is happening ?
> (I'm not really an NFS guy...:D)
>
> Thanks
>
> Cristian
