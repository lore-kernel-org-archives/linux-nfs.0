From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 2/14] knfsd: delete per transport
Date: Fri, 18 May 2007 15:56:31 +1000
Message-ID: <20070518055631.GE5104@sgi.com>
References: <20070516191951.GH9626@sgi.com>
	<17996.12924.211214.309207@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HovS9-0002Js-Hj
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 22:56:37 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HovSB-0003Ax-AE
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 22:56:40 -0700
In-Reply-To: <17996.12924.211214.309207@notabene.brown>
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

On Thu, May 17, 2007 at 08:46:20PM +1000, Neil Brown wrote:
> On Thursday May 17, gnb@sgi.com wrote:
> >  
> > @@ -886,7 +883,9 @@ svc_udp_sendto(struct svc_rqst *rqstp)
> >  static const struct svc_sock_ops svc_udp_ops = {
> >  	.sko_name = "udp",
> >  	.sko_recvfrom = svc_udp_recvfrom,
> > -	.sko_sendto = svc_udp_sendto
> > +	.sko_sendto = svc_udp_sendto,
> > +	.sko_detach = svc_tcpip_detach,
> > +	.sko_free = svc_tcpip_free
> >  };
> 
> Tiny nit:
>   Despite widespread usage, I don't see udp as being a part of
>   tcp/ip.  So having a function names *tcpip* in the svc_udp_ops looks
>   just wrong.
>   Maybe svc_ipsock_detach, svc_ipsock_free ??

I struggled with this.

The obvious thing would have been to use the word "sock" because what
these functions have in common is that they deal with sockets rather
than TCP/IP or even IP.  None of "tcpip" or "ipsock" accurately
reflect what these functions do.

But unfortunately our abstract structure is called "svc_sock".  So
doing the obvious would result in enormous confusion: is svc_sock_foo()
a generic transport function or a specific sockets-based one?

I considered renaming the existing svc_sock to svc_xprt, which
would be another horribly unpronouncable identifier(*) but would at
least be appropriately abstract and consistent with the client.

Then the naming would all be obvious and correct: svc_xprt_foo()
is a generic transport function, svc_sock_foo() is a more specific
socket-based transport function used as common code between TCP
and UDP transports.  Yay.

But it would be a much larger patch so I shied away.

I'm happy to do the naming any way you want, just let me know.

 * what did the Sun people who originally coined RPC terminology
   have against vowels, I wonder?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
