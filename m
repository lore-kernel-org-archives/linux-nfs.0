Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55351 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754441Ab1ISNip (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Sep 2011 09:38:45 -0400
Date: Mon, 19 Sep 2011 09:38:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] configure.ac: Added server 4.1 support
 configuration option
Message-ID: <20110919133845.GA1106@fieldses.org>
References: <1316272622-4894-1-git-send-email-steved@redhat.com>
 <20110917183645.GA24278@fieldses.org>
 <4E7710B7.7070804@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E7710B7.7070804@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 19, 2011 at 05:51:51AM -0400, Steve Dickson wrote:
> 
> 
> On 09/17/2011 02:36 PM, J. Bruce Fields wrote:
> > On Sat, Sep 17, 2011 at 11:17:01AM -0400, Steve Dickson wrote:
> >> Separate the v4.1 support in the client and server
> >> by creating the --enable-nfsdv4 configuration option.
> > 
> > I really dislike --enable-nfsdv4: people shouldn't have to rebuild
> > nfs-utils in order to turn on server 4.1 support.  They should be able
> > to do that at run time.
> > 
> > It makes sense for something like the block client, because there we
> > actually have to decide whether to *build* something or not, and if
> > someone knows they're never going to use that daemon, maybe they don't
> > want to bother building and installing it.
> > 
> > For server 4.1 support, we're making them rebuild just to change the
> > value of a single constant.  Why?
> If I remember correctly, that's the way you wanted... We disabled 
> 4.1 server supported this way, because the code did not conform to 
> the RFC. This was done back in Fed 2010.
> 
> All this patch is doing is reorganizing things so there is a
> configuration option to enable/disable the 4.1 client.   
> 
> Now, I agree. Enabling/disabling the 4.1 server in a more 
> dynamic way would be good... Is the code ready for that?
> Should this constraint be remove completely? 

We still don't want it on by default.  But that's no reason to force
early adopters to recompile nfs-utils just to turn it on.

So how about something like this?  (Untested.)

--b.

