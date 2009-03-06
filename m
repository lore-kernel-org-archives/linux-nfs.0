From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 17/23] NFS: Move NFS client's IP address parser to
 nfs_common/
Date: Fri, 6 Mar 2009 11:33:10 -0500
Message-ID: <20090306113310.640384a9@tleilax.poochiereds.net>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
	<20090305213330.21342.96742.stgit@ingres.1015granger.net>
	<20090305211001.2fbecabe@tupile.poochiereds.net>
	<A67BFE40-B680-4AC6-811B-B2F6E54BF6A5@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45418 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751951AbZCFQdV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Mar 2009 11:33:21 -0500
In-Reply-To: <A67BFE40-B680-4AC6-811B-B2F6E54BF6A5@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 6 Mar 2009 11:16:44 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> Hi Jeff-
> 
> On Mar 5, 2009, at Mar 5, 2009, 9:10 PM, Jeff Layton wrote:
> > On Thu, 05 Mar 2009 16:33:31 -0500
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> >
> >> The kernel's NFS server also needs to parse presentation format IP
> >> addresses.  Since both the client and the server can reside in  
> >> their own
> >> modules, move the parser logic to nfs_common, which can be used by  
> >> either.
> >>
> >> I expect other common IPv4/IPv6 helpers to be moved in here at some
> >> later point.
> >>
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >>
> >> fs/nfs/internal.h              |    3 -
> >> fs/nfs/nfs4namespace.c         |    2 +
> >> fs/nfs/super.c                 |  121  
> >> --------------------------------
> >> fs/nfs_common/Makefile         |    1
> >> fs/nfs_common/nfs_addr_parse.c |  151 ++++++++++++++++++++++++++++++ 
> >> ++++++++++
> >> include/linux/nfs_addr_parse.h |   29 ++++++++
> >> 6 files changed, 184 insertions(+), 123 deletions(-)
> >> create mode 100644 fs/nfs_common/nfs_addr_parse.c
> >> create mode 100644 include/linux/nfs_addr_parse.h
> >
> > I like the basic idea here -- moving these helpers into common code.
> > That said, I don't like the fact that this common code ends up in the
> > base kernel.
> 
> Can you explain why?  The only reason you've stated in the past is  
> because it is slightly inconvenient for those who update to a kernel  
> with this code, but build NFS in modules.  In that one case you have  
> to do a full kernel build to pick up these functions.
>

Sure, that's inconvenient but I can work around it and it's not a
big deal. My main objection is because it doesn't seem like
nfs-specific routines ought to be in core kernel code. They should be
in modules.
 
> Really, this stuff should be in some common place, like net/core/  
> (which is built-in), so these can be shared with, say, NLM, and CIFS,  
> as well.
>

Ok, I'll buy that. But if you're going to make them generic routines
it would be preferable to give them generic names and fix the current
callers. Still though, for those that aren't using networked filesystems
and such, putting this in the core kernel seems like a waste (albeit a
small one).

> > IMO, a better solution would be a new module
> > (nfs_common.ko maybe?) that contains this code and any other common
> > code that's needed in the future...
> 
> Who would load it in that case?  I think putting it in a module would  
> just add unneeded complexity in each of the callers.  Until the amount  
> of code in nfs_common.c is larger than the NFS, NLM, and NFSD logic to  
> "load the common module" you'll need, you don't gain anything.
> 

nfs.ko and nfsd.ko would load it in that case via module dependencies.
If you really wanted to make this generic library-style code, you could
call it libnetfs.ko or something. Then CIFS and other filesystems could
be changed to depend on it too.

> Since we are close to the 2.6.30 merge window, I'd prefer to worry  
> about that kind of micro-optimization later.
> 

Ok. I don't feel terribly strongly about it, but if it might be
better to wait on splitting this code out until it's closer to its
final form (in a module and/or with genericized names).

