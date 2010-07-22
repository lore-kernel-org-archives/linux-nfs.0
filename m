From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] Add complex block layout discovery and mapping daemon
Date: Thu, 22 Jul 2010 22:35:43 +0300
Message-ID: <4C489D8F.8020109@panasas.com>
References: <20100721223119.GA6618@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, Steve Dickson <steved@redhat.com>
To: Jim Rees <rees@umich.edu>, Haiying Tang <Tang_Haiying@emc.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36366 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259Ab0GVTfv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jul 2010 15:35:51 -0400
Received: by wwj40 with SMTP id 40so3841586wwj.1
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jul 2010 12:35:49 -0700 (PDT)
In-Reply-To: <20100721223119.GA6618-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 22, 2010, 1:31 +0300, Jim Rees <rees@umich.edu> wrote:
> Signed-off-by: Haiying Tang <Tang_Haiying@emc.com>
> Signed-off-by: Eric Anderle <eanderle@umich.edu>
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  configure.ac                         |    4 +
>  utils/Makefile.am                    |    4 +
>  utils/blkmapd/Makefile.am            |   63 ++++
>  utils/blkmapd/atomicio.c             |   58 ++++
>  utils/blkmapd/cfg.c                  |  272 +++++++++++++++++
>  utils/blkmapd/cfg.h                  |   48 +++
>  utils/blkmapd/device-discovery.c     |  542 ++++++++++++++++++++++++++++++++++
>  utils/blkmapd/device-discovery.h     |  162 ++++++++++
>  utils/blkmapd/device-inq.c           |  235 +++++++++++++++
>  utils/blkmapd/device-process.c       |  391 ++++++++++++++++++++++++
>  utils/blkmapd/dm-device.c            |  509 +++++++++++++++++++++++++++++++
>  utils/blkmapd/etc/initd/initd.redhat |   76 +++++
>  utils/blkmapd/etc/pnfs-block.conf    |   10 +
>  13 files changed, 2374 insertions(+), 0 deletions(-)
>  create mode 100644 utils/blkmapd/Makefile.am
>  create mode 100644 utils/blkmapd/atomicio.c
>  create mode 100644 utils/blkmapd/cfg.c
>  create mode 100644 utils/blkmapd/cfg.h
>  create mode 100644 utils/blkmapd/device-discovery.c
>  create mode 100644 utils/blkmapd/device-discovery.h
>  create mode 100644 utils/blkmapd/device-inq.c
>  create mode 100644 utils/blkmapd/device-process.c
>  create mode 100644 utils/blkmapd/dm-device.c
>  create mode 100644 utils/blkmapd/etc/initd/initd.redhat
>  create mode 100644 utils/blkmapd/etc/pnfs-block.conf
> 
> diff --git a/configure.ac b/configure.ac
> index 4d12715..f57cd45 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -64,12 +64,15 @@ AC_ARG_ENABLE(nfsv4,
>  	enable_nfsv4=yes)
>  	if test "$enable_nfsv4" = yes; then
>  		AC_DEFINE(NFS4_SUPPORTED, 1, [Define this if you want NFSv4 support compiled in])
> +		BLKMAPD=blkmapd
>  		IDMAPD=idmapd
>  		SPNFSD=spnfsd
>  	else
>  		enable_nfsv4=
> +		BLKMAPD=
>  		IDMAPD=
>  	fi
> +	AC_SUBST(BLKMAPD)
>  	AC_SUBST(IDMAPD)
>  	AC_SUBST(enable_nfsv4)
>  	AM_CONDITIONAL(CONFIG_NFSV4, [test "$enable_nfsv4" = "yes"])
> @@ -429,6 +432,7 @@ AC_CONFIG_FILES([
>  	tools/mountstats/Makefile
>  	tools/nfs-iostat/Makefile
>  	utils/Makefile
> +	utils/blkmapd/Makefile
>  	utils/exportfs/Makefile
>  	utils/gssd/Makefile
>  	utils/idmapd/Makefile
> diff --git a/utils/Makefile.am b/utils/Makefile.am
> index c777d21..c33835a 100644
> --- a/utils/Makefile.am
> +++ b/utils/Makefile.am
> @@ -10,6 +10,10 @@ if CONFIG_NFSV4
>  OPTDIRS += spnfsd
>  endif
>  
> +if CONFIG_NFSV4
> +OPTDIRS += blkmapd
> +endif
> +
>  if CONFIG_GSS
>  OPTDIRS += gssd
>  endif
> diff --git a/utils/blkmapd/Makefile.am b/utils/blkmapd/Makefile.am
> new file mode 100644
> index 0000000..e8c9fc0
> --- /dev/null
> +++ b/utils/blkmapd/Makefile.am
> @@ -0,0 +1,63 @@
> +## Process this file with automake to produce Makefile.in
> +
> +#man8_MANS	= blkmapd.man
> +
> +RPCPREFIX	= rpc.
> +KPREFIX		= @kprefix@
> +sbin_PROGRAMS	= blkmapd
> +
> +blkmapd_SOURCES = \
> +	atomicio.c \
> +	cfg.c \
> +	device-discovery.c \
> +	device-inq.c \
> +	device-process.c \
> +	dm-device.c \
> +	\
> +	cfg.h \
> +	device-discovery.h
> +
> +blkmapd_LDADD = -ldevmapper ../../support/nfs/libnfs.a
> +
> +MAINTAINERCLEANFILES = Makefile.in
> +
> +#######################################################################
> +# The following allows the current practice of having
> +# daemons renamed during the install to include RPCPREFIX
> +# and the KPREFIX
> +# This could all be done much easier with program_transform_name
> +# ( program_transform_name = s/^/$(RPCPREFIX)$(KPREFIX)/ )
> +# but that also renames the man pages, which the current
> +# practice does not do.
> +install-exec-hook:
> +	(cd $(DESTDIR)$(sbindir) && \
> +	  for p in $(sbin_PROGRAMS); do \
> +	    mv -f $$p$(EXEEXT) $(RPCPREFIX)$(KPREFIX)$$p$(EXEEXT) ;\
> +	  done)
> +uninstall-hook:
> +	(cd $(DESTDIR)$(sbindir) && \
> +	  for p in $(sbin_PROGRAMS); do \
> +	    rm -f $(RPCPREFIX)$(KPREFIX)$$p$(EXEEXT) ;\
> +	  done)
> +
> +
> +# XXX This makes some assumptions about what automake does.
> +# XXX But there is no install-man-hook or install-man-local.
> +install-man: install-man8 install-man-links
> +uninstall-man: uninstall-man8 uninstall-man-links
> +
> +install-man-links:
> +	(cd $(DESTDIR)$(man8dir) && \
> +	  for m in $(man8_MANS) $(dist_man8_MANS) $(nodist_man8_MANS); do \
> +	    inst=`echo $$m | sed -e 's/man$$/8/'`; \
> +	    rm -f $(RPCPREFIX)$$inst ; \
> +	    $(LN_S) $$inst $(RPCPREFIX)$$inst ; \
> +	  done)
> +
> +uninstall-man-links:
> +	(cd $(DESTDIR)$(man8dir) && \
> +	  for m in $(man8_MANS) $(dist_man8_MANS) $(nodist_man8_MANS); do \
> +	    inst=`echo $$m | sed -e 's/man$$/8/'`; \
> +	    rm -f $(RPCPREFIX)$$inst ; \
> +	  done)
> +
> diff --git a/utils/blkmapd/atomicio.c b/utils/blkmapd/atomicio.c
> new file mode 100644
> index 0000000..3c3c864
> --- /dev/null
> +++ b/utils/blkmapd/atomicio.c
> @@ -0,0 +1,58 @@
> +/*
> + * Copyright (c) 2002 Marius Aamodt Eriksen <marius@monkey.org>
> + * Copyright (c) 1995,1999 Theo de Raadt.  All rights reserved.
> + * All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions
> + * are met:
> + * 1. Redistributions of source code must retain the above copyright
> + *    notice, this list of conditions and the following disclaimer.
> + * 2. Redistributions in binary form must reproduce the above copyright
> + *    notice, this list of conditions and the following disclaimer in the
> + *    documentation and/or other materials provided with the distribution.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
> + * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
> + * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
> + * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
> + * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
> + * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
> + * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + */
> +
> +#include <sys/types.h>
> +#include <unistd.h>
> +#include <errno.h>
> +
> +#ifdef HAVE_CONFIG_H
> +#include "config.h"
> +#endif				/* HAVE_CONFIG_H */

We don't need this in nfs-utils...

> +
> +/*
> + * ensure all of data on socket comes through. f==read || f==write
> + */
> +ssize_t atomicio(ssize_t(*f) (int, void *, size_t), int fd, void *_s, size_t n)

Strong type checking won't like calling this function with write() as
an argument, as it's declared with a const void *buf.

> +{
> +	char *s = _s;
> +	ssize_t res, pos = 0;
> +
> +	while (n > pos) {
> +		res = (f) (fd, s + pos, n - pos);
> +		switch (res) {
> +		case -1:
> +			if (errno == EINTR || errno == EAGAIN)
> +				continue;

			/* FALLTHRU */

> +		case 0:
> +			if (pos != 0)
> +				return pos;

so it's not really atomic in this case :-/
why not return the error?

> +			return res;

So on EOF this function returns 0 regardless of how much
it read until it reached there?

Oh well, this function could just return the number of bytes
it read/written or -1 on error.

> +		default:
> +			pos += res;
> +		}
> +	}
> +	return pos;
> +}
> diff --git a/utils/blkmapd/cfg.c b/utils/blkmapd/cfg.c
> new file mode 100644
> index 0000000..b303352
> --- /dev/null
> +++ b/utils/blkmapd/cfg.c
> @@ -0,0 +1,272 @@
> +/*
> + * Copyright (c) 2010 EMC Corporation, Haiying Tang <Tang_Haiying@emc.com>
> + * All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions
> + * are met:
> + * 1. Redistributions of source code must retain the above copyright
> + *    notice, this list of conditions and the following disclaimer.
> + * 2. Redistributions in binary form must reproduce the above copyright
> + *    notice, this list of conditions and the following disclaimer in the
> + *    documentation and/or other materials provided with the distribution.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
> + * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
> + * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
> + * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
> + * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
> + * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
> + * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + */
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <string.h>
> +#include <sys/types.h>
> +#include <sys/stat.h>
> +#include <linux/errno.h>
> +#include <fcntl.h>
> +#include <unistd.h>
> +#include "device-discovery.h"
> +#include "cfg.h"
> +
> +struct scan_root_list *scan_root_list_head;
> +
> +void bl_release_list(void)
> +{
> +	struct scan_root_list *root = scan_root_list_head;
> +	struct scan_device_list *disk;
> +
> +	while (root) {
> +		disk = root->disk;
> +		while (disk) {
> +			root->disk = disk->next;
> +			/*free disk */

missing space after '*'
actually, this comment is useless anyway
doesn't give you any more information than free(disk) :-)

> +			free(disk->name);
> +			free(disk);
> +			disk = root->disk;
> +		}
> +		scan_root_list_head = root->next;
> +		/*free root */

ditto

> +		free(root->name);
> +		free(root);
> +		root = scan_root_list_head;
> +	}
> +	return;

this return statement is superfluous as well...

> +}
> +
> +struct scan_root_list *bl_alloc_root_list(char *name, unsigned int len)
> +{
> +	struct scan_root_list *root;
> +
> +	root = malloc(sizeof(struct scan_root_list));
> +	if (!root) {
> +		BL_LOG_ERR("%s: Out of memory!\n", __func__);
> +		return NULL;
> +	}
> +
> +	root->name = malloc(len + 1);
> +	if (!root->name) {
> +		BL_LOG_ERR("%s: Out of memory!\n", __func__);
> +		goto out;
> +	}
> +	strncpy(root->name, name, len);
> +	root->name[len] = '\0';

That's equivalent to root->name = strndup(name, len)


> +	root->next = scan_root_list_head;
> +	root->all_disk = 0;
> +	scan_root_list_head = root;
> +
> +	return root;
> + out:

Since this is the error path better call the label accordingly.

> +	if (root)
> +		free(root);

root will never be NULL with the current implementation.
Why not move BL_LOG_ERR here and goto err also on the first failure?

> +	return NULL;
> +}
> +
> +void bl_alloc_device_list(struct scan_root_list *root, char *name,
> +			  unsigned int len)
> +{
> +	struct scan_device_list *device;
> +
> +	device = malloc(sizeof(struct scan_device_list));
> +	if (!device) {
> +		BL_LOG_ERR("%s: Out of memory!\n", __func__);
> +		return;
> +	}
> +
> +	device->name = malloc(len + 1);
> +	if (!device->name) {
> +		BL_LOG_ERR("%s: Out of memory!\n", __func__);
> +		goto out;
> +	}
> +	strncpy(device->name, name, len);
> +	device->name[len] = '\0';

ditto

> +	device->next = root->disk;
> +	root->disk = device;
> +	return;
> + out:
> +	if (device)
> +		free(device);

ditto

> +	return;
> +}
> +
> +void bl_set_default_conf(void)
> +{
> +	struct scan_root_list *root;
> +
> +	bl_release_list();
> +
> +	root = bl_alloc_root_list("/dev", 4);
> +	if (root)
> +		bl_alloc_device_list(root, "sd", 2);
> +
> +	root = bl_alloc_root_list("/dev/mapper", 11);

I'd consider defining these names more formally and using
either compile- (sizeof) or run-time (strlen) way to
determine their length.  This is too fragile and error prone
in case someone changes the names in the future.

> +	if (root)
> +		root->all_disk = 1;
> +	return;

Hmm, better return an error if allocation failed.

> +}
> +
> +void bl_insert_device_list(struct scan_root_list *root, char *name,
> +			   unsigned int len)
> +{
> +	struct scan_device_list *device = root->disk;
> +	/* Check whether this device has been inserted */
> +	while (device) {
> +		if (device->name && !strcmp(device->name, name))

Can device->name ever be NULL?
Also, name might not be null terminated, better use strncmp()
but root->name might also be longer than len, so it should be:
		if (!strncmp(root->name, name, len) && strlen(root->name) <= len)

> +			return;
> +		device = device->next;
> +	}
> +
> +	bl_alloc_device_list(root, name, len);
> +
> +	return;

ditto (return status)

> +}
> +
> +struct scan_root_list *bl_insert_root_list(char *name, unsigned int len)
> +{
> +	struct scan_root_list *root = scan_root_list_head;
> +
> +	/* Check whether this root has been inserted */
> +	while (root) {
> +		if (!strcmp(root->name, name))

ditto

> +			return root;
> +		root = root->next;
> +	}
> +
> +	root = bl_alloc_root_list(name, len);
> +	return root;

just return the function result, not need for the intermediate assignment.

> +}
> +
> +void bl_parse_line(char *line, size_t len, struct scan_root_list **bl_root)
> +{
> +	char *root;
> +	char *device;
> +	char *end;
> +

wanna skip leading whitespaces?

> +	if (*line == '#')
> +		return;
> +
> +	root = line;
> +	while (((*root == ' ') || (*root == '\t')) && (root < line + len))

isblank(*root)

> +		root++;

this looks like a for look to me, no? :)

	for (root = line; (root < line + len) && isblank(*root); root++)
		;

> +	if (root == line + len)
> +		return;
> +
> +	end = line + len;

can move that before previous loop and use it there

> +	while (((*end == '\n') || (*end == ' ') || (*end == '\t') ||
> +		(*end == '\0')) && (end > root)) {

	(*end == '\0') || isspace(*root)

> +		end--;
> +	}
> +	/* For lines ended up with "/" or "/""*": add as a dir root */

the comment is written in a confusing way (because of the C comment avoidance trick)
how about:
  +	/* For lines ended up with '/' or '/','*': add as a dir root */

> +	if ((*end == '/') ||
> +	    ((*end == '*') && (end - root >= 1) && (*(end - 1) == '/'))) {
> +		if (*end == '*')
> +			end--;
> +		*bl_root = bl_insert_root_list(root, end - root + 1);
> +		if (*bl_root)
> +			(*bl_root)->all_disk = 1;

how about adding the all_disk flag as a parameter?

> +		return;

status?

> +	}
> +
> +	/* Other lines: add as a device */
> +	device = end;
> +	while ((*device != '/') && (device > root))
> +		device--;
> +	if (device == root)
> +		return;

so that's an invalid line?
better print out an error

> +	*bl_root = bl_insert_root_list(root, device - root + 1);
> +	if (*end == '*')
> +		end--;

so the terminating '*' doesn't really matter for devices, right?

> +	if (*bl_root)

if not, you should return (an error) earlier

> +		bl_insert_device_list(*bl_root, device + 1, end - device);
> +
> +	return;
> +}
> +
> +void bl_parse_conf(char *buf, size_t size)
> +{
> +	char *tmp = buf, *line = buf, *end = buf + size;
> +	struct scan_root_list *bl_root = NULL;
> +
> +	while (tmp < end) {
> +		if (*tmp == '\n') {
> +			*tmp = '\0';
> +			bl_parse_line(line, tmp - line, &bl_root);
> +			line = tmp + 1;
> +		}

so we lose the last line if it's not terminated with a newline?
I wonder of just using getline wouldn't be simpler...

> +		tmp++;
> +	}
> +
> +	return;
> +}
> +
> +int bl_cfg_init(void)
> +{
> +	struct stat sb;
> +	size_t size;
> +	int fd;
> +	char *buf = NULL;
> +	int ret = -ENOENT;
> +
> +	if (stat(bl_conf_path, &sb) == 0) {
> +		ret = -EPERM;
> +		size = sb.st_size;
> +		if (!size)
> +			goto err_out;
> +
> +		fd = open(bl_conf_path, O_RDONLY, 0);
> +		if (fd == -1) {
> +			BL_LOG_ERR("File %s open failed\n", bl_conf_path);
> +			goto err_out;
> +		}
> +
> +		buf = calloc(size, sizeof(char));
> +		if (!buf) {
> +			close(fd);
> +			BL_LOG_ERR("%s: Out of memory\n", __func__);
> +			ret = -ENOMEM;
> +			goto err_out;
> +		}
> +
> +		if (atomicio(read, fd, buf, size) != size) {
> +			close(fd);
> +			BL_LOG_ERR("Read file %s failed\n", bl_conf_path);
> +			goto err_out;
> +		}
> +
> +		ret = 0;
> +		close(fd);
> +		bl_parse_conf(buf, size);
> +		if (!scan_root_list_head)
> +			ret = -EINVAL;
> +	} else
> +		bl_set_default_conf();
> + err_out:
> +	if (buf)
> +		free(buf);
> +	return ret;
> +}
> diff --git a/utils/blkmapd/cfg.h b/utils/blkmapd/cfg.h
> new file mode 100644
> index 0000000..8d7bcf4
> --- /dev/null
> +++ b/utils/blkmapd/cfg.h
> @@ -0,0 +1,48 @@
> +/*
> + * bl-cfg.h
> + *
> + * Copyright (c) 2010 EMC Corporation, Haiying Tang <Tang_Haiying@emc.com>
> + * All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions
> + * are met:
> + * 1. Redistributions of source code must retain the above copyright
> + *    notice, this list of conditions and the following disclaimer.
> + * 2. Redistributions in binary form must reproduce the above copyright
> + *    notice, this list of conditions and the following disclaimer in the
> + *    documentation and/or other materials provided with the distribution.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
> + * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
> + * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
> + * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
> + * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
> + * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
> + * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + */
> +#ifndef BL_CFG_H
> +#define BL_CFG_H
> +
> +#define bl_conf_path "/etc/pnfs-block.conf"

I'd consider having the default in a variable
and allowing to override it as an option.
Also, since the daemon is called blkmapd it makes more
sense to call the config file blkmapd.conf

> +
> +extern struct scan_root_list *scan_root_list_head;
> +
> +struct scan_device_list {
> +	struct scan_device_list *next;
> +	char *name;

keeping the name length could be useful for
quick comparisons (you have it anyway on insertion)

> +};
> +
> +struct scan_root_list {
> +	struct scan_root_list *next;
> +	unsigned int all_disk;
> +	char *name;

ditto

> +	struct scan_device_list *disk;
> +};
> +
> +int bl_cfg_init(void);
> +
> +#endif
> diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
> new file mode 100644
> index 0000000..79cb2b5
> --- /dev/null
> +++ b/utils/blkmapd/device-discovery.c
> @@ -0,0 +1,542 @@
> +/*
> + * device-discovery.c: main function, discovering device and processing
> + * pipe request from kernel.
> + *
> + * Copyright (c) 2010 EMC Corporation, Haiying Tang <Tang_Haiying@emc.com>
> + * All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions
> + * are met:
> + * 1. Redistributions of source code must retain the above copyright
> + *    notice, this list of conditions and the following disclaimer.
> + * 2. Redistributions in binary form must reproduce the above copyright
> + *    notice, this list of conditions and the following disclaimer in the
> + *    documentation and/or other materials provided with the distribution.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
> + * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
> + * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
> + * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
> + * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
> + * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
> + * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + */
> +#define _LARGEFILE64_SOURCE

Is this the right place to define it?
Why not in the Makefile for all files in the binary?

> +#include <stdlib.h>
> +#include <stdio.h>
> +#include <string.h>
> +#include <dirent.h>
> +#include <ctype.h>
> +#include <linux/kdev_t.h>
> +#include <sys/types.h>
> +#include <sys/stat.h>
> +#include <sys/ioctl.h>
> +#include <sys/mount.h>
> +#include <sys/select.h>
> +#include <fcntl.h>
> +#include <unistd.h>
> +#include <libgen.h>
> +#include <errno.h>
> +#include <scsi/scsi.h>
> +#include <scsi/scsi_ioctl.h>
> +#include <scsi/sg.h>
> +#include "device-discovery.h"
> +#include "cfg.h"
> +
> +#define BL_PIPE_FILE	"/var/lib/nfs/rpc_pipefs/bl_device_pipe"



> +#define PID_FILE	"/var/run/pnfs-block.pid"

s/pnfs-block/blkmapd/ to conform with the binary name
(and use a symbolic constant for it defined in some central
header file if it makes sense)

> +
> +struct bl_disk *visible_disk_list;
> +
> +struct bl_disk_path *bl_get_path(const char *filepath,
> +				 struct bl_disk_path *paths)
> +{
> +	struct bl_disk_path *tmp = paths;
> +	while (tmp) {
> +		if (!strcmp(tmp->full_path, filepath))
> +			break;
> +		tmp = tmp->next;
> +	}
> +	return tmp;
> +}
> +
> +/* Check whether valid_path is a substring(partition) of path */
> +int bl_is_partition(struct bl_disk_path *valid_path, struct bl_disk_path *path)
> +{
> +	if (!strncmp(valid_path->full_path, path->full_path,
> +		     strlen(valid_path->full_path)))
> +		return 1;
> +
> +	return 0;
> +}
> +
> +/*
> + * For multipath devices, devices state could be PASSIVE/ACTIVE/PSEUDO,
> + * where PSEUDO > ACTIVE > PASSIVE. Device with highest state is used to
> + * create pseudo device. So if state is higher, the device path needs to
> + * be updated.
> + * If device-mapper multipath support is a must, pseudo devices should
> + * exist for each multipath device. If not, active device path will be
> + * chosen for device creation.
> + * Treat partition as invalid path.
> + */
> +int bl_update_path(struct bl_disk_path *path, enum bl_path_state_e state,
> +		   struct bl_disk *disk)
> +{
> +	struct bl_disk_path *valid_path = disk->valid_path;
> +
> +	if (valid_path) {
> +		if (valid_path->state >= state) {
> +			if (bl_is_partition(valid_path, path))
> +				return 0;
> +		}
> +	}

can there be an else case?

> +	return 1;
> +}
> +
> +void bl_release_disk(void)
> +{
> +	struct bl_disk *disk = visible_disk_list, *tmp;
> +	struct bl_disk_path *path = NULL;
> +
> +	while (disk) {
> +		path = disk->paths;
> +		while (path) {
> +			disk->paths = path->next;
> +			free(path->full_path);
> +			free(path);
> +			path = disk->paths;
> +		}
> +		if (disk->serial)

can it be NULL?

> +			free(disk->serial);
> +		tmp = disk->next;

you could use visible_disk_list for tmp, no?

> +		free(disk);
> +		disk = tmp;
> +	}
> +
> +	visible_disk_list = NULL;
> +}
> +
> +void bl_add_disk(char *filepath)
> +{
> +	struct bl_disk *disk = NULL;
> +	struct bl_disk *tmp = visible_disk_list;
> +	int fd = 0;
> +	struct stat sb;
> +	off_t size = 0;
> +	struct bl_serial *serial = NULL;
> +	enum bl_path_state_e ap_state = BL_PATH_STATE_PASSIVE;
> +	struct bl_disk_path *diskpath = NULL, *path = NULL;
> +	dev_t dev;
> +
> +	fd = open(filepath, O_RDONLY | O_LARGEFILE);
> +	if (fd < 0)
> +		return;
> +
> +	if (fstat(fd, &sb)) {
> +		close(fd);
> +		return;
> +	}
> +
> +	if (!sb.st_size)
> +		ioctl(fd, BLKGETSIZE, &size);
> +	else
> +		size = sb.st_size;
> +
> +	if (!size) {
> +		close(fd);
> +		return;
> +	}
> +
> +	dev = sb.st_rdev;
> +
> +	serial = bldev_read_serial(fd, filepath);
> +	while (tmp) {
> +		/*Already scanned or a partition?
> +		 *XXX: if released each time, maybe not need to compare

please add space after "/*"
(can use kernel scripts/checkpatch.pl)

> +		 */
> +		if ((serial->len == tmp->serial->len) &&
> +		    (memcmp(serial->data, tmp->serial->data, serial->len) ==
> +		     0)) {
> +			diskpath = bl_get_path(filepath, tmp->paths);
> +			break;
> +		}
> +		tmp = tmp->next;
> +	}
> +
> +	if (tmp && diskpath) {

why not call tmp with a more meaningful name?

> +		close(fd);
> +		return;
> +	}
> +
> +	bldev_read_ap_state(fd, &ap_state);
> +	close(fd);
> +
> +	/*
> +	 * Not sure how to identify a pseudo device created by
> +	 * device-mapper, so leave /dev/mapper for now.
> +	 */
> +	if (strncmp(filepath, "/dev/mapper", 11) == 0)
> +		ap_state = BL_PATH_STATE_PSEUDO;
> +
> +	/*add path */
> +	path = malloc(sizeof(struct bl_disk_path));
> +	if (!path) {
> +		BL_LOG_ERR("%s: Out of memory!\n", __func__);
> +		goto out_err;
> +	}
> +	path->next = NULL;
> +	path->state = ap_state;
> +	path->full_path = strdup(filepath);
> +	if (!path->full_path)
> +		goto out_err;
> +
> +	if (!tmp) {		/*add disk */

by here, I managed to forget what tmp is all about :)
please give it a useful name...

> +		disk = malloc(sizeof(struct bl_disk));
> +		if (!disk) {
> +			BL_LOG_ERR("%s: Out of memory!\n", __func__);
> +			goto out_err;
> +		}
> +		disk->next = visible_disk_list;
> +		disk->dev = dev;
> +		disk->size = size;
> +		disk->serial = serial;
> +		disk->valid_path = path;
> +		disk->paths = path;
> +		visible_disk_list = disk;
> +	} else {
> +		path->next = tmp->paths;
> +		tmp->paths = path;
> +		/*check whether we need to update disk info */
> +		if (bl_update_path(path, path->state, tmp)) {
> +			tmp->dev = dev;
> +			tmp->size = size;
> +			tmp->valid_path = path;
> +		}
> +	}
> +	return;
> +
> + out_err:
> +	if (path) {
> +		if (path->full_path)
> +			free(path->full_path);

again, these should never be NULL, no?

> +		free(path);
> +	}
> +	if (disk) {
> +		if (disk->serial)
> +			free(disk->serial);

ditto

> +		free(disk);

or just define a bl_free that checks for NULL
before calling free...

> +	}
> +	return;
> +}
> +
> +void bl_devicescan(const char *filename, struct scan_root_list *root)
> +{
> +	/*scan all disks */
> +	char filepath[PATH_MAX];
> +	struct scan_device_list *device;
> +
> +	if (!strcmp(filename, ".") || !strcmp(filename, ".."))
> +		return;
> +
> +	memset(filepath, 0, PATH_MAX);
> +	if (strlen(filename) < (PATH_MAX - strlen(root->name) - 2))
> +		sprintf(filepath, "%s/%s", root->name, filename);
> +	else
> +		return;

print error for name too long?

> +	if (root->all_disk)
> +		goto valid;
> +
> +	device = root->disk;
> +	while (device) {
> +		/* If device->name is a subset of filename, this disk should be
> +		 * valid for scanning.
> +		 * For example, device->name is "sd", filename is "sda".
> +		 */
> +		if (device->name
> +		    && !memcmp(filename, device->name, strlen(device->name)))
> +			goto valid;
> +		device = device->next;
> +	}
> +
> +	return;
> +
> + valid:
> +	/*
> +	 * sg device is not a real device, but a device created according
> +	 * to each scsi device. It won't be used for pseudo device creation.
> +	 * I moved it here, so that sg devices will not be scanned.
> +	 */
> +	if (!strncmp(filename, "/dev/sg", 7))

I'm confused...
Is /dev part of filename or root->name?

> +		return;
> +	bl_add_disk(filepath);
> +	return;
> +}
> +
> +/*
> + * Delete disks with multi-paths and no pseudo device path.
> + *
> + * If only passive device or more than one active devices available,
> + * I consider it as error since multipath of device-mapper should have worked
> + * and pseudo device should have been created.
> + */
> +void bl_del_invalid_disk(void)
> +{
> +	struct bl_disk *disk = visible_disk_list, *pre;
> +	struct bl_disk_path *path = NULL;
> +
> +	pre = disk;
> +	while (disk) {
> +		if ((disk->valid_path->state == BL_PATH_STATE_PASSIVE) ||
> +		    ((disk->valid_path->state == BL_PATH_STATE_ACTIVE) &&
> +		     (disk->paths->next))) {
> +			path = disk->paths;
> +			while (path) {
> +				disk->paths = path->next;
> +				free(path->full_path);
> +				free(path);
> +				path = disk->paths;
> +			}

You could refactor the code a bit
for these kind of loops...

> +			if (disk->serial)
> +				free(disk->serial);
> +			if (pre == visible_disk_list) {
> +				visible_disk_list = disk->next;
> +				free(disk);
> +				disk = visible_disk_list;
> +			} else {
> +				pre->next = disk->next;
> +				free(disk);
> +				disk = pre->next;
> +			}

btw, if pre would be a ** you could just always set *pre to disk->next, right?

> +		} else {
> +			pre = disk;
> +			disk = disk->next;
> +		}
> +	}
> +	return;
> +}
> +
> +int bl_discover_devices(void)
> +{
> +	DIR *dir;
> +	struct dirent *dp;
> +	struct scan_root_list *root = scan_root_list_head;
> +	/*release previous list */
> +	bl_release_disk();
> +	/*scan all disks */
> +	while (root) {
> +		dir = opendir(root->name);
> +		if (dir == NULL) {
> +			root = root->next;
> +			continue;
> +		}
> +
> +		while ((dp = readdir(dir)) != NULL)
> +			bl_devicescan(dp->d_name, root);
> +
> +		root = root->next;
> +		closedir(dir);
> +	}
> +
> +#ifdef DEL_INVALID_DISKS
> +	bl_del_invalid_disk();
> +#endif

This is dead code.
Can you please keep it in your own git repository
or enable it if it is any good? :-)