commit 3df526795eed38b27fecb51775c039b7eaeed088
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Dec 17 17:11:54 2009 -0500

    nfsd: allow choosing server 41 support at runtime
    
    Provide an enable-41 option to rpc.nfsd to turn on experimental 4.1
    support in the server.  (Current kernels have 41 off by default until
    basic 41 support is finished, so this option is intended only for people
    that know what they're doing.)
    
    Note once 4.1 defaults to on, this option will become unnecessary (and
    can probably just be dropped from nfs-utils), and only the -N 4.1 option
    will be necessary, for those that want to turn 4.1 off for some reason.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/configure.ac b/configure.ac
index 1a28f8a..7000324 100644
--- a/configure.ac
+++ b/configure.ac
@@ -73,19 +73,6 @@ AC_ARG_ENABLE(nfsv4,
 	AC_SUBST(enable_nfsv4)
 	AM_CONDITIONAL(CONFIG_NFSV4, [test "$enable_nfsv4" = "yes"])
 
-AC_ARG_ENABLE(nfsv41,
-	[AC_HELP_STRING([--enable-nfsv41],
-                        [enable support for NFSv41 @<:@default=no@:>@])],
-	enable_nfsv41=$enableval,
-	enable_nfsv41=no)
-	if test "$enable_nfsv41" = yes; then
-		AC_DEFINE(NFS41_SUPPORTED, 1, [Define this if you want NFSv41 support compiled in])
-	else
-		enable_nfsv41=
-	fi
-	AC_SUBST(enable_nfsv41)
-	AM_CONDITIONAL(CONFIG_NFSV41, [test "$enable_nfsv41" = "yes"])
-
 AC_ARG_ENABLE(gss,
 	[AC_HELP_STRING([--enable-gss],
                         [enable support for rpcsec_gss @<:@default=yes@:>@])],
diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
index c939d78..320880e 100644
--- a/support/include/nfs/nfs.h
+++ b/support/include/nfs/nfs.h
@@ -15,13 +15,6 @@
 #define NFSD_MINVERS 2
 #define NFSD_MAXVERS 4
 
-#define NFSD_MINMINORVERS4 1
-#ifdef  NFS41_SUPPORTED
-#define NFSD_MAXMINORVERS4 1
-#else
-#define NFSD_MAXMINORVERS4 0
-#endif
-
 struct nfs_fh_len {
 	int		fh_size;
 	u_int8_t	fh_handle[NFS3_FHSIZE];
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index e7e1470..fa9c429 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -40,6 +40,7 @@ static struct option longopts[] =
 	{ "port", 1, 0, 'p' },
 	{ "debug", 0, 0, 'd' },
 	{ "syslog", 0, 0, 's' },
+	{ "enable-41", 0, 0, 'X' },
 	{ NULL, 0, 0, 0 }
 };
 
@@ -94,7 +95,7 @@ main(int argc, char **argv)
 	char *p, *progname, *port;
 	char *haddr = NULL;
 	int	socket_up = 0;
-	int minorvers4 = NFSD_MAXMINORVERS4;	/* nfsv4 minor version */
+	int minorvers41 = 0;	/* nfsv4 minor version */
 	unsigned int versbits = NFSCTL_ALLBITS;
 	unsigned int protobits = NFSCTL_ALLBITS;
 	unsigned int proto4 = 0;
@@ -154,7 +155,12 @@ main(int argc, char **argv)
 			switch((c = strtol(optarg, &p, 0))) {
 			case 4:
 				if (*p == '.') {
-					minorvers4 = -atoi(p + 1);
+					int i = atoi(p+1);
+					if (i != 1) {
+						fprintf(stderr, "%s: unsupported minor version\n", optarg);
+						exit(1);
+					}
+					minorvers41 = -1;
 					break;
 				}
 			case 3:
@@ -176,6 +182,9 @@ main(int argc, char **argv)
 		case 'U':
 			NFSCTL_UDPUNSET(protobits);
 			break;
+		case 'X':
+			minorvers41 = 1;
+			break;
 		default:
 			fprintf(stderr, "Invalid argument: '%c'\n", c);
 		case 'h':
@@ -251,7 +260,7 @@ main(int argc, char **argv)
 	 * registered with rpcbind. Note that on older kernels w/o the right
 	 * interfaces, these are a no-op.
 	 */
-	nfssvc_setvers(versbits, minorvers4);
+	nfssvc_setvers(versbits, minorvers41);
  
 	error = nfssvc_set_sockets(AF_INET, proto4, haddr, port);
 	if (!error)
@@ -303,7 +312,7 @@ static void
 usage(const char *prog)
 {
 	fprintf(stderr, "Usage:\n"
-		"%s [-d|--debug] [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version version ] [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] nrservs\n", 
+		"%s [-d|--debug] [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version version ] [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] [--enable-41] nrservs\n", 
 		prog);
 	exit(2);
 }
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index f607214..683008e 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -269,7 +269,7 @@ nfssvc_set_sockets(const int family, const unsigned int protobits,
 }
 
 void
-nfssvc_setvers(unsigned int ctlbits, int minorvers4)
+nfssvc_setvers(unsigned int ctlbits, int minorvers41)
 {
 	int fd, n, off;
 	char *ptr;
@@ -280,11 +280,9 @@ nfssvc_setvers(unsigned int ctlbits, int minorvers4)
 	if (fd < 0)
 		return;
 
-	n = minorvers4 >= 0 ? minorvers4 : -minorvers4;
-	if (n >= NFSD_MINMINORVERS4 && n <= NFSD_MAXMINORVERS4)
-		    off += snprintf(ptr+off, sizeof(buf) - off, "%c4.%d ",
-				    minorvers4 > 0 ? '+' : '-',
-				    n);
+	if (minorvers41)
+		off += snprintf(ptr+off, sizeof(buf) - off, "%c4.1",
+				minorvers41 > 0 ? '+' : '-');
 	for (n = NFSD_MINVERS; n <= NFSD_MAXVERS; n++) {
 		if (NFSCTL_VERISSET(ctlbits, n))
 		    off += snprintf(ptr+off, sizeof(buf) - off, "+%d ", n);
