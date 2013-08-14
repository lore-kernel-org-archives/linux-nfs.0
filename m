Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:44999 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758878Ab3HNBqa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Aug 2013 21:46:30 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [nfs-utils PATCH 3/4] mount.nfs:  improve handling of MNT_NOARG type options
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130813224548.GB2514@tonberry.usersys.redhat.com>
Date: Tue, 13 Aug 2013 21:46:24 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <F4717878-CF49-471C-8A8E-9F61DA37ADB0@oracle.com>
References: <1376421629-21382-1-git-send-email-smayhew@redhat.com> <1376421629-21382-4-git-send-email-smayhew@redhat.com> <9C8AB6BD-D33B-4708-B8A8-C5420101BA26@oracle.com> <20130813224548.GB2514@tonberry.usersys.redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 13, 2013, at 6:45 PM, Scott Mayhew <smayhew@redhat.com> wrote:

> On Tue, 13 Aug 2013, Chuck Lever wrote:
> 
>> Hi Scott-
>> 
>> On Aug 13, 2013, at 3:20 PM, Scott Mayhew <smayhew@redhat.com> wrote:
>> 
>>> conf_parse_mntopts() maintains a linked list of options that will
>>> ultimately be passed in the data field of the mount() syscall in order
>>> to avoid unnecessary duplicates and/or conflicts.  This doesn't work
>>> very well for MNT_NOARG type options, since setting any of these to
>>> false in the nfsmount.conf doesn't correspond to any 'real' mount option
>>> (i.e. there are no such options 'nobg', 'nofg', and 'nosloppy').
>> 
>> What's broken here, exactly?
> 
> The problem here is that specifying something like bg=false, fg=false, or 
> sloppy=false doesn't perform any negation if those options appeared
> somewhere in an earlier section.  Take for example a simple config that 
> ooks like this:
> 
> [ NFSMount_Global_Options ]
>        Nfsvers=4
> 
> [ Server "nfs.smayhew.test" ]
>        Background=True
> 
> [ MountPoint "/mnt" ]
>        Background=False
> 
> If I try to perform a mount using that server and mountpoint, and the
> server happens to be unresponsive, then what should happen is that the
> mount should time out after 2 minutes.  What actually happens is that
> we'll keep retrying for 10000 minutes.

"bg" and "fg" negate each other.  "Background=True" should mean "bg" and "Background=False" should mean "fg."

"sloppy" is another matter… It was originally not a mount option, but a command line option on the mount.nfs command.  When mount option parsing was moved into the kernel, we had to make "sloppy" a real mount option.

It probably requires the approach you took.  However, that means that the mount command line cannot negate "sloppy" set in the config file.


> -Scott
>> 
>>> 
>>> This patch adds a set of internal variables for the three real MNT_NOARG
>>> options (bg, fg, sloppy) along with their pseudo options (nobg, nofg,
>>> nosloppy), and a helper function to track which of these options has
>>> been previously seen and to determine whether or not to append an option
>>> to the linked list.
>>> 
>>> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
>>> ---
>>> utils/mount/configfile.c | 50 ++++++++++++++++++++++++++++++++++++++++++++++++
>>> 1 file changed, 50 insertions(+)
>>> 
>>> diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
>>> index 221436f..623c886 100644
>>> --- a/utils/mount/configfile.c
>>> +++ b/utils/mount/configfile.c
>>> @@ -73,6 +73,8 @@ struct mnt_alias {
>>> };
>>> int mnt_alias_sz = (sizeof(mnt_alias_tab)/sizeof(mnt_alias_tab[0]));
>>> 
>>> +static int bg, nobg, fg, nofg, sloppy, nosloppy;
>>> +
>>> /*
>>> * See if the option is an alias, if so return the 
>>> * real mount option along with the argument type.
>>> @@ -278,6 +280,46 @@ default_value(char *mopt)
>>> 
>>> 	return 1;
>>> }
>>> +
>>> +int
>>> +should_add_noarg_opt(char *opt, char *val)
>>> +{
>>> +	int ret = 0;
>>> +
>>> +	if (strcasecmp(opt, "bg") == 0) {
>>> +		if (strcasecmp(val, "true") == 0) {
>>> +			if (bg == 0 && nobg == 0 && fg == 0) {
>>> +				bg = 1;
>>> +				ret = 1;
>>> +			}
>>> +		} else if (strcasecmp(val, "false") == 0) {
>>> +			if (bg == 0 && nobg == 0)
>>> +				nobg = 1;
>>> +		}
>>> +	} else if (strcasecmp(opt, "fg") == 0) {
>>> +		if (strcasecmp(val, "true") == 0) {
>>> +			if (fg == 0 && nofg == 0 && bg == 0) {
>>> +				fg = 1;
>>> +				ret = 1;
>>> +			}
>>> +		} else if (strcasecmp(val, "false") == 0) {
>>> +			if (fg == 0 && nofg == 0)
>>> +				nofg = 1;
>>> +		}
>>> +	} else if (strcasecmp(opt, "sloppy") == 0) {
>>> +		if (sloppy == 0 && nosloppy == 0) {
>>> +			if(strcasecmp(val, "true") == 0) {
>>> +				sloppy = 1;
>>> +				ret = 1;
>>> +			} else
>>> +				nosloppy = 1;
>>> +		}
>>> +	} else
>>> +		xlog_warn("Invalid MNT_NOARG option: '%s'", opt);
>>> +
>>> +	return ret;
>>> +}
>>> +
>>> /*
>>> * Parse the given section of the configuration 
>>> * file to if there are any mount options set.
>>> @@ -315,6 +357,13 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
>>> 		field = mountopts_alias(node->field, &argtype);
>>> 		if (lookup_entry(field) != NULL)
>>> 			continue;
>>> +		if (argtype == MNT_NOARG) {
>>> +			if (should_add_noarg_opt(field, value)) {
>>> +				list_size += strlen(field) + 1;
>>> +				add_entry(field);
>>> +			}
>>> +			continue;
>>> +		}
>>> 		if (argtype != MNT_NOARG) {
>>> 			snprintf(buf, BUFSIZ, "no%s", field);
>>> 			if (lookup_entry(buf) != NULL)
>>> @@ -359,6 +408,7 @@ char *conf_get_mntopts(char *spec, char *mount_point,
>>> 	char *ptr, *server, *config_opts;
>>> 	int optlen = 0;
>>> 
>>> +	bg = nobg = fg = nofg = sloppy = nosloppy = 0;
>>> 	SLIST_INIT(&head);
>>> 	list_size = 0;
>>> 	/*
>>> -- 
>>> 1.7.11.7
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> -- 
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> 
>> 
>> 
>> 
> 
> -- 
> Scott Mayhew, RHCE
> Software Maintenance Engineer
> Red Hat Global Support Services
> smayhew@redhat.com
> 1-888-REDHAT1 x43741
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



