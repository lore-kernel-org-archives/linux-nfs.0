Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:40089 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756033Ab3HOPtI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Aug 2013 11:49:08 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [nfs-utils PATCH] mount.nfs: improve handling of bg, fg, and sloppy in nfsmount.conf
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130815154032.GD2514@tonberry.usersys.redhat.com>
Date: Thu, 15 Aug 2013 11:49:01 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <FBE980B3-66D2-4F33-8244-0E26047E798C@oracle.com>
References: <1376575095-15403-1-git-send-email-smayhew@redhat.com> <EFB98378-3D68-46CA-A03E-C9E19FFFC265@oracle.com> <20130815154032.GD2514@tonberry.usersys.redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 15, 2013, at 11:40 AM, Scott Mayhew <smayhew@redhat.com> wrote:

> On Thu, 15 Aug 2013, Chuck Lever wrote:
> 
>> Hi Scott-
>> 
>> On Aug 15, 2013, at 9:58 AM, Scott Mayhew <smayhew@redhat.com> wrote:
>> 
>>> This patch makes 2 small improvements to the parsing of the bg, fg, and
>>> sloppy mount options in nfsmount.conf.
>>> 
>>> 1. "bg" and "fg" negate should each other.  "Background=True" should
>>> mean "bg" and "Background=False" should mean "fg".  The same applies to
>>> "Foreground".
>> 
>> This looks OK.
>> 
>>> 2. Once we see "Sloppy=False" while parsing the configuration file we
>>> should ignore subsequent occurrences of the sloppy option.  This will
>>> preserve the "right-most setting wins" behavior for the sloppy mount
>>> option.
>> 
>> Here, I'm confused.  The "right-most wins" rule goes:
>> 
>>  1.  mount options are parsed in order from left (closest to the command-line prompt) to right (closest to the carriage return)
>> 
>>  2.  the last instance of an option (the right-most instance) is the setting that takes effect 
>> 
>> As I understand it, this applies to config file settings in the following way:  config file settings are specified in order from "whole system" to "server" to "mount point", then the command line options are appended to the end of that.
> 
> conf_get_mntopts parses the mountpoint specific options first, then the
> server-specific options, and finally global options, inserting each
> option at the head of a list as it goes.  It then walks the list and
> appends each option to the string that it ultimately returns to the
> caller.  So the order that options appear in the list is reversed from
> how they appear in the string.

For what it's worth:

Acked-by: Chuck Lever <chuck.lever@oracle.com>


>> 
>> Then, "Right-most wins" means the last occurrence of "Sloppy=true" should override any previous occurrence of "Sloppy=False", right?  Or did I misunderstand again?
> 
> Yes, this is what it does.
>> 
>> It seems like you can just walk the appropriate sections of the config file, and set the sloppiness in each section that has such a setting.  The last section you walked with a sloppiness setting wins.  After you are done walking, append (or don't) a "sloppy" option, then pass that on to the mount.nfs command.
>> 
>> IIUC if the last config file setting is "Sloppy=True" there is no way for command-line options to disable "sloppy".
> 
> That's true with the existing code as well though.  I don't see any way
> around that besides adding another nfs mount option to the kernel... but
> what is the likelihood that someone would specify sloppy=true in their
> config file and then want to override it from the command line?
> 
> -Scott
>> 
>> 
>>> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
>>> ---
>>> utils/mount/configfile.c | 11 +++++++++++
>>> 1 file changed, 11 insertions(+)
>>> 
>>> diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
>>> index 1f1b6e7..68b9f93 100644
>>> --- a/utils/mount/configfile.c
>>> +++ b/utils/mount/configfile.c
>>> @@ -73,6 +73,8 @@ struct mnt_alias {
>>> };
>>> int mnt_alias_sz = (sizeof(mnt_alias_tab)/sizeof(mnt_alias_tab[0]));
>>> 
>>> +static int strict;
>>> +
>>> /*
>>> * See if the option is an alias, if so return the 
>>> * real mount option along with the argument type.
>>> @@ -310,7 +312,15 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
>>> 		if (strcasecmp(value, "false") == 0) {
>>> 			if (argtype != MNT_NOARG)
>>> 				snprintf(buf, BUFSIZ, "no%s", field);
>>> +			else if (strcasecmp(field, "bg") == 0)
>>> +				snprintf(buf, BUFSIZ, "fg");
>>> +			else if (strcasecmp(field, "fg") == 0)
>>> +				snprintf(buf, BUFSIZ, "bg");
>>> +			else if (strcasecmp(field, "sloppy") == 0)
>>> +				strict = 1;
>>> 		} else if (strcasecmp(value, "true") == 0) {
>>> +			if ((strcasecmp(field, "sloppy") == 0) && strict)
>>> +				continue;
>>> 			snprintf(buf, BUFSIZ, "%s", field);
>>> 		} else {
>>> 			nvalue = strdup(value);
>>> @@ -345,6 +355,7 @@ char *conf_get_mntopts(char *spec, char *mount_point,
>>> 	char *ptr, *server, *config_opts;
>>> 	int optlen = 0;
>>> 
>>> +	strict = 0;
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




