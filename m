From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH 09/11] nfs-utils: mount: Fixed mounts
 to	multi-home servers
Date: Sun, 11 Mar 2007 15:58:03 -0400
Message-ID: <45F45F4B.3030407@poochiereds.net>
References: <45E2C21E.9030501@RedHat.com>	<17891.53391.618228.526904@notabene.brown>	<45E47470.4020002@poochiereds.net>
	<17894.12530.165078.511522@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQUBI-0007DF-4b
	for nfs@lists.sourceforge.net; Sun, 11 Mar 2007 12:58:12 -0700
Received: from ms-smtp-03.southeast.rr.com ([24.25.9.102])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQUBJ-0005jX-0N
	for nfs@lists.sourceforge.net; Sun, 11 Mar 2007 12:58:14 -0700
In-Reply-To: <17894.12530.165078.511522@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Neil Brown wrote:
> On Tuesday February 27, jlayton@poochiereds.net wrote:
>> I know we saw this with Solaris servers in particular (it's been a 
>> while, but I think I was testing against Solaris 8). The fedora BZ is 
>> here if you want to see all the gory details:
>>
>> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=212471
>>
>> I'm thinking we will have to deal with this situation, unfortunately, so 
>> maybe disconnecting the socket after getting the address is the best thing?
>>
>> -- Jeff
> 
> Thanks for the link... Looks like we do need to be very careful about
> connecting UDP sockets.
> 
> This patch maybe?
> 
> NeilBrown
> 
> 
> diff --git a/support/include/conn.h b/support/include/conn.h
> index 1761dc4..11f16ab 100644
> --- a/support/include/conn.h
> +++ b/support/include/conn.h
> @@ -35,7 +35,7 @@ int clnt_ping(struct sockaddr_in *, const u_long, const u_long, const u_int,
>  	      struct sockaddr_in *);
>  u_long nfsvers_to_mnt(const u_long);
>  u_long mntvers_to_nfs(const u_long);
> -int get_socket(struct sockaddr_in *, u_int, int);
> +int get_socket(struct sockaddr_in *, u_int, int, int);
>  CLIENT * mnt_openclnt(clnt_addr_t *, int *);
>  void mnt_closeclnt(CLIENT *, int);
>  
> diff --git a/support/nfs/conn.c b/support/nfs/conn.c
> index 89f7676..1020b47 100644
> --- a/support/nfs/conn.c
> +++ b/support/nfs/conn.c
> @@ -49,7 +49,7 @@ u_long mntvers_to_nfs(const u_long vers)
>   * RPC_ANYSOCK is returned which will cause 
>   * the RPC code to create the socket instead. 
>   */
> -int get_socket(struct sockaddr_in *saddr, u_int p_prot, int resvp)
> +int get_socket(struct sockaddr_in *saddr, u_int p_prot, int resvp, int conn)
>  {
>  	int so, cc, type;
>  	struct sockaddr_in laddr;
> @@ -98,7 +98,7 @@ int get_socket(struct sockaddr_in *saddr, u_int p_prot, int resvp)
>  			return RPC_ANYSOCK;
>  		}
>  	}
> -	if (type == SOCK_STREAM || type == SOCK_DGRAM) {
> +	if (type == SOCK_STREAM || (conn && type == SOCK_DGRAM)) {
>  		cc = connect(so, (struct sockaddr *)saddr, namelen);
>  		if (cc < 0) {
>  			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
> @@ -129,9 +129,10 @@ clnt_ping(struct sockaddr_in *saddr, const u_long prog, const u_long vers,
>  	CLIENT *clnt=NULL;
>  	int sock, stat;
>  	static char clnt_res;
> +	struct sockaddr dissolve;
>  
>  	rpc_createerr.cf_stat = stat = errno = 0;
> -	sock = get_socket(saddr, prot, FALSE);
> +	sock = get_socket(saddr, prot, FALSE, TRUE);
>  	if (sock == RPC_ANYSOCK && errno == ETIMEDOUT) {
>  		/*
>  		 * TCP timeout. Bubble up the error to see 
> @@ -141,8 +142,22 @@ clnt_ping(struct sockaddr_in *saddr, const u_long prog, const u_long vers,
>  		goto out_bad;
>  	}
>  
> +	if (caddr) {
> +		/* Get the address of our end of this connection */
> +		socklen_t len = sizeof(*caddr);
> +		if (getsockname(sock, caddr, &len) != 0)
> +			caddr->sin_family = 0;
> +	}
> +
>  	switch(prot) {
>  	case IPPROTO_UDP:
> +		/* The socket is connected (so we could getsockname successfully),
> +		 * but some servers on multi-homed hosts reply from
> +		 * the wrong address, so if we stay connected, we lose the reply.
> +		 */
> +		dissolve.sa_family = AF_UNSPEC;
> +		connect(sock, &dissolve, sizeof(dissolve));
> +
>  		clnt = clntudp_bufcreate(saddr, prog, vers,
>  					 RETRY_TIMEOUT, &sock,
>  					 RPCSMALLMSGSIZE, RPCSMALLMSGSIZE);
> @@ -166,15 +181,7 @@ clnt_ping(struct sockaddr_in *saddr, const u_long prog, const u_long vers,
>  		rpc_createerr.cf_stat = stat;
>  	}
>  	clnt_destroy(clnt);
> -	if (sock != -1) {
> -		if (caddr) {
> -			/* Get the address of our end of this connection */
> -			socklen_t len = sizeof(*caddr);
> -			if (getsockname(sock, caddr, &len) != 0)
> -				caddr->sin_family = 0;
> -		}
> -		close(sock);
> -	}
> +	close(sock);
>  
>  	if (stat == RPC_SUCCESS)
>  		return 1;
> @@ -191,7 +198,7 @@ CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
>  
>  	/* contact the mount daemon via TCP */
>  	mnt_saddr->sin_port = htons((u_short)mnt_pmap->pm_port);
> -	*msock = get_socket(mnt_saddr, mnt_pmap->pm_prot, TRUE);
> +	*msock = get_socket(mnt_saddr, mnt_pmap->pm_prot, TRUE, FALSE);
>  
>  	switch (mnt_pmap->pm_prot) {
>  	case IPPROTO_UDP:
> diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
> index 507ccdb..0f66bdf 100644
> --- a/utils/mount/nfsmount.c
> +++ b/utils/mount/nfsmount.c
> @@ -306,7 +306,7 @@ getport(
>  	enum clnt_stat stat;
>  
>  	saddr->sin_port = htons (PMAPPORT);
> -	socket = get_socket(saddr, prot, FALSE);
> +	socket = get_socket(saddr, prot, FALSE, FALSE);
>  
>  	switch (prot) {
>  	case IPPROTO_UDP:
> 


Hi Neil,
   Apologies for the long delay, took me a bit to get my test rig back 
together. This patch does indeed seem to fix the problem.

Thanks,
Jeff

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
