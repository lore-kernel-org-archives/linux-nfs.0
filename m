Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:32888 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751577AbdCXNUo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Mar 2017 09:20:44 -0400
MIME-Version: 1.0
In-Reply-To: <1489752646-8749-5-git-send-email-elena.reshetova@intel.com>
References: <1489752646-8749-1-git-send-email-elena.reshetova@intel.com> <1489752646-8749-5-git-send-email-elena.reshetova@intel.com>
From: Ilya Dryomov <idryomov@gmail.com>
Date: Fri, 24 Mar 2017 14:20:42 +0100
Message-ID: <CAOi1vP97Cq5UhxryxsLe2MuNi9zJZFDaY3_CT76uU=_H_sJ-Nw@mail.gmail.com>
Subject: Re: [PATCH 04/23] net, ceph: convert ceph_snap_context.nref from
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
>  include/linux/ceph/libceph.h | 3 ++-
>  net/ceph/snapshot.c          | 6 +++---
>  2 files changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/ceph/libceph.h b/include/linux/ceph/libceph.h
> index 1816c5e..26dc674 100644
> --- a/include/linux/ceph/libceph.h
> +++ b/include/linux/ceph/libceph.h
> @@ -14,6 +14,7 @@
>  #include <linux/wait.h>
>  #include <linux/writeback.h>
>  #include <linux/slab.h>
> +#include <linux/refcount.h>
>
>  #include <linux/ceph/types.h>
>  #include <linux/ceph/messenger.h>
> @@ -159,7 +160,7 @@ struct ceph_client {
>   * dirtied.
>   */
>  struct ceph_snap_context {
> -       atomic_t nref;
> +       refcount_t nref;
>         u64 seq;
>         u32 num_snaps;
>         u64 snaps[];
> diff --git a/net/ceph/snapshot.c b/net/ceph/snapshot.c
> index 705414e..e14a5d0 100644
> --- a/net/ceph/snapshot.c
> +++ b/net/ceph/snapshot.c
> @@ -49,7 +49,7 @@ struct ceph_snap_context *ceph_create_snap_context(u32 snap_count,
>         if (!snapc)
>                 return NULL;
>
> -       atomic_set(&snapc->nref, 1);
> +       refcount_set(&snapc->nref, 1);
>         snapc->num_snaps = snap_count;
>
>         return snapc;
> @@ -59,7 +59,7 @@ EXPORT_SYMBOL(ceph_create_snap_context);
>  struct ceph_snap_context *ceph_get_snap_context(struct ceph_snap_context *sc)
>  {
>         if (sc)
> -               atomic_inc(&sc->nref);
> +               refcount_inc(&sc->nref);
>         return sc;
>  }
>  EXPORT_SYMBOL(ceph_get_snap_context);
> @@ -68,7 +68,7 @@ void ceph_put_snap_context(struct ceph_snap_context *sc)
>  {
>         if (!sc)
>                 return;
> -       if (atomic_dec_and_test(&sc->nref)) {
> +       if (refcount_dec_and_test(&sc->nref)) {
>                 /*printk(" deleting snap_context %p\n", sc);*/
>                 kfree(sc);
>         }

Applied.

Thanks,

                Ilya
