Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757537Ab3HMWj4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 18:39:56 -0400
Date: Tue, 13 Aug 2013 18:39:52 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH 1/4] mount.nfs: avoid unnecessary duplication
 of options passed to mount(2)
Message-ID: <20130813223952.GA2514@tonberry.usersys.redhat.com>
References: <1376421629-21382-1-git-send-email-smayhew@redhat.com>
 <1376421629-21382-2-git-send-email-smayhew@redhat.com>
 <B88ACB44-F0FF-4365-A783-D32892A9BCC9@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <B88ACB44-F0FF-4365-A783-D32892A9BCC9@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 13 Aug 2013, Chuck Lever wrote:

> 
> On Aug 13, 2013, at 3:20 PM, Scott Mayhew <smayhew@redhat.com> wrote:
> 
> > The nfsmount.conf file has the following format:
> > 
> > [ section "arg" ]
> > 	tag = value
> > 
> > conf_get_tag_list() currently doesn't check the arg field so we wind up
> > getting all the options that fall under a particular section value,
> > instead of just the ones that match the specific "arg" field.  As a
> > result, we wind up passing options to the mount syscall multiple times.
> > 
> > For example, if we have three different server sections, and each
> > section has an Nfsvers tag, then the string we pass to the mount syscall
> > will have three occurrences of the nfsvers option.
> > 
> > Note that the call to conf_get_section() in conf_parse_mntopts() will
> > ensure that we never pass the wrong value for an option, but we should
> > still avoid sending duplicate options if it's at all possible.
> 
> You haven't convinced me that passing duplicate options is incorrect behavior.
> 
> The idea was to do this kind of data reduction in one place.  It's either done in the kernel's NFS mount option parser, or in mount.nfs's legacy mount option parser.  There should be one authority on what setting takes effect.
> 
> Do your changes preserve the "right-most setting wins" behavior? 

Yes, they do.

> This is why the config file logic sends duplicate options: it's easier to simply stack the options onto a list, with the system specific options first, then the server specific, then the mount point specific options.  The kernel's option parser then sorts it out and applies the correct setting.
> 

I would expect to see a particular mount option at most 3 times then
(once from the global options, once from the server specific options,
and once from the mountpoint-specific options).  That's fine (although
that's what patch 2 was changing). 

The problem is that we're adding that option to the list based on config
file settings that aren't even relevant to the mount operation we happen
to be performing.  For instance if your nfsmount.conf has 100 server
sections, and each of those (along with your global and
mountpoint-specific sections) has an nfsvers option, then you could wind
up sending the nfsvers option 102 times.

If you have enough entries in your config file that the option string
exceeds one page then chances are an option is going to be lopped off
somewhere in the middle and the mount will likely fail with -EINVAL (and
even if that doesn't happen the rightmost options will most likely to be
lost).

-Scott

> If the right-most setting of an option is not taking effect, that's a bug.
> 
> 
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > ---
> > support/include/conffile.h | 2 +-
> > support/nfs/conffile.c     | 4 +++-
> > utils/mount/configfile.c   | 2 +-
> > 3 files changed, 5 insertions(+), 3 deletions(-)
> > 
> > diff --git a/support/include/conffile.h b/support/include/conffile.h
> > index ce7aa21..05ea5d2 100644
> > --- a/support/include/conffile.h
> > +++ b/support/include/conffile.h
> > @@ -54,7 +54,7 @@ extern int      conf_end(int, int);
> > extern void     conf_free_list(struct conf_list *);
> > extern struct sockaddr *conf_get_address(char *, char *);
> > extern struct conf_list *conf_get_list(char *, char *);
> > -extern struct conf_list *conf_get_tag_list(char *);
> > +extern struct conf_list *conf_get_tag_list(char *, char *);
> > extern int      conf_get_num(char *, char *, int);
> > extern char    *conf_get_str(char *, char *);
> > extern char    *conf_get_section(char *, char *, char *);
> > diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> > index 5015e94..c3434d5 100644
> > --- a/support/nfs/conffile.c
> > +++ b/support/nfs/conffile.c
> > @@ -565,7 +565,7 @@ cleanup:
> > }
> > 
> > struct conf_list *
> > -conf_get_tag_list(char *section)
> > +conf_get_tag_list(char *section, char *arg)
> > {
> > 	struct conf_list *list = 0;
> > 	struct conf_list_node *node;
> > @@ -579,6 +579,8 @@ conf_get_tag_list(char *section)
> > 	cb = LIST_FIRST(&conf_bindings[conf_hash (section)]);
> > 	for (; cb; cb = LIST_NEXT(cb, link)) {
> > 		if (strcasecmp (section, cb->section) == 0) {
> > +			if (arg != NULL && strcasecmp(arg, cb->arg) != 0)
> > +				continue;
> > 			list->cnt++;
> > 			node = calloc(1, sizeof *node);
> > 			if (!node)
> > diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
> > index 6f2ee75..1f1b6e7 100644
> > --- a/utils/mount/configfile.c
> > +++ b/utils/mount/configfile.c
> > @@ -286,7 +286,7 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
> > 	char *nvalue, *ptr;
> > 	int argtype;
> > 
> > -	list = conf_get_tag_list(section);
> > +	list = conf_get_tag_list(section, arg);
> > 	TAILQ_FOREACH(node, &list->fields, link) {
> > 		/*
> > 		 * Do not overwrite options if already exists 
> > -- 
> > 1.7.11.7
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
