Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61582 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821Ab3JWPCb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Oct 2013 11:02:31 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
CC: Steve Dickson <SteveD@redhat.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2 2/3] WIP: Add gsskeyd
Date: Wed, 23 Oct 2013 15:02:28 +0000
Message-ID: <CCB680BA-58A1-45CC-858E-CF2F4B24C8D2@netapp.com>
References: <1382451757-3032-1-git-send-email-andros@netapp.com>
 <1382451757-3032-3-git-send-email-andros@netapp.com>
 <5267DD77.2090904@RedHat.com>
 <96CE058E-C9B7-42E4-AD58-D527E272E7EF@netapp.com>
In-Reply-To: <96CE058E-C9B7-42E4-AD58-D527E272E7EF@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for all of the confusion. Next time I'll put WIP in the patch subject and make it a lot clearer as to what is going on.

Basically, the daemon is a way to automatically create/destroy a kernel keyring key on Kerberos credential cache creation and destruction which in turn triggers the Kernel code to locate and do the correct thing with the associated gss_cred and gss_contexts.

The kernel code is what I need tested. 

We also, of course, need the correct way to notify the kernel GSS layer that the credentials have been destroyed.  I like the suggestion of a libkrb5 client plugin or call out. I also think that when the Kerberos credentials are stored in the kernel keyring, there is an opportunity to have that work cleanly without any mucking with libkrb5.

-->Andy

On Oct 23, 2013, at 10:40 AM, Weston Andros Adamson <dros@netapp.com>
 wrote:

