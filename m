From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [andrew.phillips-5jPdWwX6g8k@public.gmane.org:
	Bug#451402:	nfs-kernel-server:	rpc.svcgssd needs option to
	authenticate using different	hostname]
Date: Sun, 18 Nov 2007 12:35:41 -0500
Message-ID: <1195407341.7893.9.camel@heimdal.trondhjem.org>
References: <20071118110551.GA10815@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ito3l-0005NH-Ou
	for nfs@lists.sourceforge.net; Sun, 18 Nov 2007 09:35:53 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ito3j-00015q-Ac
	for nfs@lists.sourceforge.net; Sun, 18 Nov 2007 09:35:54 -0800
In-Reply-To: <20071118110551.GA10815-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Sun, 2007-11-18 at 12:05 +0100, Steinar H. Gunderson wrote:
> Hi,
> 
> I'm sending this on from a user. Does the patch seem reasonable to you?

I partially agree with what Andrew says about the long run: we should
indeed allow a multi-homed server to authenticate using any key in the
keytab, however with the additional caveat that we should check the
server IP address against the keytab name.
My objection to this patch would be that I'm a bit worried about adding
'temporary' options that will need to be maintained indefinitely even
when a better solution becomes available.

How about instead trying to add the server IP address to the upcall
(should be trivial since this is saved in the rqstp->rq_daddr). Then you
can teach rpc.gssd to use that information (when available) to determine
which hostname it is supposed to use.

Cheers
  Trond

