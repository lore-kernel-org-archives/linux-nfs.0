From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 010 of 14] knfsd: SUNRPC: add a "generic" function
 to see if the peer uses a secure port
Date: Tue, 12 Dec 2006 17:42:07 -0800
Message-ID: <20061212174207.6180df0f.akpm@osdl.org>
References: <20061213105528.21128.patches@notabene>
	<1061212235927.21484@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuJ8O-0004Th-9S
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 17:42:12 -0800
Received: from smtp.osdl.org ([65.172.181.25])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1GuJ8P-0000b2-IK
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 17:42:13 -0800
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1061212235927.21484@suse.de>
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

On Wed, 13 Dec 2006 10:59:27 +1100
NeilBrown <neilb@suse.de> wrote:

> From: Chuck Lever <chuck.lever@oracle.com>
> The only reason svcsock.c looks at a sockaddr's port is to check whether
> the remote peer is connecting from a privileged port.  Refactor this check
> to hide processing that is specific to address format.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> ### Diffstat output
>  ./net/sunrpc/svcsock.c |   20 +++++++++++++++++---
>  1 file changed, 17 insertions(+), 3 deletions(-)
> 
> diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
> --- .prev/net/sunrpc/svcsock.c	2006-12-13 10:32:15.000000000 +1100
> +++ ./net/sunrpc/svcsock.c	2006-12-13 10:32:17.000000000 +1100
> @@ -926,6 +926,20 @@ svc_tcp_data_ready(struct sock *sk, int 
>  		wake_up_interruptible(sk->sk_sleep);
>  }
>  
> +static inline int svc_port_is_privileged(struct sockaddr *sin)
> +{
> +	switch (sin->sa_family) {
> +	case AF_INET:
> +		return ntohs(((struct sockaddr_in *)sin)->sin_port) < 1024;
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +	case AF_INET6:
> +		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port) < 1024;
> +#endif
> +	default:
> +		return 0;
> +	}
> +}

I'm a bit surprised to see this test implemented in sunrpc - it's the sort
of thing which core networking should implement?

And should that "1024" be PROT_SOCK?

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
