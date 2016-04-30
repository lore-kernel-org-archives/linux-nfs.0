Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:35840 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbcD3M3L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 08:29:11 -0400
Received: by mail-qg0-f54.google.com with SMTP id d90so52881203qgd.3
        for <linux-nfs@vger.kernel.org>; Sat, 30 Apr 2016 05:29:11 -0700 (PDT)
Message-ID: <1462019346.10011.10.camel@poochiereds.net>
Subject: Re: [PATCH v5 1/3] gssd: use pthreads to handle upcalls
From: Jeff Layton <jlayton@poochiereds.net>
To: "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>
Cc: "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Sat, 30 Apr 2016 08:29:06 -0400
In-Reply-To: <D2A86519-2118-4C46-BA57-572EC9E363F0@netapp.com>
References: <1461776287-1427-1-git-send-email-kolga@netapp.com>
	 <1461776287-1427-2-git-send-email-kolga@netapp.com>
	 <1461849204.15736.8.camel@poochiereds.net>
	 <D2A86519-2118-4C46-BA57-572EC9E363F0@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-04-28 at 14:07 +0000, Kornievskaia, Olga wrote:
> > 
> > On Apr 28, 2016, at 9:13 AM, Jeff Layton <jlayton@poochiereds.net>
> > wrote:
> > 
> > On Wed, 2016-04-27 at 12:58 -0400, Olga Kornievskaia wrote:
> > > 
> > > Currently, to persevere global data over multiple mounts,
> > > the root process does not fork when handling an upcall.
> > > Instead on not-forking create a pthread to handle the
> > > upcall since global data can be shared among threads.
> > > 
> > > Signed-off-by: Steve Dickson <steved@redhat.com>
> > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > ---
> > >  aclocal/libpthread.m4  | 13 +++++++++++++
> > >  configure.ac           |  3 +++
> > >  utils/gssd/Makefile.am |  3 ++-
> > >  utils/gssd/gssd.c      | 45
> > > ++++++++++++++++++++++++++++++++++++++++-----
> > >  utils/gssd/gssd.h      |  5 +++++
> > >  utils/gssd/gssd_proc.c | 49 ++++++++++++++++++----------------
> > > ---------------
> > >  utils/gssd/krb5_util.c |  3 +++
> > >  7 files changed, 84 insertions(+), 37 deletions(-)
> > >  create mode 100644 aclocal/libpthread.m4
> > > 
> > > diff --git a/aclocal/libpthread.m4 b/aclocal/libpthread.m4
> > > new file mode 100644
> > > index 0000000..e87d2a0
> > > --- /dev/null
> > > +++ b/aclocal/libpthread.m4
> > > @@ -0,0 +1,13 @@
> > > +dnl Checks for pthreads library and headers
> > > +dnl
> > > +AC_DEFUN([AC_LIBPTHREAD], [
> > > +
> > > +    dnl Check for library, but do not add -lpthreads to LIBS
> > > +    AC_CHECK_LIB([pthread], [pthread_create], [LIBPTHREAD=-
> > > lpthread],
> > > +                 [AC_MSG_ERROR([libpthread not found.])])
> > > +  AC_SUBST(LIBPTHREAD)
> > > +
> > > +  AC_CHECK_HEADERS([pthread.h], ,
> > > +                   [AC_MSG_ERROR([libpthread headers not
> > > found.])])
> > > +
> > > +])dnl
> > > diff --git a/configure.ac b/configure.ac
> > > index 25d2ba4..e0ecd61 100644
> > > --- a/configure.ac
> > > +++ b/configure.ac
> > > @@ -385,6 +385,9 @@ if test "$enable_gss" = yes; then
> > >    dnl Invoked after AC_KERBEROS_V5; AC_LIBRPCSECGSS needs to
> > > have KRBLIBS set
> > >    AC_LIBRPCSECGSS
> > >  
> > > +  dnl Check for pthreads
> > > +  AC_LIBPTHREAD
> > > +
> > >    dnl librpcsecgss already has a dependency on libgssapi,
> > >    dnl but we need to make sure we get the right version
> > >    if test "$enable_gss" = yes; then
> > > diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
> > > index cb040b3..3f5f59a 100644
> > > --- a/utils/gssd/Makefile.am
> > > +++ b/utils/gssd/Makefile.am
> > > @@ -49,7 +49,8 @@ gssd_LDADD = \
> > >  	$(RPCSECGSS_LIBS) \
> > >  	$(KRBLIBS) \
> > >  	$(GSSAPI_LIBS) \
> > > -	$(LIBTIRPC)
> > > +	$(LIBTIRPC) \
> > > +	$(LIBPTHREAD)
> > >  
> > >  gssd_LDFLAGS = \
> > >  	$(KRBLDFLAGS)
> > > diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> > > index e7cb07f..b676341 100644
> > > --- a/utils/gssd/gssd.c
> > > +++ b/utils/gssd/gssd.c
> > > @@ -87,7 +87,9 @@ unsigned int  rpc_timeout = 5;
> > >  char *preferred_realm = NULL;
> > >  /* Avoid DNS reverse lookups on server names */
> > >  static bool avoid_dns = true;
> > > -
> > > +int thread_started = false;
> > > +pthread_mutex_t pmutex = PTHREAD_MUTEX_INITIALIZER;
> > > +pthread_cond_t pcond = PTHREAD_COND_INITIALIZER;
> > >  
> > >  TAILQ_HEAD(topdir_list_head, topdir) topdir_list;
> > >  
> > > @@ -361,20 +363,53 @@ gssd_destroy_client(struct clnt_info *clp)
> > >  
> > >  static void gssd_scan(void);
> > >  
> > > +static inline void wait_for_child_and_detach(pthread_t th)
> > > +{
> > > +	pthread_mutex_lock(&pmutex);
> > > +	while (!thread_started)
> > > +		pthread_cond_wait(&pcond, &pmutex);
> > > +	thread_started = false;
> > > +	pthread_mutex_unlock(&pmutex);
> > > +	pthread_detach(th);
> > > +}
> > > +
> > > +/* For each upcall create a thread, detach from the main process
> > > so that
> > > + * resources are released back into the system without the need
> > > for a join.
> > > + * We need to wait for the child thread to start and consume the
> > > event from
> > > + * the file descriptor.
> > > + */
> > >  static void
> > >  gssd_clnt_gssd_cb(int UNUSED(fd), short UNUSED(which), void
> > > *data)
> > >  {
> > >  	struct clnt_info *clp = data;
> > > -
> > > -	handle_gssd_upcall(clp);
> > > +	pthread_t th;
> > > +	int ret;
> > > +
> > > +	ret = pthread_create(&th, NULL, (void
> > > *)handle_gssd_upcall,
> > > +				(void *)clp);
> > > +	if (ret != 0) {
> > > +		printerr(0, "ERROR: pthread_create failed: ret
> > > %d: %s\n",
> > > +			 ret, strerror(errno));
> > > +		return;
> > > +	}
> > > +	wait_for_child_and_detach(th);
> > >  }
> > >  
> > >  static void
> > >  gssd_clnt_krb5_cb(int UNUSED(fd), short UNUSED(which), void
> > > *data)
> > >  {
> > >  	struct clnt_info *clp = data;
> > > -
> > > -	handle_krb5_upcall(clp);
> > > +	pthread_t th;
> > > +	int ret;
> > > +
> > > +	ret = pthread_create(&th, NULL, (void
> > > *)handle_krb5_upcall,
> > > +				(void *)clp);
> > > +	if (ret != 0) {
> > > +		printerr(0, "ERROR: pthread_create failed: ret
> > > %d: %s\n",
> > > +			 ret, strerror(errno));
> > > +		return;
> > > +	}
> > > +	wait_for_child_and_detach(th);
> > >  }
> > >  
> > >  static struct clnt_info *
> > > diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
> > > index c6937c5..565bce3 100644
> > > --- a/utils/gssd/gssd.h
> > > +++ b/utils/gssd/gssd.h
> > > @@ -36,6 +36,7 @@
> > >  #include 
> > >  #include 
> > >  #include 
> > > +#include 
> > >  
> > >  #ifndef GSSD_PIPEFS_DIR
> > >  #define GSSD_PIPEFS_DIR		"/var/lib/nfs/rpc_pipefs"
> > > @@ -61,6 +62,10 @@ extern int			root_uses_ma
> > > chine_creds;
> > >  extern unsigned int 		context_timeout;
> > >  extern unsigned int rpc_timeout;
> > >  extern char			*preferred_realm;
> > > +extern pthread_mutex_t ple_lock;
> > > +extern pthread_cond_t pcond;
> > > +extern pthread_mutex_t pmutex;
> > > +extern int thread_started;
> > >  
> > >  struct clnt_info {
> > >  	TAILQ_ENTRY(clnt_info)	list;
> > > diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> > > index 1ef68d8..e2e95dc 100644
> > > --- a/utils/gssd/gssd_proc.c
> > > +++ b/utils/gssd/gssd_proc.c
> > > @@ -629,36 +629,6 @@ process_krb5_upcall(struct clnt_info *clp,
> > > uid_t uid, int fd, char *tgtname,
> > >  	if (uid != 0 || (uid == 0 && root_uses_machine_creds ==
> > > 0 &&
> > >  				service == NULL)) {
> > >  
> > > -		/* already running as uid 0 */
> > > -		if (uid == 0)
> > > -			goto no_fork;
> > > -
> > > -		pid = fork();
> > > -		switch(pid) {
> > > -		case 0:
> > > -			/* Child: fall through to rest of
> > > function */
> > > -			childpid = getpid();
> > > -			unsetenv("KRB5CCNAME");
> > > -			printerr(2, "CHILD forked pid %d \n",
> > > childpid);
> > > -			break;
> > > -		case -1:
> > > -			/* fork() failed! */
> > > -			printerr(0, "WARNING: unable to fork()
> > > to handle"
> > > -				"upcall: %s\n",
> > > strerror(errno));
> > > -			return;
> > > -		default:
> > > -			/* Parent: just wait on child to exit
> > > and return */
> > > -			do {
> > > -				pid = wait(&err);
> > > -			} while(pid == -1 && errno != -ECHILD);
> > > -
> > > -			if (WIFSIGNALED(err))
> > > -				printerr(0, "WARNING: forked
> > > child was killed"
> > > -					 "with signal %d\n",
> > > WTERMSIG(err));
> > > -			return;
> > > -		}
> > > -no_fork:
> > > -
> > >  		auth = krb5_not_machine_creds(clp, uid, tgtname,
> > > &downcall_err,
> > >  						&err,
> > > &rpc_clnt);
> > >  		if (err)
> > > @@ -735,12 +705,28 @@ out_return_error:
> > >  	goto out;
> > >  }
> > >  
> > > +/* signal to the parent thread that we have read from the file
> > > descriptor.
> > > + * it should allow the parent to proceed to poll on the
> > > descriptor for
> > > + * the next upcall from the kernel.
> > > + */
> > > +static void
> > > +signal_parent_event_consumed(void)
> > > +{
> > > +	pthread_mutex_lock(&pmutex);
> > > +	thread_started = true;
> > > +	pthread_cond_signal(&pcond);
> > > +	pthread_mutex_unlock(&pmutex);
> > > +}
> > > +
> > >  void
> > >  handle_krb5_upcall(struct clnt_info *clp)
> > >  {
> > >  	uid_t			uid;
> > > +	int 			status;
> > >  
> > > -	if (read(clp->krb5_fd, &uid, sizeof(uid)) <
> > > (ssize_t)sizeof(uid)) {
> > > +	status = read(clp->krb5_fd, &uid, sizeof(uid)) <
> > > (ssize_t)sizeof(uid);
> > > +	signal_parent_event_consumed();
> > > +	if (status) {
> > >  		printerr(0, "WARNING: failed reading uid from
> > > krb5 "
> > >  			    "upcall pipe: %s\n",
> > > strerror(errno));
> > >  		return;
> > > @@ -765,6 +751,7 @@ handle_gssd_upcall(struct clnt_info *clp)
> > >  	char			*enctypes = NULL;
> > >  
> > >  	lbuflen = read(clp->gssd_fd, lbuf, sizeof(lbuf));
> > > +	signal_parent_event_consumed();
> > >  	if (lbuflen <= 0 || lbuf[lbuflen-1] != '\n') {
> > >  		printerr(0, "WARNING: handle_gssd_upcall: "
> > >  			    "failed reading request\n");
> > > diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> > > index 8ef8184..3328696 100644
> > > --- a/utils/gssd/krb5_util.c
> > > +++ b/utils/gssd/krb5_util.c
> > > @@ -128,6 +128,7 @@
> > >  
> > >  /* Global list of principals/cache file names for machine
> > > credentials */
> > >  struct gssd_k5_kt_princ *gssd_k5_kt_princ_list = NULL;
> > > +pthread_mutex_t ple_lock = PTHREAD_MUTEX_INITIALIZER;
> > >  
> > >  #ifdef HAVE_SET_ALLOWABLE_ENCTYPES
> > >  int limit_to_legacy_enctypes = 0;
> > > @@ -586,10 +587,12 @@ get_ple_by_princ(krb5_context context,
> > > krb5_principal princ)
> > >  
> > >  	/* Need to serialize list if we ever become multi-
> > > threaded! */
> > >  
> > > +	pthread_mutex_lock(&ple_lock);
> > >  	ple = find_ple_by_princ(context, princ);
> > >  	if (ple == NULL) {
> > >  		ple = new_ple(context, princ);
> > >  	}
> > > +	pthread_mutex_unlock(&ple_lock);
> > >  
> > >  	return ple;
> > >  }
> > Looks good. One thing that might be neat as a follow up is to make
> > the
> > thread_started variable a per-clnt thing. I don't think there's any
> > reason to serialize I/O to different fds there.
> Since there is only 1 main thread that reads/creates the event for
> the thread to consume I don’t see how we can have multiple threads
> started with different fds. Just to clarify, main thread only waits
> for the upcall info to be consumed from the fd not for the process of
> the upcall. Then, multiple upcalls can be processing at the same
> time.
> 

Ok, yeah you do need to serialize there because of the event handling.
You can't return from the event handler until the read event has been
consumed or or it would get mighty confused.

Still, I wonder -- might it be cleaner to do the read in the context of
the event loop and then just spawn a detached thread to handle the
result?

It seems like that would be less back-and-forth between the parent and
child. You also wouldn't need the pmutex and condition variable with
that. You would have to come up with some way to pass both "clp" and
"uid" to the child however.

Either way, that could be reworked later and this is a clear
improvement. Nice work, btw!
-- 
Jeff Layton <jlayton@poochiereds.net>

