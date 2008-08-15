From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Fri, 15 Aug 2008 12:59:09 -0400
Message-ID: <52C9C44B-750E-437C-B3E8-380DB7371629@oracle.com>
References: <20080814223028.GN23859@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:51296 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757062AbYHORAT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Aug 2008 13:00:19 -0400
In-Reply-To: <20080814223028.GN23859@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 14, 2008, at 6:30 PM, J. Bruce Fields wrote:
> I was looking back at this bug with the misparsing of
> (non-mull-terminated) fs_locations attributes.  Thanks to the work on
> nfs_parse_server_address, etc., we can now also more easily support  
> ipv6
> addresses here.  But I got lost in the usual maze of twisty struct
> sockaddr_*'s, all alike.  Is this right?  Does any of it need to be
> under CONFIG_IPV6?  Is there a simpler way?

The use of the new address parser looks correct, but your string  
handling needs work.  :-)

Comments below...

>
>
> --b.
>
>    nfs: Fix misparsing of nfsv4 fs_locations attribute
>
>    The code incorrectly assumes here that the server name (or ip  
> address)
>    is null-terminated.  This can cause referrals to fail in some  
> cases.
>
>    Also support ipv6 addresses.
>
>    Compile-tested only.
>
>    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>
> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> index b112857..c0f5191 100644
> --- a/fs/nfs/nfs4namespace.c
> +++ b/fs/nfs/nfs4namespace.c
> @@ -93,23 +93,6 @@ static int nfs4_validate_fspath(const struct  
> vfsmount *mnt_parent,
> 	return 0;
> }
>
> -/*
> - * Check if the string represents a "valid" IPv4 address
> - */
> -static inline int valid_ipaddr4(const char *buf)
> -{
> -	int rc, count, in[4];
> -
> -	rc = sscanf(buf, "%d.%d.%d.%d", &in[0], &in[1], &in[2], &in[3]);
> -	if (rc != 4)
> -		return -EINVAL;
> -	for (count = 0; count < 4; count++) {
> -		if (in[count] > 255)
> -			return -EINVAL;
> -	}
> -	return 0;
> -}
> -
> /**
>  * nfs_follow_referral - set up mountpoint when hitting a referral  
> on moved error
>  * @mnt_parent - mountpoint of parent directory
> @@ -172,30 +155,44 @@ static struct vfsmount  
> *nfs_follow_referral(const struct vfsmount *mnt_parent,
>
> 		s = 0;
> 		while (s < location->nservers) {
> -			struct sockaddr_in addr = {
> -				.sin_family	= AF_INET,
> -				.sin_port	= htons(NFS_PORT),
> -			};
> -
> -			if (location->servers[s].len <= 0 ||
> -			    valid_ipaddr4(location->servers[s].data) < 0) {
> -				s++;
> -				continue;
> -			}
> +			const struct nfs4_string *buf = &location->servers[s];
> +			struct sockaddr_storage addr;
> +
> +			if (buf->len <= 0 || buf->len >= PAGE_SIZE)
> +				goto next;
>
> -			mountdata.hostname = location->servers[s].data;
> -			addr.sin_addr.s_addr = in_aton(mountdata.hostname),
> 			mountdata.addr = (struct sockaddr *)&addr;
> -			mountdata.addrlen = sizeof(addr);
> +
> +			if (memchr(buf->data, '%', buf->len))
> +				goto next;

Why are you looking for a '%' ?

> +			nfs_parse_ip_address(buf->data, buf->len,
> +					mountdata.addr, &mountdata.addrlen);

Now what's so hard about that?  :-)

>
> +			switch (mountdata.addr->sa_family) {
> +			case AF_UNSPEC:
> +				goto next;
> +			case AF_INET:
> +				((struct sockaddr_in *)&addr)->sin_port =
> +							htons(NFS_PORT);
> +				break;
> +			case AF_INET6:
> +				((struct sockaddr_in6 *)&addr)->sin6_port =
> +							htons(NFS_PORT);
> +				break;
> +			}

It might be cleaner to pull the whole while {} loop into a separate  
function.  I didn't look closely enough to see if this would be easy.

At least here, you could set the port in a small helper function, and  
then put an "if (unlikely(family == AF_UNSPEC)) goto next;" just after  
the call to nfs_parse_ip_address, to save all the crazy indenting.  If  
we ever create a global helper to manage AF-agnostic port setting,  
that would make it easier to use here if the AF_UNSPEC check were  
separate.

In fact, as part of this patch you could add a static inline helper in  
fs/nfs/internal.h to do the port setting.  That can be shared between  
fs/nfs/super.c and fs/nfs/nfs4namespace.c.

Arguably the addition of the AF_UNSPEC check in the switch statement  
is an optimization that is slightly confusing.  You are checking for  
AF_UNSPEC to see if you should continue the loop, but the other cases  
are for setting a port; two entirely different purposes.

It would be more precise structuring to keep these two separate, even  
though it might add an extra conditional branch.  This makes it easier  
to spot the loop condition expressions.

> +
> +			mountdata.hostname = kmalloc(buf->len + 1, GFP_KERNEL);
> +			mountdata.hostname[buf->len] = 0;

The usual practice is to use '\0' here since it is a character array;  
0 is an int, not a character, so this does an implicit cast.   
Harmless, but using a character constant is more precise.

But I'm not sure why you are not using location->servers[s].data (or  
buf->data).  You kmalloc a buffer for hostname, but aren't setting it  
to anything.  Did you mean kstrndup?

> 			snprintf(page, PAGE_SIZE, "%s:%s",
> 					mountdata.hostname,
> 					mountdata.mnt_path);

For snprintf, you can specify the length of the string with a "%.*s"  
format.  Then you pass buf->len and buf->data (in that order) to it.   
That way you can print a non-NUL-terminated string safely.  That  
should make any memory allocation or string copying unnecessary here.

> 			mnt = vfs_kern_mount(&nfs4_referral_fs_type, 0, page, &mountdata);
> +			kfree(mountdata.hostname);

mountdata.hostname is used in other places... I don't think you can  
just free it here.  Another reason to use a pointer to location- 
 >servers[s].data.

If location->servers[s].data isn't always NUL-terminated, you might  
make mountdata.hostname an nfs4_string so it carries the string length  
with it; the other users of mountdata.hostname can then see the length.

> 			if (!IS_ERR(mnt)) {
> 				break;
> 			}
> +next:
> 			s++;
> 		}
> 		loc++;
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 9abcd2b..1d10756 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -798,7 +798,7 @@ static void nfs_parse_ipv6_address(char *string,  
> size_t str_len,
>  * If there is a problem constructing the new sockaddr, set the  
> address
>  * family to AF_UNSPEC.
>  */
> -static void nfs_parse_ip_address(char *string, size_t str_len,
> +void nfs_parse_ip_address(char *string, size_t str_len,
> 				 struct sockaddr *sap, size_t *addr_len)
> {
> 	unsigned int i, colons;
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 78a5922..62ca683 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -444,6 +444,8 @@ extern const struct inode_operations  
> nfs_referral_inode_operations;
> extern int nfs_mountpoint_expiry_timeout;
> extern void nfs_release_automount_timer(void);
>
> +void nfs_parse_ip_address(char *, size_t, struct sockaddr *, size_t  
> *);
> +

Perhaps a better place for this would be fs/nfs/internal.h.  This  
function is used only internally in fs/nfs; no need to expose it to  
user space.

>
> /*
>  * linux/fs/nfs/unlink.c
>  */

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
