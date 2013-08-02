Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750948Ab3HBOQu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Aug 2013 10:16:50 -0400
Subject: Re: [PATCH 2/2] KEYS: Add per-user_namespace registers for
 persistent per-UID kerberos caches
From: Simo Sorce <simo@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: David Howells <dhowells@redhat.com>, keyrings@linux-nfs.org,
        linux-nfs@vger.kernel.org, krbdev@mit.edu,
        "Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
        linux-kernel@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <20130802095555.07a2cda3@tlielax.poochiereds.net>
References: <20130801173846.28023.19009.stgit@warthog.procyon.org.uk>
	 <20130801173902.28023.68819.stgit@warthog.procyon.org.uk>
	 <20130802095555.07a2cda3@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 02 Aug 2013 10:16:44 -0400
Message-ID: <1375453004.15733.249.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-08-02 at 09:55 -0400, Jeff Layton wrote:
> On Thu, 01 Aug 2013 18:39:02 +0100
> David Howells <dhowells@redhat.com> wrote:
> 
> > Add support for per-user_namespace registers of persistent per-UID kerberos
> > caches held within the kernel.
> > 
> > This allows the kerberos cache to be retained beyond the life of all a user's
> > processes so that the user's cron jobs can work.
> > 
> > The kerberos cache is envisioned as a keyring/key tree looking something like:
> > 
> > 	struct user_namespace
> > 	  \___ .krb_cache keyring		- The register
> > 		\___ _krb.0 keyring		- Root's Kerberos cache
> > 		\___ _krb.5000 keyring		- User 5000's Kerberos cache
> > 		\___ _krb.5001 keyring		- User 5001's Kerberos cache
> > 			\___ tkt785 big_key	- A ccache blob
> > 			\___ tkt12345 big_key	- Another ccache blob
> > 
> > Or possibly:
> > 
> > 	struct user_namespace
> > 	  \___ .krb_cache keyring		- The register
> > 		\___ _krb.0 keyring		- Root's Kerberos cache
> > 		\___ _krb.5000 keyring		- User 5000's Kerberos cache
> > 		\___ _krb.5001 keyring		- User 5001's Kerberos cache
> > 			\___ tkt785 keyring	- A ccache
> > 				\___ krbtgt/REDHAT.COM@REDHAT.COM big_key
> > 				\___ http/REDHAT.COM@REDHAT.COM user
> > 				\___ afs/REDHAT.COM@REDHAT.COM user
> > 				\___ nfs/REDHAT.COM@REDHAT.COM user
> > 				\___ krbtgt/KERNEL.ORG@KERNEL.ORG big_key
> > 				\___ http/KERNEL.ORG@KERNEL.ORG big_key
> > 
> > What goes into a particular Kerberos cache is entirely up to userspace.  Kernel
> > support is limited to giving you the Kerberos cache keyring that you want.
> > 
> > The user asks for their Kerberos cache by:
> > 
> > 	krb_cache = keyctl_get_krbcache(uid, dest_keyring);
> > 
> > The uid is -1 or the user's own UID for the user's own cache or the uid of some
> > other user's cache (requires CAP_SETUID).  This permits rpc.gssd or whatever to
> > mess with the cache.
> > 
> > The cache returned is a keyring named "_krb.<uid>" that the possessor can read,
> > search, clear, invalidate, unlink from and add links to.  SELinux and co. get a
> > say as to whether this call will succeed as the caller must have LINK
> > permission on the cache keyring.
> > 
> > Each uid's cache keyring is created when it first accessed and is given a
> > timeout that is extended each time this function is called so that the keyring
> > goes away after a while.  The timeout is configurable by sysctl but defaults to
> > three days.
> > 
> > Each user_namespace struct gets a lazily-created keyring that serves as the
> > register.  The cache keyrings are added to it.  This means that standard key
> > search and garbage collection facilities are available.
> > 
> > The user_namespace struct's register goes away when it does and anything left
> > in it is then automatically gc'd.
> > 
> > Signed-off-by: David Howells <dhowells@redhat.com>
> > cc: Serge E. Hallyn <serge.hallyn@ubuntu.com>
> > cc: Eric W. Biederman <ebiederm@xmission.com>
> > ---
> > 
> >  include/linux/user_namespace.h |    6 ++
> >  include/uapi/linux/keyctl.h    |    1 
> >  kernel/user.c                  |    4 +
> >  kernel/user_namespace.c        |    2 +
> >  security/keys/Kconfig          |   12 ++++
> >  security/keys/Makefile         |    1 
> >  security/keys/compat.c         |    3 +
> >  security/keys/internal.h       |    9 +++
> >  security/keys/keyctl.c         |    3 +
> >  security/keys/krbcache.c       |  132 ++++++++++++++++++++++++++++++++++++++++
> >  security/keys/sysctl.c         |   11 +++
> >  11 files changed, 184 insertions(+)
> >  create mode 100644 security/keys/krbcache.c
> > 
> > diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> > index b6b215f..3cce8c7 100644
> > --- a/include/linux/user_namespace.h
> > +++ b/include/linux/user_namespace.h
> > @@ -28,6 +28,12 @@ struct user_namespace {
> >  	unsigned int		proc_inum;
> >  	bool			may_mount_sysfs;
> >  	bool			may_mount_proc;
> > +
> > +	/* Register of per-UID Kerberos caches for this namespace */
> > +#ifdef CONFIG_KEYS_KERBEROS_CACHE
> > +	struct key		*krb_cache_register;
> > +	struct rw_semaphore	krb_cache_register_sem;
> > +#endif
> >  };
> >  
> >  extern struct user_namespace init_user_ns;
> > diff --git a/include/uapi/linux/keyctl.h b/include/uapi/linux/keyctl.h
> > index c9b7f4fa..a37c62b 100644
> > --- a/include/uapi/linux/keyctl.h
> > +++ b/include/uapi/linux/keyctl.h
> > @@ -56,5 +56,6 @@
> >  #define KEYCTL_REJECT			19	/* reject a partially constructed key */
> >  #define KEYCTL_INSTANTIATE_IOV		20	/* instantiate a partially constructed key */
> >  #define KEYCTL_INVALIDATE		21	/* invalidate a key */
> > +#define KEYCTL_GET_KRBCACHE		22	/* get a user's kerberos cache keyring */
> >  
> >  #endif /*  _LINUX_KEYCTL_H */
> > diff --git a/kernel/user.c b/kernel/user.c
> > index 69b4c3d..6c9e1b9 100644
> > --- a/kernel/user.c
> > +++ b/kernel/user.c
> > @@ -53,6 +53,10 @@ struct user_namespace init_user_ns = {
> >  	.proc_inum = PROC_USER_INIT_INO,
> >  	.may_mount_sysfs = true,
> >  	.may_mount_proc = true,
> > +#ifdef CONFIG_KEYS_KERBEROS_CACHE
> > +	.krb_cache_register_sem =
> > +	__RWSEM_INITIALIZER(init_user_ns.krb_cache_register_sem),
> > +#endif
> >  };
> >  EXPORT_SYMBOL_GPL(init_user_ns);
> >  
> > diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> > index d8c30db..098d954 100644
> > --- a/kernel/user_namespace.c
> > +++ b/kernel/user_namespace.c
> > @@ -99,6 +99,7 @@ int create_user_ns(struct cred *new)
> >  
> >  	update_mnt_policy(ns);
> >  
> > +	rwsem_init(&ns->krb_cache_register_sem);
> >  	return 0;
> >  }
> >  
> > @@ -123,6 +124,7 @@ void free_user_ns(struct user_namespace *ns)
> >  
> >  	do {
> >  		parent = ns->parent;
> > +		key_put(ns->krb_cache_register);
> >  		proc_free_inum(ns->proc_inum);
> >  		kmem_cache_free(user_ns_cachep, ns);
> >  		ns = parent;
> > diff --git a/security/keys/Kconfig b/security/keys/Kconfig
> > index eafb335..ee3f5a5 100644
> > --- a/security/keys/Kconfig
> > +++ b/security/keys/Kconfig
> > @@ -20,6 +20,18 @@ config KEYS
> >  
> >  	  If you are unsure as to whether this is required, answer N.
> >  
> > +config KEYS_KERBEROS_CACHE
> > +	bool "Enable persistent keyring-based kerberos cache"
> > +	depends on KEYS
> > +	help
> > +	  This option provides a register of per-UID kerberos cache keyrings.
> > +	  A particular keyring may be accessed by either the user whose keyring
> > +	  it is or by a process with administrative privileges.  SELinux gets
> > +	  to rule on which admin-level processes get to access the cache.
> > +
> > +	  Keyrings are created and added into the register upon demand and get
> > +	  removed if they expire (a default timeout is set upon creation).
> > +
> >  config BIG_KEYS
> >  	tristate "Large payload keys"
> >  	depends on KEYS
> > diff --git a/security/keys/Makefile b/security/keys/Makefile
> > index c487c77..c168ad6 100644
> > --- a/security/keys/Makefile
> > +++ b/security/keys/Makefile
> > @@ -18,6 +18,7 @@ obj-y := \
> >  obj-$(CONFIG_KEYS_COMPAT) += compat.o
> >  obj-$(CONFIG_PROC_FS) += proc.o
> >  obj-$(CONFIG_SYSCTL) += sysctl.o
> > +obj-$(CONFIG_KEYS_KERBEROS_CACHE) += krbcache.o
> >  
> >  #
> >  # Key types
> > diff --git a/security/keys/compat.c b/security/keys/compat.c
> > index d65fa7f..ead383b 100644
> > --- a/security/keys/compat.c
> > +++ b/security/keys/compat.c
> > @@ -138,6 +138,9 @@ asmlinkage long compat_sys_keyctl(u32 option,
> >  	case KEYCTL_INVALIDATE:
> >  		return keyctl_invalidate_key(arg2);
> >  
> > +	case KEYCTL_GET_KRBCACHE:
> > +		return keyctl_get_krbcache(arg2, arg3);
> > +
> >  	default:
> >  		return -EOPNOTSUPP;
> >  	}
> > diff --git a/security/keys/internal.h b/security/keys/internal.h
> > index 581c6f6..fa379c6 100644
> > --- a/security/keys/internal.h
> > +++ b/security/keys/internal.h
> > @@ -255,6 +255,15 @@ extern long keyctl_invalidate_key(key_serial_t);
> >  extern long keyctl_instantiate_key_common(key_serial_t,
> >  					  const struct iovec *,
> >  					  unsigned, size_t, key_serial_t);
> > +#ifdef CONFIG_KEYS_KERBEROS_CACHE
> > +extern long keyctl_get_krbcache(uid_t, key_serial_t);
> > +extern unsigned krb_cache_expiry;
> > +#else
> > +static inline long keyctl_get_krbcache(uid_t uid, key_serial_t destring)
> > +{
> > +	return -EOPNOTSUPP;
> > +}
> > +#endif
> >  
> >  /*
> >   * Debugging key validation
> > diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
> > index 33cfd27..c4fae05 100644
> > --- a/security/keys/keyctl.c
> > +++ b/security/keys/keyctl.c
> > @@ -1667,6 +1667,9 @@ SYSCALL_DEFINE5(keyctl, int, option, unsigned long, arg2, unsigned long, arg3,
> >  	case KEYCTL_INVALIDATE:
> >  		return keyctl_invalidate_key((key_serial_t) arg2);
> >  
> > +	case KEYCTL_GET_KRBCACHE:
> > +		return keyctl_get_krbcache((uid_t)arg2, (key_serial_t)arg3);
> > +
> >  	default:
> >  		return -EOPNOTSUPP;
> >  	}
> > diff --git a/security/keys/krbcache.c b/security/keys/krbcache.c
> > new file mode 100644
> > index 0000000..4e2aa9c
> > --- /dev/null
> > +++ b/security/keys/krbcache.c
> > @@ -0,0 +1,132 @@
> > +/* Kerberos persistent cache register
> > + *
> > + * Copyright (C) 2013 Red Hat, Inc. All Rights Reserved.
> > + * Written by David Howells (dhowells@redhat.com)
> > + *
> > + * This program is free software; you can redistribute it and/or
> > + * modify it under the terms of the GNU General Public Licence
> > + * as published by the Free Software Foundation; either version
> > + * 2 of the Licence, or (at your option) any later version.
> > + */
> > +
> > +#include <linux/user_namespace.h>
> > +#include "internal.h"
> > +
> > +unsigned krb_cache_expiry = 3 * 24 * 3600; /* Expire after 3 days of non-use */
> > +
> > +/*
> > + * Get the Kerberos cache keyring for a specific UID and link it to the
> > + * nominated keyring.
> > + */
> > +long keyctl_get_krbcache(uid_t _uid, key_serial_t destid)
> > +{
> > +	struct user_namespace *ns = current_user_ns();
> > +	struct keyring_index_key index_key;
> > +	struct key *krb;
> > +	key_ref_t reg_ref, dest_ref, krb_ref;
> > +	kuid_t uid;
> > +	char buf[24];
> > +	long ret;
> > +
> > +	/* -1 indicates the current user */
> > +	if (_uid == (uid_t)-1) {
> > +		uid = current_uid();
> 
> 
> Isn't it possible to have a valid uid of (unsigned int)-1? I know that
> at least some sites use that for "nobody". Why not just require passing
> in the correct UID?
> 
> > +	} else {
> > +		uid = make_kuid(ns, _uid);
> > +		if (!uid_valid(uid))
> > +			return -EINVAL;
> > +
> > +		/* You can only see your own kerberos cache if you're not
> > +		 * sufficiently privileged.
> > +		 */
> > +		if (uid != current_uid() &&
> > +		    uid != current_suid() &&
> > +		    uid != current_euid() &&
> > +		    uid != current_fsuid() &&
> > +		    !nsown_capable(CAP_SETUID))
> > +			return -EPERM;
> > +	}
> > +
> > +	/* There must be a destination keyring */
> > +	dest_ref = lookup_user_key(destid, KEY_LOOKUP_CREATE, KEY_WRITE);
> > +	if (IS_ERR(dest_ref))
> > +		return PTR_ERR(dest_ref);
> > +	if (key_ref_to_ptr(dest_ref)->type != &key_type_keyring) {
> > +		ret = -ENOTDIR;
> > +		goto out_put_dest;
> > +	}
> > +
> > +	/* Look in the register if it exists */
> > +	index_key.type = &key_type_keyring;
> > +	index_key.description = buf;
> > +	index_key.desc_len = sprintf(buf, "_krb.%u", __kuid_val(uid));
> > +
> > +	if (ns->krb_cache_register) {
> > +		reg_ref = make_key_ref(ns->krb_cache_register, true);
> > +		down_read(&ns->krb_cache_register_sem);
> > +		krb_ref = find_key_to_update(reg_ref, &index_key);
> > +		up_read(&ns->krb_cache_register_sem);
> > +
> > +		if (krb_ref)
> > +			goto found;
> > +	}
> > +
> > +	/* It wasn't in the register, so we'll need to create it.  We might
> > +	 * also need to create the register.
> > +	 */
> > +	down_write(&ns->krb_cache_register_sem);
> > +
> > +	if (!ns->krb_cache_register) {
> > +		struct key *reg = 
> > +			keyring_alloc(".krb_cache",
> > +				      KUIDT_INIT(0), KGIDT_INIT(0),
> > +				      current_cred(),
> > +				      ((KEY_POS_ALL & ~KEY_POS_SETATTR) |
> > +				       KEY_USR_VIEW | KEY_USR_READ),
> > +				      KEY_ALLOC_NOT_IN_QUOTA, NULL);
> > +		if (IS_ERR(reg)) {
> > +			up_write(&ns->krb_cache_register_sem);
> > +			ret = PTR_ERR(reg);
> > +			goto out_put_dest;
> > +		}
> > +
> > +		ns->krb_cache_register = reg;
> > +	} else {
> > +		reg_ref = make_key_ref(ns->krb_cache_register, true);
> > +		krb_ref = find_key_to_update(reg_ref, &index_key);
> > +		if (krb_ref) {
> > +			up_write(&ns->krb_cache_register_sem);
> > +			goto found;
> > +		}
> > +	}
> > +
> > +	krb = keyring_alloc(buf,
> > +			    uid, INVALID_GID, current_cred(),
> > +			    ((KEY_POS_ALL & ~KEY_POS_SETATTR) |
> > +			     KEY_USR_VIEW | KEY_USR_READ),
> > +			    KEY_ALLOC_NOT_IN_QUOTA,
> > +			    ns->krb_cache_register);
> > +	up_write(&ns->krb_cache_register_sem);
> > +	if (!IS_ERR(krb)) {
> > +		krb_ref = make_key_ref(krb, true);
> > +		goto found;
> > +	}
> > +
> > +out_put_krb:
> > +	key_ref_to_ptr(krb_ref);
> > +out_put_dest:
> > +	key_ref_to_ptr(dest_ref);
> > +	return ret;
> > +
> > +found:
> > +	ret = key_task_permission(krb_ref, current_cred(), KEY_LINK);
> > +	if (ret < 0)
> > +		goto out_put_krb;
> > +
> > +	ret = key_link(key_ref_to_ptr(dest_ref), key_ref_to_ptr(krb_ref));
> > +	if (ret == 0) {
> > +		key_set_timeout(key_ref_to_ptr(krb_ref), krb_cache_expiry);
> > +		ret = key_ref_to_ptr(krb_ref)->serial;		
> > +	}
> > +	goto out_put_krb;
> > +}
> > diff --git a/security/keys/sysctl.c b/security/keys/sysctl.c
> > index ee32d18..3af1798 100644
> > --- a/security/keys/sysctl.c
> > +++ b/security/keys/sysctl.c
> > @@ -61,5 +61,16 @@ ctl_table key_sysctls[] = {
> >  		.extra1 = (void *) &zero,
> >  		.extra2 = (void *) &max,
> >  	},
> > +#ifdef CONFIG_KEYS_KERBEROS_CACHE
> > +	{
> > +		.procname = "krb_expiry",
> > +		.data = &krb_cache_expiry,
> > +		.maxlen = sizeof(unsigned),
> > +		.mode = 0644,
> > +		.proc_handler = proc_dointvec_minmax,
> > +		.extra1 = (void *) &zero,
> > +		.extra2 = (void *) &max,
> > +	},
> > +#endif
> >  	{ }
> >  };
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> Looks good overall, but I share Daniel's concerns about making
> krb5-specific infrastructure like this. Essentially this is just a
> persistent keyring that's associated with a kuid, right? Perhaps this
> could be done in such a way that it could be usable for other
> applications in the future?

Well to be honest there is nothing kerberos specific here but the name
at this stage, however we do not want 'extraneous' keys in the kerberos
keyring. So in order to make it generic we'd have to pass in a prefix at
request time, something like:
keyctl_get_userkeycache(uid, prefix, id);

And then in the kerberos case call it like:
krbcache_id = keyctl_get_userkeycache(uid, "_krb", parent_id);

I see no problem from the kerberos end about using this, but it depends
on whether you want to allow to create arbitrary keyrings like this.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

