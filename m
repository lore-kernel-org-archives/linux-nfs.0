From: Steve French <smfrench@gmail.com>
Subject: Re: [PATCH 1/3] NFS: Use kernel DNS resolver [ver #2]
Date: Wed, 11 Aug 2010 11:01:19 -0500
Message-ID: <AANLkTinFOhtSe8nXu1pHbD+vbyFzgsgOqqz7SJ_70bT9@mail.gmail.com>
References: <20100811083753.19001.28878.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: torvalds@osdl.org, akpm@linux-foundation.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
	Bryan Schumaker <bjschuma@netapp.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: David Howells <dhowells@redhat.com>
Return-path: <linux-cifs-owner@vger.kernel.org>
In-Reply-To: <20100811083753.19001.28878.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Sender: linux-cifs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Patches 1 - 3 of this series now in cifs-2.6.git

On Wed, Aug 11, 2010 at 3:37 AM, David Howells <dhowells@redhat.com> wr=
ote:
> From: Bryan Schumaker <bjschuma@netapp.com>
>
> Use the kernel DNS resolver to translate hostnames to IP addresses. =A0=
Create a
> new config option to choose between the legacy DNS resolver and the n=
ew
> resolver.
>
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>
> =A0fs/nfs/Kconfig =A0 =A0 =A0 | =A0 16 ++++++++++++++++
> =A0fs/nfs/dns_resolve.c | =A0 24 ++++++++++++++++++++++++
> =A0fs/nfs/dns_resolve.h | =A0 12 ++++++++++++
> =A03 files changed, 52 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index cc1bb33..c5bbdca 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -100,3 +100,19 @@ config NFS_FSCACHE
> =A0 =A0 =A0 =A0help
> =A0 =A0 =A0 =A0 =A0Say Y here if you want NFS data to be cached local=
ly on disc through
> =A0 =A0 =A0 =A0 =A0the general filesystem cache manager
> +
> +config NFS_USE_LEGACY_DNS
> + =A0 =A0 =A0 bool "Use the legacy NFS DNS resolver"
> + =A0 =A0 =A0 depends on NFS_V4
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 The kernel now provides a method for translating a =
host name into an
> + =A0 =A0 =A0 =A0 IP address. =A0Select Y here if you would rather us=
e your own DNS
> + =A0 =A0 =A0 =A0 resolver script.
> +
> + =A0 =A0 =A0 =A0 If unsure, say N
> +
> +config NFS_USE_KERNEL_DNS
> + =A0 =A0 =A0 bool
> + =A0 =A0 =A0 depends on NFS_V4 && !NFS_USE_LEGACY_DNS
> + =A0 =A0 =A0 select DNS_RESOLVER
> + =A0 =A0 =A0 default y
> diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
> index 76fd235..dba50a5 100644
> --- a/fs/nfs/dns_resolve.c
> +++ b/fs/nfs/dns_resolve.c
> @@ -6,6 +6,29 @@
> =A0* Resolves DNS hostnames into valid ip addresses
> =A0*/
>
> +#ifdef CONFIG_NFS_USE_KERNEL_DNS
> +
> +#include <linux/sunrpc/clnt.h>
> +#include <linux/dns_resolver.h>
> +
> +ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sockaddr *sa, size_t salen)
> +{
> + =A0 =A0 =A0 ssize_t ret;
> + =A0 =A0 =A0 char *ip_addr =3D NULL;
> + =A0 =A0 =A0 int ip_len;
> +
> + =A0 =A0 =A0 ip_len =3D dns_query(NULL, name, namelen, NULL, &ip_add=
r, NULL);
> + =A0 =A0 =A0 if (ip_len > 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D rpc_pton(ip_addr, ip_len, sa, s=
alen);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ESRCH;
> + =A0 =A0 =A0 kfree(ip_addr);
> + =A0 =A0 =A0 return ret;
> +}
> +
> +#else
> +
> =A0#include <linux/hash.h>
> =A0#include <linux/string.h>
> =A0#include <linux/kmod.h>
> @@ -346,3 +369,4 @@ void nfs_dns_resolver_destroy(void)
> =A0 =A0 =A0 =A0nfs_cache_unregister(&nfs_dns_resolve);
> =A0}
>
> +#endif
> diff --git a/fs/nfs/dns_resolve.h b/fs/nfs/dns_resolve.h
> index a3f0938..199bb55 100644
> --- a/fs/nfs/dns_resolve.h
> +++ b/fs/nfs/dns_resolve.h
> @@ -6,8 +6,20 @@
>
> =A0#define NFS_DNS_HOSTNAME_MAXLEN =A0 =A0 =A0 =A0(128)
>
> +
> +#ifdef CONFIG_NFS_USE_KERNEL_DNS
> +static inline int nfs_dns_resolver_init(void)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static inline void nfs_dns_resolver_destroy(void)
> +{}
> +#else
> =A0extern int nfs_dns_resolver_init(void);
> =A0extern void nfs_dns_resolver_destroy(void);
> +#endif
> +
> =A0extern ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct sockaddr *sa, size_t salen);
>
>
>



--=20
Thanks,

Steve
