From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Patch 6/10] NFS Mount Configuration File (Vers 3)
Date: Thu, 6 Aug 2009 16:44:41 -0400
Message-ID: <95B06B96-FCFB-49FA-ACA6-3E336DB5BE33@oracle.com>
References: <4A7B2324.9090406@RedHat.com> <4A7B24D0.1060209@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A7B24D0.1060209@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 6, 2009, at 2:45 PM, Steve Dickson wrote:

> commit 8e88dd908d8b5ff07649c375ff638ee6ca964ead
> Author: Steve Dickson <steved@redhat.com>
> Date:   Wed Aug 5 16:17:38 2009 -0400
>
>    Support routines used to read sections from the configuration file
>    and parse them into comma separated mount options.
>
>    Signed-off-by: Steve Dickson <steved@redhat.com>
>
> diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
> index 459fa45..a1b56ca 100644
> --- a/utils/mount/Makefile.am
> +++ b/utils/mount/Makefile.am
> @@ -17,6 +17,10 @@ mount_nfs_SOURCES = mount.c error.c network.c  
> fstab.c token.c \
> 		    parse_opt.h parse_dev.h \
> 		    nfs4_mount.h nfs_mount4.h stropts.h version.h
>
> +if MOUNT_CONFIG
> +mount_nfs_SOURCES += configfile.c
> +endif
> +
> mount_nfs_LDADD = ../../support/nfs/libnfs.a \
> 		  ../../support/export/libexport.a
>
> diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
> new file mode 100644
> index 0000000..cad8c52
> --- /dev/null
> +++ b/utils/mount/configfile.c
> @@ -0,0 +1,317 @@
> +/*
> + * configfile.c -- mount configuration file manipulation
> + * Copyright (C) 2008 Red Hat, Inc <nfs@redhat.com>
> + *
> + * - Routines use to create mount options from the mount
> + *   configuration file.
> + *
> + * This program is free software; you can redistribute it and/or  
> modify
> + * it under the terms of the GNU General Public License as  
> published by
> + * the Free Software Foundation; either version 2, or (at your  
> option)
> + * any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + */
> +#ifdef HAVE_CONFIG_H
> +#include <config.h>
> +#endif
> +#include <sys/types.h>
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <string.h>
> +#include <ctype.h>
> +
> +#include "xlog.h"
> +#include "conffile.h"
> +
> +#define KBYTES(x)     ((x) * (1024))
> +#define MEGABYTES(x)  ((x) * (1048576))
> +#define GIGABYTES(x)  ((x) * (1073741824))
> +
> +#ifndef NFSMOUNT_GLOBAL_OPTS
> +#define NFSMOUNT_GLOBAL_OPTS "NFSMount_Global_Options"
> +#endif
> +
> +#ifndef NFSMOUNT_MOUNTPOINT  "MountPoint"
> +#define NFSMOUNT_MOUNTPOINT "MountPoint"
> +#endif
> +
> +#ifndef NFSMOUNT_SERVER "Server"
> +#define NFSMOUNT_SERVER "Server"
> +#endif
> +
> +#ifndef MOUNTOPTS_CONFFILE
> +#define MOUNTOPTS_CONFFILE "/etc/nfsmount.conf"
> +#endif
> +char *conf_path = MOUNTOPTS_CONFFILE;
> +enum {
> +	MNT_NOARG=0,
> +	MNT_INTARG,
> +	MNT_STRARG,
> +	MNT_SPEC,
> +	MNT_UNSET
> +};
> +struct mnt_alias {
> +	char *alias;
> +	char *opt;
> +	int  argtype;
> +} mnt_alias_tab[] = {
> +	{"background", "bg", MNT_NOARG},
> +	{"foreground", "fg", MNT_NOARG},
> +	{"sloppy", "sloppy", MNT_NOARG},
> +};
> +int mnt_alias_sz = (sizeof(mnt_alias_tab)/sizeof(mnt_alias_tab[0]));
> +
> +/*
> + * See if the option is an alias, if so return the
> + * real mount option along with the argument type.
> + */
> +inline static
> +char *mountopts_alias(char *opt, int *argtype)
> +{
> +	int i;
> +
> +	*argtype = MNT_UNSET;
> +	for (i=0; i < mnt_alias_sz; i++) {
> +		if (strcasecmp(opt, mnt_alias_tab[i].alias) != 0)
> +			continue;
> +		*argtype = mnt_alias_tab[i].argtype;
> +		return mnt_alias_tab[i].opt;
> +	}
> +	return opt;
> +}
> +/*
> + * Convert numeric strings that end with 'k', 'm' or 'g'
> + * into numeric strings with the real value.
> + * Meaning '8k' becomes '8094'.
> + */
> +char *mountopts_convert(char *value)
> +{
> +	unsigned long long factor, num;
> +	static char buf[64];
> +	char *ch;
> +
> +	ch = &value[strlen(value)-1];
> +	switch (tolower(*ch)) {
> +	case 'k':
> +		factor = KBYTES(1);
> +		break;
> +	case 'm':
> +		factor = MEGABYTES(1);
> +		break;
> +	case 'g':
> +		factor = GIGABYTES(1);
> +		break;
> +	default:
> +		return value;
> +	}
> +	*ch = '\0';
> +	if (strncmp(value, "0x", 2) == 0) {
> +		num = strtol(value, (char **)NULL, 16);
> +	} else if (strncmp(value, "0", 1) == 0) {
> +		num = strtol(value, (char **)NULL, 8);
> +	} else {
> +		num = strtol(value, (char **)NULL, 10);
> +	}
> +	num *= factor;
> +	snprintf(buf, 64, "%lld", num);
> +
> +	return buf;
> +}
> +
> +struct entry {
> +	SLIST_ENTRY(entry) entries;
> +	char *opt;
> +};
> +static SLIST_HEAD(shead, entry) head = SLIST_HEAD_INITIALIZER(head);
> +static int list_size;
> +
> +/*
> + * Add option to the link list
> + */
> +inline static void
> +add_entry(char *opt)
> +{
> +	struct entry *entry;
> +
> +	entry = calloc(1, sizeof(struct entry));
> +	if (entry == NULL) {
> +		xlog_warn("Unable calloc memory for mount configs");
> +		return;
> +	}
> +	entry->opt = strdup(opt);
> +	if (entry->opt == NULL) {
> +		xlog_warn("Unable calloc memory for mount opts");
> +		free(entry);
> +		return;
> +	}
> +	SLIST_INSERT_HEAD(&head, entry, entries);
> +}
> +/*
> + * See if the given entry exists if the link list,
> + * if so return that entry
> + */
> +inline static
> +char *lookup_entry(char *opt)
> +{
> +	struct entry *entry;
> +
> +	SLIST_FOREACH(entry, &head, entries) {
> +		if (strcasecmp(entry->opt, opt) == 0)
> +			return opt;
> +	}
> +	return NULL;
> +}
> +/*
> + * Free all entries on the link list
> + */
> +inline static
> +void free_all(void)
> +{
> +	struct entry *entry;
> +
> +	while (!SLIST_EMPTY(&head)) {
> +		entry = SLIST_FIRST(&head);
> +		SLIST_REMOVE_HEAD(&head, entries);
> +		free(entry->opt);
> +		free(entry);
> +	}
> +}
> +/*
> + * Parse the given section of the configuration
> + * file to if there are any mount options set.
> + * If so, added them to link list.
> + */
> +static void
> +conf_parse_mntopts(char *section, char *arg, char *opts)
> +{
> +	struct conf_list *list;
> +	struct conf_list_node *node;
> +	char buf[BUFSIZ], *value, *field;
> +	char *nvalue, *ptr;
> +	int argtype;
> +
> +	list = conf_get_tag_list(section);
> +	TAILQ_FOREACH(node, &list->fields, link) {
> +		/*
> +		 * Do not overwrite options if already exists
> +		 */
> +		snprintf(buf, BUFSIZ, "%s=", node->field);
> +		if (opts && strstr(opts, buf) != NULL)
> +			continue;
> +		if (lookup_entry(node->field) != NULL)
> +			continue;
> +		buf[0] = '\0';
> +		value = conf_get_section(section, arg, node->field);
> +		if (value == NULL)
> +			continue;
> +		field = mountopts_alias(node->field, &argtype);
> +		if (strcasecmp(value, "false") == 0) {
> +			if (argtype != MNT_NOARG)
> +				snprintf(buf, BUFSIZ, "no%s", field);
> +		} else if (strcasecmp(value, "true") == 0) {
> +			snprintf(buf, BUFSIZ, "%s", field);
> +		} else {
> +			nvalue = strdup(value);
> +			ptr = mountopts_convert(nvalue);
> +			snprintf(buf, BUFSIZ, "%s=%s", field, ptr);
> +			free(nvalue);
> +		}
> +		if (buf[0] == '\0')
> +			continue;
> +		/*
> +		 * Keep a running tally of the list size adding
> +		 * one for the ',' that will be appened later
> +		 */
> +		list_size += strlen(buf) + 1;
> +		add_entry(buf);
> +	}
> +	conf_free_list(list);
> +}
> +
> +/*
> + * Concatenate options from the configuration file with the
> + * given options by building a link list of options from the
> + * different sections in the conf file. Options that exists
> + * in the either the given options or link list are not
> + * overwritten so it matter which when each section is
> + * parsed.
> + */
> +char *conf_get_mntopts(char *spec, char *mount_point,
> +	char *mount_opts)
> +{
> +	struct entry *entry;
> +	char *ptr, *server, *config_opts;
> +	int optlen = 0;
> +
> +	SLIST_INIT(&head);
> +	list_size = 0;
> +	/*
> +	 * First see if there are any mount options relative
> +	 * to the mount point.
> +	 */
> +	conf_parse_mntopts(NFSMOUNT_MOUNTPOINT, mount_point, mount_opts);
> +
> +	/*
> +	 * Next, see if there are any mount options relative
> +	 * to the server
> +	 */
> +	server = strdup(spec);
> +	if (server == NULL) {
> +		xlog_warn("conf_get_mountops: Unable calloc memory for server");
> +		free_all();
> +		return mount_opts;
> +	}
> +	if ((ptr = strchr(server, ':')) != NULL)
> +		*ptr='\0';
> +	conf_parse_mntopts(NFSMOUNT_SERVER, server, mount_opts);
> +	free(server);
> +
> +	/*
> +	 * Finally process all the global mount options.
> +	 */
> +	conf_parse_mntopts(NFSMOUNT_GLOBAL_OPTS, NULL, mount_opts);
> +
> +	/*
> +	 * If no mount options were found in the configuration file
> +	 * just return what was passed in .
> +	 */
> +	if (SLIST_EMPTY(&head))
> +		return mount_opts;
> +
> +	/*
> +	 * Found options in the configuration file. So
> +	 * concatenate the configuration options with the
> +	 * options that were passed in
> +	 */
> +	if (mount_opts)
> +		optlen = strlen(mount_opts);
> +
> +	/* list_size + optlen + ',' + '\0' */
> +	config_opts = calloc(1, (list_size+optlen+2));
> +	if (server == NULL) {
> +		xlog_warn("conf_get_mountops: Unable calloc memory for  
> config_opts");
> +		free_all();
> +		return mount_opts;
> +	}
> +	if (mount_opts) {
> +		strcpy(config_opts, mount_opts);
> +		strcat(config_opts, ",");
> +	}
> +	SLIST_FOREACH(entry, &head, entries) {
> +		strcat(config_opts, entry->opt);
> +		strcat(config_opts, ",");
> +	}
> +	*(strrchr(config_opts, ',')) = '\0';
> +
> +	free_all();
> +	if (mount_opts)
> +		free(mount_opts);
> +
> +	return config_opts;
> +}

Seems to me the text-based mount option parser routines (parse_opt. 
[ch]) already does a lot of this.  It can break up a string into a  
linked list of options, handle quoted commas properly, catenate  
options to the list, and flatten the list back into a C string.

Wouldn't it be easier to adapt that code rather than adding new code  
that does nearly the same thing?  It would save you a lot of C string  
manipulation, and reuse working code.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