> >> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> >> index 4da6bbd..82d899f 100644
> >> --- a/fs/nfs/internal.h
> >> +++ b/fs/nfs/internal.h
> >> @@ -167,7 +167,6 @@ extern void nfs4_clear_inode(struct inode *);
> >> void nfs_zap_acl_cache(struct inode *inode);
> >>
> >> /* super.c */
> >> -void nfs_parse_ip_address(char *, size_t, struct sockaddr *,  
> >> size_t *);
> >> extern struct file_system_type nfs_xdev_fs_type;
> >> #ifdef CONFIG_NFS_V4
> >> extern struct file_system_type nfs4_xdev_fs_type;
> >> @@ -291,8 +290,6 @@ unsigned int nfs_page_array_len(unsigned int  
> >> base, size_t len)
> >> 		PAGE_SIZE - 1) >> PAGE_SHIFT;
> >> }
> >>
> >> -#define IPV6_SCOPE_DELIMITER	'%'
> >> -
> >> /*
> >>  * Set the port number in an address.  Be agnostic about the address
> >>  * family.
> >> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> >> index 30befc3..660fc36 100644
> >> --- a/fs/nfs/nfs4namespace.c
> >> +++ b/fs/nfs/nfs4namespace.c
> >> @@ -15,6 +15,8 @@
> >> #include <linux/sunrpc/clnt.h>
> >> #include <linux/vfs.h>
> >> #include <linux/inet.h>
> >> +#include <linux/nfs_addr_parse.h>
> >> +
> >> #include "internal.h"
> >> #include "nfs4_fs.h"
> >>
> >> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> >> index 520fe6f..bf55e23 100644
> >> --- a/fs/nfs/super.c
> >> +++ b/fs/nfs/super.c
> >> @@ -51,6 +51,7 @@
> >> #include <linux/nfs_xdr.h>
> >> #include <linux/magic.h>
> >> #include <linux/parser.h>
> >> +#include <linux/nfs_addr_parse.h>
> >>
> >> #include <asm/system.h>
> >> #include <asm/uaccess.h>
> >> @@ -697,126 +698,6 @@ static int nfs_verify_server_address(struct  
> >> sockaddr *addr)
> >> 	return 0;
> >> }
> >>
> >> -static void nfs_parse_ipv4_address(char *string, size_t str_len,
> >> -				   struct sockaddr *sap, size_t *addr_len)
> >> -{
> >> -	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
> >> -	u8 *addr = (u8 *)&sin->sin_addr.s_addr;
> >> -
> >> -	if (str_len <= INET_ADDRSTRLEN) {
> >> -		dfprintk(MOUNT, "NFS: parsing IPv4 address %*s\n",
> >> -				(int)str_len, string);
> >> -
> >> -		sin->sin_family = AF_INET;
> >> -		*addr_len = sizeof(*sin);
> >> -		if (in4_pton(string, str_len, addr, '\0', NULL))
> >> -			return;
> >> -	}
> >> -
> >> -	sap->sa_family = AF_UNSPEC;
> >> -	*addr_len = 0;
> >> -}
> >> -
> >> -#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> >> -static int nfs_parse_ipv6_scope_id(const char *string, const  
> >> size_t str_len,
> >> -				   const char *delim,
> >> -				   struct sockaddr_in6 *sin6)
> >> -{
> >> -	char *p;
> >> -	size_t len;
> >> -
> >> -	if ((string + str_len) == delim)
> >> -		return 1;
> >> -
> >> -	if (*delim != IPV6_SCOPE_DELIMITER)
> >> -		return 0;
> >> -
> >> -	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL))
> >> -		return 0;
> >> -
> >> -	len = (string + str_len) - delim - 1;
> >> -	p = kstrndup(delim + 1, len, GFP_KERNEL);
> >> -	if (p) {
> >> -		unsigned long scope_id = 0;
> >> -		struct net_device *dev;
> >> -
> >> -		dev = dev_get_by_name(&init_net, p);
> >> -		if (dev != NULL) {
> >> -			scope_id = dev->ifindex;
> >> -			dev_put(dev);
> >> -		} else {
> >> -			if (strict_strtoul(p, 10, &scope_id) == 0) {
> >> -				kfree(p);
> >> -				return 0;
> >> -			}
> >> -		}
> >> -
> >> -		kfree(p);
> >> -
> >> -		sin6->sin6_scope_id = scope_id;
> >> -		dfprintk(MOUNT, "NFS: IPv6 scope ID = %lu\n", scope_id);
> >> -		return 1;
> >> -	}
> >> -
> >> -	return 0;
> >> -}
> >> -
> >> -static void nfs_parse_ipv6_address(char *string, size_t str_len,
> >> -				   struct sockaddr *sap, size_t *addr_len)
> >> -{
> >> -	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
> >> -	u8 *addr = (u8 *)&sin6->sin6_addr.in6_u;
> >> -	const char *delim;
> >> -
> >> -	if (str_len <= INET6_ADDRSTRLEN) {
> >> -		dfprintk(MOUNT, "NFS: parsing IPv6 address %*s\n",
> >> -				(int)str_len, string);
> >> -
> >> -		sin6->sin6_family = AF_INET6;
> >> -		*addr_len = sizeof(*sin6);
> >> -		if (in6_pton(string, str_len, addr,
> >> -					IPV6_SCOPE_DELIMITER, &delim) != 0) {
> >> -			if (nfs_parse_ipv6_scope_id(string, str_len,
> >> -							delim, sin6) != 0)
> >> -				return;
> >> -		}
> >> -	}
> >> -
> >> -	sap->sa_family = AF_UNSPEC;
> >> -	*addr_len = 0;
> >> -}
> >> -#else
> >> -static void nfs_parse_ipv6_address(char *string, size_t str_len,
> >> -				   struct sockaddr *sap, size_t *addr_len)
> >> -{
> >> -	sap->sa_family = AF_UNSPEC;
> >> -	*addr_len = 0;
> >> -}
> >> -#endif
> >> -
> >> -/*
> >> - * Construct a sockaddr based on the contents of a string that  
> >> contains
> >> - * an IP address in presentation format.
> >> - *
> >> - * If there is a problem constructing the new sockaddr, set the  
> >> address
> >> - * family to AF_UNSPEC.
> >> - */
> >> -void nfs_parse_ip_address(char *string, size_t str_len,
> >> -				 struct sockaddr *sap, size_t *addr_len)
> >> -{
> >> -	unsigned int i, colons;
> >> -
> >> -	colons = 0;
> >> -	for (i = 0; i < str_len; i++)
> >> -		if (string[i] == ':')
> >> -			colons++;
> >> -
> >> -	if (colons >= 2)
> >> -		nfs_parse_ipv6_address(string, str_len, sap, addr_len);
> >> -	else
> >> -		nfs_parse_ipv4_address(string, str_len, sap, addr_len);
> >> -}
> >> -
> >> /*
> >>  * Sanity check the NFS transport protocol.
> >>  *
> >> diff --git a/fs/nfs_common/Makefile b/fs/nfs_common/Makefile
> >> index f689ed8..032b4c5 100644
> >> --- a/fs/nfs_common/Makefile
> >> +++ b/fs/nfs_common/Makefile
> >> @@ -2,6 +2,7 @@
> >> # Makefile for Linux filesystem routines that are shared by client  
> >> and server.
> >> #
> >>
> >> +obj-$(CONFIG_NFS_COMMON) += nfs_addr_parse.o
> >> obj-$(CONFIG_NFS_ACL_SUPPORT) += nfs_acl.o
> >>
> >> nfs_acl-objs := nfsacl.o
> >> diff --git a/fs/nfs_common/nfs_addr_parse.c b/fs/nfs_common/ 
> >> nfs_addr_parse.c
> >> new file mode 100644
> >> index 0000000..529b407
> >> --- /dev/null
> >> +++ b/fs/nfs_common/nfs_addr_parse.c
> >> @@ -0,0 +1,151 @@
> >> +/*
> >> + * Copyright (C) 2008 Oracle Corporation.  All rights reserved.
> >> + *
> >> + * This program is free software; you can redistribute it and/or
> >> + * modify it under the terms of the GNU General Public
> >> + * License as published by the Free Software Foundation; either
> >> + * version 2 of the License, or (at your option) any later version.
> >> + *
> >> + * This program is distributed in the hope that it will be useful,
> >> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> >> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> >> + * General Public License for more details.
> >> + *
> >> + * You should have received a copy of the GNU General Public
> >> + * License along with this program; if not, write to the
> >> + * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
> >> + * Boston, MA 021110-1307, USA.
> >> + */
> >> +
> >> +#include <linux/kernel.h>
> >> +#include <linux/string.h>
> >> +#include <linux/errno.h>
> >> +#include <linux/unistd.h>
> >> +
> >> +#include <linux/inet.h>
> >> +#include <linux/in6.h>
> >> +#include <net/ipv6.h>
> >> +#include <linux/netdevice.h>
> >> +
> >> +#include <linux/nfs_addr_parse.h>
> >> +
> >> +static void nfs_parse_ipv4_address(const char *buf, const size_t  
> >> buflen,
> >> +				   struct sockaddr *sap, size_t *salenp)
> >> +{
> >> +	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
> >> +	u8 *addr = (u8 *)&sin->sin_addr.s_addr;
> >> +
> >> +	if (buflen <= INET_ADDRSTRLEN) {
> >> +		sin->sin_family = AF_INET;
> >> +		*salenp = sizeof(*sin);
> >> +		if (in4_pton(buf, buflen, addr, '\0', NULL))
> >> +			return;
> >> +	}
> >> +
> >> +	sap->sa_family = AF_UNSPEC;
> >> +	*salenp = 0;
> >> +}
> >> +
> >> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> >> +static int nfs_parse_ipv6_scope_id(const char *buf, const size_t  
> >> buflen,
> >> +				   const char *delim,
> >> +				   struct sockaddr_in6 *sin6)
> >> +{
> >> +	char *p;
> >> +	size_t len;
> >> +
> >> +	if ((buf + buflen) == delim)
> >> +		return 1;
> >> +
> >> +	if (*delim != IPV6_SCOPE_DELIMITER)
> >> +		return 0;
> >> +
> >> +	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL))
> >> +		return 0;
> >> +
> >> +	len = (buf + buflen) - delim - 1;
> >> +	p = kstrndup(delim + 1, len, GFP_KERNEL);
> >> +	if (p) {
> >> +		unsigned long scope_id = 0;
> >> +		struct net_device *dev;
> >> +
> >> +		dev = dev_get_by_name(&init_net, p);
> >> +		if (dev != NULL) {
> >> +			scope_id = dev->ifindex;
> >> +			dev_put(dev);
> >> +		} else {
> >> +			if (strict_strtoul(p, 10, &scope_id) == 0) {
> >> +				kfree(p);
> >> +				return 0;
> >> +			}
> >> +		}
> >> +
> >> +		kfree(p);
> >> +
> >> +		sin6->sin6_scope_id = scope_id;
> >> +		return 1;
> >> +	}
> >> +
> >> +	return 0;
> >> +}
> >> +
> >> +static void nfs_parse_ipv6_address(const char *buf, const size_t  
> >> buflen,
> >> +				   struct sockaddr *sap, size_t *salenp)
> >> +{
> >> +	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
> >> +	u8 *addr = (u8 *)&sin6->sin6_addr.in6_u;
> >> +	const char *delim;
> >> +
> >> +	if (buflen <= INET6_ADDRSTRLEN) {
> >> +		sin6->sin6_family = AF_INET6;
> >> +		*salenp = sizeof(*sin6);
> >> +		if (in6_pton(buf, buflen, addr,
> >> +					IPV6_SCOPE_DELIMITER, &delim) != 0) {
> >> +			if (nfs_parse_ipv6_scope_id(buf, buflen,
> >> +							delim, sin6) != 0)
> >> +				return;
> >> +		}
> >> +	}
> >> +
> >> +	sap->sa_family = AF_UNSPEC;
> >> +	*salenp = 0;
> >> +}
> >> +#else	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
> >> +static void nfs_parse_ipv6_address(const char *buf, const size_t  
> >> buflen,
> >> +				   struct sockaddr *sap, size_t *salenp)
> >> +{
> >> +	sap->sa_family = AF_UNSPEC;
> >> +	*salenp = 0;
> >> +}
> >> +#endif	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
> >> +
> >> +/**
> >> + * nfs_parse_ip_address - convert IP address string to sockaddr
> >> + * @buf: C string containing presentation format IP address
> >> + * @buflen: length of @buf in bytes
> >> + * @sap: pointer to buffer in which to construct sockaddr
> >> + * @salenp: IN: length of buffer in bytes
> >> + *	      OUT: size of address in bytes
> >> + *
> >> + * Construct a sockaddr based on the contents of a string that  
> >> contains
> >> + * an IP address in presentation format.
> >> + *
> >> + * If there is a problem constructing the new sockaddr, set the  
> >> address
> >> + * family to AF_UNSPEC.
> >> + */
> >> +void nfs_parse_ip_address(const char *buf, const size_t buflen,
> >> +			  struct sockaddr *sap, size_t *salenp)
> >> +{
> >> +	unsigned int i, colons;
> >> +
> >> +	colons = 0;
> >> +	for (i = 0; i < buflen; i++)
> >> +		if (buf[i] == ':')
> >> +			colons++;
> >> +
> >> +	if (colons >= 2)
> >> +		nfs_parse_ipv6_address(buf, buflen, sap, salenp);
> >> +	else
> >> +		nfs_parse_ipv4_address(buf, buflen, sap, salenp);
> >> +}
> >> +EXPORT_SYMBOL_GPL(nfs_parse_ip_address);
> >> diff --git a/include/linux/nfs_addr_parse.h b/include/linux/ 
> >> nfs_addr_parse.h
> >> new file mode 100644
> >> index 0000000..193c71c
> >> --- /dev/null
> >> +++ b/include/linux/nfs_addr_parse.h
> >> @@ -0,0 +1,29 @@
> >> +/*
> >> + * Copyright (C) 2008 Oracle Corporation.  All rights reserved.
> >> + *
> >> + * This program is free software; you can redistribute it and/or
> >> + * modify it under the terms of the GNU General Public
> >> + * License as published by the Free Software Foundation; either
> >> + * version 2 of the License, or (at your option) any later version.
> >> + *
> >> + * This program is distributed in the hope that it will be useful,
> >> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> >> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> >> + * General Public License for more details.
> >> + *
> >> + * You should have received a copy of the GNU General Public
> >> + * License along with this program; if not, write to the
> >> + * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
> >> + * Boston, MA 021110-1307, USA.
> >> + *
> >> + */
> >> +
> >> +#ifndef __LINUX_NFS_ADDR_PARSE_H
> >> +#define __LINUX_NFS_ADDR_PARSE_H
> >> +
> >> +#define IPV6_SCOPE_DELIMITER	'%'
> >> +
> >> +void	nfs_parse_ip_address(const char *buf, const size_t buflen,
> >> +				struct sockaddr *sap, size_t *salenp);
> >> +
> >> +#endif	/* !__LINUX_NFS_ADDR_PARSE_H */
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux- 
> >> nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> >
> >
> > -- 
> > Jeff Layton <jlayton@redhat.com>
> 


-- 
Jeff Layton <jlayton@redhat.com>
