From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 11/33] svc: Add xpo_accept transport function
Date: Fri, 28 Sep 2007 11:10:16 -0500
Message-ID: <1190995816.10604.50.camel@trinity.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050157.12677.92320.stgit@dell3.ogc.int>
	<18172.29482.366028.515043@notabene.brown>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbIRC-000487-0i
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:11:34 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbIRE-0002IB-M6
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:11:36 -0700
In-Reply-To: <18172.29482.366028.515043@notabene.brown>
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

On Fri, 2007-09-28 at 13:21 +1000, Neil Brown wrote:
> On Thursday September 27, tom@opengridcomputing.com wrote:
> > @@ -1046,9 +1054,10 @@ static inline int svc_port_is_privileged
> >  /*
> >   * Accept a TCP connection
> >   */
> > -static void
> > -svc_tcp_accept(struct svc_sock *svsk)
> > +static struct svc_xprt *
> > +svc_tcp_accept(struct svc_xprt *xprt)
> >  {
> > +	struct svc_sock *svsk = (struct svc_sock *)xprt;
> 
> This cast should use container_of
> 
>         struct svc_sock *svsk = container_of(xprt, struct svc_sock *, sk_xprt);
> 
> That makes it clearer what is happening.

Good suggestion. Thanks,

> 
> 
> 
> NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
