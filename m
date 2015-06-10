Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:36289 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326AbbFJAof convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2015 20:44:35 -0400
Received: by ieclw1 with SMTP id lw1so24446788iec.3
        for <linux-nfs@vger.kernel.org>; Tue, 09 Jun 2015 17:44:35 -0700 (PDT)
Date: Tue, 9 Jun 2015 20:44:28 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpc.nfsd: Squelch DNS errors when using the --host
 option
Message-ID: <20150609204428.2778caf8@tlielax.poochiereds.net>
In-Reply-To: <300356A1-F75B-41CB-8867-E1BCF982396D@oracle.com>
References: <20150609200515.21211.41160.stgit@manet.1015granger.net>
	<20150609192211.28cb5524@tlielax.poochiereds.net>
	<300356A1-F75B-41CB-8867-E1BCF982396D@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 9 Jun 2015 20:12:54 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jun 9, 2015, at 7:22 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
> 
> > On Tue, 09 Jun 2015 16:20:22 -0400
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> >> Sean Elble <elbles@sessys.com> says:
> >>> [rpc.nfsd --host] throws an error/warning (where nfs-server is
> >>> defined in /etc/hosts for the IPv4 address of the interface I wish
> >>> for TCP port 2049 to be opened on):
> >>> 
> >>> rpc.nfsd: unable to resolve nfs-server:nfs to inet6 address: Name
> >>> or service not known
> >> 
> >> I think we can simplify the use of getaddrinfo(3) so that only one
> >> call is needed to gather both IPv4 and IPv6 addresses. The call
> >> should fail, and an error should be reported, only when there are
> >> _no_ usable addresses bound to a hostname.
> >> 
> >> Reported-by: Sean Elble <elbles@sessys.com>
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >> 
> >> Here's an untested naive proposal: drop the /etc/netconfig logic
> >> because the kernel doesn't use libtirpc, and use a single
> >> getaddrinfo(3) call to gather all the addresses needed for the NFSD
> >> listeners at once.
> >> 
> >> utils/nfsd/nfsd.c   |   75 +++------------------------------------------------
> >> utils/nfsd/nfssvc.c |   11 ++++++-
> >> utils/nfsd/nfssvc.h |    2 +
> >> 3 files changed, 15 insertions(+), 73 deletions(-)
> >> 
> >> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> >> index 201bb13..586a9f2 100644
> >> --- a/utils/nfsd/nfsd.c
> >> +++ b/utils/nfsd/nfsd.c
> >> @@ -52,50 +52,6 @@ static struct option longopts[] =
> >> 	{ NULL, 0, 0, 0 }
> >> };
> >> 
> >> -/* given a family and ctlbits, disable any that aren't listed in netconfig */
> >> -#ifdef HAVE_LIBTIRPC
> >> -static void
> >> -nfsd_enable_protos(unsigned int *proto4, unsigned int *proto6)
> >> -{
> >> -	struct netconfig *nconf;
> >> -	unsigned int *famproto;
> >> -	void *handle;
> >> -
> >> -	xlog(D_GENERAL, "Checking netconfig for visible protocols.");
> >> -
> >> -	handle = setnetconfig();
> >> -	while((nconf = getnetconfig(handle))) {
> >> -		if (!(nconf->nc_flag & NC_VISIBLE))
> >> -			continue;
> >> -
> >> -		if (!strcmp(nconf->nc_protofmly, NC_INET))
> >> -			famproto = proto4;
> >> -		else if (!strcmp(nconf->nc_protofmly, NC_INET6))
> >> -			famproto = proto6;
> >> -		else
> >> -			continue;
> >> -
> >> -		if (!strcmp(nconf->nc_proto, NC_TCP))
> >> -			NFSCTL_TCPSET(*famproto);
> >> -		else if (!strcmp(nconf->nc_proto, NC_UDP))
> >> -			NFSCTL_UDPSET(*famproto);
> >> -
> >> -		xlog(D_GENERAL, "Enabling %s %s.", nconf->nc_protofmly,
> >> -			nconf->nc_proto);
> >> -	}
> >> -	endnetconfig(handle);
> >> -	return;
> >> -}
> >> -#else /* HAVE_LIBTIRPC */
> >> -static void
> >> -nfsd_enable_protos(unsigned int *proto4, unsigned int *proto6)
> >> -{
> >> -	/* Enable all IPv4 protocols if no TIRPC support */
> >> -	*proto4 = NFSCTL_ALLBITS;
> >> -	*proto6 = 0;
> >> -}
> >> -#endif /* HAVE_LIBTIRPC */
> >> -
> >> int
> >> main(int argc, char **argv)
> >> {
> >> @@ -108,8 +64,6 @@ main(int argc, char **argv)
> >> 	unsigned int minorversset = 0;
> >> 	unsigned int versbits = NFSCTL_VERDEFAULT;
> >> 	unsigned int protobits = NFSCTL_ALLBITS;
> >> -	unsigned int proto4 = 0;
> >> -	unsigned int proto6 = 0;
> >> 	int grace = -1;
> >> 	int lease = -1;
> >> 
> >> @@ -278,18 +232,6 @@ main(int argc, char **argv)
> >> 
> >> 	xlog_open(progname);
> >> 
> >> -	nfsd_enable_protos(&proto4, &proto6);
> >> -
> >> -	if (!NFSCTL_TCPISSET(protobits)) {
> >> -		NFSCTL_TCPUNSET(proto4);
> >> -		NFSCTL_TCPUNSET(proto6);
> >> -	}
> >> -
> >> -	if (!NFSCTL_UDPISSET(protobits)) {
> >> -		NFSCTL_UDPUNSET(proto4);
> >> -		NFSCTL_UDPUNSET(proto6);
> >> -	}
> >> -
> >> 	/* make sure that at least one version is enabled */
> >> 	found_one = 0;
> >> 	for (c = NFSD_MINVERS; c <= NFSD_MAXVERS; c++) {
> >> @@ -302,8 +244,7 @@ main(int argc, char **argv)
> >> 	}
> >> 
> >> 	if (NFSCTL_VERISSET(versbits, 4) &&
> >> -	    !NFSCTL_TCPISSET(proto4) &&
> >> -	    !NFSCTL_TCPISSET(proto6)) {
> >> +	    !NFSCTL_TCPISSET(protobits)) {
> >> 		xlog(L_ERROR, "version 4 requires the TCP protocol");
> >> 		exit(1);
> >> 	}
> >> @@ -335,23 +276,17 @@ main(int argc, char **argv)
> >> 	if (lease  > 0)
> >> 		nfssvc_set_time("lease", lease);
> >> 
> >> -	i = 0;
> >> -	do {
> >> -		error = nfssvc_set_sockets(AF_INET, proto4, haddr[i], port);
> >> +	for (i = 0; i < hcounter; i++) {
> >> +		error = nfssvc_set_sockets(protobits, haddr[i], port);
> >> 		if (!error)
> >> 			socket_up = 1;
> >> -#ifdef IPV6_SUPPORTED
> >> -		error = nfssvc_set_sockets(AF_INET6, proto6, haddr[i], port);
> >> -		if (!error)
> >> -			socket_up = 1;
> >> -#endif /* IPV6_SUPPORTED */
> >> -	} while (++i < hcounter); 
> >> -
> >> +	}
> >> 	if (rdma_port) {
> >> 		error = nfssvc_set_rdmaport(rdma_port);
> >> 		if (!error)
> >> 			socket_up = 1;
> >> 	}
> >> +
> >> set_threads:
> >> 	/* don't start any threads if unable to hand off any sockets */
> >> 	if (!socket_up) {
> >> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> >> index 027e5ac..c30220c 100644
> >> --- a/utils/nfsd/nfssvc.c
> >> +++ b/utils/nfsd/nfssvc.c
> >> @@ -24,6 +24,7 @@
> >> 
> >> #include "nfslib.h"
> >> #include "xlog.h"
> >> +#include "nfssvc.h"
> >> 
> >> #ifndef NFSD_FS_DIR
> >> #define NFSD_FS_DIR	  "/proc/fs/nfsd"
> >> @@ -252,12 +253,18 @@ error:
> >> }
> >> 
> >> int
> >> -nfssvc_set_sockets(const int family, const unsigned int protobits,
> >> +nfssvc_set_sockets(const unsigned int protobits,
> >> 		   const char *host, const char *port)
> >> {
> >> 	struct addrinfo hints = { .ai_flags = AI_PASSIVE };
> >> 
> >> -	hints.ai_family = family;
> >> +#ifdef IPV6_SUPPORTED
> >> +	hints.ai_family = AF_INET6;
> >> +	if (host)
> >> +		hints.ai_family = AF_UNSPEC;
> > 
> > I may be looking at this wrong, but is this correct?
> > 
> > In the event that no host is specified, it looks like you'll only get
> > an IPv6 address? I'd expect that if IPv6 is supported you'd set it to
> > AF_UNSPEC and AF_INET if it isn’t.
> 
> When “host” is not NULL, then setting ai_family to AF_INET will
> give us just IPv4 addresses, and setting it to ai_family to
> AF_UNSPEC will give us both IPv4 and IPv6 addresses.
> 
> When “host” is NULL, we want getaddrinfo(3) to generate an ANY
> bind address. So ai_family has to be either AF_INET or AF_INET6,
> AF_UNSPEC doesn’t work in that case.
> 

That seemed to work when I tested it (on Fedora 22, but I'd expect
earlier ones to work the same way). I got several addresses in the list
(8 or so?). Some had unsuitable ai_socktypes, but I did get addrinfo
for both AF_INET and AF_INET6 addrs for both SOCK_STREAM and SOCK_DGRAM.

> Hm, I guess in the IPv6 case, we do need two separate calls to
> nfssvc_set_fds() to get both an IPv4 and an IPv6 socket. Sigh.
> I’ll respin.
> 

I don't think that's needed. I think you can just set the ai_family to
AF_UNSPEC. Be sure to sanity check my results there though...

-- 
Jeff Layton <jlayton@poochiereds.net>