> /* Steinar */
> email message attachment
> > -------- Forwarded Message --------
> > From: Andrew Phillips <andrew.phillips-5jPdWwX6g8k@public.gmane.org>
> > Reply-To: Andrew Phillips <andrew.phillips-5jPdWwX6g8k@public.gmane.org>,
> > 451402@bugs.debian.org
> > To: Debian Bug Tracking System <submit@bugs.debian.org>
> > Subject: Bug#451402: nfs-kernel-server: rpc.svcgssd needs option to
> > authenticate using different hostname
> > Date: Thu, 15 Nov 2007 14:11:29 -0400
> > 
> > Package: nfs-kernel-server
> > Version: 1:1.1.1~git-20070929-1
> > Severity: wishlist
> > Tags: patch
> > 
> > Normally you can only connect to NFS using Kerberos using the hostname
> > of the server.  If you have a cluster where the NFS service can
> > failover between machines, using heartbeat for instance, you would
> > want to connect to a single address.  This does not work with
> > rpc.svcgssd as it will only authenticate machines connecting to it's
> > hostname, not another address the machine handles.  For instance, if
> > you have servers nfs1.foo and nfs2.foo, you might want to have an
> > address nfs.foo that passes between each other.
> > 
> > The following two patches (one for 1.1.1~git-2007092 (sid), and one
> > for 1.0.10 (etch)) add an option to rpc.svcgssd to specify the
> > hostname (-h) you will be connecting to it by.  They also remove
> > references to options that rpc.svcgssd does not support.  
> > 
> > Ideally, in the long run nfs-utils would provide an option similar to
> > what recent openssh versions use, and authenticate with any key in the
> > keytab.
> > 
> > Patch for 1.1.1~git-2007092:
> > diff -rud nfs-utils-1.1.1~git-20070929/utils/gssd/svcgssd.c nfs-utils-1.1.1~git-20070929-krb/utils/gssd/svcgssd.c
> > --- nfs-utils-1.1.1~git-20070929/utils/gssd/svcgssd.c	2007-09-29 09:55:13.000000000 -0300
> > +++ nfs-utils-1.1.1~git-20070929-krb/utils/gssd/svcgssd.c	2007-11-15 10:43:33.000000000 -0400
> > @@ -155,7 +155,7 @@
> >  static void
> >  usage(char *progname)
> >  {
> > -	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i]\n",
> > +	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i] [-h hostname]\n",
> >  		progname);
> >  	exit(1);
> >  }
> > @@ -171,8 +171,9 @@
> >  	int opt;
> >  	extern char *optarg;
> >  	char *progname;
> > +	char *servicename = NULL;
> >  
> > -	while ((opt = getopt(argc, argv, "fivrnp:")) != -1) {
> > +	while ((opt = getopt(argc, argv, "fivrnh:")) != -1) {
> >  		switch (opt) {
> >  			case 'f':
> >  				fg = 1;
> > @@ -189,6 +190,12 @@
> >  			case 'r':
> >  				rpc_verbosity++;
> >  				break;
> > +			case 'h':
> > +				servicename = calloc(strlen(optarg) + strlen(GSSD_SERVICE_NAME) + 2, sizeof(char));
> > +
> > +				/* GSSAPI needs @ instead of / between service name and hostname */
> > +				snprintf(servicename, strlen(optarg) + strlen(GSSD_SERVICE_NAME) + 2, "%s@%s", GSSD_SERVICE_NAME, optarg);
> > +				break;
> >  			default:
> >  				usage(argv[0]);
> >  				break;
> > @@ -228,7 +235,10 @@
> >  	signal(SIGTERM, sig_die);
> >  	signal(SIGHUP, sig_hup);
> >  
> > -	if (get_creds && !gssd_acquire_cred(GSSD_SERVICE_NAME)) {
> > +	if (servicename == NULL)
> > +		servicename = GSSD_SERVICE_NAME;
> > +
> > +	if (get_creds && !gssd_acquire_cred(servicename)) {
> >                  printerr(0, "unable to obtain root (machine) credentials\n");
> >                  printerr(0, "do you have a keytab entry for "
> >  			    "nfs/<your.host>@<YOUR.REALM> in "
> > Only in nfs-utils-1.1.1~git-20070929-krb/utils/gssd: svcgssd.c.orig
> > diff -rud nfs-utils-1.1.1~git-20070929/utils/gssd/svcgssd.man nfs-utils-1.1.1~git-20070929-krb/utils/gssd/svcgssd.man
> > --- nfs-utils-1.1.1~git-20070929/utils/gssd/svcgssd.man	2007-09-29 09:55:13.000000000 -0300
> > +++ nfs-utils-1.1.1~git-20070929-krb/utils/gssd/svcgssd.man	2007-11-15 10:26:01.000000000 -0400
> > @@ -6,7 +6,7 @@
> >  .SH NAME
> >  rpc.svcgssd \- server-side rpcsec_gss daemon
> >  .SH SYNOPSIS
> > -.B "rpc.svcgssd [-v] [-r] [-i] [-f] [-p pipefsdir]"
> > +.B "rpc.svcgssd [-v] [-r] [-i] [-f] [-h hostname]"
> >  .SH DESCRIPTION
> >  The rpcsec_gss protocol gives a means of using the gss-api generic security
> >  api to provide security for protocols using rpc (in particular, nfs).  Before
> > @@ -35,6 +35,10 @@
> >  .B -i
> >  If the nfsidmap library supports setting debug level,
> >  increases the verbosity of the output (can be specified multiple times).
> > +.TP
> > +.B -h hostname
> > +Specify the hostname to use when looking for the service principal in
> > +the keytab.
> >  
> >  .SH SEE ALSO
> >  .BR rpc.gssd(8),
> > 
> > 
> > Patch for 1.0.10:
> > diff -rud nfs-utils-1.0.10/utils/gssd/svcgssd.c nfs-utils-1.0.10-krb/utils/gssd/svcgssd.c
> > --- nfs-utils-1.0.10/utils/gssd/svcgssd.c	2006-08-07 03:40:50.000000000 -0300
> > +++ nfs-utils-1.0.10-krb/utils/gssd/svcgssd.c	2007-11-15 10:41:58.000000000 -0400
> > @@ -154,7 +154,7 @@
> >  static void
> >  usage(char *progname)
> >  {
> > -	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r]\n",
> > +	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-h hostname]\n",
> >  		progname);
> >  	exit(1);
> >  }
> > @@ -169,8 +169,9 @@
> >  	int opt;
> >  	extern char *optarg;
> >  	char *progname;
> > +	char *servicename = NULL;
> >  
> > -	while ((opt = getopt(argc, argv, "fvrnp:")) != -1) {
> > +	while ((opt = getopt(argc, argv, "fvrnh:")) != -1) {
> >  		switch (opt) {
> >  			case 'f':
> >  				fg = 1;
> > @@ -184,6 +185,12 @@
> >  			case 'r':
> >  				rpc_verbosity++;
> >  				break;
> > +			case 'h':
> > +				servicename = calloc(strlen(optarg) + strlen(GSSD_SERVICE_NAME) + 2, sizeof(char));
> > +
> > +				/* GSSAPI needs @ instead of / between service name and hostname */
> > +				snprintf(servicename, strlen(optarg) + strlen(GSSD_SERVICE_NAME) + 2, "%s@%s", GSSD_SERVICE_NAME, optarg);
> > +				break;
> >  			default:
> >  				usage(argv[0]);
> >  				break;
> > @@ -216,7 +223,10 @@
> >  	signal(SIGTERM, sig_die);
> >  	signal(SIGHUP, sig_hup);
> >  
> > -	if (get_creds && !gssd_acquire_cred(GSSD_SERVICE_NAME)) {
> > +	if (servicename == NULL)
> > +		servicename = GSSD_SERVICE_NAME;
> > +
> > +	if (get_creds && !gssd_acquire_cred(servicename)) {
> >                  printerr(0, "unable to obtain root (machine) credentials\n");
> >                  printerr(0, "do you have a keytab entry for "
> >  			    "nfs/<your.host>@<YOUR.REALM> in "
> > diff -rud nfs-utils-1.0.10/utils/gssd/svcgssd.man nfs-utils-1.0.10-krb/utils/gssd/svcgssd.man
> > --- nfs-utils-1.0.10/utils/gssd/svcgssd.man	2006-08-07 03:40:50.000000000 -0300
> > +++ nfs-utils-1.0.10-krb/utils/gssd/svcgssd.man	2007-11-15 10:27:42.000000000 -0400
> > @@ -6,7 +6,7 @@
> >  .SH NAME
> >  rpc.svcgssd \- server-side rpcsec_gss daemon
> >  .SH SYNOPSIS
> > -.B "rpc.svcgssd [-v] [-r] [-f] [-p pipefsdir]"
> > +.B "rpc.svcgssd [-v] [-r] [-f] [-h hostname]"
> >  .SH DESCRIPTION
> >  The rpcsec_gss protocol gives a means of using the gss-api generic security
> >  api to provide security for protocols using rpc (in particular, nfs).  Before
> > @@ -31,6 +31,10 @@
> >  .B -r
> >  If the rpcsec_gss library supports setting debug level,
> >  increases the verbosity of the output (can be specified multiple times).
> > +.TP
> > +.B -h hostname
> > +Specify the hostname to use when looking for the service principal in
> > +the keytab.
> >  
> >  .SH SEE ALSO
> >  .BR rpc.gssd(8),
> > 
> > -- System Information:
> > Debian Release: lenny/sid
> >   APT prefers testing
> >   APT policy: (500, 'testing'), (500, 'stable')
> > Architecture: i386 (i686)
> > 
> > Kernel: Linux 2.6.22-2-686 (SMP w/2 CPU cores)
> > Locale: LANG=en_CA.UTF-8, LC_CTYPE=en_CA.UTF-8 (charmap=UTF-8)
> > Shell: /bin/sh linked to /bin/bash
> > 
> > Versions of packages nfs-kernel-server depends on:
> > ii  libblkid1         1.40.2-1               block device id library
> > ii  libc6             2.6.1-1+b1             GNU C Library: Shared libraries
> > ii  libcomerr2        1.40.2-1               common error description library
> > ii  libgssglue1       0.1-1                  mechanism-switch gssapi library
> > ii  libkrb53          1.6.dfsg.3~beta1-2     MIT Kerberos runtime libraries
> > ii  libnfsidmap2      0.20-0                 An nfs idmapping library
> > ii  librpcsecgss3     0.17-1                 allows secure rpc communication us
> > ii  libwrap0          7.6.dbs-14             Wietse Venema's TCP wrappers libra
> > ii  lsb-base          3.1-24                 Linux Standard Base 3.1 init scrip
> > ii  nfs-common        1:1.1.1~git-20070929-1 NFS support files common to client
> > ii  ucf               3.003                  Update Configuration File: preserv
> > 
> > nfs-kernel-server recommends no packages.
> > 
> > -- no debconf information
> > 
> > 
> > 
> > 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2005.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________ NFS maillist - NFS@lists.sourceforge.net https://lists.sourceforge.net/lists/listinfo/nfs _______________________________________________ Please note that nfs@lists.sourceforge.net is being discontinued. Please subscribe to linux-nfs@vger.kernel.org instead. http://vger.kernel.org/vger-lists.html#linux-nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

