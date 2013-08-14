Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:40627 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932806Ab3HNRAi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Aug 2013 13:00:38 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [nfs-utils PATCH] mount.nfs: dont pass options from configuration sections that are not relevant
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1376495307-14174-1-git-send-email-smayhew@redhat.com>
Date: Wed, 14 Aug 2013 13:00:31 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <DB1F3118-3BFF-4AB8-B1C7-AB3FEAF6C626@oracle.com>
References: <1376495307-14174-1-git-send-email-smayhew@redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 14, 2013, at 11:48 AM, Scott Mayhew <smayhew@redhat.com> wrote:

> The nfsmount.conf file has the following format:
> 
> [ section "arg" ]
> 	tag = value
> 
> conf_get_tag_list() currently doesn't check the arg field so we wind up
> getting all the options that fall under a particular section value,
> instead of just the ones that match the specific "arg" field.  As a
> result, we wind up passing options to the mount syscall from sections
> that aren't even relevant to the mount operation that is being
> performed.
> 
> For example, if we have three different server sections, and each
> section has an Nfsvers tag, then the string we pass to the mount syscall
> will have two extra occurrences of the nfsvers option.  Each option
> should appear at most 4 times -- once for the system section, once for
> the server-specific section, once for the mount-specific section, and
> once for the command line mount options.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>

Acked-by: Chuck Lever <chuck.lever@oracle.com>

Btw, is there still a problem with "sloppy" ?


> ---
> support/include/conffile.h | 2 +-
> support/nfs/conffile.c     | 4 +++-
> utils/mount/configfile.c   | 2 +-
> 3 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/support/include/conffile.h b/support/include/conffile.h
> index ce7aa21..05ea5d2 100644
> --- a/support/include/conffile.h
> +++ b/support/include/conffile.h
> @@ -54,7 +54,7 @@ extern int      conf_end(int, int);
> extern void     conf_free_list(struct conf_list *);
> extern struct sockaddr *conf_get_address(char *, char *);
> extern struct conf_list *conf_get_list(char *, char *);
> -extern struct conf_list *conf_get_tag_list(char *);
> +extern struct conf_list *conf_get_tag_list(char *, char *);
> extern int      conf_get_num(char *, char *, int);
> extern char    *conf_get_str(char *, char *);
> extern char    *conf_get_section(char *, char *, char *);
> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> index 5015e94..c3434d5 100644
> --- a/support/nfs/conffile.c
> +++ b/support/nfs/conffile.c
> @@ -565,7 +565,7 @@ cleanup:
> }
> 
> struct conf_list *
> -conf_get_tag_list(char *section)
> +conf_get_tag_list(char *section, char *arg)
> {
> 	struct conf_list *list = 0;
> 	struct conf_list_node *node;
> @@ -579,6 +579,8 @@ conf_get_tag_list(char *section)
> 	cb = LIST_FIRST(&conf_bindings[conf_hash (section)]);
> 	for (; cb; cb = LIST_NEXT(cb, link)) {
> 		if (strcasecmp (section, cb->section) == 0) {
> +			if (arg != NULL && strcasecmp(arg, cb->arg) != 0)
> +				continue;
> 			list->cnt++;
> 			node = calloc(1, sizeof *node);
> 			if (!node)
> diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
> index 6f2ee75..1f1b6e7 100644
> --- a/utils/mount/configfile.c
> +++ b/utils/mount/configfile.c
> @@ -286,7 +286,7 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
> 	char *nvalue, *ptr;
> 	int argtype;
> 
> -	list = conf_get_tag_list(section);
> +	list = conf_get_tag_list(section, arg);
> 	TAILQ_FOREACH(node, &list->fields, link) {
> 		/*
> 		 * Do not overwrite options if already exists 
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



