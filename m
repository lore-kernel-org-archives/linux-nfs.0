From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 2/14] knfsd: delete per transport
Date: Thu, 17 May 2007 16:38:38 +1000
Message-ID: <20070517063838.GB27247@sgi.com>
References: <20070516191951.GH9626@sgi.com>
	<20070516205123.GB18927@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoZdP-0005JB-4O
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 23:38:47 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HoZdR-0005Pl-TX
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 23:38:50 -0700
In-Reply-To: <20070516205123.GB18927@fieldses.org>
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

On Wed, May 16, 2007 at 04:51:23PM -0400, J. Bruce Fields wrote:
> Trivial comments, since I couldn't find any real problems:

Well, that's hopeful ;-)

> On Thu, May 17, 2007 at 05:19:51AM +1000, Greg Banks wrote:
> > @@ -886,7 +883,9 @@ svc_udp_sendto(struct svc_rqst *rqstp)
> >  static const struct svc_sock_ops svc_udp_ops = {
> >  	.sko_name = "udp",
> >  	.sko_recvfrom = svc_udp_recvfrom,
> > -	.sko_sendto = svc_udp_sendto
> > +	.sko_sendto = svc_udp_sendto,
> 
> Any objection to always just including a trailing comma and saving a
> little noise in each diff?  That seems to be common practice elsewhere.

Fixed.

> > +static void
> > +svc_tcpip_free(struct svc_sock *svsk)
> > +{
> > +	dprintk("svc: svc_sock_free(%p)\n", svsk);
> 
> We lived without these dprintk's before; do we need them now?

Not really.  Removed.

> >  	int			(*sko_sendto)(struct svc_rqst *rqstp);
> > +	/*
> > +	 * Detach the svc_sock from it's socket, so that the
> 
> s/it's/its/
> 

Doh!  Fixed.

Thanks Bruce.

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
