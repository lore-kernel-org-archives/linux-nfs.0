From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [PATCH] knfsd: Fix race that can disable NFS server.
Date: Sun, 5 Nov 2006 08:49:08 +0100
Message-ID: <20061105074908.GE13381@stusta.de>
References: <20061020114959.26698.patches@notabene>
	<1061020015244.26756@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ggckj-0000zd-DN
	for nfs@lists.sourceforge.net; Sat, 04 Nov 2006 23:49:13 -0800
Received: from emailhub.stusta.mhn.de ([141.84.69.5]
	helo=mailout.stusta.mhn.de)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Ggckj-0002hx-3N
	for nfs@lists.sourceforge.net; Sat, 04 Nov 2006 23:49:14 -0800
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1061020015244.26756@suse.de>
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

On Fri, Oct 20, 2006 at 11:52:44AM +1000, NeilBrown wrote:

> This patch is suitable for just about any 2.6 kernel.
> It should go in 2.6.19 and 2.6.18.2 and possible even the .17 and .16
> stable series.


Thanks, applied to 2.6.16.


> ### Comments for Changeset
> 
> This is a long standing bug that seems to have only recently become
> apparent, presumably due to increasing use of NFS over TCP - many
> distros seem to be making it the default.
> 
> The SK_CONN bit gets set when a listening socket may be ready
> for an accept, just as SK_DATA is set when data may be available.
> 
> It is entirely possible for svc_tcp_accept to be called with neither
> of these set.  It doesn't happen often but there is a small race in
> svc_sock_enqueue as SK_CONN and SK_DATA are tested outside the
> spin_lock.  They could be cleared immediately after the test and
> before the lock is gained.
> 
> This normally shouldn't be a problem.  The sockets are non-blocking so
> trying to read() or accept() when ther is nothing to do is not a problem.
> 
> However: svc_tcp_recvfrom makes the decision "Should I accept() or
> should I read()" based on whether SK_CONN is set or not.  This usually
> works but is not safe.  The decision should be based on whether it is
> a TCP_LISTEN socket or a TCP_CONNECTED socket.
> 
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> ### Diffstat output
>  ./net/sunrpc/svcsock.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
> --- .prev/net/sunrpc/svcsock.c	2006-10-20 11:49:18.000000000 +1000
> +++ ./net/sunrpc/svcsock.c	2006-10-20 11:49:47.000000000 +1000
> @@ -1002,7 +1002,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  		return 0;
>  	}
>  
> -	if (test_bit(SK_CONN, &svsk->sk_flags)) {
> +	if (svsk->sk_sk->sk_state == TCP_LISTEN) {
>  		svc_tcp_accept(svsk);
>  		svc_sock_received(svsk);
>  		return 0;

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
