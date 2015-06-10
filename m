Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35230 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246AbbFJANB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2015 20:13:01 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] rpc.nfsd: Squelch DNS errors when using the --host option
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150609192211.28cb5524@tlielax.poochiereds.net>
Date: Tue, 9 Jun 2015 20:12:54 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <300356A1-F75B-41CB-8867-E1BCF982396D@oracle.com>
References: <20150609200515.21211.41160.stgit@manet.1015granger.net> <20150609192211.28cb5524@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 9, 2015, at 7:22 PM, Jeff Layton <jlayton@poochiereds.net> wrote:

> On Tue, 09 Jun 2015 16:20:22 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> Sean Elble <elbles@sessys.com> says:
>>> [rpc.nfsd --host] throws an error/warning (where nfs-server is
>>> defined in /etc/hosts for the IPv4 address of the interface I wish
>>> for TCP port 2049 to be opened on):
>>> 
>>> rpc.nfsd: unable to resolve nfs-server:nfs to inet6 address: Name
>>> or service not known
>> 
>> I think we can simplify the use of getaddrinfo(3) so that only one
>> call is needed to gather both IPv4 and IPv6 addresses. The call
>> should fail, and an error should be reported, only when there are
>> _no_ usable addresses bound to a hostname.
>> 
>> Reported-by: Sean Elble <elbles@sessys.com>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> Here's an untested naive proposal: drop the /etc/netconfig logic
>> because the kernel doesn't use libtirpc, and use a single
>> getaddrinfo(3) call to gather all the addresses needed for the NFSD
>> listeners at once.
>> 
>> utils/nfsd/nfsd.c   |   75 +++------------------------------------------------
>> utils/nfsd/nfssvc.c |   11 ++++++-
>> utils/nfsd/nfssvc.h |    2 +
>> 3 files changed, 15 insertions(+), 73 deletions(-)
>> 
>> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
>> index 201bb13..586a9f2 100644
>> --- a/utils/nfsd/nfsd.c
>> +++ b/utils/nfsd/nfsd.c
>> @@ -52,50 +52,6 @@ static struct option longopts[] =
>> 	{ NULL, 0, 0, 0 }
>> };
>> 
>> -/* given a family and ctlbits, disable any that aren't listed in netconfig */
>> -#ifdef HAVE_LIBTIRPC
>> -static void
>> -nfsd_enable_protos(unsigned int *proto4, unsigned int *proto6)
>> -{
>> -	struct netconfig *nconf;
>> -	unsigned int *famproto;
>> -	void *handle;
>> -
>> -	xlog(D_GENERAL, "Checking netconfig for visible protocols.");
>> -
>> -	handle = setnetconfig();
>> -	while((nconf = getnetconfig(handle))) {
>> -		if (!(nconf->nc_flag & NC_VISIBLE))
>> -			continue;
>> -
>> -		if (!strcmp(nconf->nc_protofmly, NC_INET))
>> -			famproto = proto4;
>> -		else if (!strcmp(nconf->nc_protofmly, NC_INET6))
>> -			famproto = proto6;
>> -		else
>> -			continue;
>> -
>> -		if (!strcmp(nconf->nc_proto, NC_TCP))
>> -			NFSCTL_TCPSET(*famproto);
>> -		else if (!strcmp(nconf->nc_proto, NC_UDP))
>> -			NFSCTL_UDPSET(*famproto);
>> -
>> -		xlog(D_GENERAL, "Enabling %s %s.", nconf->nc_protofmly,
>> -			nconf->nc_proto);
>> -	}
>> -	endnetconfig(handle);
>> -	return;
>> -}
>> -#else /* HAVE_LIBTIRPC */
>> -static void
>> -nfsd_enable_protos(unsigned int *proto4, unsigned int *proto6)
>> -{
>> -	/* Enable all IPv4 protocols if no TIRPC support */
>> -	*proto4 = NFSCTL_ALLBITS;
>> -	*proto6 = 0;
>> -}
>> -#endif /* HAVE_LIBTIRPC */
>> -
>> int
>> main(int argc, char **argv)
>> {
>> @@ -108,8 +64,6 @@ main(int argc, char **argv)
>> 	unsigned int minorversset = 0;
>> 	unsigned int versbits = NFSCTL_VERDEFAULT;
>> 	unsigned int protobits = NFSCTL_ALLBITS;
>> -	unsigned int proto4 = 0;
>> -	unsigned int proto6 = 0;
>> 	int grace = -1;
>> 	int lease = -1;
>> 
>> @@ -278,18 +232,6 @@ main(int argc, char **argv)
>> 
>> 	xlog_open(progname);
>> 
>> -	nfsd_enable_protos(&proto4, &proto6);
>> -
>> -	if (!NFSCTL_TCPISSET(protobits)) {
>> -		NFSCTL_TCPUNSET(proto4);
>> -		NFSCTL_TCPUNSET(proto6);
>> -	}
>> -
>> -	if (!NFSCTL_UDPISSET(protobits)) {
>> -		NFSCTL_UDPUNSET(proto4);
>> -		NFSCTL_UDPUNSET(proto6);
>> -	}
>> -
>> 	/* make sure that at least one version is enabled */
>> 	found_one = 0;
>> 	for (c = NFSD_MINVERS; c <= NFSD_MAXVERS; c++) {
>> @@ -302,8 +244,7 @@ main(int argc, char **argv)
>> 	}
>> 
>> 	if (NFSCTL_VERISSET(versbits, 4) &&
>> -	    !NFSCTL_TCPISSET(proto4) &&
>> -	    !NFSCTL_TCPISSET(proto6)) {
>> +	    !NFSCTL_TCPISSET(protobits)) {
>> 		xlog(L_ERROR, "version 4 requires the TCP protocol");
>> 		exit(1);
>> 	}
>> @@ -335,23 +276,17 @@ main(int argc, char **argv)
>> 	if (lease  > 0)
>> 		nfssvc_set_time("lease", lease);
>> 
>> -	i = 0;
>> -	do {
>> -		error = nfssvc_set_sockets(AF_INET, proto4, haddr[i], port);
>> +	for (i = 0; i < hcounter; i++) {
>> +		error = nfssvc_set_sockets(protobits, haddr[i], port);
>> 		if (!error)
>> 			socket_up = 1;
>> -#ifdef IPV6_SUPPORTED
>> -		error = nfssvc_set_sockets(AF_INET6, proto6, haddr[i], port);
>> -		if (!error)
>> -			socket_up = 1;
>> -#endif /* IPV6_SUPPORTED */
>> -	} while (++i < hcounter); 
>> -
>> +	}
>> 	if (rdma_port) {
>> 		error = nfssvc_set_rdmaport(rdma_port);
>> 		if (!error)
>> 			socket_up = 1;
>> 	}
>> +
>> set_threads:
>> 	/* don't start any threads if unable to hand off any sockets */
>> 	if (!socket_up) {
>> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
>> index 027e5ac..c30220c 100644
>> --- a/utils/nfsd/nfssvc.c
>> +++ b/utils/nfsd/nfssvc.c
>> @@ -24,6 +24,7 @@
>> 
>> #include "nfslib.h"
>> #include "xlog.h"
>> +#include "nfssvc.h"
>> 
>> #ifndef NFSD_FS_DIR
>> #define NFSD_FS_DIR	  "/proc/fs/nfsd"
>> @@ -252,12 +253,18 @@ error:
>> }
>> 
>> int
>> -nfssvc_set_sockets(const int family, const unsigned int protobits,
>> +nfssvc_set_sockets(const unsigned int protobits,
>> 		   const char *host, const char *port)
>> {
>> 	struct addrinfo hints = { .ai_flags = AI_PASSIVE };
>> 
>> -	hints.ai_family = family;
>> +#ifdef IPV6_SUPPORTED
>> +	hints.ai_family = AF_INET6;
>> +	if (host)
>> +		hints.ai_family = AF_UNSPEC;
> 
> I may be looking at this wrong, but is this correct?
> 
> In the event that no host is specified, it looks like you'll only get
> an IPv6 address? I'd expect that if IPv6 is supported you'd set it to
> AF_UNSPEC and AF_INET if it isn’t.

When “host” is not NULL, then setting ai_family to AF_INET will
give us just IPv4 addresses, and setting it to ai_family to
AF_UNSPEC will give us both IPv4 and IPv6 addresses.

When “host” is NULL, we want getaddrinfo(3) to generate an ANY
bind address. So ai_family has to be either AF_INET or AF_INET6,
AF_UNSPEC doesn’t work in that case.

Hm, I guess in the IPv6 case, we do need two separate calls to
nfssvc_set_fds() to get both an IPv4 and an IPv6 socket. Sigh.
I’ll respin.



>> +#else
>> +	hints.ai_family = AF_INET;
>> +#endif
>> 
>> 	if (!NFSCTL_ANYPROTO(protobits))
>> 		return EPROTOTYPE;
>> diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
>> index fbb89b2..7d70f0d 100644
>> --- a/utils/nfsd/nfssvc.h
>> +++ b/utils/nfsd/nfssvc.h
>> @@ -22,7 +22,7 @@
>> 
>> void	nfssvc_mount_nfsdfs(char *progname);
>> int	nfssvc_inuse(void);
>> -int	nfssvc_set_sockets(const int family, const unsigned int
>> protobits, +int	nfssvc_set_sockets(const unsigned int
>> protobits, const char *host, const char *port);
>> void	nfssvc_set_time(const char *type, const int seconds);
>> int	nfssvc_set_rdmaport(const char *port);
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>> in the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> -- 
> Jeff Layton <jlayton@poochiereds.net>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



