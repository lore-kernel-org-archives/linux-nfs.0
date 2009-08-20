From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 30/32] NFS: Add a dns resolver for use with NFSv4
	referrals and migration
Date: Thu, 20 Aug 2009 17:03:52 -0400
Message-ID: <20090820210352.GB2451@fieldses.org>
References: <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-28-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-29-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-30-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-31-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47632 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755420AbZHTVDv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Aug 2009 17:03:51 -0400
In-Reply-To: <1250725135-14632-31-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 19, 2009 at 07:38:53PM -0400, Trond Myklebust wrote:
> The NFSv4 and NFSv4.1 protocols both allow for the redirection of a c=
lient
> from one server to another in order to support filesystem migration a=
nd
> replication. For full protocol support, we need to add the ability to
> convert a DNS host name into an IP address that we can feed to the RP=
C
> client.

Your current nfs-for-2.6.32 doesn't compile for me:

	In file included from fs/nfs/cache_lib.c:14:
	include/linux/sunrpc/rpc_pipe_fs.h:35: error: field =E2=80=98queue_tim=
eout=E2=80=99 has incomplete type

(I wonder why you weren't seeing this?)

--b.


>=20
> We'll reuse the sunrpc cache, now that it has been converted to work =
with
> rpc_pipefs.
>=20
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  Documentation/filesystems/nfs.txt   |   98 ++++++++++
>  Documentation/kernel-parameters.txt |    8 +
>  fs/nfs/Makefile                     |    3 +-
>  fs/nfs/cache_lib.c                  |  140 +++++++++++++++
>  fs/nfs/cache_lib.h                  |   27 +++
>  fs/nfs/dns_resolve.c                |  335 +++++++++++++++++++++++++=
++++++++++
>  fs/nfs/dns_resolve.h                |   14 ++
>  fs/nfs/inode.c                      |    8 +
>  net/sunrpc/rpc_pipe.c               |    7 +
>  9 files changed, 639 insertions(+), 1 deletions(-)
>  create mode 100644 Documentation/filesystems/nfs.txt
>  create mode 100644 fs/nfs/cache_lib.c
>  create mode 100644 fs/nfs/cache_lib.h
>  create mode 100644 fs/nfs/dns_resolve.c
>  create mode 100644 fs/nfs/dns_resolve.h
>=20
> diff --git a/Documentation/filesystems/nfs.txt b/Documentation/filesy=
stems/nfs.txt
> new file mode 100644
> index 0000000..f50f26c
> --- /dev/null
> +++ b/Documentation/filesystems/nfs.txt
> @@ -0,0 +1,98 @@
> +
> +The NFS client
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +The NFS version 2 protocol was first documented in RFC1094 (March 19=
89).
> +Since then two more major releases of NFS have been published, with =
NFSv3
> +being documented in RFC1813 (June 1995), and NFSv4 in RFC3530 (April
> +2003).
> +
> +The Linux NFS client currently supports all the above published vers=
ions,
> +and work is in progress on adding support for minor version 1 of the=
 NFSv4
> +protocol.
> +
> +The purpose of this document is to provide information on some of th=
e
> +upcall interfaces that are used in order to provide the NFS client w=
ith
> +some of the information that it requires in order to fully comply wi=
th
> +the NFS spec.
> +
> +The DNS resolver
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +NFSv4 allows for one server to refer the NFS client to data that has=
 been
> +migrated onto another server by means of the special "fs_locations"
> +attribute. See
> +	http://tools.ietf.org/html/rfc3530#section-6
> +and
> +	http://tools.ietf.org/html/draft-ietf-nfsv4-referrals-00
> +
> +The fs_locations information can take the form of either an ip addre=
ss and
> +a path, or a DNS hostname and a path. The latter requires the NFS cl=
ient to
> +do a DNS lookup in order to mount the new volume, and hence the need=
 for an
> +upcall to allow userland to provide this service.
> +
> +Assuming that the user has the 'rpc_pipefs' filesystem mounted in th=
e usual
> +/var/lib/nfs/rpc_pipefs, the upcall consists of the following steps:
> +
> +   (1) The process checks the dns_resolve cache to see if it contain=
s a
> +       valid entry. If so, it returns that entry and exits.
> +
> +   (2) If no valid entry exists, the helper script '/sbin/nfs_cache_=
getent'
> +       (may be changed using the 'nfs.cache_getent' kernel boot para=
meter)
> +       is run, with two arguments:
> +		- the cache name, "dns_resolve"
> +		- the hostname to resolve
> +
> +   (3) After looking up the corresponding ip address, the helper scr=
ipt
> +       writes the result into the rpc_pipefs pseudo-file
> +       '/var/lib/nfs/rpc_pipefs/cache/dns_resolve/channel'
> +       in the following (text) format:
> +
> +		"<ip address> <hostname> <ttl>\n"
> +
> +       Where <ip address> is in the usual IPv4 (123.456.78.90) or IP=
v6
> +       (ffee:ddcc:bbaa:9988:7766:5544:3322:1100, ffee::1100, ...) fo=
rmat.
> +       <hostname> is identical to the second argument of the helper
> +       script, and <ttl> is the 'time to live' of this cache entry (=
in
> +       units of seconds).
> +
> +       Note: If <ip address> is invalid, say the string "0", then a =
negative
> +       entry is created, which will cause the kernel to treat the ho=
stname
> +       as having no valid DNS translation.
> +
> +
> +
> +
> +A basic sample /sbin/nfs_cache_getent
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +#!/bin/bash
> +#
> +ttl=3D600
> +#
> +cut=3D/usr/bin/cut
> +getent=3D/usr/bin/getent
> +rpc_pipefs=3D/var/lib/nfs/rpc_pipefs
> +#
> +die()
> +{
> +	echo "Usage: $0 cache_name entry_name"
> +	exit 1
> +}
> +
> +[ $# -lt 2 ] && die
> +cachename=3D"$1"
> +cache_path=3D${rpc_pipefs}/cache/${cachename}/channel
> +
> +case "${cachename}" in
> +	dns_resolve)
> +		name=3D"$2"
> +		result=3D"$(${getent} hosts ${name} | ${cut} -f1 -d\ )"
> +		[ -z "${result}" ] && result=3D"0"
> +		;;
> +	*)
> +		die
> +		;;
> +esac
> +echo "${result} ${name} ${ttl}" >${cache_path}
> +
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kern=
el-parameters.txt
> index 2f18206..4d0ed96 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -1499,6 +1499,14 @@ and is between 256 and 4096 characters. It is =
defined in the file
>  			[NFS] set the TCP port on which the NFSv4 callback
>  			channel should listen.
> =20
> +	nfs.cache_getent=3D
> +			[NFS] sets the pathname to the program which is used
> +			to update the NFS client cache entries.
> +
> +	nfs.cache_getent_timeout=3D
> +			[NFS] sets the timeout after which an attempt to
> +			update a cache entry is deemed to have failed.
> +
>  	nfs.idmap_cache_timeout=3D
>  			[NFS] set the maximum lifetime for idmapper cache
>  			entries.
> diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
> index 8451598..da7fda6 100644
> --- a/fs/nfs/Makefile
> +++ b/fs/nfs/Makefile
> @@ -6,7 +6,8 @@ obj-$(CONFIG_NFS_FS) +=3D nfs.o
> =20
>  nfs-y 			:=3D client.o dir.o file.o getroot.o inode.o super.o nfs2xd=
r.o \
>  			   direct.o pagelist.o proc.o read.o symlink.o unlink.o \
> -			   write.o namespace.o mount_clnt.o
> +			   write.o namespace.o mount_clnt.o \
> +			   dns_resolve.o cache_lib.o
>  nfs-$(CONFIG_ROOT_NFS)	+=3D nfsroot.o
>  nfs-$(CONFIG_NFS_V3)	+=3D nfs3proc.o nfs3xdr.o
>  nfs-$(CONFIG_NFS_V3_ACL)	+=3D nfs3acl.o
> diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
> new file mode 100644
> index 0000000..b4ffd01
> --- /dev/null
> +++ b/fs/nfs/cache_lib.c
> @@ -0,0 +1,140 @@
> +/*
> + * linux/fs/nfs/cache_lib.c
> + *
> + * Helper routines for the NFS client caches
> + *
> + * Copyright (c) 2009 Trond Myklebust <Trond.Myklebust@netapp.com>
> + */
> +#include <linux/kmod.h>
> +#include <linux/module.h>
> +#include <linux/moduleparam.h>
> +#include <linux/mount.h>
> +#include <linux/namei.h>
> +#include <linux/sunrpc/cache.h>
> +#include <linux/sunrpc/rpc_pipe_fs.h>
> +
> +#include "cache_lib.h"
> +
> +#define NFS_CACHE_UPCALL_PATHLEN 256
> +#define NFS_CACHE_UPCALL_TIMEOUT 15
> +
> +static char nfs_cache_getent_prog[NFS_CACHE_UPCALL_PATHLEN] =3D
> +				"/sbin/nfs_cache_getent";
> +static unsigned long nfs_cache_getent_timeout =3D NFS_CACHE_UPCALL_T=
IMEOUT;
> +
> +module_param_string(cache_getent, nfs_cache_getent_prog,
> +		sizeof(nfs_cache_getent_prog), 0600);
> +MODULE_PARM_DESC(cache_getent, "Path to the client cache upcall prog=
ram");
> +module_param_named(cache_getent_timeout, nfs_cache_getent_timeout, u=
long, 0600);
> +MODULE_PARM_DESC(cache_getent_timeout, "Timeout (in seconds) after w=
hich "
> +		"the cache upcall is assumed to have failed");
> +
> +int nfs_cache_upcall(struct cache_detail *cd, char *entry_name)
> +{
> +	static char *envp[] =3D { "HOME=3D/",
> +		"TERM=3Dlinux",
> +		"PATH=3D/sbin:/usr/sbin:/bin:/usr/bin",
> +		NULL
> +	};
> +	char *argv[] =3D {
> +		nfs_cache_getent_prog,
> +		cd->name,
> +		entry_name,
> +		NULL
> +	};
> +	int ret =3D -EACCES;
> +
> +	if (nfs_cache_getent_prog[0] =3D=3D '\0')
> +		goto out;
> +	ret =3D call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
> +	/*
> +	 * Disable the upcall mechanism if we're getting an ENOENT or
> +	 * EACCES error. The admin can re-enable it on the fly by using
> +	 * sysfs to set the 'cache_getent' parameter once the problem
> +	 * has been fixed.
> +	 */
> +	if (ret =3D=3D -ENOENT || ret =3D=3D -EACCES)
> +		nfs_cache_getent_prog[0] =3D '\0';
> +out:
> +	return ret > 0 ? 0 : ret;
> +}
> +
> +/*
> + * Deferred request handling
> + */
> +void nfs_cache_defer_req_put(struct nfs_cache_defer_req *dreq)
> +{
> +	if (atomic_dec_and_test(&dreq->count))
> +		kfree(dreq);
> +}
> +
> +static void nfs_dns_cache_revisit(struct cache_deferred_req *d, int =
toomany)
> +{
> +	struct nfs_cache_defer_req *dreq;
> +
> +	dreq =3D container_of(d, struct nfs_cache_defer_req, deferred_req);
> +
> +	complete_all(&dreq->completion);
> +	nfs_cache_defer_req_put(dreq);
> +}
> +
> +static struct cache_deferred_req *nfs_dns_cache_defer(struct cache_r=
eq *req)
> +{
> +	struct nfs_cache_defer_req *dreq;
> +
> +	dreq =3D container_of(req, struct nfs_cache_defer_req, req);
> +	dreq->deferred_req.revisit =3D nfs_dns_cache_revisit;
> +	atomic_inc(&dreq->count);
> +
> +	return &dreq->deferred_req;
> +}
> +
> +struct nfs_cache_defer_req *nfs_cache_defer_req_alloc(void)
> +{
> +	struct nfs_cache_defer_req *dreq;
> +
> +	dreq =3D kzalloc(sizeof(*dreq), GFP_KERNEL);
> +	if (dreq) {
> +		init_completion(&dreq->completion);
> +		atomic_set(&dreq->count, 1);
> +		dreq->req.defer =3D nfs_dns_cache_defer;
> +	}
> +	return dreq;
> +}
> +
> +int nfs_cache_wait_for_upcall(struct nfs_cache_defer_req *dreq)
> +{
> +	if (wait_for_completion_timeout(&dreq->completion,
> +			nfs_cache_getent_timeout * HZ) =3D=3D 0)
> +		return -ETIMEDOUT;
> +	return 0;
> +}
> +
> +int nfs_cache_register(struct cache_detail *cd)
> +{
> +	struct nameidata nd;
> +	struct vfsmount *mnt;
> +	int ret;
> +
> +	mnt =3D rpc_get_mount();
> +	if (IS_ERR(mnt))
> +		return PTR_ERR(mnt);
> +	ret =3D vfs_path_lookup(mnt->mnt_root, mnt, "/cache", 0, &nd);
> +	if (ret)
> +		goto err;
> +	ret =3D sunrpc_cache_register_pipefs(nd.path.dentry,
> +			cd->name, 0600, cd);
> +	path_put(&nd.path);
> +	if (!ret)
> +		return ret;
> +err:
> +	rpc_put_mount();
> +	return ret;
> +}
> +
> +void nfs_cache_unregister(struct cache_detail *cd)
> +{
> +	sunrpc_cache_unregister_pipefs(cd);
> +	rpc_put_mount();
> +}
> +
> diff --git a/fs/nfs/cache_lib.h b/fs/nfs/cache_lib.h
> new file mode 100644
> index 0000000..76f856e
> --- /dev/null
> +++ b/fs/nfs/cache_lib.h
> @@ -0,0 +1,27 @@
> +/*
> + * Helper routines for the NFS client caches
> + *
> + * Copyright (c) 2009 Trond Myklebust <Trond.Myklebust@netapp.com>
> + */
> +
> +#include <linux/completion.h>
> +#include <linux/sunrpc/cache.h>
> +#include <asm/atomic.h>
> +
> +/*
> + * Deferred request handling
> + */
> +struct nfs_cache_defer_req {
> +	struct cache_req req;
> +	struct cache_deferred_req deferred_req;
> +	struct completion completion;
> +	atomic_t count;
> +};
> +
> +extern int nfs_cache_upcall(struct cache_detail *cd, char *entry_nam=
e);
> +extern struct nfs_cache_defer_req *nfs_cache_defer_req_alloc(void);
> +extern void nfs_cache_defer_req_put(struct nfs_cache_defer_req *dreq=
);
> +extern int nfs_cache_wait_for_upcall(struct nfs_cache_defer_req *dre=
q);
> +
> +extern int nfs_cache_register(struct cache_detail *cd);
> +extern void nfs_cache_unregister(struct cache_detail *cd);
> diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
> new file mode 100644
> index 0000000..f4d54ba
> --- /dev/null
> +++ b/fs/nfs/dns_resolve.c
> @@ -0,0 +1,335 @@
> +/*
> + * linux/fs/nfs/dns_resolve.c
> + *
> + * Copyright (c) 2009 Trond Myklebust <Trond.Myklebust@netapp.com>
> + *
> + * Resolves DNS hostnames into valid ip addresses
> + */
> +
> +#include <linux/hash.h>
> +#include <linux/string.h>
> +#include <linux/kmod.h>
> +#include <linux/module.h>
> +#include <linux/socket.h>
> +#include <linux/seq_file.h>
> +#include <linux/inet.h>
> +#include <linux/sunrpc/clnt.h>
> +#include <linux/sunrpc/cache.h>
> +#include <linux/sunrpc/svcauth.h>
> +
> +#include "dns_resolve.h"
> +#include "cache_lib.h"
> +
> +#define NFS_DNS_HASHBITS 4
> +#define NFS_DNS_HASHTBL_SIZE (1 << NFS_DNS_HASHBITS)
> +
> +static struct cache_head *nfs_dns_table[NFS_DNS_HASHTBL_SIZE];
> +
> +struct nfs_dns_ent {
> +	struct cache_head h;
> +
> +	char *hostname;
> +	size_t namelen;
> +
> +	struct sockaddr_storage addr;
> +	size_t addrlen;
> +};
> +
> +
> +static void nfs_dns_ent_init(struct cache_head *cnew,
> +		struct cache_head *ckey)
> +{
> +	struct nfs_dns_ent *new;
> +	struct nfs_dns_ent *key;
> +
> +	new =3D container_of(cnew, struct nfs_dns_ent, h);
> +	key =3D container_of(ckey, struct nfs_dns_ent, h);
> +
> +	kfree(new->hostname);
> +	new->hostname =3D kstrndup(key->hostname, key->namelen, GFP_KERNEL)=
;
> +	if (new->hostname) {
> +		new->namelen =3D key->namelen;
> +		memcpy(&new->addr, &key->addr, key->addrlen);
> +		new->addrlen =3D key->addrlen;
> +	} else {
> +		new->namelen =3D 0;
> +		new->addrlen =3D 0;
> +	}
> +}
> +
> +static void nfs_dns_ent_put(struct kref *ref)
> +{
> +	struct nfs_dns_ent *item;
> +
> +	item =3D container_of(ref, struct nfs_dns_ent, h.ref);
> +	kfree(item->hostname);
> +	kfree(item);
> +}
> +
> +static struct cache_head *nfs_dns_ent_alloc(void)
> +{
> +	struct nfs_dns_ent *item =3D kmalloc(sizeof(*item), GFP_KERNEL);
> +
> +	if (item !=3D NULL) {
> +		item->hostname =3D NULL;
> +		item->namelen =3D 0;
> +		item->addrlen =3D 0;
> +		return &item->h;
> +	}
> +	return NULL;
> +};
> +
> +static unsigned int nfs_dns_hash(const struct nfs_dns_ent *key)
> +{
> +	return hash_str(key->hostname, NFS_DNS_HASHBITS);
> +}
> +
> +static void nfs_dns_request(struct cache_detail *cd,
> +		struct cache_head *ch,
> +		char **bpp, int *blen)
> +{
> +	struct nfs_dns_ent *key =3D container_of(ch, struct nfs_dns_ent, h)=
;
> +
> +	qword_add(bpp, blen, key->hostname);
> +	(*bpp)[-1] =3D '\n';
> +}
> +
> +static int nfs_dns_upcall(struct cache_detail *cd,
> +		struct cache_head *ch)
> +{
> +	struct nfs_dns_ent *key =3D container_of(ch, struct nfs_dns_ent, h)=
;
> +	int ret;
> +
> +	ret =3D nfs_cache_upcall(cd, key->hostname);
> +	if (ret)
> +		ret =3D sunrpc_cache_pipe_upcall(cd, ch, nfs_dns_request);
> +	return ret;
> +}
> +
> +static int nfs_dns_match(struct cache_head *ca,
> +		struct cache_head *cb)
> +{
> +	struct nfs_dns_ent *a;
> +	struct nfs_dns_ent *b;
> +
> +	a =3D container_of(ca, struct nfs_dns_ent, h);
> +	b =3D container_of(cb, struct nfs_dns_ent, h);
> +
> +	if (a->namelen =3D=3D 0 || a->namelen !=3D b->namelen)
> +		return 0;
> +	return memcmp(a->hostname, b->hostname, a->namelen) =3D=3D 0;
> +}
> +
> +static int nfs_dns_show(struct seq_file *m, struct cache_detail *cd,
> +		struct cache_head *h)
> +{
> +	struct nfs_dns_ent *item;
> +	long ttl;
> +
> +	if (h =3D=3D NULL) {
> +		seq_puts(m, "# ip address      hostname        ttl\n");
> +		return 0;
> +	}
> +	item =3D container_of(h, struct nfs_dns_ent, h);
> +	ttl =3D (long)item->h.expiry_time - (long)get_seconds();
> +	if (ttl < 0)
> +		ttl =3D 0;
> +
> +	if (!test_bit(CACHE_NEGATIVE, &h->flags)) {
> +		char buf[INET6_ADDRSTRLEN+IPV6_SCOPE_ID_LEN+1];
> +
> +		rpc_ntop((struct sockaddr *)&item->addr, buf, sizeof(buf));
> +		seq_printf(m, "%15s ", buf);
> +	} else
> +		seq_puts(m, "<none>          ");
> +	seq_printf(m, "%15s %ld\n", item->hostname, ttl);
> +	return 0;
> +}
> +
> +struct nfs_dns_ent *nfs_dns_lookup(struct cache_detail *cd,
> +		struct nfs_dns_ent *key)
> +{
> +	struct cache_head *ch;
> +
> +	ch =3D sunrpc_cache_lookup(cd,
> +			&key->h,
> +			nfs_dns_hash(key));
> +	if (!ch)
> +		return NULL;
> +	return container_of(ch, struct nfs_dns_ent, h);
> +}
> +
> +struct nfs_dns_ent *nfs_dns_update(struct cache_detail *cd,
> +		struct nfs_dns_ent *new,
> +		struct nfs_dns_ent *key)
> +{
> +	struct cache_head *ch;
> +
> +	ch =3D sunrpc_cache_update(cd,
> +			&new->h, &key->h,
> +			nfs_dns_hash(key));
> +	if (!ch)
> +		return NULL;
> +	return container_of(ch, struct nfs_dns_ent, h);
> +}
> +
> +static int nfs_dns_parse(struct cache_detail *cd, char *buf, int buf=
len)
> +{
> +	char buf1[NFS_DNS_HOSTNAME_MAXLEN+1];
> +	struct nfs_dns_ent key, *item;
> +	unsigned long ttl;
> +	ssize_t len;
> +	int ret =3D -EINVAL;
> +
> +	if (buf[buflen-1] !=3D '\n')
> +		goto out;
> +	buf[buflen-1] =3D '\0';
> +
> +	len =3D qword_get(&buf, buf1, sizeof(buf1));
> +	if (len <=3D 0)
> +		goto out;
> +	key.addrlen =3D rpc_pton(buf1, len,
> +			(struct sockaddr *)&key.addr,
> +			sizeof(key.addr));
> +
> +	len =3D qword_get(&buf, buf1, sizeof(buf1));
> +	if (len <=3D 0)
> +		goto out;
> +
> +	key.hostname =3D buf1;
> +	key.namelen =3D len;
> +	memset(&key.h, 0, sizeof(key.h));
> +
> +	ttl =3D get_expiry(&buf);
> +	if (ttl =3D=3D 0)
> +		goto out;
> +	key.h.expiry_time =3D ttl + get_seconds();
> +
> +	ret =3D -ENOMEM;
> +	item =3D nfs_dns_lookup(cd, &key);
> +	if (item =3D=3D NULL)
> +		goto out;
> +
> +	if (key.addrlen =3D=3D 0)
> +		set_bit(CACHE_NEGATIVE, &key.h.flags);
> +
> +	item =3D nfs_dns_update(cd, &key, item);
> +	if (item =3D=3D NULL)
> +		goto out;
> +
> +	ret =3D 0;
> +	cache_put(&item->h, cd);
> +out:
> +	return ret;
> +}
> +
> +static struct cache_detail nfs_dns_resolve =3D {
> +	.owner =3D THIS_MODULE,
> +	.hash_size =3D NFS_DNS_HASHTBL_SIZE,
> +	.hash_table =3D nfs_dns_table,
> +	.name =3D "dns_resolve",
> +	.cache_put =3D nfs_dns_ent_put,
> +	.cache_upcall =3D nfs_dns_upcall,
> +	.cache_parse =3D nfs_dns_parse,
> +	.cache_show =3D nfs_dns_show,
> +	.match =3D nfs_dns_match,
> +	.init =3D nfs_dns_ent_init,
> +	.update =3D nfs_dns_ent_init,
> +	.alloc =3D nfs_dns_ent_alloc,
> +};
> +
> +static int do_cache_lookup(struct cache_detail *cd,
> +		struct nfs_dns_ent *key,
> +		struct nfs_dns_ent **item,
> +		struct nfs_cache_defer_req *dreq)
> +{
> +	int ret =3D -ENOMEM;
> +
> +	*item =3D nfs_dns_lookup(cd, key);
> +	if (*item) {
> +		ret =3D cache_check(cd, &(*item)->h, &dreq->req);
> +		if (ret)
> +			*item =3D NULL;
> +	}
> +	return ret;
> +}
> +
> +static int do_cache_lookup_nowait(struct cache_detail *cd,
> +		struct nfs_dns_ent *key,
> +		struct nfs_dns_ent **item)
> +{
> +	int ret =3D -ENOMEM;
> +
> +	*item =3D nfs_dns_lookup(cd, key);
> +	if (!*item)
> +		goto out_err;
> +	ret =3D -ETIMEDOUT;
> +	if (!test_bit(CACHE_VALID, &(*item)->h.flags)
> +			|| (*item)->h.expiry_time < get_seconds()
> +			|| cd->flush_time > (*item)->h.last_refresh)
> +		goto out_put;
> +	ret =3D -ENOENT;
> +	if (test_bit(CACHE_NEGATIVE, &(*item)->h.flags))
> +		goto out_put;
> +	return 0;
> +out_put:
> +	cache_put(&(*item)->h, cd);
> +out_err:
> +	*item =3D NULL;
> +	return ret;
> +}
> +
> +static int do_cache_lookup_wait(struct cache_detail *cd,
> +		struct nfs_dns_ent *key,
> +		struct nfs_dns_ent **item)
> +{
> +	struct nfs_cache_defer_req *dreq;
> +	int ret =3D -ENOMEM;
> +
> +	dreq =3D nfs_cache_defer_req_alloc();
> +	if (!dreq)
> +		goto out;
> +	ret =3D do_cache_lookup(cd, key, item, dreq);
> +	if (ret =3D=3D -EAGAIN) {
> +		ret =3D nfs_cache_wait_for_upcall(dreq);
> +		if (!ret)
> +			ret =3D do_cache_lookup_nowait(cd, key, item);
> +	}
> +	nfs_cache_defer_req_put(dreq);
> +out:
> +	return ret;
> +}
> +
> +ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
> +		struct sockaddr *sa, size_t salen)
> +{
> +	struct nfs_dns_ent key =3D {
> +		.hostname =3D name,
> +		.namelen =3D namelen,
> +	};
> +	struct nfs_dns_ent *item =3D NULL;
> +	ssize_t ret;
> +
> +	ret =3D do_cache_lookup_wait(&nfs_dns_resolve, &key, &item);
> +	if (ret =3D=3D 0) {
> +		if (salen >=3D item->addrlen) {
> +			memcpy(sa, &item->addr, item->addrlen);
> +			ret =3D item->addrlen;
> +		} else
> +			ret =3D -EOVERFLOW;
> +		cache_put(&item->h, &nfs_dns_resolve);
> +	} else if (ret =3D=3D -ENOENT)
> +		ret =3D -ESRCH;
> +	return ret;
> +}
> +
> +int nfs_dns_resolver_init(void)
> +{
> +	return nfs_cache_register(&nfs_dns_resolve);
> +}
> +
> +void nfs_dns_resolver_destroy(void)
> +{
> +	nfs_cache_unregister(&nfs_dns_resolve);
> +}
> +
> diff --git a/fs/nfs/dns_resolve.h b/fs/nfs/dns_resolve.h
> new file mode 100644
> index 0000000..a3f0938
> --- /dev/null
> +++ b/fs/nfs/dns_resolve.h
> @@ -0,0 +1,14 @@
> +/*
> + * Resolve DNS hostnames into valid ip addresses
> + */
> +#ifndef __LINUX_FS_NFS_DNS_RESOLVE_H
> +#define __LINUX_FS_NFS_DNS_RESOLVE_H
> +
> +#define NFS_DNS_HOSTNAME_MAXLEN	(128)
> +
> +extern int nfs_dns_resolver_init(void);
> +extern void nfs_dns_resolver_destroy(void);
> +extern ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
> +		struct sockaddr *sa, size_t salen);
> +
> +#endif
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index fe5a8b4..060022b 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -46,6 +46,7 @@
>  #include "iostat.h"
>  #include "internal.h"
>  #include "fscache.h"
> +#include "dns_resolve.h"
> =20
>  #define NFSDBG_FACILITY		NFSDBG_VFS
> =20
> @@ -1506,6 +1507,10 @@ static int __init init_nfs_fs(void)
>  {
>  	int err;
> =20
> +	err =3D nfs_dns_resolver_init();
> +	if (err < 0)
> +		goto out8;
> +
>  	err =3D nfs_fscache_register();
>  	if (err < 0)
>  		goto out7;
> @@ -1564,6 +1569,8 @@ out5:
>  out6:
>  	nfs_fscache_unregister();
>  out7:
> +	nfs_dns_resolver_destroy();
> +out8:
>  	return err;
>  }
> =20
> @@ -1575,6 +1582,7 @@ static void __exit exit_nfs_fs(void)
>  	nfs_destroy_inodecache();
>  	nfs_destroy_nfspagecache();
>  	nfs_fscache_unregister();
> +	nfs_dns_resolver_destroy();
>  #ifdef CONFIG_PROC_FS
>  	rpc_proc_unregister("nfs");
>  #endif
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 3fdacaf..7f676bd 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -416,11 +416,13 @@ struct vfsmount *rpc_get_mount(void)
>  		return ERR_PTR(err);
>  	return rpc_mount;
>  }
> +EXPORT_SYMBOL_GPL(rpc_get_mount);
> =20
>  void rpc_put_mount(void)
>  {
>  	simple_release_fs(&rpc_mount, &rpc_mount_count);
>  }
> +EXPORT_SYMBOL_GPL(rpc_put_mount);
> =20
>  static int rpc_delete_dentry(struct dentry *dentry)
>  {
> @@ -946,6 +948,7 @@ enum {
>  	RPCAUTH_portmap,
>  	RPCAUTH_statd,
>  	RPCAUTH_nfsd4_cb,
> +	RPCAUTH_cache,
>  	RPCAUTH_RootEOF
>  };
> =20
> @@ -974,6 +977,10 @@ static const struct rpc_filelist files[] =3D {
>  		.name =3D "nfsd4_cb",
>  		.mode =3D S_IFDIR | S_IRUGO | S_IXUGO,
>  	},
> +	[RPCAUTH_cache] =3D {
> +		.name =3D "cache",
> +		.mode =3D S_IFDIR | S_IRUGO | S_IXUGO,
> +	},
>  };
> =20
>  static int
> --=20
> 1.6.0.4
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