> +
> +	return 0;
> +}
> +
> +/* process kernel request
> + * return 0: request processed, and no more request waiting;
> + * return 1: request processed, and more requests waiting;
> + * return < 0: error
> + */
> +int bl_disk_inquiry_process(int fd)
> +{
> +	int ret = 0;
> +	struct pipefs_hdr *head = NULL, *tmp;
> +	char *buf = NULL;
> +	uint32_t major, minor;
> +	uint16_t buflen;
> +	unsigned int len = 0;
> +
> +	head = calloc(1, sizeof(struct pipefs_hdr));
> +	if (!head) {
> +		BL_LOG_ERR("%s: Out of memory!\n", __func__);
> +		return -ENOMEM;
> +	}
> +
> +	/*read request */
> +	if (atomicio(read, fd, head, sizeof(*head)) != sizeof(*head)) {
> +		/* Note that an error in this or the next read is pretty
> +		 * catastrophic, as there is no good way to resync into
> +		 * the pipe's stream.
> +		 */
> +		BL_LOG_ERR("Read pipefs head error!\n");
> +		ret = -EIO;
> +		goto out;
> +	}
> +
> +	buflen = head->totallen - sizeof(*head);
> +	buf = malloc(buflen);
> +	if (!buf) {
> +		BL_LOG_ERR("%s: Out of memory!\n", __func__);
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	if (atomicio(read, fd, buf, buflen) != buflen) {
> +		BL_LOG_ERR("Read pipefs content error!\n");
> +		ret = -EIO;
> +		goto out;
> +	}
> +
> +	head->status = BL_DEVICE_REQUEST_PROC;
> +	switch (head->type) {
> +	case BL_DEVICE_MOUNT:
> +		if (!process_deviceinfo(buf, buflen, &major, &minor)) {
> +			head->status = BL_DEVICE_REQUEST_ERR;
> +			goto out;
> +		}
> +		tmp = realloc(head, sizeof(major) + sizeof(minor) +
> +			      sizeof(struct pipefs_hdr));
> +		if (!tmp) {
> +			BL_LOG_ERR("%s: Out of memory!\n", __func__);
> +			ret = -ENOMEM;
> +			goto out;
> +		}
> +		head = tmp;
> +		memcpy((void *)head + sizeof(struct pipefs_hdr),
> +		       &major, sizeof(major));
> +		memcpy((void *)head + sizeof(struct pipefs_hdr) + sizeof(major),
> +		       &minor, sizeof(minor));
> +		len = sizeof(major) + sizeof(minor);
> +		break;
> +	case BL_DEVICE_UMOUNT:
> +		if (!dm_device_remove_all((uint64_t *) buf))
> +			head->status = BL_DEVICE_REQUEST_ERR;
> +		bl_discover_devices();
> +		break;
> +	default:
> +		head->status = BL_DEVICE_REQUEST_ERR;
> +	}
> +
> +	head->totallen = sizeof(struct pipefs_hdr) + len;
> +	/* write to pipefs */
> +	if (atomicio((void *)write, fd, head, head->totallen)

this just calls for atomic_read, atomic_write because of the
type cast.
(or not "atomic", as it's not... I'd call it readn()/writen()...)

> +	    != head->totallen) {
> +		BL_LOG_ERR("Write pipefs error!\n");
> +		ret = -EIO;
> +	}
> +
> + out:
> +	if (buf)
> +		free(buf);
> +	if (head)
> +		free(head);
> +	return ret;
> +}
> +
> +/*TODO: set bl_process_stop to 1 in command*/
> +unsigned int bl_process_stop;

volatile maybe?

> +
> +int bl_run_disk_inquiry_process(int fd)
> +{
> +	fd_set rset;
> +	struct timeval tv;
> +	int ret;
> +
> +	bl_process_stop = 0;
> +
> +	for (;;) {
> +		if (bl_process_stop)
> +			return 1;
> +		FD_ZERO(&rset);
> +		FD_SET(fd, &rset);
> +		ret = 0;
> +		tv.tv_sec = BL_DEVICE_DISCOVERY_INTERVAL;
> +		switch (select(fd + 1, &rset, NULL, NULL, &tv)) {
> +		case -1:
> +			if (errno == EINTR)
> +				continue;
> +			else {
> +				ret = -errno;
> +				goto out;
> +			}
> +		case 0:
> +			goto out;
> +		default:
> +			if (FD_ISSET(fd, &rset))
> +				ret = bl_disk_inquiry_process(fd);
> +		}
> +	}
> + out:
> +	return ret;
> +}
> +
> +/* Daemon */
> +int main(void)
> +{
> +	int fd, ret = 1;
> +	struct stat statbuf;
> +	char pidbuf[64];
> +
> +	if (!stat(PID_FILE, &statbuf)) {
> +		fprintf(stderr, "Pid file already existed\n");
> +		return -1;
> +	}
> +
> +	if (daemon(0, 0) != 0) {
> +		fprintf(stderr, "Daemonize failed\n");
> +		return -1;
> +	}
> +
> +	openlog("pnfs-block", LOG_PID, 0);

ditto using the binary name

Benny

> +	fd = open(PID_FILE, O_WRONLY | O_CREAT, 0644);
> +	if (fd < 0) {
> +		BL_LOG_ERR("Create pid file failed\n");
> +		return -1;
> +	}
> +
> +	if (lockf(fd, F_TLOCK, 0) < 0) {
> +		BL_LOG_ERR("Lock pid file failed\n");
> +		close(fd);
> +		return -1;
> +	}
> +	ftruncate(fd, 0);
> +	sprintf(pidbuf, "%d\n", getpid());
> +	write(fd, pidbuf, strlen(pidbuf));
> +
> +	/*open pipe file */
> +	fd = open(BL_PIPE_FILE, O_RDWR);
> +	if (fd < 0) {
> +		BL_LOG_ERR("open pipe file error\n");
> +		return -1;
> +	}
> +
> +	ret = bl_cfg_init();
> +	if (ret < 0) {
> +		if (ret == -ENOENT)
> +			BL_LOG_WARNING("Config file not exist, use default\n");
> +		else {
> +			BL_LOG_ERR("Open/read Block pNFS config file error\n");
> +			return -1;
> +		}
> +	}
> +
> +	while (1) {
> +		/*discover device when needed */
> +		bl_discover_devices();
> +
> +		ret = bl_run_disk_inquiry_process(fd);
> +		if (ret < 0) {
> +			/* what should we do with process error? */
> +			BL_LOG_ERR("inquiry process return %d\n", ret);
> +		}
> +	}
> +	close(fd);
> +	return ret;
> +}
> diff --git a/utils/blkmapd/device-discovery.h b/utils/blkmapd/device-discovery.h
> new file mode 100644
> index 0000000..9f87ebe
> --- /dev/null
> +++ b/utils/blkmapd/device-discovery.h
> @@ -0,0 +1,162 @@
> +/*
> + * bl-device-discovery.h
> + *
> + * Copyright (c) 2010 EMC Corporation, Haiying Tang <Tang_Haiying@emc.com>
> + * All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions
> + * are met:
> + * 1. Redistributions of source code must retain the above copyright
> + *    notice, this list of conditions and the following disclaimer.
> + * 2. Redistributions in binary form must reproduce the above copyright
> + *    notice, this list of conditions and the following disclaimer in the
> + *    documentation and/or other materials provided with the distribution.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
> + * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
> + * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
> + * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
> + * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
> + * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
> + * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + */
> +#ifndef BL_DEVICE_DISCOVERY_H
> +#define BL_DEVICE_DISCOVERY_H
> +
> +#define BL_DEVICE_DISCOVERY_INTERVAL 60
> +
> +#include <stdint.h>
> +#include <syslog.h>
> +
> +enum blk_vol_type {
> +	BLOCK_VOLUME_SIMPLE = 0,	/* maps to a single LU */
> +	BLOCK_VOLUME_SLICE = 1,	/* slice of another volume */
> +	BLOCK_VOLUME_CONCAT = 2,	/* concatenation of multiple volumes */
> +	BLOCK_VOLUME_STRIPE = 3,	/* striped across multiple volumes */
> +	BLOCK_VOLUME_PSEUDO = 4,
> +};
> +
> +/* All disk offset/lengths are stored in 512-byte sectors */
> +struct bl_volume {
> +	uint32_t bv_type;
> +	off_t bv_size;
> +	struct bl_volume **bv_vols;
> +	int bv_vol_n;
> +	union {
> +		dev_t bv_dev;	/*for BLOCK_VOLUME_SIMPLE(PSEUDO) */
> +		off_t bv_stripe_unit;	/*for BLOCK_VOLUME_STRIPE(CONCAT) */
> +		off_t bv_offset;	/*for BLOCK_VOLUME_SLICE */
> +	} param;
> +};
> +
> +struct bl_sig_comp {
> +	int64_t bs_offset;	/* In bytes */
> +	uint32_t bs_length;	/* In bytes */
> +	char *bs_string;
> +};
> +
> +/* Maximum number of signatures components in a simple volume */
> +# define BLOCK_MAX_SIG_COMP 16
> +
> +struct bl_sig {
> +	int si_num_comps;
> +	struct bl_sig_comp si_comps[BLOCK_MAX_SIG_COMP];
> +};
> +
> +/*
> + * Multipath support: ACTIVE or PSEUDO device is valid,
> + *		      PASSIVE is a standby for ACTIVE.
> + */
> +enum bl_path_state_e {
> +	BL_PATH_STATE_PASSIVE = 1,
> +	BL_PATH_STATE_ACTIVE = 2,
> +	BL_PATH_STATE_PSEUDO = 3,
> +};
> +
> +struct bl_serial {
> +	int len;
> +	char *data;
> +};
> +
> +struct bl_disk_path {
> +	struct bl_disk_path *next;
> +	char *full_path;
> +	enum bl_path_state_e state;
> +};
> +
> +struct bl_disk {
> +	struct bl_disk *next;
> +	struct bl_serial *serial;
> +	dev_t dev;
> +	off_t size;
> +	struct bl_disk_path *valid_path;
> +	struct bl_disk_path *paths;
> +};
> +
> +struct bl_dev_id {
> +	unsigned char type;
> +	unsigned char ids;
> +	unsigned char reserve;
> +	unsigned char len;
> +	char data[0];
> +};
> +
> +struct pipefs_hdr {
> +	uint32_t msgid;
> +	uint8_t type;
> +	uint8_t flags;
> +	uint16_t totallen;	/* length of entire message, including hdr */
> +	uint32_t status;
> +};
> +
> +#define BL_DEVICE_UMOUNT                0x0	/* Umount--delete devices */
> +#define BL_DEVICE_MOUNT                 0x1	/* Mount--create devices */
> +#define BL_DEVICE_REQUEST_INIT          0x0	/* Start request */
> +#define BL_DEVICE_REQUEST_PROC          0x1	/* User process succeeds */
> +#define BL_DEVICE_REQUEST_ERR           0x2	/* User process fails */
> +
> +uint32_t *blk_overflow(uint32_t * p, uint32_t * end, size_t nbytes);
> +
> +#define BLK_READBUF(p, e, nbytes)  do { \
> +	p = blk_overflow(p, e, nbytes); \
> +	if (!p) {\
> +		goto out_err;\
> +	} \
> +} while (0)
> +
> +#define READ32(x)         (x) = ntohl(*p++)
> +
> +#define READ64(x)         do {                  \
> +	(x) = (uint64_t)ntohl(*p++) << 32;           \
> +	(x) |= ntohl(*p++);                     \
> +} while (0)
> +
> +#define READ_SECTOR(x)     do { \
> +	READ64(tmp); \
> +	if (tmp & 0x1ff) { \
> +		goto out_err; \
> +	} \
> +	(x) = tmp >> 9; \
> +} while (0)
> +
> +extern struct bl_disk *visible_disk_list;
> +uint64_t dm_device_create(struct bl_volume *vols, int num_vols);
> +int dm_device_remove_all(uint64_t *dev);
> +uint64_t process_deviceinfo(const char *dev_addr_buf,
> +			    unsigned int dev_addr_len,
> +			    uint32_t *major, uint32_t *minor);
> +
> +extern ssize_t atomicio(ssize_t(*f) (int, void *, size_t),
> +			int fd, void *_s, size_t n);
> +extern struct bl_serial *bldev_read_serial(int fd, const char *filename);
> +extern void bldev_read_ap_state(int fd, enum bl_path_state_e *ap_state_out);
> +extern int bl_discover_devices(void);
> +
> +#define BL_LOG_WARNING(fmt...)		syslog(LOG_WARNING, fmt)
> +#define BL_LOG_ERR(fmt...)		syslog(LOG_ERR, fmt)
> +#define BL_LOG_DEBUG(fmt...)		syslog(LOG_DEBUG, fmt)
> +#endif
> diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
> new file mode 100644
> index 0000000..ff38fd6
> --- /dev/null
> +++ b/utils/blkmapd/device-inq.c
> @@ -0,0 +1,235 @@
> +/*
> + * device-inq.c: inquire SCSI device information.
> + *
> + * Copyright (c) 2010 EMC Corporation, Haiying Tang <Tang_Haiying@emc.com>
> + * All rights reserved.
> + *
> + * This program refers to "SCSI Primary Commands - 3 (SPC-3)
> + * at http://www.t10.org and sg_inq.c in sg3_utils-1.26 for
> + * Linux OS SCSI subsystem, by D. Gilbert.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions
> + * are met:
> + * 1. Redistributions of source code must retain the above copyright
> + *    notice, this list of conditions and the following disclaimer.
> + * 2. Redistributions in binary form must reproduce the above copyright
> + *    notice, this list of conditions and the following disclaimer in the
> + *    documentation and/or other materials provided with the distribution.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
> + * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
> + * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
> + * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
> + * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
> + * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
> + * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + */
> +#include <stdlib.h>
> +#include <stdio.h>
> +#include <string.h>
> +#include <dirent.h>
> +#include <ctype.h>
> +#include <sys/types.h>
> +#include <sys/stat.h>
> +#include <sys/ioctl.h>
> +#include <sys/mount.h>
> +#include <sys/select.h>
> +#include <fcntl.h>
> +#include <unistd.h>
> +#include <libgen.h>
> +#include <errno.h>
> +#include <scsi/scsi.h>
> +#include <scsi/scsi_ioctl.h>
> +#include <scsi/sg.h>
> +#include "device-discovery.h"
> +
> +#define DEF_ALLOC_LEN	255
> +#define MX_ALLOC_LEN	(0xc000 + 0x80)
> +
> +struct bl_serial *bl_create_scsi_string(int len, const char *bytes)
> +{
> +	struct bl_serial *s;
> +	s = malloc(sizeof(*s) + len);
> +	if (s) {
> +		s->data = (char *)&s[1];
> +		s->len = len;
> +		memcpy(s->data, bytes, len);
> +	}
> +	return s;
> +}
> +
> +void bl_free_scsi_string(struct bl_serial *str)
> +{
> +	if (str)
> +		free(str);
> +}
> +
> +#define sg_io_ok(io_hdr) \
> +	((((io_hdr).status & 0x7e) == 0) && \
> +	((io_hdr).host_status == 0) && \
> +	(((io_hdr).driver_status & 0x0f) == 0))
> +
> +static int sg_timeout = 1 * 1000;
> +
> +static int bldev_inquire_page(int fd, int page, char *buffer, int len)
> +{
> +	unsigned char cmd[] = { INQUIRY, 0, 0, 0, 0, 0 };
> +	unsigned char sense_b[28];
> +	struct sg_io_hdr io_hdr;
> +	if (page >= 0) {
> +		cmd[1] = 1;
> +		cmd[2] = page;
> +	}
> +	cmd[3] = (unsigned char)((len >> 8) & 0xff);
> +	cmd[4] = (unsigned char)(len & 0xff);
> +
> +	memset(&io_hdr, 0, sizeof(struct sg_io_hdr));
> +	io_hdr.interface_id = 'S';
> +	io_hdr.cmd_len = sizeof(cmd);
> +	io_hdr.mx_sb_len = sizeof(sense_b);
> +	io_hdr.dxfer_direction = SG_DXFER_FROM_DEV;
> +	io_hdr.dxfer_len = len;
> +	io_hdr.dxferp = buffer;
> +	io_hdr.cmdp = cmd;
> +	io_hdr.sbp = sense_b;
> +	io_hdr.timeout = sg_timeout;
> +	if (ioctl(fd, SG_IO, &io_hdr) < 0)
> +		return -1;
> +
> +	if (sg_io_ok(io_hdr))
> +		return 0;
> +	return -1;
> +}
> +
> +int bldev_inquire_pages(int fd, int page, char **buffer)
> +{
> +	int status = 0;
> +	char *tmp;
> +	int len;
> +
> +	*buffer = calloc(DEF_ALLOC_LEN, sizeof(char));
> +	if (!*buffer) {
> +		BL_LOG_ERR("%s: Out of memory!\n", __func__);
> +		return -ENOMEM;
> +	}
> +
> +	status = bldev_inquire_page(fd, page, *buffer, DEF_ALLOC_LEN);
> +	if (status)
> +		goto out;
> +
> +	status = -1;
> +	if ((*(*buffer + 1) & 0xff) != page)
> +		goto out;
> +
> +	len = (*(*buffer + 2) << 8) + *(*buffer + 3) + 4;
> +	if (len > MX_ALLOC_LEN) {
> +		BL_LOG_ERR("SCSI response length too long: %d\n", len);
> +		goto out;
> +	}
> +	if (len > DEF_ALLOC_LEN) {
> +		tmp = realloc(*buffer, len);
> +		if (!tmp) {
> +			BL_LOG_ERR("%s: Out of memory!\n", __func__);
> +			status = -ENOMEM;
> +			goto out;
> +		}
> +		*buffer = tmp;
> +		status = bldev_inquire_page(fd, page, *buffer, len);
> +		if (status)
> +			goto out;
> +	}
> +	status = 0;
> + out:
> +	return status;
> +}
> +
> +/* For EMC multipath devices, use VPD page (0xc0) to get status.
> + * For other devices, return ACTIVE for now
> + */
> +void bldev_read_ap_state(int fd, enum bl_path_state_e *ap_state_out)
> +{
> +	int status = 0;
> +	char *buffer;
> +
> +	*ap_state_out = BL_PATH_STATE_ACTIVE;
> +
> +	status = bldev_inquire_pages(fd, 0xc0, &buffer);
> +	if (status)
> +		goto out;
> +
> +	if (buffer[4] < 0x02)
> +		*ap_state_out = BL_PATH_STATE_PASSIVE;
> + out:
> +	if (buffer)
> +		free(buffer);
> +	return;
> +}
> +
> +struct bl_serial *bldev_read_serial(int fd, const char *filename)
> +{
> +	struct bl_serial *serial_out = NULL;
> +	int status = 0, pos, len;
> +	char *buffer;
> +	struct bl_dev_id *dev_root, *dev_id;
> +	unsigned int current_id = 0;
> +
> +	status = bldev_inquire_pages(fd, 0x83, &buffer);
> +	if (status)
> +		goto out;
> +
> +	dev_root = (struct bl_dev_id *)buffer;
> +
> +	pos = 0;
> +	current_id = 0;
> +	len = dev_root->len;
> +	while (pos < (len - sizeof(struct bl_dev_id) + sizeof(unsigned char))) {
> +		dev_id = (struct bl_dev_id *)&(dev_root->data[pos]);
> +		if ((dev_id->ids & 0xf) < current_id)
> +			continue;
> +		switch (dev_id->ids & 0xf) {
> +			/* We process SCSI ID with four ID cases: 0, 1, 2 and 3.
> +			 * When more than one ID is available, priority is
> +			 * 3>2>1>0.
> +			 */
> +		case 2:	/* EUI-64 based */
> +			if ((dev_id->len != 8) && (dev_id->len != 12) &&
> +			    (dev_id->len != 16)) {
> +				BL_LOG_ERR("EUI-64 only decodes 8, "
> +					   "12 and 16\n");
> +				break;
> +			}
> +		case 3:	/* NAA */
> +			/* TODO: NAA validity judgement too complicated,
> +			 * so just ingore it here.
> +			 */
> +			if ((dev_id->type & 0xf) != 1) {
> +				BL_LOG_ERR("Binary code_set expected\n");
> +				break;
> +			}
> +		case 0:	/* vendor specific */
> +		case 1:	/* T10 vendor identification */
> +			current_id = dev_id->ids & 0xf;
> +			if (serial_out)
> +				bl_free_scsi_string(serial_out);
> +			serial_out = bl_create_scsi_string(dev_id->len,
> +							   dev_id->data);
> +			break;
> +		default:
> +			break;
> +		}
> +		if (current_id == 3)
> +			break;
> +		pos += (dev_id->len + sizeof(struct bl_dev_id) -
> +			sizeof(unsigned char));
> +	}
> + out:
> +	if (!serial_out)
> +		serial_out = bl_create_scsi_string(strlen(filename), filename);
> +	if (buffer)
> +		free(buffer);
> +	return serial_out;
> +}
> diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
> new file mode 100644
> index 0000000..6252552
> --- /dev/null
> +++ b/utils/blkmapd/device-process.c
> @@ -0,0 +1,391 @@
> +/*
> + * device-process.c: detailed processing of device information sent
> + * from kernel.
> + *
> + * Copyright (c) 2006 The Regents of the University of Michigan.
> + * All rights reserved.
> + *
> + *  Andy Adamson <andros@citi.umich.edu>
> + *  Fred Isaman <iisaman@umich.edu>
> + *
> + * Copyright (c) 2010 EMC Corporation, Haiying Tang <Tang_Haiying@emc.com>
> + *
> + * Used codes in linux/fs/nfs/blocklayout/blocklayoutdev.c.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions
> + * are met:
> + * 1. Redistributions of source code must retain the above copyright
> + *    notice, this list of conditions and the following disclaimer.
> + * 2. Redistributions in binary form must reproduce the above copyright
> + *    notice, this list of conditions and the following disclaimer in the
> + *    documentation and/or other materials provided with the distribution.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
> + * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
> + * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
> + * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
> + * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
> + * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
> + * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + */
> +#define _LARGEFILE64_SOURCE
> +#include <libdevmapper.h>
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <string.h>
> +#include <unistd.h>
> +#include <sys/types.h>
> +#include <sys/stat.h>
> +#include <sys/user.h>
> +#include <fcntl.h>
> +#include <errno.h>
> +#include <arpa/inet.h>
> +#include <linux/kdev_t.h>
> +#include "device-discovery.h"
> +
> +uint32_t *blk_overflow(uint32_t * p, uint32_t * end, size_t nbytes)
> +{
> +	uint32_t *q = p + ((nbytes + 3) >> 2);
> +	if (q > end || q < p)
> +		return NULL;
> +	return p;
> +}
> +
> +static int decode_blk_signature(uint32_t **pp, uint32_t *end,
> +				struct bl_sig *sig)
> +{
> +	int i, tmp;
> +	uint32_t *p = *pp;
> +
> +	BLK_READBUF(p, end, 4);
> +	READ32(sig->si_num_comps);
> +	if (sig->si_num_comps == 0) {
> +		BL_LOG_ERR("0 components in sig\n");
> +		goto out_err;
> +	}
> +	if (sig->si_num_comps >= BLOCK_MAX_SIG_COMP) {
> +		BL_LOG_ERR("number of sig comps %i >= BLOCK_MAX_SIG_COMP\n",
> +			   sig->si_num_comps);
> +		goto out_err;
> +	}
> +	for (i = 0; i < sig->si_num_comps; i++) {
> +		BLK_READBUF(p, end, 12);
> +		READ64(sig->si_comps[i].bs_offset);
> +		READ32(tmp);
> +		sig->si_comps[i].bs_length = tmp;
> +		BLK_READBUF(p, end, tmp);
> +		/* Note we rely here on fact that sig is used immediately
> +		 * for mapping, then thrown away.
> +		 */
> +		sig->si_comps[i].bs_string = (char *)p;
> +		BL_LOG_ERR("%s: si_comps[%d]: bs_length %d, bs_string %s\n",
> +			   __func__, i, sig->si_comps[i].bs_length,
> +			   sig->si_comps[i].bs_string);
> +		p += ((tmp + 3) >> 2);
> +	}
> +	*pp = p;
> +	return 0;
> + out_err:
> +	return -EIO;
> +}
> +
> +/* Read signature from device
> + * return 0: read successfully
> + * return -1: error
> + */
> +int read_cmp_blk_sig(const char *dev_name, struct bl_sig_comp *comp,
> +		     int64_t bs_offset)
> +{
> +	int fd, ret = -1;
> +	char *sig = NULL;
> +
> +	BL_LOG_ERR("%s: dev_name %s\n", __func__, dev_name);
> +	fd = open(dev_name, O_RDONLY | O_LARGEFILE);
> +	if (fd < 0) {
> +		BL_LOG_ERR("%s could not be opened for read\n", dev_name);
> +		goto error;
> +	}
> +
> +	sig = (char *)malloc(comp->bs_length);
> +	if (!sig) {
> +		BL_LOG_ERR("%s: Out of memory\n", __func__);
> +		goto error;
> +	}
> +
> +	if (lseek64(fd, bs_offset, SEEK_SET) == -1) {
> +		BL_LOG_ERR("File %s lseek error\n", dev_name);
> +		goto error;
> +	}
> +
> +	if (atomicio(read, fd, sig, comp->bs_length) != comp->bs_length) {
> +		BL_LOG_ERR("File %s read error\n", dev_name);
> +		goto error;
> +	}
> +
> +	BL_LOG_ERR
> +	    ("%s: sig: %s, bs_string: %s, bs_length: %d, bs_offset: %lld\n",
> +	     __func__, sig, comp->bs_string, comp->bs_length, bs_offset);
> +	ret = memcmp(sig, comp->bs_string, comp->bs_length);
> +
> + error:
> +	if (sig)
> +		free(sig);
> +	if (fd >= 0)
> +		close(fd);
> +	return ret;
> +}
> +
> +/*
> + * All signatures in sig must be found on disk for verification.
> + * Returns True if sig matches, False otherwise.
> + */
> +static int verify_sig(struct bl_disk *disk, struct bl_sig *sig)
> +{
> +	struct bl_sig_comp *comp;
> +	int i, ret;
> +	int64_t bs_offset;
> +
> +	for (i = 0; i < sig->si_num_comps; i++) {
> +		comp = &sig->si_comps[i];
> +		bs_offset = comp->bs_offset;
> +		if (bs_offset < 0)
> +			bs_offset += (((int64_t) disk->size) << 9);
> +		BL_LOG_ERR("%s: bs_offset: %lld\n", __func__, bs_offset);
> +		ret = read_cmp_blk_sig(disk->valid_path->full_path,
> +				       comp, bs_offset);
> +		if (ret)
> +			return 0;
> +	}
> +	return 1;
> +}
> +
> +/*
> + * map_sig_to_device()
> + * Given a signature, walk the list of visible disks searching for
> + * a match. Returns True if mapping was done, False otherwise.
> + *
> + * While we're at it, fill in the vol->bv_size.
> + */
> +static int map_sig_to_device(struct bl_sig *sig, struct bl_volume *vol)
> +{
> +	int mapped = 0;
> +	struct bl_disk *disk = visible_disk_list;
> +	char *filepath = 0;
> +	struct bl_disk *lolDisk = disk;
> +	while (lolDisk) {
> +		BL_LOG_ERR("%s: visible_disk_list: %s\n", __func__,
> +			   lolDisk->valid_path->full_path);
> +		lolDisk = lolDisk->next;
> +	}
> +
> +	/*scan disk list to find out match device */
> +	while (disk) {
> +		/* FIXME: should we use better algorithm for disk scan? */
> +		mapped = verify_sig(disk, sig);
> +		if (mapped) {
> +			vol->param.bv_dev = disk->dev;
> +			filepath = disk->valid_path->full_path;
> +			vol->bv_size = disk->size;
> +			break;
> +		}
> +		disk = disk->next;
> +	}
> +	return mapped;
> +}
> +
> +/* We are given an array of XDR encoded array indices, each of which should
> + * refer to a previously decoded device.  Translate into a list of pointers
> + * to the appropriate pnfs_blk_volume's.
> + */
> +static int set_vol_array(uint32_t **pp, uint32_t *end,
> +			 struct bl_volume *vols, int working)
> +{
> +	int i, index;
> +	uint32_t *p = *pp;
> +	struct bl_volume **array = vols[working].bv_vols;
> +	for (i = 0; i < vols[working].bv_vol_n; i++) {
> +		BLK_READBUF(p, end, 4);
> +		READ32(index);
> +		if ((index < 0) || (index >= working)) {
> +			BL_LOG_ERR("set_vol_array: Id %i out of range\n",
> +				   index);
> +			goto out_err;
> +		}
> +		array[i] = &vols[index];
> +	}
> +	*pp = p;
> +	return 0;
> + out_err:
> +	return -EIO;
> +}
> +
> +static uint64_t sum_subvolume_sizes(struct bl_volume *vol)
> +{
> +	int i;
> +	uint64_t sum = 0;
> +	for (i = 0; i < vol->bv_vol_n; i++)
> +		sum += vol->bv_vols[i]->bv_size;
> +	return sum;
> +}
> +
> +static int decode_blk_volume(uint32_t **pp, uint32_t *end,
> +			     struct bl_volume *vols, int i, int *array_cnt)
> +{
> +	int status = 0, j;
> +	struct bl_sig sig;
> +	uint32_t *p = *pp;
> +	struct bl_volume *vol = &vols[i];
> +	uint64_t tmp, tmp_size;
> +	div_t d;
> +
> +	BLK_READBUF(p, end, 4);
> +	READ32(vol->bv_type);
> +	switch (vol->bv_type) {
> +	case BLOCK_VOLUME_SIMPLE:
> +		*array_cnt = 0;
> +		status = decode_blk_signature(&p, end, &sig);
> +		if (status)
> +			return status;
> +		status = map_sig_to_device(&sig, vol);
> +		if (!status) {
> +			BL_LOG_ERR("Could not find disk for device\n");
> +			return -ENXIO;
> +		}
> +		status = 0;
> +		break;
> +	case BLOCK_VOLUME_SLICE:
> +		BLK_READBUF(p, end, 16);
> +		READ_SECTOR(vol->param.bv_offset);
> +		READ_SECTOR(vol->bv_size);
> +		*array_cnt = vol->bv_vol_n = 1;
> +		status = set_vol_array(&p, end, vols, i);
> +		break;
> +	case BLOCK_VOLUME_STRIPE:
> +		BLK_READBUF(p, end, 8);
> +		READ_SECTOR(vol->param.bv_stripe_unit);
> +		off_t chunksize = vol->param.bv_stripe_unit;
> +		if ((chunksize == 0) ||
> +		    ((chunksize & (chunksize - 1)) != 0) ||
> +		    (chunksize < (PAGE_SIZE >> 9)))
> +			return -EIO;
> +		BLK_READBUF(p, end, 4);
> +		READ32(vol->bv_vol_n);
> +		if (!vol->bv_vol_n)
> +			return -EIO;
> +		*array_cnt = vol->bv_vol_n;
> +		status = set_vol_array(&p, end, vols, i);
> +		if (status)
> +			return status;
> +		for (j = 1; j < vol->bv_vol_n; j++) {
> +			if (vol->bv_vols[j]->bv_size !=
> +			    vol->bv_vols[0]->bv_size) {
> +				BL_LOG_ERR("varying subvol size\n");
> +				return -EIO;
> +			}
> +		}
> +		/* Make sure total size only includes addressable areas */
> +		tmp_size = vol->bv_vols[0]->bv_size;
> +		d = div(tmp_size, (uint32_t) vol->param.bv_stripe_unit);
> +		tmp_size = d.quot;
> +		vol->bv_size = tmp_size * vol->param.bv_stripe_unit;
> +		break;
> +	case BLOCK_VOLUME_CONCAT:
> +		BLK_READBUF(p, end, 4);
> +		READ32(vol->bv_vol_n);
> +		if (!vol->bv_vol_n)
> +			return -EIO;
> +		*array_cnt = vol->bv_vol_n;
> +		status = set_vol_array(&p, end, vols, i);
> +		if (status)
> +			return status;
> +		vol->bv_size = sum_subvolume_sizes(vol);
> +		break;
> +	default:
> +		BL_LOG_ERR("Unknown volume type %i\n", vol->bv_type);
> + out_err:
> +		return -EIO;
> +	}
> +	*pp = p;
> +	return status;
> +}
> +
> +uint64_t process_deviceinfo(const char *dev_addr_buf,
> +			    unsigned int dev_addr_len,
> +			    uint32_t *major, uint32_t *minor)
> +{
> +	int num_vols, i, status, count;
> +	uint32_t *p, *end;
> +	struct bl_volume *vols = NULL, **arrays = NULL, **arrays_ptr = NULL;
> +	uint64_t dev = 0;
> +	int tried = 0;
> +
> + restart:
> +	p = (uint32_t *) dev_addr_buf;
> +	end = (uint32_t *) ((char *)p + dev_addr_len);
> +	/* Decode block volume */
> +	BLK_READBUF(p, end, 4);
> +	READ32(num_vols);
> +	if (num_vols <= 0) {
> +		BL_LOG_WARNING("Error: number of vols: %d\n", num_vols);
> +		goto out_err;
> +	}
> +
> +	vols = (struct bl_volume *)malloc(num_vols * sizeof(struct bl_volume));
> +	if (!vols) {
> +		BL_LOG_ERR("%s: Out of memory\n", __func__);
> +		goto out_err;
> +	}
> +
> +	/* Each volume in vols array needs its own array.  Save time by
> +	 * allocating them all in one large hunk.  Because each volume
> +	 * array can only reference previous volumes, and because once
> +	 * a concat or stripe references a volume, it may never be
> +	 * referenced again, the volume arrays are guaranteed to fit
> +	 * in the suprisingly small space allocated.
> +	 */
> +	arrays =
> +	    (struct bl_volume **)malloc(num_vols * 2 *
> +					sizeof(struct bl_volume *));
> +	if (!arrays) {
> +		BL_LOG_ERR("%s: Out of memory\n", __func__);
> +		goto out_err;
> +	}
> +
> +	arrays_ptr = arrays;
> +
> +	for (i = 0; i < num_vols; i++) {
> +		vols[i].bv_vols = arrays_ptr;
> +		status = decode_blk_volume(&p, end, vols, i, &count);
> +		if (status == -ENXIO && (tried <= 5)) {
> +			sleep(1);
> +			BL_LOG_DEBUG("%s: discover again!\n", __func__);
> +			bl_discover_devices();
> +			tried++;
> +			free(vols);
> +			free(arrays);
> +			goto restart;
> +		}
> +		if (status)
> +			goto out_err;
> +		arrays_ptr += count;
> +	}
> +
> +	if (p != end) {
> +		BL_LOG_ERR("p is not equal to end!\n");
> +		goto out_err;
> +	}
> +
> +	dev = dm_device_create(vols, num_vols);
> +	*major = MAJOR(dev);
> +	*minor = MINOR(dev);
> + out_err:
> +	if (vols)
> +		free(vols);
> +	if (arrays)
> +		free(arrays);
> +	return dev;
> +}
> diff --git a/utils/blkmapd/dm-device.c b/utils/blkmapd/dm-device.c
> new file mode 100644
> index 0000000..f08df7b
> --- /dev/null
> +++ b/utils/blkmapd/dm-device.c
> @@ -0,0 +1,509 @@
> +/*
> + * dm-device.c: create or remove device via device mapper API.
> + *
> + * Copyright (c) 2010 EMC Corporation, Haiying Tang <Tang_Haiying@emc.com>
> + * All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions
> + * are met:
> + * 1. Redistributions of source code must retain the above copyright
> + *    notice, this list of conditions and the following disclaimer.
> + * 2. Redistributions in binary form must reproduce the above copyright
> + *    notice, this list of conditions and the following disclaimer in the
> + *    documentation and/or other materials provided with the distribution.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
> + * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
> + * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
> + * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
> + * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
> + * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
> + * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + */
> +#include <libdevmapper.h>
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <string.h>
> +#include <sys/types.h>
> +#include <sys/stat.h>
> +#include <fcntl.h>
> +#include <errno.h>
> +#include <linux/kdev_t.h>
> +#include "device-discovery.h"
> +
> +#define DM_DEV_NAME_LEN		256
> +
> +#ifndef DM_MAX_TYPE_NAME
> +#define DM_MAX_TYPE_NAME	16
> +#endif
> +
> +#define DM_PARAMS_LEN		512	/*XXX: is this enough for target? */
> +#define DM_DIR			"/dev/mapper"
> +#define DM_DIR_LEN12
> +#define TYPE_HAS_DEV(type)	((type == BLOCK_VOLUME_SIMPLE) || \
> +			 (type == BLOCK_VOLUME_PSEUDO))
> +
> +struct bl_dm_table {
> +	uint64_t offset;
> +	uint64_t size;
> +	char target_type[DM_MAX_TYPE_NAME];
> +	char params[DM_PARAMS_LEN];
> +	struct bl_dm_table *next;
> +};
> +
> +struct bl_dm_tree {
> +	uint64_t dev;
> +	struct dm_tree *tree;
> +	struct bl_dm_tree *next;
> +};
> +
> +static inline struct bl_dm_table *bl_dm_table_alloc(void)
> +{
> +	return (struct bl_dm_table *)calloc(1, sizeof(struct bl_dm_table));
> +}
> +
> +void bl_dm_table_free(struct bl_dm_table *bl_table_head)
> +{
> +	struct bl_dm_table *p = bl_table_head;
> +	while (bl_table_head) {
> +		p = bl_table_head->next;
> +		free(bl_table_head);
> +		bl_table_head = p;
> +	}
> +}
> +
> +void add_to_bl_dm_table(struct bl_dm_table **bl_table_head,
> +			struct bl_dm_table *table)
> +{
> +	struct bl_dm_table *pre;
> +	if (!*bl_table_head) {
> +		*bl_table_head = table;
> +		return;
> +	}
> +	pre = *bl_table_head;
> +	while (pre->next)
> +		pre = pre->next;
> +	pre->next = table;
> +	return;
> +}
> +
> +struct bl_dm_tree *bl_tree_head;
> +
> +struct bl_dm_tree *find_bl_dm_tree(uint64_t dev)
> +{
> +	struct bl_dm_tree *p = bl_tree_head;
> +	while (p) {
> +		if (p->dev == dev)
> +			return p;
> +		p = p->next;
> +	}
> +	return NULL;
> +}
> +
> +void del_from_bl_dm_tree(uint64_t dev)
> +{
> +	struct bl_dm_tree *pre = bl_tree_head;
> +	struct bl_dm_tree *p;
> +
> +	p = pre;
> +	while (p) {
> +		if (p->dev == dev) {
> +			pre->next = p->next;
> +			if (p == bl_tree_head)
> +				bl_tree_head = bl_tree_head->next;
> +			free(p);
> +			break;
> +		}
> +		pre = p;
> +		p = pre->next;
> +	}
> +}
> +
> +void add_to_bl_dm_tree(struct bl_dm_tree *tree)
> +{
> +	struct bl_dm_tree *pre;
> +	if (!bl_tree_head) {
> +		bl_tree_head = tree;
> +		return;
> +	}
> +	pre = bl_tree_head;
> +	while (pre->next)
> +		pre = pre->next;
> +	pre->next = tree;
> +	return;
> +}
> +
> +/* Create device via device mapper
> + * return 0 when creation failed
> + * return dev no for created device
> + */
> +uint64_t dm_single_device_create(const char *dev_name, struct bl_dm_table * p)
> +{
> +	struct dm_task *dmt;
> +	struct dm_info dminfo;
> +	int ret = 0;
> +
> +	dmt = dm_task_create(DM_DEVICE_CREATE);
> +	if (!dmt) {
> +		BL_LOG_ERR("Create dm_task for %s failed\n", dev_name);
> +		return 0;
> +	}
> +	ret = dm_task_set_name(dmt, dev_name);
> +	if (!ret)
> +		goto err_out;
> +
> +	while (p) {
> +		ret = dm_task_add_target(dmt, p->offset, p->size,
> +					 p->target_type, p->params);
> +		if (!ret)
> +			goto err_out;
> +		p = p->next;
> +	}
> +
> +	ret = dm_task_run(dmt) &&
> +	    dm_task_get_info(dmt, &dminfo) && dminfo.exists;
> +
> +	if (!ret)
> +		goto err_out;
> +
> +	dm_task_update_nodes();
> +
> + err_out:
> +	dm_task_destroy(dmt);
> +
> +	if (!ret) {
> +		BL_LOG_ERR("Create device %s failed\n", dev_name);
> +		return 0;
> +	}
> +	return MKDEV(dminfo.major, dminfo.minor);
> +}
> +
> +int dm_device_remove_byname(const char *dev_name)
> +{
> +	struct dm_task *dmt;
> +	int ret = 0;
> +
> +	dmt = dm_task_create(DM_DEVICE_REMOVE);
> +	if (!dmt)
> +		return -ENODEV;
> +
> +	ret = dm_task_set_name(dmt, dev_name) && dm_task_run(dmt);
> +
> +	dm_task_update_nodes();
> +
> +	if (dmt)
> +		dm_task_destroy(dmt);
> +
> +	return ret;
> +}
> +
> +int dm_device_remove(uint64_t dev)
> +{
> +	struct dm_task *dmt;
> +	struct dm_names *dmnames;
> +	char *names = NULL;
> +	int ret = -1;
> +
> +	/* Look for dev_name via dev, if dev_name could be transferred here,
> +	   we could jump to DM_DEVICE_REMOVE directly */
> +	dmt = dm_task_create(DM_DEVICE_LIST);
> +	if (!dmt) {
> +		BL_LOG_ERR("dm_task creation failed\n");
> +		return -ENODEV;
> +	}
> +
> +	ret = dm_task_run(dmt);
> +	if (!ret) {
> +		BL_LOG_ERR("dm_task_run failed\n");
> +		goto error;
> +	}
> +
> +	dmnames = dm_task_get_names(dmt);
> +	if (!dmnames || !dmnames->dev) {
> +		BL_LOG_ERR("dm_task_get_names failed\n");
> +		goto error;
> +	}
> +
> +	do {
> +		if (dmnames->dev == dev) {
> +			names = dmnames->name;
> +			break;
> +		}
> +		dmnames = (void *)dmnames + dmnames->next;
> +	} while (dmnames);
> +
> +	if (!names) {
> +		BL_LOG_ERR("Could not find device\n");
> +		goto error;
> +	}
> +
> +	dm_task_update_nodes();
> +
> + error:
> +	dm_task_destroy(dmt);
> +
> +	/*Start to remove device */
> +	if (names)
> +		ret = dm_device_remove_byname(names);
> +	return ret;
> +}
> +
> +static unsigned long dev_count;
> +
> +void dm_devicelist_remove(unsigned long start, unsigned long end)
> +{
> +	char dev_name[DM_DEV_NAME_LEN];
> +	unsigned long count;
> +
> +	if ((start >= dev_count) || (end <= 1) || (start >= end - 1))
> +		return;
> +
> +	for (count = end - 1; count > start; count--) {
> +		sprintf(dev_name, "pnfs_vol_%lu", count - 1);
> +		dm_device_remove_byname(dev_name);
> +	}
> +
> +	return;
> +}
> +
> +void bl_dm_remove_tree(uint64_t dev)
> +{
> +	struct bl_dm_tree *p;
> +
> +	p = find_bl_dm_tree(dev);
> +	if (!p)
> +		return;
> +
> +	dm_tree_free(p->tree);
> +	del_from_bl_dm_tree(dev);
> +}
> +
> +void bl_dm_create_tree(uint64_t dev)
> +{
> +	struct dm_tree *tree;
> +	struct bl_dm_tree *bl_tree;
> +
> +	bl_tree = find_bl_dm_tree(dev);
> +	if (bl_tree)
> +		return;		/*XXX: error? */
> +
> +	tree = dm_tree_create();
> +	if (!tree)
> +		return;
> +
> +	if (!dm_tree_add_dev(tree, MAJOR(dev), MINOR(dev))) {
> +		dm_tree_free(tree);
> +		return;
> +	}
> +
> +	bl_tree = malloc(sizeof(struct bl_dm_tree));
> +	if (!bl_tree) {
> +		dm_tree_free(tree);
> +		return;
> +	}
> +
> +	bl_tree->dev = dev;
> +	bl_tree->tree = tree;
> +	bl_tree->next = NULL;
> +	add_to_bl_dm_tree(bl_tree);
> +
> +	return;
> +}
> +
> +uint64_t dm_device_nametodev(char *dev_name)
> +{
> +	struct dm_task *dmt;
> +	int ret = 0;
> +	struct dm_info dminfo;
> +
> +	dmt = dm_task_create(DM_DEVICE_INFO);
> +	if (!dmt)
> +		return -ENODEV;
> +
> +	ret = dm_task_set_name(dmt, dev_name) &&
> +	    dm_task_run(dmt) && dm_task_get_info(dmt, &dminfo);
> +
> +	if (dmt)
> +		dm_task_destroy(dmt);
> +
> +	if (!ret)
> +		return 0;
> +
> +	return MKDEV(dminfo.major, dminfo.minor);
> +}
> +
> +int dm_device_remove_all(uint64_t *dev)
> +{
> +	struct bl_dm_tree *p;
> +	struct dm_tree_node *node;
> +	const char *uuid;
> +	int ret = 0;
> +	uint32_t major, minor;
> +	uint64_t bl_dev;
> +
> +	memcpy(&major, dev, sizeof(uint32_t));
> +	memcpy(&minor, (void *)dev + sizeof(uint32_t), sizeof(uint32_t));
> +	bl_dev = MKDEV(major, minor);
> +	p = find_bl_dm_tree(bl_dev);
> +	if (!p)
> +		return ret;
> +
> +	node = dm_tree_find_node(p->tree, MAJOR(bl_dev), MINOR(bl_dev));
> +	if (!node)
> +		return ret;
> +
> +	uuid = dm_tree_node_get_uuid(node);
> +	if (!uuid)
> +		return ret;
> +
> +	dm_device_remove(bl_dev);
> +	ret = dm_tree_deactivate_children(node, uuid, strlen(uuid));
> +	dm_task_update_nodes();
> +	bl_dm_remove_tree(bl_dev);
> +	return ret;
> +}
> +
> +/* TODO: check the value for DM_DEV_NAME_LEN, DM_TYPE_LEN, DM_PARAMS_LEN */
> +uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
> +{
> +	uint64_t size, dev = 0;
> +	unsigned long count = dev_count;
> +	int number = 0, i, pos;
> +	struct bl_volume *node;
> +	char *tmp;
> +	struct bl_dm_table *table = NULL;
> +	struct bl_dm_table *bl_table_head = NULL;
> +	unsigned int len;
> +	char *dev_name = NULL;
> +	/* Create pseudo device here */
> +	while (number < num_vols) {
> +		node = &vols[number];
> +		switch (node->bv_type) {
> +		case BLOCK_VOLUME_SIMPLE:
> +			/* Do not need to create device here */
> +			dev = node->param.bv_dev;
> +			goto continued;
> +		case BLOCK_VOLUME_SLICE:
> +			table = bl_dm_table_alloc();
> +			if (!table)
> +				goto out;
> +			table->offset = 0;
> +			table->size = node->bv_size;
> +			strcpy(table->target_type, "linear");
> +			if (!TYPE_HAS_DEV(node->bv_vols[0]->bv_type)) {
> +				free(table);
> +				goto out;
> +			}
> +			dev = node->bv_vols[0]->param.bv_dev;
> +			tmp = table->params;
> +			if (!dm_format_dev(tmp, DM_PARAMS_LEN,
> +					   MAJOR(dev), MINOR(dev))) {
> +				free(table);
> +				goto out;
> +			}
> +			tmp += strlen(tmp);
> +			sprintf(tmp, " %lu", node->param.bv_offset);
> +			add_to_bl_dm_table(&bl_table_head, table);
> +			break;
> +		case BLOCK_VOLUME_STRIPE:
> +			table = bl_dm_table_alloc();
> +			if (!table)
> +				goto out;
> +			table->offset = 0;
> +			table->size = node->bv_size;
> +			strcpy(table->target_type, "striped");
> +			sprintf(table->params, "%d %lu %n", node->bv_vol_n,
> +				node->param.bv_stripe_unit, &pos);
> +			/* Repeatedly copy subdev to params */
> +			tmp = table->params + pos;
> +			len = DM_PARAMS_LEN - pos;
> +			for (i = 0; i < node->bv_vol_n; i++) {
> +				if (!TYPE_HAS_DEV(node->bv_vols[i]->bv_type)) {
> +					free(table);
> +					goto out;
> +				}
> +				dev = node->bv_vols[i]->param.bv_dev;
> +				if (!dm_format_dev(tmp, len, MAJOR(dev),
> +						   MINOR(dev))) {
> +					free(table);
> +					goto out;
> +				}
> +				pos = strlen(tmp);
> +				tmp += pos;
> +				len -= pos;
> +				sprintf(tmp, " %d ", 0);
> +				tmp += 3;
> +				len -= 3;
> +			}
> +			add_to_bl_dm_table(&bl_table_head, table);
> +			break;
> +		case BLOCK_VOLUME_CONCAT:
> +			size = 0;
> +			for (i = 0; i < node->bv_vol_n; i++) {
> +				table = bl_dm_table_alloc();
> +				if (!table)
> +					goto out;
> +				table->offset = size;
> +				table->size = node->bv_vols[i]->bv_size;
> +				if (!TYPE_HAS_DEV(node->bv_vols[i]->bv_type)) {
> +					free(table);
> +					goto out;
> +				}
> +				strcpy(table->target_type, "linear");
> +				tmp = table->params;
> +				dev = node->bv_vols[i]->param.bv_dev;
> +				if (!dm_format_dev(tmp, DM_PARAMS_LEN,
> +						   MAJOR(dev), MINOR(dev))) {
> +					free(table);
> +					goto out;
> +				}
> +				tmp += strlen(tmp);
> +				sprintf(tmp, " %d", 0);
> +				size += table->size;
> +				add_to_bl_dm_table(&bl_table_head, table);
> +			}
> +			break;
> +		default:
> +			/* Delete previous temporary devices */
> +			dm_devicelist_remove(count, dev_count);
> +			goto out;
> +		}		/*end of swtich */
> +		/* Create dev_name here. Name of device is pnfs_vol_XXX */
> +		if (dev_name)
> +			free(dev_name);
> +		dev_name = (char *)calloc(DM_DEV_NAME_LEN, sizeof(char));
> +		if (!dev_name) {
> +			BL_LOG_ERR("%s: Out of memory\n", __func__);
> +			goto out;
> +		}
> +		sprintf(dev_name, "pnfs_vol_%lu", dev_count++);
> +
> +		dev = dm_single_device_create(dev_name, bl_table_head);
> +		if (!dev) {
> +			/* Delete previous temporary devices */
> +			dm_devicelist_remove(count, dev_count);
> +			goto out;
> +		}
> +		node->param.bv_dev = dev;
> +		/*TODO: extend use with PSEUDO later */
> +		node->bv_type = BLOCK_VOLUME_PSEUDO;
> + continued:
> +		number++;
> +		if (bl_table_head)
> +			bl_dm_table_free(bl_table_head);
> +		bl_table_head = NULL;
> +	}
> + out:
> +	if (bl_table_head)
> +		bl_dm_table_free(bl_table_head);
> +	bl_table_head = NULL;
> +	if (dev)
> +		bl_dm_create_tree(dev);
> +	if (dev_name)
> +		free(dev_name);
> +	return dev;
> +}
> diff --git a/utils/blkmapd/etc/initd/initd.redhat b/utils/blkmapd/etc/initd/initd.redhat
> new file mode 100644
> index 0000000..a52250c
> --- /dev/null
> +++ b/utils/blkmapd/etc/initd/initd.redhat
> @@ -0,0 +1,76 @@
> +#!/bin/sh
> +#
> +# description: Starts and stops the iSCSI initiator
> +#
> +# processname: pnfsi-block
> +# pidfile: /var/run/pnfs-block.pid
> +# config:  /etc/pnfs-block.conf
> +
> +# Source function library.
> +if [ -f /etc/init.d/functions ] ; then
> +	. /etc/init.d/functions
> +elif [ -f /etc/rc.d/init.d/functions ] ; then
> +	. /etc/rc.d/init.d/functions
> +else
> +	exit 0
> +fi
> +
> +PATH=/sbin:/bin:/usr/sbin:/usr/bin
> +
> +RETVAL=0
> +
> +start()
> +{
> +	echo -n $"Starting pNFS block-layout device discovery service: "
> +	modprobe -q blocklayoutdriver
> +	daemon /usr/sbin/bl-device
> +	RETVAL=$?
> +	if [ $RETVAL -eq 0 ]; then
> +		touch /var/lock/subsys/pnfs-block
> +	fi
> +	echo
> +	return $RETVAL
> +}
> +
> +stop()
> +{
> +	echo -n $"Stopping pNFS block-layout device discovery service: "
> +	killproc bl-device 2> /dev/null
> +	rm -f /var/run/pnfs-block.pid
> +	RETVAL=$?
> +	[ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/pnfs-block
> +	if [ $RETVAL -eq 0 ]; then
> +                echo_success
> +        else
> +                echo_failure
> +        fi
> +	echo
> +	return $RETVAL
> +}
> +
> +restart()
> +{
> +	stop
> +	start
> +}
> +
> +case "$1" in
> +	start)
> +		start
> +		;;
> +	stop)
> +		stop
> +		;;
> +	restart)
> +		stop
> +		start
> +		;;
> +	status)
> +		status pnfs-block
> +		;;
> +	*)
> +	echo $"Usage: $0 {start|stop|restart|status}"
> +	exit 1
> +esac
> +
> +exit $RETVAL
> diff --git a/utils/blkmapd/etc/pnfs-block.conf b/utils/blkmapd/etc/pnfs-block.conf
> new file mode 100644
> index 0000000..da70d94
> --- /dev/null
> +++ b/utils/blkmapd/etc/pnfs-block.conf
> @@ -0,0 +1,10 @@
> +# This is an example config file
> +
> +# Look at all /dev/sd* devices
> +# /dev/sd or /dev/sd*
> +/dev/sd*
> +
> +# Look at all /dev/mapper/* devices
> +# /dev/mapper/* or
> +# /dev/mapper/
> +/dev/mapper/*
