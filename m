From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] portmap: misc stuff
Date: Tue, 13 May 2008 11:25:20 +1000
Message-ID: <18472.60928.592008.312730@notabene.brown>
References: <20080511001719.GA19204@nibiru.local>
	<18471.35491.391564.960994@notabene.brown>
	<20080512123646.GB1500@nibiru.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: weigelt-EU+a56NjgY8@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40107 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756325AbYEMBZd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 May 2008 21:25:33 -0400
In-Reply-To: message from Enrico Weigelt on Monday May 12
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday May 12, weigelt-EU+a56NjgY8@public.gmane.org wrote:
> * Neil Brown <neilb@suse.de> schrieb:
> 
> Hi,
> 
> > I've made a few little changes like removing spaces from the end of
> > the line and a little reformatting.  I also moved the usage messages
> > into a separate function so that the lines didn't get so long.
> 
> Doesnt seem to be in git yet :(

It is now (I wanted the man page updates to be in the same commit).

> 
> > If you could make corresponding updates to the man page, I'll include
> > those and push it all into .git.
> 
> Done. Here's a patch against your latest git.

Thanks.

> 
> > > BTW: is there a maillist for portmap development ?
> > 
> > No, there isn't really much development...
> > 
> > Probably linux-nfs@vger.kernel.org would be best, as NFS is the main
> > user of SUNRPC and hence portmap.
> 
> Okay, subscribed there. Maybe we could move this discussion there.
> 

Done.

Thanks again,
NeilBrown


> 
> cu
> -- 
> ---------------------------------------------------------------------
>  Enrico Weigelt    ==   metux IT service - http://www.metux.de/
> ---------------------------------------------------------------------
>  Please visit the OpenSource QM Taskforce:
>  	http://wiki.metux.de/public/OpenSource_QM_Taskforce
>  Patches / Fixes for a lot dozens of packages in dozens of versions:
> 	http://patches.metux.de/
> ---------------------------------------------------------------------
> Index: portmap.c
> ===================================================================
> --- portmap.c	(.../git-200805102115)	(revision 184)
> +++ portmap.c	(.../metux-6.0.0.2)	(revision 184)
> @@ -99,14 +99,8 @@
>  #include <stdlib.h>
>  #include <pwd.h>
>  
> -#ifndef LOG_PERROR
> -#define LOG_PERROR 0
> -#endif
> +#include "config.h"
>  
> -#ifndef LOG_DAEMON
> -#define LOG_DAEMON 0
> -#endif
> -
>  /* Older SYSV. */
>  #if !defined(SIGCHLD) && defined(SIGCLD)
>  #define SIGCHLD      SIGCLD
> @@ -149,13 +143,9 @@
>  #endif
>  #endif
>  
> -#ifdef DAEMON_UID
>  int daemon_uid = DAEMON_UID;
>  int daemon_gid = DAEMON_GID;
> -#else
> -int daemon_uid = 1;
> -int daemon_gid = 1;
> -#endif
> +const char* mapping_file = PORTMAP_MAPPING_FILE;
>  
>  /*
>   * We record with each registration a flag telling whether it was
> @@ -169,6 +159,18 @@
>  	int priv;
>  };
>  
> +static inline int __getuid(const char* username)
> +{
> +    struct passwd* pw = getpwnam(username);
> +
> +    if (!pw)
> +	return 0;
> +    
> +    daemon_uid = pw->pw_uid;
> +    daemon_gid = pw->pw_gid;
> +    return 1;
> +}
> +
>  int
>  main(int argc, char **argv)
>  {
> @@ -184,13 +186,26 @@
>  	int foreground = 0;
>  	int have_uid = 0;
>  
> -	while ((c = getopt(argc, argv, "Vdflt:vi:u:g:")) != EOF) {
> +	while ((c = getopt(argc, argv, "hVdfFlt:vi:u:U:g:m:")) != EOF) {
>  		switch (c) {
>  
>  		case 'V':
> -			printf("portmap version 6.0 - 2007-May-11\n");
> +			printf("portmap version 6.0.0.1 - 2008-05-10\n");
>  			exit(1);
>  
> +		case 'm':
> +			mapping_file = strdup(optarg);
> +			break;
> +
> +		case 'U':
> +			// try to fetch user-given uid/gid by name
> +			if (!__getuid(optarg))
> +			{
> +			    fprintf(stderr,"portmap: illegal username: \"%s\"\n", optarg);
> +			    exit(1);
> +			}
> +			have_uid = 1;
> +			break;
>  		case 'u':
>  			daemon_uid = atoi(optarg);
>  			if (daemon_uid <= 0) {
> @@ -214,6 +229,10 @@
>  		case 'f':
>  			foreground = 1;
>  			break;
> +		case 'F':
> +			// run in foreground, but still log as usual
> +			foreground = 2;
> +			break;
>  
>  		case 't':
>  			chroot_path = optarg;
> @@ -229,20 +248,22 @@
>  		case 'i':
>  			have_bindaddr = inet_aton(optarg, &bindaddr);
>  			break;
> +		case 'h':
>  		default:
>  			fprintf(stderr,
> -				"usage: %s [-dflv] [-t dir] [-i address] "
> -				"[-u uid] [-g gid]\n",
> +				"usage: %s [-dfFlv] [-t dir] [-i address] [-u uid] [-g gid] [-U username] \n",
>  				argv[0]);
> -			fprintf(stderr, "-d: debugging mode\n");
> -			fprintf(stderr,
> -				"-f: don't daemonize, log to standard error\n");
> -			fprintf(stderr, "-t dir: chroot into dir\n");
> -			fprintf(stderr, "-v: verbose logging\n");
> -			fprintf(stderr, "-i address: bind to address\n");
> -			fprintf(stderr, "-l: same as -i 127.0.0.1\n");
> -			fprintf(stderr, "-u uid : setuid to this uid\n");
> -			fprintf(stderr, "-g uid : setgid to this gid\n");
> +			fprintf(stderr, "-v                verbose logging\n");
> +			fprintf(stderr, "-d                debugging mode\n");
> +			fprintf(stderr,	"-f                don't daemonize, log to standard error\n");
> +			fprintf(stderr, "-F                don't daemonize, log as usual\n");
> +			fprintf(stderr, "-t <dir>          chroot into dir\n");
> +			fprintf(stderr, "-i <address>      bind to address\n");
> +			fprintf(stderr, "-l                same as -i 127.0.0.1\n");
> +			fprintf(stderr, "-u <uid>          run as this uid (default: %d)\n", DAEMON_UID);
> +			fprintf(stderr, "-g <uid>          run as this gid (default: %d)\n", DAEMON_GID);
> +			fprintf(stderr, "-U <username>     suid/sgid to this user\n");
> +			fprintf(stderr, "-m <mapfile>      specify the mapping file name (default: " PORTMAP_MAPPING_FILE ")\n");
>  			exit(1);
>  		}
>  	}
> @@ -253,20 +274,15 @@
>  	}
>  
>  #ifdef LOG_DAEMON
> -	openlog("portmap", LOG_PID|LOG_NDELAY | ( foreground ? LOG_PERROR : 0),
> +	openlog("portmap", LOG_PID|LOG_NDELAY | ( (foreground==1) ? LOG_PERROR : 0),
>  	    FACILITY);
>  #else
> -	openlog("portmap", LOG_PID|LOG_NDELAY | ( foreground ? LOG_PERROR : 0));
> +	openlog("portmap", LOG_PID|LOG_NDELAY | ( (foreground==1) ? LOG_PERROR : 0));
>  #endif
>  
>  #ifdef RPCUSER
>  	if (!have_uid) {
> -		struct passwd *pwent;
> -		pwent = getpwnam(RPCUSER);
> -		if (pwent) {
> -			daemon_uid = pwent->pw_uid;
> -			daemon_gid = pwent->pw_gid;
> -		} else
> +		if (!__getuid(RPCUSER)) 
>  			syslog(LOG_WARNING, "user '" RPCUSER
>  			       "' not found, reverting to default uid");
>  	}
> @@ -369,7 +385,7 @@
>  
>  	(void)svc_register(xprt, PMAPPROG, PMAPVERS, reg_service, FALSE);
>  
> -	store_fd = open("/var/run/portmap_mapping", O_RDWR|O_CREAT, 0600);
> +	store_fd = open(mapping_file, O_RDWR|O_CREAT, PORTMAP_MAPPING_FMODE);
>  	load_table();
>  
>  	/* additional initializations */
> Index: portmap.8
> ===================================================================
> --- portmap.8	(.../git-200805102115)	(revision 184)
> +++ portmap.8	(.../metux-6.0.0.2)	(revision 184)
> @@ -33,7 +33,7 @@
>  .\"     from: @(#)portmap.8	5.3 (Berkeley) 3/16/91
>  .\"	$Id: portmap.8,v 1.2 2004/04/03 09:30:21 herbert Exp $
>  .\"
> -.Dd Apr 20, 2007
> +.Dd May 12, 2008
>  .Dt PORTMAP 8
>  .Os BSD 4.3
>  .Sh NAME
> @@ -47,6 +47,7 @@
>  .Nm portmap
>  .Op Fl d
>  .Op Fl f
> +.Op Fl F
>  .Op Fl t Ar dir
>  .Op Fl v
>  .Op Fl V
> @@ -117,6 +118,8 @@
>  from running as a daemon,
>  and causes log messages
>  to be printed to the standard error output.
> +.It Fl F 
> +(foreground) same as -f, but logging as usual
>  .It Fl t Ar dir
>  (chroot) tell
>  .Nm portmap
> @@ -127,6 +130,9 @@
>  .Ar dir
>  should be empty, not writeable by the daemon user, and preferably on a
>  filesystem mounted read-only, noexec, nodev, and nosuid.
> +.It Fl m Ar file
> +(mapfile) speficy an alternative mapping 
> +.Ar file
>  .It Fl u Ar uid
>  .It Fl g Ar gid
>  Set the user-id and group-id of the running process to those given,
> @@ -138,6 +144,10 @@
>  .Nm RPCUSER
>  and use the uid and gid of that user.
>  ..
> +.It Fl U Ar username
> +Lets 
> +.Nm portmap
> +run under this user (uid/gid) rather than compiled-in defaults of DEAMON_UID/DAEMON_GID.
>  .It Fl v
>  (verbose) run
>  .Nm portmap
> Index: config.h
> ===================================================================
> --- config.h	(.../git-200805102115)	(revision 0)
> +++ config.h	(.../metux-6.0.0.2)	(revision 184)
> @@ -0,0 +1,33 @@
> +
> +#ifndef __PORTMAP_CONFIG_H
> +#define __PORTMAP_CONFIG_H
> +
> +#ifndef PORTMAP_MAPPING_FILE
> +#define PORTMAP_MAPPING_FILE	"/var/run/portmap_mapping"
> +#endif
> +
> +#ifndef PORTMAP_MAPPING_FMODE
> +#define PORTMAP_MAPPING_FMODE	0600
> +#endif
> +
> +#ifndef LOG_PERROR
> +#define LOG_PERROR		0
> +#endif
> +
> +#ifndef RPCUSER
> +#define RPCUSER			"bin"
> +#endif
> +
> +#ifndef LOG_DAEMON
> +#define LOG_DAEMON		0
> +#endif
> +
> +#ifndef DAEMON_UID
> +#define DAEMON_UID		1
> +#endif
> +
> +#ifndef DAEMON_GID
> +#define DAEMON_GID		1
> +#endif
> +
> +#endif
> Index: Makefile
> ===================================================================
> --- Makefile	(.../git-200805102115)	(revision 184)
> +++ Makefile	(.../metux-6.0.0.2)	(revision 184)
> @@ -27,6 +27,38 @@
>  endif
>  endif
>  
> +ifeq ($(PREFIX),)
> +PREFIX = /usr
> +endif
> +ifeq ($(SBINDIR),)
> +SBINDIR = $(PREFIX)/sbin
> +endif
> +ifeq ($(DATADIR),)
> +DATADIR = $(PREFIX)/share
> +endif
> +ifeq ($(MANDIR),)
> +MANDIR = $(DATADIR)/man
> +endif
> +ifeq ($(MAN8DIR),)
> +MAN8DIR = $(MANDIR)/man8
> +endif
> +
> +## backwards compatibility to older distro builders
> +ifeq ($(DESTDIR),)
> +DESTDIR = $(BASEDIR)
> +endif
> +
> +ifeq ($(INSTALL),)
> +INSTALL = install
> +endif
> +ifeq ($(INSTALL_MAN),)
> +INSTALL_MAN = $(INSTALL) -o root -g root -m 0644
> +endif
> +ifeq ($(INSTALL_BIN),)
> +INSTALL_BIN = $(INSTALL) -s -o root -g root -m 0755
> +endif
> +
> +
>  # Comment out if your RPC library does not allocate privileged ports for
>  # requests from processes with root privilege, or the new portmap will
>  # always reject requests to register/unregister services on privileged
> @@ -135,15 +167,28 @@
>  portmap.man : portmap.8
>  	sed $(MAN_SED) < portmap.8 > portmap.man
>  
> -DESTDIR = $(BASEDIR)
> -install: all
> -	install -o root -g root -m 0755 portmap $(DESTDIR)/sbin
> -	install -o root -g root -m 0755 pmap_dump $(DESTDIR)/sbin
> -	install -o root -g root -m 0755 pmap_set $(DESTDIR)/sbin
> -	install -o root -g root -m 0644 portmap.man $(DESTDIR)/usr/share/man/man8/portmap.8
> -	install -o root -g root -m 0644 pmap_dump.8 $(DESTDIR)/usr/share/man/man8
> -	install -o root -g root -m 0644 pmap_set.8 $(DESTDIR)/usr/share/man/man8
> +install: all install-portmap install-pmap_dump install-pmap_set install-man
>  
> +install-dirs-sbin:
> +	mkdir -p $(DESTDIR)$(SBINDIR)
> +
> +install-dirs-man:
> +	mkdir -p $(DESTDIR)$(MAN8DIR)
> +
> +install-man:	install-dirs-man
> +	$(INSTALL_MAN) portmap.man $(DESTDIR)$(MAN8DIR)/portmap.8
> +	$(INSTALL_MAN) pmap_dump.8 $(DESTDIR)$(MAN8DIR)/pmap_dump.8
> +	$(INSTALL_MAN) pmap_set.8  $(DESTDIR)$(MAN8DIR)/map_set.8	
> +
> +install-pmap_dump:	pmap_dump	install-dirs-sbin
> +	$(INSTALL_BIN)  pmap_dump	$(DESTDIR)$(SBINDIR)
> +
> +install-pmap_set:	pmap_set	install-dirs-sbin
> +	$(INSTALL_BIN)	pmap_set	$(DESTDIR)$(SBINDIR)
> +
> +install-portmap:	portmap 	install-dirs-sbin
> +	$(INSTALL_BIN)  portmap		$(DESTDIR)$(SBINDIR)
> +
>  clean:
>  	rm -f *.o portmap pmap_dump pmap_set from_local \
>  	    core portmap.man
