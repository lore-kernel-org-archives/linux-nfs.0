From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 23/33] svc: Move the authinfo cache to svc_xprt.
Date: Sat, 29 Sep 2007 15:49:36 -0500
Message-ID: <1191098976.10604.123.camel@trinity.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050222.12677.48478.stgit@dell3.ogc.int>
	<18172.33610.417174.67852@notabene.brown>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbjH6-0000wF-5W
	for nfs@lists.sourceforge.net; Sat, 29 Sep 2007 13:50:56 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbjH7-0001Yg-HQ
	for nfs@lists.sourceforge.net; Sat, 29 Sep 2007 13:50:59 -0700
In-Reply-To: <18172.33610.417174.67852@notabene.brown>
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

On Fri, 2007-09-28 at 14:30 +1000, Neil Brown wrote:
> On Thursday September 27, tom@opengridcomputing.com wrote:
> >  
> >  	/* Initialize the socket */
> >  	if (sock->type == SOCK_DGRAM) {
> >  		svc_xprt_init(&svc_udp_class, &svsk->sk_xprt, serv);
> >  		svc_udp_init(svsk);
> > +		clear_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
> >  	} else {
> >  		svc_xprt_init(&svc_tcp_class, &svsk->sk_xprt, serv);
> >  		svc_tcp_init(svsk);
> > +		set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
> >  	}
> >  

This is design detritus. At one point, I was going to move this stuff
into common logic, but decided I couldn't do it. I agree it will look
cleaner if it gets moved it into the svc_xxx_init functions.

Thanks,
Tom
> 
> Why don't these clear_bit/set_bit calls go inside svc_{udp,tcp}_init?
> Further, why aren't the svc_xprt_init calling inside there too?
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
