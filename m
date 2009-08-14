From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/6] nfsd: add support for NFSv4 callbacks over IPv6 (try
	#5)
Date: Fri, 14 Aug 2009 14:05:03 -0400
Message-ID: <D24FC53A-3E15-444F-BCDF-BE8454205B4F@oracle.com>
References: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Cc: NFS list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Jeff Layton <jlayton@redhat.com>, Bruce Fields <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 14, 2009, at 12:57 PM, Jeff Layton wrote:
> Fifth attempt at a patchset to add support for NFSv4 callbacks over
> IPv6. Changes from last patchset are mostly to address Chuck's  
> comments:
>
> 1) made the new address comparison and copy routines into static  
> inlines
> and added them to clnt.h. Ditto for the get_scope_id function.
>
> 2) combined the patch to change nfs4_cb_conn to hold address in
> sockaddr_storage with the one to convert gen_callback to use
> rpc_uaddr2sockaddr. That eliminates changes to the parse_ipv4 function
> that eventually gets ripped out.
>
> Tested using opensolaris and linux and verifying that delegations  
> could
> be properly recalled. I also tested mounts to the server's link-local
> address and verified that the callback channel connected correctly.

Looks good.

Acked-by: Chuck Lever <chuck.lever@oracle.com>

> Jeff Layton (6):
>  sunrpc: add routine for comparing addresses
>  sunrpc: add common routine for copying address portion of a sockaddr
>  nfsd: make nfs4_client->cl_addr a struct sockaddr_storage
>  nfsd: convert nfs4_cb_conn struct to hold address in sockaddr_storage
>  nfsd: add support for NFSv4 callbacks over IPv6
>  nfsd: populate sin6_scope_id on callback address with scopeid from
>    rq_addr on SETCLIENTID call
>
> fs/lockd/clntlock.c         |    2 +-
> fs/lockd/host.c             |    4 +-
> fs/lockd/mon.c              |    2 +-
> fs/lockd/svcsubs.c          |    2 +-
> fs/nfsd/nfs4callback.c      |   11 +---
> fs/nfsd/nfs4state.c         |  133 +++++++++++++ 
> +-----------------------------
> include/linux/lockd/lockd.h |   43 --------------
> include/linux/nfsd/state.h  |    6 +-
> include/linux/sunrpc/clnt.h |  113 ++++++++++++++++++++++++++++++++++ 
> ++
> 9 files changed, 166 insertions(+), 150 deletions(-)
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
