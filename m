From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 000 of 11] knfsd: NUMAisation
Date: Wed, 26 Jul 2006 14:26:27 -0400
Message-ID: <76bd70e30607261126s28003af9neae6366f001fefe3@mail.gmail.com>
References: <1153805274.21040.38.camel@hole.melbourne.sgi.com>
	<17605.50325.842862.8823@cse.unsw.edu.au>
	<76bd70e30607250705h3e8c9eefjc794397e0c45a21b@mail.gmail.com>
	<D29213A6-C328-4C88-8D6D-428F3FDF4F56@rgmadvisors.com>
	<76bd70e30607250836v35110d6eo20043dccc4d284b7@mail.gmail.com>
	<1153895119.21040.494.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Paul Jimenez <pj@rgmadvisors.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5oUv-0003io-NP
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 11:52:45 -0700
Received: from nf-out-0910.google.com ([64.233.182.187])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5oUt-0001IH-MI
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 11:52:44 -0700
Received: by nf-out-0910.google.com with SMTP id m19so788823nfc
	for <nfs@lists.sourceforge.net>; Wed, 26 Jul 2006 11:52:37 -0700 (PDT)
To: "Greg Banks" <gnb@melbourne.sgi.com>
In-Reply-To: <1153895119.21040.494.camel@hole.melbourne.sgi.com>
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

On 7/26/06, Greg Banks <gnb@melbourne.sgi.com> wrote:
> On Wed, 2006-07-26 at 01:36, Chuck Lever wrote:
> > On 7/25/06, Paul Jimenez <pj@rgmadvisors.com> wrote:
> > >
> > My vote is to zap the least recently used connection.  That is overall
> > the safest compromise.
>
> Agreed.  The following patch (on top of my earlier patch 001) does
> that.  I've verified that it enforces the connection limit and
> doesn't kill the oldest socket.

Looks like you're only dropping sockets that aren't registered with
the local portmapper.  Should you do something similar for the
permanent sockets, or am I missing something?


> --
>
> sunrpc: when enforcing the TCP connection limit, choose exactly the
> least recently used TCP connection.  This is fairer than the new
> algorithm which was a side effect of the recent connection aging
> patch, and minimises the chances of closing an active connection
> (which is known to have adverse consequences).
>
>
> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> ---
>
>  net/sunrpc/svcsock.c |   34 +++++++++++++++++++++++++++-------
>  1 files changed, 27 insertions(+), 7 deletions(-)
>
> Index: linus-git/net/sunrpc/svcsock.c
> ===================================================================
> --- linus-git.orig/net/sunrpc/svcsock.c 2006-07-26 15:33:32.989291299 +1000
> +++ linus-git/net/sunrpc/svcsock.c      2006-07-26 16:18:10.988508212 +1000
> @@ -798,6 +798,32 @@ svc_tcp_data_ready(struct sock *sk, int
>                 wake_up_interruptible(sk->sk_sleep);
>  }
>
> +
> +/*
> + * Find and return the Least Recently Used temp socket
> + * on the serv.  Used to choose a victim when enforcing
> + * connection limits.  The idea here is to avoid dropping
> + * active connections, which is known to have adverse
> + * effects.  Caller must own serv->sv_lock.
> + */
> +static struct svc_sock *
> +svc_lru_temp_socket(struct svc_serv *serv)
> +{
> +       struct svc_sock *svsk;
> +       struct svc_sock *lru_svsk = NULL;
> +       unsigned long lru_when = 0;
> +
> +       list_for_each_entry(svsk, &serv->sv_tempsocks, sk_list) {
> +               unsigned long when = svsk->sk_lastrecv;
> +               if (lru_svsk == NULL || when < lru_when) {
> +                       lru_svsk = svsk;
> +                       lru_when = when;
> +               }
> +       }
> +
> +       return lru_svsk;
> +}
> +
>  /*
>   * Accept a TCP connection
>   */
> @@ -896,13 +922,7 @@ svc_tcp_accept(struct svc_sock *svsk)
>                                         NIPQUAD(sin.sin_addr.s_addr),
>                                         ntohs(sin.sin_port));
>                         }
> -                       /*
> -                        * Always select the oldest socket. It's not fair,
> -                        * but so is life
> -                        */
> -                       svsk = list_entry(serv->sv_tempsocks.prev,
> -                                         struct svc_sock,
> -                                         sk_list);
> +                       svsk = svc_lru_temp_socket(serv);
>                         set_bit(SK_CLOSE, &svsk->sk_flags);
>                         svsk->sk_inuse ++;
>                 }
>
>
>
> Greg.
> --
> Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> I don't speak for SGI.
>
>
>


-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
