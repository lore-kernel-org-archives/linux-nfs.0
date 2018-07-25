Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36791 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728927AbeGYOLn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jul 2018 10:11:43 -0400
MIME-Version: 1.0
References: <20180724192918.31165-1-sthemmin@microsoft.com> <20180724192918.31165-8-sthemmin@microsoft.com>
In-Reply-To: <20180724192918.31165-8-sthemmin@microsoft.com>
From: Ilya Dryomov <idryomov@gmail.com>
Date: Wed, 25 Jul 2018 14:59:56 +0200
Message-ID: <CAOi1vP8C4-Sn1HAD5Cjo98je8g2M-BXeV97weJHUP-2_mYwM9A@mail.gmail.com>
Subject: Re: [PATCH PATCH net-next 07/18] ceph: fix whitespace
To: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>, ericvh@gmail.com,
        rminnich@sandia.gov, lucho@ionkov.net, ralf@linux-mips.org,
        jreuter@yaina.de, pablo@netfilter.org, kadlec@blackhole.kfki.hu,
        fw@strlen.de, alex.aring@gmail.com, stefan@datenfreihafen.org,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        johannes@sipsolutions.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us,
        Vlad Yasevich <vyasevich@gmail.com>, nhorman@tuxdriver.com,
        marcelo.leitner@gmail.com, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, steffen.klassert@secunet.com,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev <netdev@vger.kernel.org>,
        v9fs-developer@lists.sourceforge.net, linux-hams@vger.kernel.org,
        Ceph Development <ceph-devel@vger.kernel.org>,
        linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org,
        linux-wireless@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-x25@vger.kernel.org, sthemmin@microsoft.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 24, 2018 at 9:31 PM Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> Remove blank lines at end of file and trailing whitespace.
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> ---
>  net/ceph/Kconfig      | 1 -
>  net/ceph/Makefile     | 1 -
>  net/ceph/auth_none.c  | 1 -
>  net/ceph/auth_none.h  | 1 -
>  net/ceph/auth_x.c     | 2 --
>  net/ceph/auth_x.h     | 1 -
>  net/ceph/mon_client.c | 2 +-
>  net/ceph/pagevec.c    | 1 -
>  8 files changed, 1 insertion(+), 9 deletions(-)
>
> diff --git a/net/ceph/Kconfig b/net/ceph/Kconfig
> index f8cceb99e732..cd2d5b9301a1 100644
> --- a/net/ceph/Kconfig
> +++ b/net/ceph/Kconfig
> @@ -41,4 +41,3 @@ config CEPH_LIB_USE_DNS_RESOLVER
>           Documentation/networking/dns_resolver.txt
>
>           If unsure, say N.
> -
> diff --git a/net/ceph/Makefile b/net/ceph/Makefile
> index 12bf49772d24..db09defe27d0 100644
> --- a/net/ceph/Makefile
> +++ b/net/ceph/Makefile
> @@ -15,4 +15,3 @@ libceph-y := ceph_common.o messenger.o msgpool.o buffer.o pagelist.o \
>         auth_x.o \
>         ceph_fs.o ceph_strings.o ceph_hash.o \
>         pagevec.o snapshot.o string_table.o
> -
> diff --git a/net/ceph/auth_none.c b/net/ceph/auth_none.c
> index 41d2a0c72236..edb7042479ed 100644
> --- a/net/ceph/auth_none.c
> +++ b/net/ceph/auth_none.c
> @@ -142,4 +142,3 @@ int ceph_auth_none_init(struct ceph_auth_client *ac)
>         ac->ops = &ceph_auth_none_ops;
>         return 0;
>  }
> -
> diff --git a/net/ceph/auth_none.h b/net/ceph/auth_none.h
> index 860ed9875791..4158f064302e 100644
> --- a/net/ceph/auth_none.h
> +++ b/net/ceph/auth_none.h
> @@ -26,4 +26,3 @@ struct ceph_auth_none_info {
>  int ceph_auth_none_init(struct ceph_auth_client *ac);
>
>  #endif
> -
> diff --git a/net/ceph/auth_x.c b/net/ceph/auth_x.c
> index 2f4a1baf5f52..32c7f5c4b1a6 100644
> --- a/net/ceph/auth_x.c
> +++ b/net/ceph/auth_x.c
> @@ -823,5 +823,3 @@ int ceph_x_init(struct ceph_auth_client *ac)
>  out:
>         return ret;
>  }
> -
> -
> diff --git a/net/ceph/auth_x.h b/net/ceph/auth_x.h
> index 454cb54568af..a71c4c282b57 100644
> --- a/net/ceph/auth_x.h
> +++ b/net/ceph/auth_x.h
> @@ -52,4 +52,3 @@ struct ceph_x_info {
>  int ceph_x_init(struct ceph_auth_client *ac);
>
>  #endif
> -
> diff --git a/net/ceph/mon_client.c b/net/ceph/mon_client.c
> index d7a7a2330ef7..18deb3d889c4 100644
> --- a/net/ceph/mon_client.c
> +++ b/net/ceph/mon_client.c
> @@ -1249,7 +1249,7 @@ static void dispatch(struct ceph_connection *con, struct ceph_msg *msg)
>                 if (monc->client->extra_mon_dispatch &&
>                     monc->client->extra_mon_dispatch(monc->client, msg) == 0)
>                         break;
> -
> +
>                 pr_err("received unknown message type %d %s\n", type,
>                        ceph_msg_type_name(type));
>         }
> diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
> index e560d3975f41..d3736f5bffec 100644
> --- a/net/ceph/pagevec.c
> +++ b/net/ceph/pagevec.c
> @@ -197,4 +197,3 @@ void ceph_zero_page_vector_range(int off, int len, struct page **pages)
>         }
>  }
>  EXPORT_SYMBOL(ceph_zero_page_vector_range);
> -

Applied.

Thanks,

                Ilya
