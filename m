From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: PATCH - RPC/TCP 2 of 4 - Allow  SO_REUSEADDR for NFS sockets
Date: Mon, 12 Aug 2002 23:23:35 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.BSO.4.33.0208122322420.6948-100000@citi.umich.edu>
References: <15704.30117.665447.109832@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linus Torvalds <torvalds@transmeta.com>,
	Minoura Makoto <minoura@valinux.co.jp>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from citi.umich.edu ([141.211.92.141])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eSHT-0004L6-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 20:23:39 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15704.30117.665447.109832@notabene.cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

it's been suggested that the client should also try reusing the port
number when reconnecting over TCP... any thoughts on that?

On Tue, 13 Aug 2002, Neil Brown wrote:

>
> Otherwise if you cannot stop and restart nfsd while a client holds a
> connection.  Why this isn't the default I cannot imagine...
>
>  ----------- Diffstat output ------------
>  ./net/sunrpc/svcsock.c |    1 +
>  1 files changed, 1 insertion(+)
>
> --- ./net/sunrpc/svcsock.c	2002/08/12 06:01:42	1.2
> +++ ./net/sunrpc/svcsock.c	2002/08/13 01:54:39	1.3
> @@ -1208,6 +1208,7 @@ svc_create_socket(struct svc_serv *serv,
>  		return error;
>
>  	if (sin != NULL) {
> +		sock->sk->reuse = 1; /* allow address reuse */
>  		error = sock->ops->bind(sock, (struct sockaddr *) sin,
>  						sizeof(*sin));
>  		if (error < 0)
>

	- Chuck Lever
--
corporate:	<cel@netapp.com>
personal:	<chucklever@bigfoot.com>



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