> Hey Steve,
> 
> This patch is simply for testing.  It is not anywhere near something we’d ask for inclusion in nfs-utils.
> If and when we want something like this, we’ll post something appropriate.
> 
> -dros
> 
> On Oct 23, 2013, at 10:30 AM, Steve Dickson <SteveD@redhat.com> wrote:
> 
>> Hello.
>> 
>> After read this these recent threads about this, we may or may not end up with this
>> type of daemon, personally I hope we don't... ;-) But if we do... 
>> 
>> On 22/10/13 10:22, andros@netapp.com wrote:
>>> From: Weston Andros Adamson <dros@netapp.com>
>>> 
>>> this is an experimental daemon that watches for krb credential cache files
>>> being created and deleted and creates or removes the mapping in the user
>>> keyring.
>>> 
>>> this replaces the wrappers for kinit and kdestroy as they are no longer needed -
>>> users can go ahead using kinit/kdestroy and existing pam modules.
>>> 
>>> if this is the way we want to go, this should probably end up as a processes
>>> forked from gssd and not its own daemon.
>>> 
>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>> ---
>>> configure.ac            |   1 +
>>> utils/Makefile.am       |   2 +-
>>> utils/gsskeyd/gsskeyd.c | 328 ++++++++++++++++++++++++++++++++++++++++++++++++
>>> 3 files changed, 330 insertions(+), 1 deletion(-)
>>> create mode 100644 utils/gsskeyd/gsskeyd.c
>>> 
>>> diff --git a/configure.ac b/configure.ac
>>> index d3ad854..a8e75ac 100644
>>> --- a/configure.ac
>>> +++ b/configure.ac
>>> @@ -497,6 +497,7 @@ AC_CONFIG_FILES([
>>> 	utils/nfsdcltrack/Makefile
>>> 	utils/exportfs/Makefile
>>> 	utils/gssd/Makefile
>>> +	utils/gsskeyd/Makefile
>>> 	utils/idmapd/Makefile
>>> 	utils/mount/Makefile
>>> 	utils/mountd/Makefile
>>> diff --git a/utils/Makefile.am b/utils/Makefile.am
>>> index b892dc8..943ae2d 100644
>>> --- a/utils/Makefile.am
>>> +++ b/utils/Makefile.am
>>> @@ -14,7 +14,7 @@ OPTDIRS += blkmapd
>>> endif
>>> 
>>> if CONFIG_GSS
>>> -OPTDIRS += gssd
>>> +OPTDIRS += gssd gsskeyd
>>> endif
>>> 
>>> if CONFIG_MOUNT
>>> diff --git a/utils/gsskeyd/gsskeyd.c b/utils/gsskeyd/gsskeyd.c
>>> new file mode 100644
>>> index 0000000..6d598fa
>>> --- /dev/null
>>> +++ b/utils/gsskeyd/gsskeyd.c
>>> @@ -0,0 +1,328 @@
>>> +#include <stdio.h>
>>> +#include <stdlib.h>
>>> +#include <limits.h>
>>> +#include <assert.h>
>>> +#include <keyutils.h>
>>> +#include <err.h>
>>> +#include <errno.h>
>>> +#include <string.h>
>>> +
>>> +#include <sys/inotify.h>
>>> +#include <sys/errno.h>
>>> +#include <sys/select.h>
>>> +#include <sys/param.h>
>>> +#include <sys/time.h>
>>> +#include <sys/types.h>
>>> +#include <sys/wait.h>
>>> +#include <sys/queue.h>
>>> +#include <sys/uio.h>
>>> +#include <unistd.h>
>>> +
>>> +#define MAX_EVENT_SIZE (sizeof(struct inotify_event) + NAME_MAX + 1)
>>> +
>>> +//#define DEBUG_TRACE
>>> +
>>> +#ifdef DEBUG_TRACE
>>> +#define TRACE(X...) do { fprintf(stderr, "_trace_: " X); } while (0)
>>> +#else
>>> +#define TRACE(X...)
>>> +#endif
>> Please do not make debugging a compile decision. Go ahead and 
>> use a '-d' or '-vvvv' (which each 'v' add more logging) flags to
>> make it a run time decision... Having to recompile to debug is
>> something that never made much sense to me... 
>> 
>> Secondly, you please use the existing xlog() interface to do your 
>> error/warning/debugging logging... Having all logging going through
>> on interface is a good thing... IMHO... 
>> 
>> steved.
>>> +
>>> +/* .25 second timeouts to select */
>>> +#define SELECT_INTERVAL_TV { 0, 250000 }
>>> +
>>> +/* .5 seconds to collect list of unique file names that had events */
>>> +#define COLLECT_INTERVAL_TV { 0, 500000 }
>>> +
>>> +struct watchdir {
>>> +	char dir[MAXPATHLEN];
>>> +	int wd;
>>> +	LIST_ENTRY(watchdir) entry;
>>> +};
>>> +
>>> +LIST_HEAD(watchdir_list, watchdir);
>>> +
>>> +struct update {
>>> +	char dir[MAXPATHLEN];
>>> +	char name[MAXPATHLEN];
>>> +	int is_remove;
>>> +	LIST_ENTRY(update) entry;
>>> +};
>>> +
>>> +LIST_HEAD(update_list, update);
>>> +
>>> +struct updates {
>>> +	struct update_list list;
>>> +	struct timeval first;
>>> +};
>>> +
>>> +void
>>> +watchdir_add(struct watchdir_list *watchdirs, int notify, char *dir)
>>> +{
>>> +	struct watchdir *w;
>>> +
>>> +	w = calloc(1, sizeof(struct watchdir));
>>> +	assert(w != NULL);
>>> +
>>> +	strncpy(w->dir, dir, MAXPATHLEN);
>>> +
>>> +	w->wd = inotify_add_watch(notify, dir,
>>> +	    IN_CREATE | IN_DELETE | IN_MOVED_FROM | IN_MOVED_TO );
>>> +	    //| IN_MODIFY
>>> +
>>> +	if (w->wd < 0)
>>> +		perror("inotify_add_watch");
>>> +
>>> +	LIST_INSERT_HEAD(watchdirs, w, entry);
>>> +
>>> +	TRACE("WATCH(%d): %s\n", w->wd, w->dir);
>>> +}
>>> +
>>> +/*
>>> + * XXX maybe use hash when there is more than one watchdir?
>>> + */
>>> +struct watchdir *
>>> +watchdir_lookup(struct watchdir_list *watchdirs, int wd)
>>> +{
>>> +	struct watchdir *w;
>>> +
>>> +	LIST_FOREACH(w, watchdirs, entry) {
>>> +		if (wd == w->wd)
>>> +			return w;
>>> +	}
>>> +
>>> +	return NULL;
>>> +}
>>> +
>>> +static void
>>> +update_set_type(struct update *u, struct inotify_event *e)
>>> +{
>>> +	if (e->mask & (IN_DELETE | IN_MOVED_FROM))
>>> +		u->is_remove = 1;
>>> +	else
>>> +		u->is_remove = 0;
>>> +}
>>> +
>>> +void
>>> +updates_add(struct updates *updates, struct watchdir_list *watchdirs, struct inotify_event *e)
>>> +{
>>> +	struct update *u;
>>> +	struct watchdir *w;
>>> +
>>> +
>>> +	w = watchdir_lookup(watchdirs, e->wd);
>>> +	assert(w != NULL);
>>> +
>>> +	TRACE("updates_add: %s/%s\n", w->dir, e->name);
>>> +
>>> +	LIST_FOREACH(u, &updates->list, entry) {
>>> +		if (strncmp(w->dir, u->dir, MAXPATHLEN) == 0 &&
>>> +		    strncmp(e->name, u->name, MAXPATHLEN) == 0) {
>>> +			update_set_type(u, e);
>>> +			return;
>>> +		}
>>> +	}
>>> +
>>> +	u = calloc(1, sizeof(struct update));
>>> +	strncpy(u->dir, w->dir, MAXPATHLEN);
>>> +	strncpy(u->name, e->name, MAXPATHLEN);
>>> +	update_set_type(u, e);
>>> +
>>> +	LIST_INSERT_HEAD(&updates->list, u, entry);
>>> +
>>> +	if (!timerisset(&updates->first)) {
>>> +		if (gettimeofday(&updates->first, NULL) < 0)
>>> +			perror("gettimeofday");
>>> +	}
>>> +}
>>> +
>>> +void
>>> +print_event_mask(FILE *fp, uint32_t mask)
>>> +{
>>> +#define _print_if_found(X, S) do {	\
>>> +		if (mask & (X)) { 		\
>>> +			fprintf(fp, S);		\
>>> +		} \
>>> +	} while(0)
>>> +
>>> +	_print_if_found(IN_ACCESS,		"access");
>>> +	_print_if_found(IN_ATTRIB,		"attrib");
>>> +	_print_if_found(IN_CLOSE_WRITE,		"close write");
>>> +	_print_if_found(IN_CLOSE_NOWRITE,	"close nowrite");
>>> +	_print_if_found(IN_CREATE,		"create");
>>> +	_print_if_found(IN_DELETE,		"delete");
>>> +	_print_if_found(IN_DELETE_SELF,		"delete self");
>>> +	_print_if_found(IN_MODIFY,		"modify");
>>> +	_print_if_found(IN_MOVE_SELF,		"move self");
>>> +	_print_if_found(IN_MOVED_FROM,		"moved from");
>>> +	_print_if_found(IN_MOVED_TO,		"moved to");
>>> +	_print_if_found(IN_OPEN,		"open");
>>> +}
>>> +
>>> +static int
>>> +manage_gss_ctx_keyring_mapping(struct update *u)
>>> +{
>>> +	char buf[MAXPATHLEN];
>>> +	int status;
>>> +	uid_t uid;
>>> +	pid_t pid;
>>> +	key_serial_t key;
>>> +	long res;
>>> +
>>> +	snprintf(buf, MAXPATHLEN, "%s/%s", u->dir, u->name);
>>> +
>>> +	if (sscanf(u->name, "krb5cc_%u", &uid) <= 0)
>>> +		perror("parsing krb5cc uid");
>>> +
>>> +	if ((pid = fork()) < 0)
>>> +		perror("fork");
>>> +
>>> +	if (pid == 0) {
>>> +		if (setuid(uid) < 0)
>>> +			perror("setuid");
>>> +
>>> +		if (u->is_remove) {
>>> +			fprintf(stderr, "remove gss ctx mapping for uid %u\n",
>>> +				uid);
>>> +			key = request_key("gss-ctx", "_nfstgt_", NULL,
>>> +				KEY_SPEC_USER_KEYRING);
>>> +			if (key > 0) {
>>> +				res = keyctl_unlink(key, KEY_SPEC_USER_KEYRING);
>>> +				if (res < 0)
>>> +					warn("keyctl_unlink failed");
>>> +			} else
>>> +				warn("request_key failed");
>>> +		} else {
>>> +			fprintf(stderr, "add gss ctx mapping for uid=%u\n",
>>> +				uid);
>>> +			snprintf(buf, MAXPATHLEN, "FILE:%s/%s",
>>> +				u->dir, u->name);
>>> +			key = add_key("gss-ctx", "_nfstgt_", buf,
>>> +				MAXPATHLEN, KEY_SPEC_USER_KEYRING);
>>> +
>>> +			if (key < 0)
>>> +				warn("add_key failed");
>>> +		}
>>> +
>>> +		exit(0);
>>> +	} else {
>>> +		waitpid(pid, &status, 0);
>>> +
>>> +		if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
>>> +			return WEXITSTATUS(status);
>>> +		}
>>> +	}
>>> +
>>> +	return 0;
>>> +}
>>> +
>>> +void
>>> +parse_events(int notify, struct watchdir_list *watchdirs, struct updates *updates)
>>> +{
>>> +	ssize_t nread, pos;
>>> +	unsigned char buf[MAX_EVENT_SIZE * 100];
>>> +	struct inotify_event *e;
>>> +
>>> +	for (;;) {
>>> +		nread = read(notify, buf, sizeof(buf));
>>> +
>>> +		if (nread <= 0) {
>>> +			TRACE("read returns %d, errno %u\n", nread, errno);
>>> +			break;
>>> +		}
>>> +
>>> +		TRACE("Read %d bytes\n", nread);
>>> +
>>> +		pos = 0;
>>> +		while (pos < nread) {
>>> +			assert((nread - pos) >=
>>> +			       (ssize_t)sizeof(struct inotify_event));
>>> +			e = (struct inotify_event *)(buf + pos);
>>> +			pos += sizeof(struct inotify_event) + e->len;
>>> +
>>> +#ifdef DEBUG_TRACE
>>> +			TRACE("EVENT on %s: ", e->name);
>>> +			print_event_mask(stderr, e->mask);
>>> +			fprintf(stderr, "\n");
>>> +#endif
>>> +
>>> +			if (strlen(e->name) >= strlen("krb5cc_") &&
>>> +			    strncmp("krb5cc_", e->name, strlen("krb5cc_")) != 0)
>>> +				TRACE("skip file: %s\n", e->name);
>>> +			else
>>> +				updates_add(updates, watchdirs, e);
>>> +		}
>>> +		assert(pos == nread);
>>> +	}
>>> +}
>>> +
>>> +void
>>> +handle_events(struct updates *updates)
>>> +{
>>> +	struct update *u;
>>> +	struct timeval now, diff, collection_interval = COLLECT_INTERVAL_TV;
>>> +
>>> +	if (!timerisset(&updates->first))
>>> +		return;
>>> +
>>> +	if (gettimeofday(&now, NULL) < 0)
>>> +		perror("gettimeofday");
>>> +
>>> +	timersub(&now, &updates->first, &diff);
>>> +
>>> +	if (!(diff.tv_sec >= collection_interval.tv_sec &&
>>> +	      diff.tv_usec >= collection_interval.tv_usec)) {
>>> +		TRACE("it's been %u s %u ms - waiting longer...\n",
>>> +			diff.tv_sec, diff.tv_usec);
>>> +		return;
>>> +	}
>>> +
>>> +	while (!LIST_EMPTY(&updates->list)) {
>>> +		u = updates->list.lh_first;
>>> +
>>> +		TRACE("handle krb5 cc file: %s\n", u->name);
>>> +		manage_gss_ctx_keyring_mapping(u);
>>> +		LIST_REMOVE(u, entry);
>>> +	}
>>> +
>>> +	timerclear(&updates->first);
>>> +}
>>> +
>>> +
>>> +int
>>> +main(int argc, char **argv)
>>> +{
>>> +	fd_set readfds;
>>> +	int notify;
>>> +	int res;
>>> +	struct timeval timeo, select_interval = SELECT_INTERVAL_TV;
>>> +	struct watchdir_list watchdirs;
>>> +	struct updates updates;
>>> +
>>> +	LIST_INIT(&watchdirs);
>>> +
>>> +	notify = inotify_init1(IN_NONBLOCK);
>>> +	if (notify < 0)
>>> +		perror("inotify_init1");
>>> +
>>> +	watchdir_add(&watchdirs, notify, "/tmp");
>>> +
>>> +	LIST_INIT(&updates.list);
>>> +	timerclear(&updates.first);
>>> +
>>> +	for (;;) {
>>> +		FD_ZERO(&readfds);
>>> +		FD_SET(notify, &readfds);
>>> +		memcpy(&timeo, &select_interval, sizeof(struct timeval));
>>> +
>>> +		res = select(notify + 1, &readfds, NULL, NULL, &timeo);
>>> +
>>> +		if (res < 0)
>>> +			perror("error calling select");
>>> +
>>> +		if (FD_ISSET(notify, &readfds))
>>> +			parse_events(notify, &watchdirs, &updates);
>>> +
>>> +		handle_events(&updates);
>>> +	}
>>> +}
> 

