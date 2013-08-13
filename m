Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:51810 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757516Ab3HMTcd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Aug 2013 15:32:33 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [nfs-utils PATCH 3/4] mount.nfs:  improve handling of MNT_NOARG type options
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1376421629-21382-4-git-send-email-smayhew@redhat.com>
Date: Tue, 13 Aug 2013 15:32:25 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <9C8AB6BD-D33B-4708-B8A8-C5420101BA26@oracle.com>
References: <1376421629-21382-1-git-send-email-smayhew@redhat.com> <1376421629-21382-4-git-send-email-smayhew@redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Scott-

On Aug 13, 2013, at 3:20 PM, Scott Mayhew <smayhew@redhat.com> wrote:

> conf_parse_mntopts() maintains a linked list of options that will
> ultimately be passed in the data field of the mount() syscall in order
> to avoid unnecessary duplicates and/or conflicts.  This doesn't work
> very well for MNT_NOARG type options, since setting any of these to
> false in the nfsmount.conf doesn't correspond to any 'real' mount option
> (i.e. there are no such options 'nobg', 'nofg', and 'nosloppy').

What's broken here, exactly?

> 
> This patch adds a set of internal variables for the three real MNT_NOARG
> options (bg, fg, sloppy) along with their pseudo options (nobg, nofg,
> nosloppy), and a helper function to track which of these options has
> been previously seen and to determine whether or not to append an option
> to the linked list.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
> utils/mount/configfile.c | 50 ++++++++++++++++++++++++++++++++++++++++++++++++
> 1 file changed, 50 insertions(+)
> 
> diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
> index 221436f..623c886 100644
> --- a/utils/mount/configfile.c
> +++ b/utils/mount/configfile.c
> @@ -73,6 +73,8 @@ struct mnt_alias {
> };
> int mnt_alias_sz = (sizeof(mnt_alias_tab)/sizeof(mnt_alias_tab[0]));
> 
> +static int bg, nobg, fg, nofg, sloppy, nosloppy;
> +
> /*
>  * See if the option is an alias, if so return the 
>  * real mount option along with the argument type.
> @@ -278,6 +280,46 @@ default_value(char *mopt)
> 
> 	return 1;
> }
> +
> +int
> +should_add_noarg_opt(char *opt, char *val)
> +{
> +	int ret = 0;
> +
> +	if (strcasecmp(opt, "bg") == 0) {
> +		if (strcasecmp(val, "true") == 0) {
> +			if (bg == 0 && nobg == 0 && fg == 0) {
> +				bg = 1;
> +				ret = 1;
> +			}
> +		} else if (strcasecmp(val, "false") == 0) {
> +			if (bg == 0 && nobg == 0)
> +				nobg = 1;
> +		}
> +	} else if (strcasecmp(opt, "fg") == 0) {
> +		if (strcasecmp(val, "true") == 0) {
> +			if (fg == 0 && nofg == 0 && bg == 0) {
> +				fg = 1;
> +				ret = 1;
> +			}
> +		} else if (strcasecmp(val, "false") == 0) {
> +			if (fg == 0 && nofg == 0)
> +				nofg = 1;
> +		}
> +	} else if (strcasecmp(opt, "sloppy") == 0) {
> +		if (sloppy == 0 && nosloppy == 0) {
> +			if(strcasecmp(val, "true") == 0) {
> +				sloppy = 1;
> +				ret = 1;
> +			} else
> +				nosloppy = 1;
> +		}
> +	} else
> +		xlog_warn("Invalid MNT_NOARG option: '%s'", opt);
> +
> +	return ret;
> +}
> +
> /*
>  * Parse the given section of the configuration 
>  * file to if there are any mount options set.
> @@ -315,6 +357,13 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
> 		field = mountopts_alias(node->field, &argtype);
> 		if (lookup_entry(field) != NULL)
> 			continue;
> +		if (argtype == MNT_NOARG) {
> +			if (should_add_noarg_opt(field, value)) {
> +				list_size += strlen(field) + 1;
> +				add_entry(field);
> +			}
> +			continue;
> +		}
> 		if (argtype != MNT_NOARG) {
> 			snprintf(buf, BUFSIZ, "no%s", field);
> 			if (lookup_entry(buf) != NULL)
> @@ -359,6 +408,7 @@ char *conf_get_mntopts(char *spec, char *mount_point,
> 	char *ptr, *server, *config_opts;
> 	int optlen = 0;
> 
> +	bg = nobg = fg = nofg = sloppy = nosloppy = 0;
> 	SLIST_INIT(&head);
> 	list_size = 0;
> 	/*
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




