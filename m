Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50080 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203AbcBAX3f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Feb 2016 18:29:35 -0500
Subject: Re: [Linux-cachefs] [PATCH 2/2] Suspend/resume culling based on
 recently released file/block counts
To: David Howells <dhowells@redhat.com>, linux-cachefs@redhat.com
References: <20160125164111.9466.79976.stgit@warthog.procyon.org.uk>
 <20160125164937.9670.4281.stgit@warthog.procyon.org.uk>
Cc: linux-nfs@vger.kernel.org, neilb@suse.de, linux-fsdevel@vger.kernel.org,
        jlayton@poochiereds.net
From: John Snow <jsnow@redhat.com>
Message-ID: <56AFEA5E.2080401@redhat.com>
Date: Mon, 1 Feb 2016 18:29:34 -0500
MIME-Version: 1.0
In-Reply-To: <20160125164937.9670.4281.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/25/2016 11:49 AM, David Howells wrote:
> Newer kernels include the counts of objects and blocks unpinned since last
> the status was read over the control device fd.  The unpinning is usually
> through relinquishment by the netfs.
> 
> If these fields are present, extract them and use them to work out whether
> there can be anything to cull.  The fields are reset when read and POLLIN
> is signalled when the file counter is increased from 0.
> 
> If there is nothing new to cull, scanning to build a cull table is
> suspended until more stuff is available.  If the new fields are present,
> work on that basis - otherwise we sleep for 30s and try again.
> 
> The thresholds at which culling should be resumed can be set by adding:
> 
> 	resume_thresholds <block> <file>
> 
> to the config file.  The cull scan is retried when sufficient cumulative
> unpinning has happened that either threshold is exceeded.  The block
> threshold watches the cumulative i_blocks for unpinned cache inodes and the
> file threshold watches the number of cache inodes unpinned.  If either is
> "-" then that threshold is disabled.  The default is 5 files and no block
> threshold.
> 
> Further:
> 
>  (*) Some of the variable names are changed to be more obvious as to what
>      they do.
> 
>  (*) If time-based culling is used, then SIGALRM must be blocked between
>      the did-it-happen check and the call to poll.  SIGINT, SIGTERM and
>      SIGIO are already so blocked.
> 
>  (*) All the decision making logic is moved into the cachefilesd() function
>      rather than being spread out.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  README             |   13 ++
>  cachefilesd.c      |  275 +++++++++++++++++++++++++++++++++++++---------------
>  cachefilesd.conf.5 |   10 ++
>  3 files changed, 219 insertions(+), 79 deletions(-)
> 
> diff --git a/README b/README
> index 8446a3b..6ed7de2 100644
> --- a/README
> +++ b/README
> @@ -114,6 +114,19 @@ set up cache ready for use.  The following script commands are available:
>  	entries.  The permissible values are between 12 and 20, the latter
>  	indicating 1048576 entries.  The default is 12.
>  
> + (*) resume_thresholds <blocks> <files>
> +
> +	Scanning to refill the cull table is suspended when all the objects in
> +	a cache are pinned by a live network filesystem in the kernel and
> +	there's nothing available to cull.  Scanning is resumed when the kernel
> +	releases sufficient objects that either the number of objects released
> +	exceeds the files parameter here or the cumulative i_blocks values
> +	exceed the blocks parameter.  Either threshold can be disabled by
> +	specifying it as "-".
> +
> +	The default is to ignore the block threshold and to resume when five or
> +	more files have been released.
> +
>   (*) debug <mask>
>  
>  	Specify a numeric bitmask to control debugging in the kernel module.
> diff --git a/cachefilesd.c b/cachefilesd.c
> index eaa1bb0..affd9f9 100644
> --- a/cachefilesd.c
> +++ b/cachefilesd.c
> @@ -46,6 +46,7 @@
>  #include <dirent.h>
>  #include <time.h>
>  #include <poll.h>
> +#include <limits.h>
>  #include <sys/inotify.h>
>  #include <sys/time.h>
>  #include <sys/vfs.h>
> @@ -85,8 +86,8 @@ static int nobjects = 1;
>  static int nopendir;
>  
>  /* current scan point */
> -static struct object *scan = &root;
> -static bool jumpstart_scan;
> +static struct object *scan_cursor;
> +static bool scan_signalled, stop_signalled, reap_signalled;
>  
>  /* ranked order of cullable objects
>   * - we have two tables: one we're building and one that's full of ready to be
> @@ -99,7 +100,10 @@ static struct object **cullready;
>  static unsigned nr_in_build_table;
>  static unsigned nr_in_ready_table;
>  static int ncullable;
> -static bool cull_delayed;
> +static bool kernel_wants_cull;
> +static bool have_nr_releases;
> +static unsigned long long f_released_since_last_scan;
> +static unsigned long long b_released_since_last_scan;
>  
>  
>  static const char *configfile = "/etc/cachefilesd.conf";
> @@ -108,11 +112,13 @@ static const char *procfile = "/proc/fs/cachefiles";
>  static const char *pidfile = "/var/run/cachefilesd.pid";
>  static char *cacheroot, *graveyardpath;
>  
> +static bool culling_disabled;
>  static bool xnolog, xopenedlog;
>  static int xdebug;
> -static bool nocull, stop, reap, cull;
>  static int graveyardfd;
>  static unsigned long long brun, bcull, bstop, frun, fcull, fstop;
> +static unsigned long long b_resume_threshold = ULLONG_MAX;
> +static unsigned long long f_resume_threshold = 5;
>  
>  #define cachefd 3
>  
> @@ -212,7 +218,8 @@ static void reap_graveyard_aux(const char *dirname);
>  static void read_cache_state(void);
>  static int is_object_in_use(const char *filename);
>  static void cull_file(const char *filename);
> -static void build_cull_table(void);
> +static void begin_building_cull_table(void);
> +static bool build_cull_table(void);
>  static void decant_cull_table(void);
>  static void insert_into_cull_table(struct object *object);
>  static void put_object(struct object *object);
> @@ -228,7 +235,7 @@ static void cull_objects(void);
>   */
>  static void sigterm(int sig)
>  {
> -	stop = true;
> +	stop_signalled = true;
>  }
>  
>  /*****************************************************************************/
> @@ -237,7 +244,7 @@ static void sigterm(int sig)
>   */
>  static void sigio(int sig)
>  {
> -	reap = true;
> +	reap_signalled = true;
>  }
>  
>  /*****************************************************************************/
> @@ -246,8 +253,7 @@ static void sigio(int sig)
>   */
>  static void sigalrm(int sig)
>  {
> -	jumpstart_scan = true;
> -	cull_delayed = false;
> +	scan_signalled = true;
>  }
>  
>  /*****************************************************************************/
> @@ -312,7 +318,7 @@ int main(int argc, char *argv[])
>  
>  		case 'N':
>  			/* disable culling */
> -			nocull = true;
> +			culling_disabled = true;
>  			break;
>  
>  		case 'f':
> @@ -420,7 +426,7 @@ int main(int argc, char *argv[])
>  		/*  allow culling to be disabled */
>  		if (memcmp(cp, "nocull", 6) == 0 &&
>  		    (!cp[6] || isspace(cp[6]))) {
> -			nocull = true;
> +			culling_disabled = true;
>  		}
>  
>  		/* note the cull table size command */
> @@ -439,6 +445,40 @@ int main(int argc, char *argv[])
>  			continue;
>  		}
>  
> +		/* Note the suspension resume released file count thresholds
> +		 * ("-" to disable a threshold).
> +		 */
> +		if (memcmp(cp, "resume_thresholds", 18) == 0 && isspace(cp[18])) {
> +			unsigned long long b_thresh, f_thresh;
> +			char *sp;
> +
> +			for (sp = cp + 18; isspace(*sp); sp++) {;}
> +
> +			if (*sp == '-') {
> +				sp++;
> +				b_thresh = ULLONG_MAX;
> +			} else {
> +				b_thresh = strtoul(sp, &sp, 10);
> +			}
> +
> +			if (!*sp || !isspace(*sp) || b_thresh == 0)
> +				cfgerror("Invalid resume threshold (blocks)");

Seems to me like we're mixing parsing errors with invalid configuration
error messages, but I'm just bike-shedding aboard the SS Howells.

> +			for (; isspace(*sp); sp++) {;}
> +
> +			if (*sp == '-') {
> +				sp++;
> +				f_thresh = ULLONG_MAX;
> +			} else {
> +				f_thresh = strtoul(sp, &sp, 10);
> +				if (*sp || f_thresh == 0)
> +					cfgerror("Invalid resume threshold (files)");
> +			}
> +
> +			b_resume_threshold = b_thresh;
> +			f_resume_threshold = f_thresh;
> +			continue;
> +		}
> +
>  		/* note the dir command */
>  		if (memcmp(cp, "dir", 3) == 0 && isspace(cp[3])) {
>  			char *sp;
> @@ -479,7 +519,7 @@ int main(int argc, char *argv[])
>  		oserror("Unable to close %s", configfile);
>  
>  	/* allocate the cull tables */
> -	if (!nocull) {
> +	if (!culling_disabled) {
>  		cullbuild = calloc(culltable_size, sizeof(cullbuild[0]));
>  		if (!cullbuild)
>  			oserror("calloc");
> @@ -583,6 +623,8 @@ static void open_cache(void)
>  static void cachefilesd(void)
>  {
>  	sigset_t sigs, osigs;
> +	bool scanning_suspended = false;
> +	bool scan_in_progress = false;
>  
>  	struct pollfd pollfds[1] = {
>  		[0] = {
> @@ -596,13 +638,14 @@ static void cachefilesd(void)
>  	/* open the cache directories */
>  	open_cache();
>  
> -	/* we need to disable I/O and termination signals so they're only
> -	 * caught at appropriate times
> +	/* We need to be able to disable signals that we need to check for
> +	 * before calling poll so that we don't race and miss something.
>  	 */
>  	sigemptyset(&sigs);
>  	sigaddset(&sigs, SIGIO);
>  	sigaddset(&sigs, SIGINT);
>  	sigaddset(&sigs, SIGTERM);
> +	sigaddset(&sigs, SIGALRM);
>  
>  	signal(SIGTERM, sigterm);
>  	signal(SIGINT, sigterm);
> @@ -610,16 +653,81 @@ static void cachefilesd(void)
>  	/* check the graveyard for graves */
>  	reap_graveyard();
>  
> -	while (!stop) {
> +	while (!stop_signalled) {
> +		bool do_cull = false;
> +
> +		debug(3, "Loop %sbuild=%d ready=%d susp=%u scan=%u",
> +		      culling_disabled ? "NOCULL " : "",
> +		      nr_in_build_table, nr_in_ready_table,
> +		      scanning_suspended, scan_in_progress);
> +		

Trailing whitespace

>  		read_cache_state();
>  
> -		/* sleep without racing on reap and cull with the signal
> -		 * handlers */
> -		if (!scan && !reap && !(cull && !cull_delayed)) {
> +		if (!culling_disabled) {
> +			/* Determine if we're going to need to start a new scan
> +			 * to refill the cull table.  We want to do this if the
> +			 * secondary cull table is less than half full - but
> +			 * overriding that, we don't want to do this if we know
> +			 * there's insufficient cullables to make it worth
> +			 * while.
> +			 */
> +			if (!scan_in_progress) {
> +				bool begin_scan = false;
> +
> +				debug(1, "Consider scan %d/%d",
> +				      nr_in_build_table, culltable_size / 2);
> +
> +				if (nr_in_build_table < culltable_size / 2) {
> +					debug(1, "Want to scan");
> +					begin_scan = true;
> +				}
> +
> +				if (begin_scan && scanning_suspended) {
> +					debug(1, "Scanning suspended");
> +					if (have_nr_releases) {
> +						if (f_released_since_last_scan <
> +						    f_resume_threshold &&
> +						    b_released_since_last_scan <
> +						    b_resume_threshold)
> +							begin_scan = false;
> +					} else {
> +						begin_scan = scan_signalled;
> +					}
> +				}
> +
> +				if (begin_scan) {
> +					debug(1, "Beginning a scan");
> +					begin_building_cull_table();
> +					scan_in_progress = true;
> +					scanning_suspended = false;
> +					scan_signalled = false;
> +					f_released_since_last_scan = 0;
> +					b_released_since_last_scan = 0;
> +				}
> +			}
> +
> +			/* Determine if there's anything we can actually cull yet if
> +			 * the kernel is calling for space.
> +			 */
> +			if (kernel_wants_cull) {
> +				debug(1, "Want to cull");
> +				if (nr_in_ready_table > 0)
> +					do_cull = true;
> +			}
> +		}
> +
> +		/* We block the signals across the checks for reap, cull and
> +		 * scan initiation before polling so that we sleep without
> +		 * racing against the signal handlers.
> +		 */
> +		if (!scan_in_progress && !reap_signalled && !do_cull) {
>  			if (sigprocmask(SIG_BLOCK, &sigs, &osigs) < 0)
>  				oserror("Unable to block signals");
>  
> -			if (!reap && !stop && !jumpstart_scan) {
> +			if (!reap_signalled &&
> +			    !stop_signalled &&
> +			    !scan_signalled) {
> +				debug(1, "Poll");
>  				if (ppoll(pollfds, 1, NULL, &osigs) < 0 &&
>  				    errno != EINTR)
>  					oserror("Unable to suspend process");
> @@ -627,37 +735,44 @@ static void cachefilesd(void)
>  
>  			if (sigprocmask(SIG_UNBLOCK, &sigs, NULL) < 0)
>  				oserror("Unable to unblock signals");
> -
> -			read_cache_state();
> +			continue;
>  		}
>  
> -		if (nocull) {
> -			cull = false;
> -		} else {
> -			if (jumpstart_scan) {
> -				jumpstart_scan = false;
> -				if (!stop && !scan) {
> -					debug(1, "Refilling cull table");
> -					root.usage++;
> -					scan = &root;
> +		if (!culling_disabled) {
> +			if (do_cull)
> +				cull_objects();
> +
> +			if (scan_in_progress) {
> +				scan_in_progress = build_cull_table();
> +				if (!scan_in_progress) {
> +					/* Scan complete.
> +					 *
> +					 * If the scan didn't produce a full
> +					 * table then don't repeat the scan
> +					 * until something gets released by the
> +					 * kernel.
> +					 */
> +					if (nr_in_build_table < culltable_size) {
> +						debug(1, "Suspend scanning");
> +						scanning_suspended = true;
> +						if (!have_nr_releases) {
> +							signal(SIGALRM, sigalrm);
> +							alarm(30);
> +						}
> +					}
>  				}
>  			}
>  
> -			if (cull) {
> -				if (nr_in_ready_table > 0)
> -					cull_objects();
> -				else if (nr_in_build_table == 0 && !cull_delayed)
> -					jumpstart_scan = true;
> +			if (!scan_in_progress) {
> +				if (nr_in_ready_table <= culltable_size / 2 + 2 &&
> +				    nr_in_build_table > 0) {
> +					debug(1, "Decant");
> +					decant_cull_table();
> +				}
>  			}
> -
> -			if (scan)
> -				build_cull_table();
> -
> -			if (!scan && nr_in_ready_table == 0 && nr_in_build_table > 0)
> -				decant_cull_table();
>  		}
>  
> -		if (reap)
> +		if (reap_signalled)
>  			reap_graveyard();
>  	}
>  
> @@ -672,7 +787,7 @@ static void cachefilesd(void)
>  static void reap_graveyard(void)
>  {
>  	/* set a one-shot notification to catch more graves appearing */
> -	reap = false;
> +	reap_signalled = false;
>  	signal(SIGIO, sigio);
>  	if (fcntl(graveyardfd, F_NOTIFY, DN_CREATE) < 0)
>  		oserror("unable to set notification on graveyard");
> @@ -763,6 +878,8 @@ static void read_cache_state(void)
>  		oserror("Unable to read cache state");
>  	buffer[n] = '\0';
>  
> +	debug(3, "KERNEL: %s", buffer);
> +	

Trailing whitespace

>  	tok = buffer;
>  	do {
>  		next = strpbrk(tok, " \t");
> @@ -777,20 +894,27 @@ static void read_cache_state(void)
>  			continue;
>  		}
>  
> -		if (strcmp(tok, "cull") == 0)
> -			cull = (strtoul(arg, NULL, 0) != 0);
> -		else if (strcmp(tok, "brun") == 0)
> +		if (strcmp(tok, "cull") == 0) {
> +			kernel_wants_cull = (strtoul(arg, NULL, 0) != 0);
> +		} else if (strcmp(tok, "brun") == 0) {
>  			brun = strtoull(arg, NULL, 16);
> -		else if (strcmp(tok, "bcull") == 0)
> +		} else if (strcmp(tok, "bcull") == 0) {
>  			bcull = strtoull(arg, NULL, 16);
> -		else if (strcmp(tok, "bstop") == 0)
> +		} else if (strcmp(tok, "bstop") == 0) {
>  			bstop = strtoull(arg, NULL, 16);
> -		else if (strcmp(tok, "frun") == 0)
> +		} else if (strcmp(tok, "frun") == 0) {
>  			frun = strtoull(arg, NULL, 16);
> -		else if (strcmp(tok, "fcull") == 0)
> +		} else if (strcmp(tok, "fcull") == 0) {
>  			fcull = strtoull(arg, NULL, 16);
> -		else if (strcmp(tok, "fstop") == 0)
> +		} else if (strcmp(tok, "fstop") == 0) {
>  			fstop = strtoull(arg, NULL, 16);
> +		} else if (strcmp(tok, "breleased") == 0) {
> +			b_released_since_last_scan += strtoull(arg, NULL, 16);
> +			have_nr_releases = true;
> +		} else if (strcmp(tok, "freleased") == 0) {
> +			f_released_since_last_scan += strtoull(arg, NULL, 16);
> +			have_nr_releases = true;
> +		}
>  
>  	} while ((tok = next));
>  }
> @@ -1123,9 +1247,21 @@ static void insert_into_cull_table(struct object *object)
>  
>  /*****************************************************************************/
>  /*
> - * do the next step in building up the cull table
> + * Begin a scan to build a cull table.
>   */
> -static void build_cull_table(void)
> +static void begin_building_cull_table(void)
> +{
> +	debug(1, "Refilling cull table");
> +	root.usage++;
> +	scan_cursor = &root;
> +}
> +
> +/*****************************************************************************/
> +/*
> + * Do the next step in building up the cull table.  Returns false upon
> + * completion of a scan.
> + */
> +static bool build_cull_table(void)
>  {
>  	struct dirent dirent, *de;
>  	struct object *curr, *child;
> @@ -1133,7 +1269,7 @@ static void build_cull_table(void)
>  	unsigned loop;
>  	int fd;
>  
> -	curr = scan;
> +	curr = scan_cursor;
>  
>  	if (!curr->dir) {
>  		curr->empty = true;
> @@ -1289,10 +1425,10 @@ next:
>  		debug(2, "- descend");
>  
>  		child->new = false;
> -		scan = child;
> +		scan_cursor = child;
>  
>  		debug(2, "<-- build_cull_table({%s})", curr->name);
> -		return;
> +		return true;
>  
>  	default:
>  		error("Unexpected type");
> @@ -1335,15 +1471,13 @@ dir_read_complete:
>  		}
>  	}
>  
> -	scan = curr->parent;
> -	if (!scan) {
> +	scan_cursor = curr->parent;
> +	if (!scan_cursor)
>  		debug(1, "Scan complete");
> -		decant_cull_table();
> -	}
>  
>  	debug(2, "<-- build_cull_table({%s})", curr->name);
>  	put_object(curr);
> -	return;
> +	return scan_cursor != NULL;
>  
>  	/* delete unexpected objects that we've found */
>  found_unexpected_object:
> @@ -1361,17 +1495,9 @@ static void decant_cull_table(void)
>  {
>  	unsigned loop, avail, copy, leave, space, n;
>  
> -	if (scan)
> +	if (scan_cursor)
>  		error("Can't decant cull table whilst scanning");
>  
> -	/* if nothing there, scan again in a short while */
> -	if (nr_in_build_table == 0) {
> -		cull_delayed = true;
> -		signal(SIGALRM, sigalrm);
> -		alarm(30);
> -		return;
> -	}
> -
>  	/* mark the new entries cullable */
>  	for (loop = 0; loop < nr_in_build_table; loop++) {
>  		if (!cullbuild[loop]->cullable) {
> @@ -1504,13 +1630,4 @@ static void cull_objects(void)
>  		cull_object(cullready[nr_in_ready_table - 1]);
>  		cullready[--nr_in_ready_table] = (void *)(0x6b000000 | __LINE__);
>  	}
> -
> -	/* must start refilling the cull table */
> -	if (!scan && nr_in_build_table < culltable_size / 2 + 2) {
> -		decant_cull_table();
> -
> -		debug(1, "Refilling cull table");
> -		root.usage++;
> -		scan = &root;
> -	}
>  }
> diff --git a/cachefilesd.conf.5 b/cachefilesd.conf.5
> index 028105e..b108bdc 100644
> --- a/cachefilesd.conf.5
> +++ b/cachefilesd.conf.5
> @@ -75,6 +75,16 @@ amount of a systems resources, which may be undesirable.  Supplying this option
>  disables all culling activity.  The cache will keep building up to the limits
>  set and won't be shrunk, except by the removal of out-dated cache files.
>  .TP
> +.B resume_thresholds <blocks> <files>
> +This command specifies the amount of blocks or files that the kernel should let
> +go of before the daemon should resume from culling table scan suspension.
> +.IP
> +Scanning to refill the cull table is suspended when all the objects in a cache
> +are pinned by a live network filesystem in the kernel and there's nothing to
> +cull.
> +.IP
> +Either value can be "-" to indicate that this threshold should be ignored.
> +.TP
>  .B debug <mask>
>  This command specifies a numeric bitmask to control debugging in the kernel
>  module.  The default is zero (all off).  The following values can be OR'd into
> 
> --
> Linux-cachefs mailing list
> Linux-cachefs@redhat.com
> https://www.redhat.com/mailman/listinfo/linux-cachefs
> 

Reviewed-by: John Snow <jsnow@redhat.com>
