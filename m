From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 03/10] nfs-utils: convert rpc.nfsd to use xlog()
Date: Wed, 3 Jun 2009 16:22:14 -0400
Message-ID: <20090603162214.2aeed744@tlielax.poochiereds.net>
References: <1244058763-10352-1-git-send-email-jlayton@redhat.com>
	<1244058763-10352-4-git-send-email-jlayton@redhat.com>
	<99D20D44-A4FC-43A5-B85A-F67B8EB166F4@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36175 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823AbZFCUWU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 16:22:20 -0400
In-Reply-To: <99D20D44-A4FC-43A5-B85A-F67B8EB166F4@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 3 Jun 2009 16:01:24 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jun 3, 2009, at 3:52 PM, Jeff Layton wrote:
> 
> > ...and add a --debug option to make nfsd log messages to stderr.
> >
> > rpc.nfsd is usually run out of init scripts in which case logging to
> > syslog makes more sense. Make that the default and add a switch that
> > makes log messages go to stderr. Eventually however nfsd has to close
> > stderr, at which point the program switches to logging to syslog
> > unconditionally.
> >
> > For now, stderr gets closed rather early, so --debug isn't terribly
> > helpful. Later patches will make rpc.nfsd delay closing of stderr  
> > longer
> > which should make it more useful.
> >
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > support/nfs/nfssvc.c |   46 +++++++++++++++++-------------------
> > utils/nfsd/nfsd.c    |   63 ++++++++++++++++++++++++++++++ 
> > +-------------------
> > 2 files changed, 61 insertions(+), 48 deletions(-)
> >
> > diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
> > index 33c15a7..3e6bd31 100644
> > --- a/support/nfs/nfssvc.c
> > +++ b/support/nfs/nfssvc.c
> > @@ -16,10 +16,9 @@
> > #include <unistd.h>
> > #include <fcntl.h>
> > #include <errno.h>
> > -#include <syslog.h>
> > -
> >
> > #include "nfslib.h"
> > +#include "xlog.h"
> >
> > #define NFSD_PORTS_FILE     "/proc/fs/nfsd/portlist"
> > #define NFSD_VERS_FILE    "/proc/fs/nfsd/versions"
> > @@ -57,13 +56,13 @@ nfssvc_setfds(int port, unsigned int ctlbits,  
> > char *haddr)
> > 	if (NFSCTL_UDPISSET(ctlbits)) {
> > 		udpfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
> > 		if (udpfd < 0) {
> > -			syslog(LOG_ERR, "nfssvc: unable to create UPD socket: "
> > -				"errno %d (%s)\n", errno, strerror(errno));
> > +			xlog(L_ERROR, "unable to create UDP socket: "
> > +				"errno %d (%m)", errno);
> > 			exit(1);
> > 		}
> > 		if (bind(udpfd, (struct  sockaddr  *)&sin, sizeof(sin)) < 0){
> > -			syslog(LOG_ERR, "nfssvc: unable to bind UPD socket: "
> > -				"errno %d (%s)\n", errno, strerror(errno));
> > +			xlog(L_ERROR, "unable to bind UDP socket: "
> > +				"errno %d (%m)", errno);
> > 			exit(1);
> > 		}
> > 	}
> > @@ -71,32 +70,32 @@ nfssvc_setfds(int port, unsigned int ctlbits,  
> > char *haddr)
> > 	if (NFSCTL_TCPISSET(ctlbits)) {
> > 		tcpfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
> > 		if (tcpfd < 0) {
> > -			syslog(LOG_ERR, "nfssvc: unable to createt tcp socket: "
> > -				"errno %d (%s)\n", errno, strerror(errno));
> > +			xlog(L_ERROR, "unable to createt tcp socket: "
> > +				"errno %d (%m)", errno);
> > 			exit(1);
> > 		}
> > 		if (setsockopt(tcpfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)) <  
> > 0) {
> > -			syslog(LOG_ERR, "nfssvc: unable to set SO_REUSEADDR: "
> > -				"errno %d (%s)\n", errno, strerror(errno));
> > +			xlog(L_ERROR, "unable to set SO_REUSEADDR: "
> > +				"errno %d (%m)", errno);
> > 			exit(1);
> > 		}
> > 		if (bind(tcpfd, (struct  sockaddr  *)&sin, sizeof(sin)) < 0){
> > -			syslog(LOG_ERR, "nfssvc: unable to bind TCP socket: "
> > -				"errno %d (%s)\n", errno, strerror(errno));
> > +			xlog(L_ERROR, "unable to bind TCP socket: "
> > +				"errno %d (%m)", errno);
> > 			exit(1);
> > 		}
> > 		if (listen(tcpfd, 64) < 0){
> > -			syslog(LOG_ERR, "nfssvc: unable to create listening socket: "
> > -				"errno %d (%s)\n", errno, strerror(errno));
> > +			xlog(L_ERROR, "unable to create listening socket: "
> > +				"errno %d (%m)", errno);
> > 			exit(1);
> > 		}
> > 	}
> > 	if (udpfd >= 0) {
> > 		snprintf(buf, BUFSIZ,"%d\n", udpfd);
> > 		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
> > -			syslog(LOG_ERR,
> > -			       "nfssvc: writing fds to kernel failed: errno %d (%s)",
> > -			       errno, strerror(errno));
> > +			xlog(L_ERROR,
> > +			       "writing fds to kernel failed: errno %d (%m)",
> > +			       errno);
> > 		}
> > 		close(fd);
> > 		fd = -1;
> > @@ -106,9 +105,9 @@ nfssvc_setfds(int port, unsigned int ctlbits,  
> > char *haddr)
> > 			fd = open(NFSD_PORTS_FILE, O_WRONLY);
> > 		snprintf(buf, BUFSIZ,"%d\n", tcpfd);
> > 		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
> > -			syslog(LOG_ERR,
> > -			       "nfssvc: writing fds to kernel failed: errno %d (%s)",
> > -			       errno, strerror(errno));
> > +			xlog(L_ERROR,
> > +			       "writing fds to kernel failed: errno %d (%m)",
> > +			       errno);
> > 		}
> > 	}
> > 	close(fd);
> > @@ -139,10 +138,9 @@ nfssvc_versbits(unsigned int ctlbits, int  
> > minorvers4)
> > 				    minorvers4 > 0 ? '+' : '-',
> > 				    n);
> > 	snprintf(ptr+off, BUFSIZ - off, "\n");
> > -	if (write(fd, buf, strlen(buf)) != strlen(buf)) {
> > -		syslog(LOG_ERR, "nfssvc: Setting version failed: errno %d (%s)",
> > -			errno, strerror(errno));
> > -	}
> > +	if (write(fd, buf, strlen(buf)) != strlen(buf))
> > +		xlog(L_ERROR, "Setting version failed: errno %d (%m)", errno);
> > +
> > 	close(fd);
> >
> > 	return;
> > diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> > index c7bd003..6dfea67 100644
> > --- a/utils/nfsd/nfsd.c
> > +++ b/utils/nfsd/nfsd.c
> > @@ -18,13 +18,13 @@
> > #include <string.h>
> > #include <errno.h>
> > #include <getopt.h>
> > -#include <syslog.h>
> > #include <netdb.h>
> > #include <sys/socket.h>
> > #include <netinet/in.h>
> > #include <arpa/inet.h>
> >
> > #include "nfslib.h"
> > +#include "xlog.h"
> >
> > static void	usage(const char *);
> >
> > @@ -37,6 +37,7 @@ static struct option longopts[] =
> > 	{ "no-udp", 0, 0, 'U' },
> > 	{ "port", 1, 0, 'P' },
> > 	{ "port", 1, 0, 'p' },
> > +	{ "debug", 0, 0, 'd' },
> > 	{ NULL, 0, 0, 0 }
> > };
> > unsigned int protobits = NFSCTL_ALLBITS;
> > @@ -50,7 +51,7 @@ main(int argc, char **argv)
> > 	int	count = 1, c, error, port, fd, found_one;
> > 	struct servent *ent;
> > 	struct hostent *hp;
> > -	char *p;
> > +	char *p, *progname;
> >
> > 	ent = getservbyname ("nfs", "udp");
> > 	if (ent != NULL)
> > @@ -58,8 +59,22 @@ main(int argc, char **argv)
> > 	else
> > 		port = 2049;
> >
> > -	while ((c = getopt_long(argc, argv, "H:hN:p:P:TU", longopts,  
> > NULL)) != EOF) {
> > +	progname = strdup(basename(argv[0]));
> > +	if (!progname) {
> > +		fprintf(stderr, "%s: unable to allocate memory.\n", argv[0]);
> > +		exit(1);
> > +	}
> > +
> > +	xlog_syslog(1);
> > +	xlog_stderr(0);
> > +
> > +	while ((c = getopt_long(argc, argv, "dH:hN:p:P:TU", longopts,  
> > NULL)) != EOF) {
> > 		switch(c) {
> > +		case 'd':
> > +			xlog_config(D_ALL, 1);
> > +			xlog_syslog(0);
> > +			xlog_stderr(1);
> > +			break;
> > 		case 'H':
> > 			if (inet_addr(optarg) != INADDR_NONE) {
> > 				haddr = strdup(optarg);
> > @@ -67,8 +82,8 @@ main(int argc, char **argv)
> > 				haddr = inet_ntoa((*(struct in_addr*)(hp->h_addr_list[0])));
> > 			} else {
> > 				fprintf(stderr, "%s: Unknown hostname: %s\n",
> > -					argv[0], optarg);
> > -				usage(argv [0]);
> > +					progname, optarg);
> > +				usage(progname);
> > 			}
> > 			break;
> > 		case 'P':	/* XXX for nfs-server compatibility */
> > @@ -76,8 +91,8 @@ main(int argc, char **argv)
> > 			port = atoi(optarg);
> > 			if (port <= 0 || port > 65535) {
> > 				fprintf(stderr, "%s: bad port number: %s\n",
> > -					argv[0], optarg);
> > -				usage(argv [0]);
> > +					progname, optarg);
> > +				usage(progname);
> > 			}
> > 			break;
> > 		case 'N':
> > @@ -105,14 +120,17 @@ main(int argc, char **argv)
> > 		default:
> > 			fprintf(stderr, "Invalid argument: '%c'\n", c);
> > 		case 'h':
> > -			usage(argv[0]);
> > +			usage(progname);
> > 		}
> > 	}
> > +
> > +	xlog_open(progname);
> > +
> > 	/*
> > 	 * Do some sanity checking, if the ctlbits are set
> > 	 */
> > 	if (!NFSCTL_UDPISSET(protobits) && !NFSCTL_TCPISSET(protobits)) {
> > -		fprintf(stderr, "invalid protocol specified\n");
> > +		xlog(L_ERROR, "invalid protocol specified");
> > 		exit(1);
> > 	}
> > 	found_one = 0;
> > @@ -121,12 +139,12 @@ main(int argc, char **argv)
> > 			found_one = 1;
> > 	}
> > 	if (!found_one) {
> > -		fprintf(stderr, "no version specified\n");
> > +		xlog(L_ERROR, "no version specified");
> > 		exit(1);
> > 	}			
> >
> > 	if (NFSCTL_VERISSET(versbits, 4) && !NFSCTL_TCPISSET(protobits)) {
> > -		fprintf(stderr, "version 4 requires the TCP protocol\n");
> > +		xlog(L_ERROR, "version 4 requires the TCP protocol");
> > 		exit(1);
> > 	}
> > 	if (haddr == NULL) {
> > @@ -135,17 +153,15 @@ main(int argc, char **argv)
> > 	}
> >
> > 	if (chdir(NFS_STATEDIR)) {
> > -		fprintf(stderr, "%s: chdir(%s) failed: %s\n",
> > -			argv [0], NFS_STATEDIR, strerror(errno));
> > +		xlog(L_ERROR, "chdir(%s) failed: %m", NFS_STATEDIR);
> > 		exit(1);
> > 	}
> >
> > 	if (optind < argc) {
> > 		if ((count = atoi(argv[optind])) < 0) {
> > 			/* insane # of servers */
> > -			fprintf(stderr,
> > -				"%s: invalid server count (%d), using 1\n",
> > -				argv[0], count);
> > +			xlog(L_ERROR, "invalid server count (%d), using 1",
> > +				      count);
> > 			count = 1;
> > 		}
> > 	}
> > @@ -155,21 +171,20 @@ main(int argc, char **argv)
> > 	   everything before spawning kernel threads.  --Chip */
> > 	fd = open("/dev/null", O_RDWR);
> > 	if (fd == -1)
> > -		perror("/dev/null");
> > +		xlog(L_ERROR, "Unable to open /dev/null: %m");
> > 	else {
> > 		(void) dup2(fd, 0);
> > 		(void) dup2(fd, 1);
> > 		(void) dup2(fd, 2);
> > 	}
> > +	xlog_syslog(1);
> > +	xlog_stderr(0);
> > 	closeall(3);
> >
> > -	openlog("nfsd", LOG_PID, LOG_DAEMON);
> > -	if ((error = nfssvc(port, count, versbits, minorvers4, protobits,  
> > haddr)) < 0) {
> > -		int e = errno;
> > -		syslog(LOG_ERR, "nfssvc: %s", strerror(e));
> > -		closelog();
> > -	}
> > +	if ((error = nfssvc(port, count, versbits, minorvers4, protobits,  
> > haddr)) < 0)
> > +		xlog(L_ERROR, "nfssvc (%m)");
> 
> Nit: Maybe get rid of the "nfssvc" here as well?
> 

