Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50081 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899Ab1ISOfE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Sep 2011 10:35:04 -0400
Date: Mon, 19 Sep 2011 10:35:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] configure.ac: Added server 4.1 support
 configuration option
Message-ID: <20110919143503.GA1474@fieldses.org>
References: <1316272622-4894-1-git-send-email-steved@redhat.com>
 <20110917183645.GA24278@fieldses.org>
 <4E7710B7.7070804@RedHat.com>
 <20110919133845.GA1106@fieldses.org>
 <4E774FB6.6040707@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E774FB6.6040707@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 19, 2011 at 10:20:38AM -0400, Steve Dickson wrote:
> 
> 
> On 09/19/2011 09:38 AM, J. Bruce Fields wrote:
> > diff --git a/configure.ac b/configure.ac
> > index 1a28f8a..7000324 100644
> > --- a/configure.ac
> > +++ b/configure.ac
> > @@ -73,19 +73,6 @@ AC_ARG_ENABLE(nfsv4,
> >  	AC_SUBST(enable_nfsv4)
> >  	AM_CONDITIONAL(CONFIG_NFSV4, [test "$enable_nfsv4" = "yes"])
> >  
> > -AC_ARG_ENABLE(nfsv41,
> > -	[AC_HELP_STRING([--enable-nfsv41],
> > -                        [enable support for NFSv41 @<:@default=no@:>@])],
> > -	enable_nfsv41=$enableval,
> > -	enable_nfsv41=no)
> > -	if test "$enable_nfsv41" = yes; then
> > -		AC_DEFINE(NFS41_SUPPORTED, 1, [Define this if you want NFSv41 support compiled in])
> > -	else
> > -		enable_nfsv41=
> > -	fi
> > -	AC_SUBST(enable_nfsv41)
> > -	AM_CONDITIONAL(CONFIG_NFSV41, [test "$enable_nfsv41" = "yes"])
> > -
> I think we still need this for the 4.1 client code.

OK.  Or I can wait and resend a patch after you've committed the changes
for the client's block daemon, if you'd prefer.

> > diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> > index e7e1470..fa9c429 100644
> > --- a/utils/nfsd/nfsd.c
> > +++ b/utils/nfsd/nfsd.c
> > @@ -40,6 +40,7 @@ static struct option longopts[] =
> >  	{ "port", 1, 0, 'p' },
> >  	{ "debug", 0, 0, 'd' },
> >  	{ "syslog", 0, 0, 's' },
> > +	{ "enable-41", 0, 0, 'X' },
> >  	{ NULL, 0, 0, 0 }
> >  };
> Introducing temporary, undocumented command line arguments
> is generally not a good thing... IMHO... I was think more
> of an echo to /proc/fs/nfsd/versions to enable the support.

I think it's a reasonable thing to do for experimental code.

But we could do the following instead.  (Warning: still untested.)

--b.

commit 8d69da4c556f8ad2d42caa3875a665761c27463e
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Dec 17 17:11:54 2009 -0500

    nfsd: allow choosing server 41 support at runtime
    
    In the case where -N 4.1 is left off the commandline, the current code
    explicitly turns it on or off anyway, depending on configure options.
    
    Instead, just leave 4.1 support alone.  This allows a user to add an
    "echo +4.1 >/proc/fs/nfsd/versions" to their init scripts, if they want.
    Otherwise they will get the kernel's default (currently to leave 4.1
    off, as long as 4.1 support is experimental).
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

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
index e7e1470..8bc5d3a 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -94,7 +94,7 @@ main(int argc, char **argv)
 	char *p, *progname, *port;
 	char *haddr = NULL;
 	int	socket_up = 0;
-	int minorvers4 = NFSD_MAXMINORVERS4;	/* nfsv4 minor version */
+	int minorvers41 = 0;	/* nfsv4 minor version */
 	unsigned int versbits = NFSCTL_ALLBITS;
 	unsigned int protobits = NFSCTL_ALLBITS;
 	unsigned int proto4 = 0;
@@ -154,7 +154,12 @@ main(int argc, char **argv)
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
@@ -251,7 +256,7 @@ main(int argc, char **argv)
 	 * registered with rpcbind. Note that on older kernels w/o the right
 	 * interfaces, these are a no-op.
 	 */
-	nfssvc_setvers(versbits, minorvers4);
+	nfssvc_setvers(versbits, minorvers41);
  
 	error = nfssvc_set_sockets(AF_INET, proto4, haddr, port);
 	if (!error)
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
