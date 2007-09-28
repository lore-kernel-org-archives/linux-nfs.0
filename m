From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 09/33] svc: Add a transport function that checks	for write
	space
Date: Fri, 28 Sep 2007 11:09:42 -0500
Message-ID: <1190995782.10604.49.camel@trinity.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050153.12677.18487.stgit@dell3.ogc.int>
	<18172.28434.751796.240775@notabene.brown>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbIQc-00041t-FG
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:10:58 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbIQg-00024D-UB
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:11:03 -0700
In-Reply-To: <18172.28434.751796.240775@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-09-28 at 13:03 +1000, Neil Brown wrote:
> On Thursday September 27, tom@opengridcomputing.com wrote:
> > @@ -898,6 +900,25 @@ svc_udp_prep_reply_hdr(struct svc_rqst *
> >  {
> >  }
> >  
> > +static int
> > +svc_udp_has_wspace(struct svc_xprt *xprt)
> > +{
> > +	struct svc_sock *svsk = (struct svc_sock*)xprt;
> > +	struct svc_serv	*serv = svsk->sk_server;
> > +	int required;
> > +
> > +	/*
> > +	 * Set the SOCK_NOSPACE flag before checking the available
> > +	 * sock space.
> > +	 */
> > +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > +	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
> > +	if (required*2 > sock_wspace(svsk->sk_sk))
> > +		return 0;
> > +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > +	return 1;
> > +}
> > +
> >  static struct svc_xprt_ops svc_udp_ops = {
> >  	.xpo_recvfrom = svc_udp_recvfrom,
> >  	.xpo_sendto = svc_udp_sendto,
> > @@ -1368,6 +1390,25 @@ svc_tcp_prep_reply_hdr(struct svc_rqst *
> >  	svc_putnl(resv, 0);
> >  }
> >  
> > +static int
> > +svc_tcp_has_wspace(struct svc_xprt *xprt)
> > +{
> > +	struct svc_sock *svsk = (struct svc_sock*)xprt;
> > +	struct svc_serv	*serv = svsk->sk_server;
> > +	int required;
> > +
> > +	/*
> > +	 * Set the SOCK_NOSPACE flag before checking the available
> > +	 * sock space.
> > +	 */
> > +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > +	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
> > +	if (required*2 > sk_stream_wspace(svsk->sk_sk))
> > +		return 0;
> > +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > +	return 1;
> > +}
> > +
> >  static struct svc_xprt_ops svc_tcp_ops = {
> >  	.xpo_recvfrom = svc_tcp_recvfrom,
> >  	.xpo_sendto = svc_tcp_sendto,
> 
> As these two functions are identical, could we just have one called
> "svc_sock_has_wspace" or similar?
> 

They are not quite identical. One calls sk_stream_wspace(...) to get
socket space and the other calls sock_wspace(...).  Maybe I should add
this to the comment, so it's more obvious? I also broken them apart
instead of combining them to make the importance of the ordering of the
setting/resetting of the NOSPACE bits obvious.

> Makes maintenance a little easier.
> 
> NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
