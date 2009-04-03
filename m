From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/6] nfs-utils: convert gssd to TI-RPC and add IPv6 support
	(try #2)
Date: Fri, 03 Apr 2009 12:07:18 -0400
Message-ID: <49D63436.8010709@RedHat.com>
References: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

I believe Patch 1/6 is missing from this patch set,
at least I can't seem to find it.... 

Also, is this the final version? Or will there be another
one addressing Chuck's issues.

steved.

Jeff Layton wrote:
> This patchset is a second attempt at adding support for IPv6 to
> rpc.gssd. The main changes from the first set are some minor fixes and
> changes suggested by Chuck Lever. This set is also based on mainline
> nfs-utils since the requisite patches for it are now there.
> 
> In order to do this, we first have to convert rpc.gssd to use TI-RPC.
> The first 5 patches do this and abstract out some of the code to make
> this easier. Once that support is in place, the last patch in the series
> actually adds the (fairly minimal) changes to add IPv6 support.
> 
> The series should be fully bisectable, but I've only really tested the
> end result for anything other than to see if it compiles. With these
> patches I've been able to mount an OpenSolaris server using
> NFSv3/4 + IPv6 + krb5 auth
> 
> Specific changes from the last set:
> - cleaned up the usage of sockaddr and sockaddr_storage and pointers to
>   them
> - moved the sockaddr_storage to be part of the clnt_info instead of a
>   separate allocation
> - use a C99 initializer for ai_hints instead of memset()
> - properly handle a return of EAI_SYSTEM from getaddrinfo()
> 
> Comments welcome.
> 
> Jeff Layton (6):
>   nfs-utils: make getnameinfo() required for --enable-gss
>   nfs-utils: store the address given in the upcall for later use
>   nfs-utils: skip getaddrinfo in create_auth_rpc_client unless we need
>     port
>   nfs-utils: split out gssd rpc client creation into separate function
>   nfs-utils: when TIRPC is enabled, use new API to create RPC client
>   nfs-utils: add IPv6 code to gssd
> 
>  configure.ac           |    2 +
>  utils/gssd/gssd.h      |    2 +-
>  utils/gssd/gssd_proc.c |  398 +++++++++++++++++++++++++++++++++++++-----------
>  3 files changed, 309 insertions(+), 93 deletions(-)
> 
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
