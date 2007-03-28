From: Thorsten Kranzkowski <dl8bcu@dl8bcu.de>
Subject: Re: Odd log message associated with NFS
Date: Wed, 28 Mar 2007 18:55:34 +0000
Message-ID: <20070328185534.GA585@ds20.borg.net>
References: <2fe399760703271140l703c2791oa84e9e1832487dcb@mail.gmail.com>
	<20070327193909.GA585@ds20.borg.net>
	<17929.53448.506302.615732@notabene.brown>
Reply-To: dl8bcu@dl8bcu.de
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Phy Prabab <phyprabab@gmail.com>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWdJA-0000CF-28
	for nfs@lists.sourceforge.net; Wed, 28 Mar 2007 11:55:44 -0700
Received: from xdsler061.osnanet.de
	([89.166.177.61] helo=Marvin.DL8BCU.ampr.org ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWdJA-0005TX-If
	for nfs@lists.sourceforge.net; Wed, 28 Mar 2007 11:55:46 -0700
In-Reply-To: <17929.53448.506302.615732@notabene.brown>
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

On Wed, Mar 28, 2007 at 12:19:52PM +1000, Neil Brown wrote:
> On Tuesday March 27, dl8bcu@dl8bcu.de wrote:
> > On Tue, Mar 27, 2007 at 11:40:48AM -0700, Phy Prabab wrote:
> > > kernel: rpcsvc: received unknown control message:-2144992132/-1
> > 
> > Just a 'me, too':
> 
> For the 'unknown control message' messages,
> see:   "fix typo in svc_udp_recvfrom"  previously on
> nfs@lists.sourceforge.net.
> 
> Fix is in -mm and below.

will try, thanks.
 
> For "svc: bad direction" .... Don't know... garbage on the net maybe?
> Or maybe not.  I have seen something like that before, but haven't

I don't think so as it would mean corruption at other places, too. The
Network is quite uninteresting: single ethernet segment, 2 switches
involved, longest cable 8 meters ...

> been able to pin it on anything yet.
> NeilBrown

I _had_ problems with the previous kernel (same version, same config, 
different (older) compiler (gcc 3.4.5 instead of 4.1.2), on both client and server)
It would randomly (usually within 30 mins) 'lock up' NFS, where the client
sends out requests but doesn't get any answer (apart from tcp-ack) from the 
server. Only a forced umount/remount recovered that (until the next lock-up). 
But I'm willing to attribute that to a somehow broken gcc.

again, thanks for commenting.

bye,
Thorsten
 
> --- linux-2.6.orig/net/sunrpc/svcsock.c
> +++ linux-2.6/net/sunrpc/svcsock.c
> @@ -779,7 +779,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>  	}
>  
>  	clear_bit(SK_DATA, &svsk->sk_flags);
> -	while ((err == kernel_recvmsg(svsk->sk_sock, &msg, NULL,
> +	while ((err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
>  				      0, 0, MSG_PEEK | MSG_DONTWAIT)) < 0 ||
>  	       (skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err)) == NULL) {
>  		if (err == -EAGAIN) {
> 
> 
> > 
> > Mar 16 16:57:06 Marvin kernel: svc: bad direction 268435456, dropping request
> > Mar 16 17:58:19 Marvin kernel: svc: bad direction 268435456, dropping request
> > Mar 16 19:55:49 Marvin kernel: svc: bad direction 268435456, dropping request
> > ...
> > Mar 17 04:30:03 Marvin kernel: svc: bad direction 268435456, dropping request

-- 
| Thorsten Kranzkowski        Internet: dl8bcu@dl8bcu.de                      |
| Mobile: ++49 170 1876134       Snail: Kiebitzstr. 14, 49324 Melle, Germany  |
| Ampr: dl8bcu@db0lj.#rpl.deu.eu, dl8bcu@marvin.dl8bcu.ampr.org [44.130.8.19] |

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