Well, the "nfssvc" here tells us that the nfssvc() call returned an
error. Later patches will clean that up when I break up the nfssvc()
interface. That said though, there's a bug there. %m isn't appropriate
since errno isn't being set. Whoops!

> >
> >
> > +	free(progname);
> 
> You go to the trouble of freeing progname here, but you exit in some  
> cases in the code above without freeing.  I usually copy argv[0] into  
> a static buffer to avoid all that strdup(3) bother.
> 

Six of one, half dozen of another. I try to be good about freeing
memory that's been allocated in case this code gets reorganized in the
future. The existing code is pretty bad about it, but it doesn't
matter much since this program isn't long running.

As far as allocating a static buffer for it, the problem there is that
you don't know how big a buffer you'll need. Using strdup means less
memory is being used.

> > 	return (error != 0);
> > }
> >
> > @@ -177,7 +192,7 @@ static void
> > usage(const char *prog)
> > {
> > 	fprintf(stderr, "Usage:\n"
> > -		"%s [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version  
> > version ] [-T|--no-tcp] [-U|--no-udp] nrservs\n",
> > +		"%s [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version  
> > version ] [-T|--no-tcp] [-U|--no-udp] [-d|--debug] nrservs\n",
> > 		prog);
> > 	exit(2);
> > }
> > -- 
> > 1.6.2.2
> >
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 


-- 
Jeff Layton <jlayton@redhat.com>
