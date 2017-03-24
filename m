Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:34887 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753903AbdCXNuB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Mar 2017 09:50:01 -0400
MIME-Version: 1.0
In-Reply-To: <1489752646-8749-7-git-send-email-elena.reshetova@intel.com>
References: <1489752646-8749-1-git-send-email-elena.reshetova@intel.com> <1489752646-8749-7-git-send-email-elena.reshetova@intel.com>
From: Ilya Dryomov <idryomov@gmail.com>
Date: Fri, 24 Mar 2017 14:49:48 +0100
Message-ID: <CAOi1vP8BeC5R8CU0_NpbFBXA_JpVfbBzxyVsAne+9JGkOgPbKA@mail.gmail.com>
Subject: Re: [PATCH 06/23] net, ceph: convert ceph_pagelist.refcnt from
 atomic_t to refcount_t
To: Elena Reshetova <elena.reshetova@intel.com>
Cc: netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-rdma@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, linux-x25@vger.kernel.org,
        linux-sctp@vger.kernel.org, vyasevich@gmail.com,
        nhorman@tuxdriver.com, linux-hams@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Ceph Development <ceph-devel@vger.kernel.org>,
        "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
        bfields@fieldses.org, Jeff Layton <jlayton@poochiereds.net>,
        steffen.klassert@secunet.com,
        Herbert Xu <herbert@gondor.apana.org.au>,
        santosh.shilimkar@oracle.com, jreuter@yaina.de,
        ralf@linux-mips.org, peterz@infradead.org,
        Kees Cook <keescook@chromium.org>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 17, 2017 at 1:10 PM, Elena Reshetova
<elena.reshetova@intel.com> wrote:
> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
>
> Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: David Windsor <dwindsor@gmail.com>
> ---
>  fs/ceph/mds_client.c          | 2 +-
>  include/linux/ceph/pagelist.h | 6 +++---
>  net/ceph/pagelist.c           | 2 +-
>  3 files changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
> index c681762..7b38e6c 100644
> --- a/fs/ceph/mds_client.c
> +++ b/fs/ceph/mds_client.c
> @@ -1991,7 +1991,7 @@ static struct ceph_msg *create_request_message(struct ceph_mds_client *mdsc,
>
>         if (req->r_pagelist) {
>                 struct ceph_pagelist *pagelist = req->r_pagelist;
> -               atomic_inc(&pagelist->refcnt);
> +               refcount_inc(&pagelist->refcnt);
>                 ceph_msg_data_add_pagelist(msg, pagelist);
>                 msg->hdr.data_len = cpu_to_le32(pagelist->length);
>         } else {
> diff --git a/include/linux/ceph/pagelist.h b/include/linux/ceph/pagelist.h
> index 13d71fe..75a7db2 100644
> --- a/include/linux/ceph/pagelist.h
> +++ b/include/linux/ceph/pagelist.h
> @@ -2,7 +2,7 @@
>  #define __FS_CEPH_PAGELIST_H
>
>  #include <asm/byteorder.h>
> -#include <linux/atomic.h>
> +#include <linux/refcount.h>
>  #include <linux/list.h>
>  #include <linux/types.h>
>
> @@ -13,7 +13,7 @@ struct ceph_pagelist {
>         size_t room;
>         struct list_head free_list;
>         size_t num_pages_free;
> -       atomic_t refcnt;
> +       refcount_t refcnt;
>  };
>
>  struct ceph_pagelist_cursor {
> @@ -30,7 +30,7 @@ static inline void ceph_pagelist_init(struct ceph_pagelist *pl)
>         pl->room = 0;
>         INIT_LIST_HEAD(&pl->free_list);
>         pl->num_pages_free = 0;
> -       atomic_set(&pl->refcnt, 1);
> +       refcount_set(&pl->refcnt, 1);
>  }
>
>  extern void ceph_pagelist_release(struct ceph_pagelist *pl);
> diff --git a/net/ceph/pagelist.c b/net/ceph/pagelist.c
> index 6864007..ce09f73 100644
> --- a/net/ceph/pagelist.c
> +++ b/net/ceph/pagelist.c
> @@ -16,7 +16,7 @@ static void ceph_pagelist_unmap_tail(struct ceph_pagelist *pl)
>
>  void ceph_pagelist_release(struct ceph_pagelist *pl)
>  {
> -       if (!atomic_dec_and_test(&pl->refcnt))
> +       if (!refcount_dec_and_test(&pl->refcnt))
>                 return;
>         ceph_pagelist_unmap_tail(pl);
>         while (!list_empty(&pl->head)) {

Applied.

Thanks,

                Ilya
