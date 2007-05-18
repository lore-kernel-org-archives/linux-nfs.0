From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 2/14] knfsd: delete per transport
Date: Fri, 18 May 2007 17:55:00 +1000
Message-ID: <20070518075500.GJ5104@sgi.com>
References: <20070516191951.GH9626@sgi.com>
	<17996.12924.211214.309207@notabene.brown>
	<20070518055631.GE5104@sgi.com>
	<17997.19270.91547.343390@notabene.brown>
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
	id 1HoxIl-00067X-Fk
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 00:55:03 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1/TLY0ul9SJzqShkSCAUyvY7+muRzpKY0U=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoxIn-0002z0-RA
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 00:55:06 -0700
In-Reply-To: <17997.19270.91547.343390@notabene.brown>
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

On Fri, May 18, 2007 at 04:44:22PM +1000, Neil Brown wrote:
> On Friday May 18, gnb@sgi.com wrote:
> > 
> > I considered renaming the existing svc_sock to svc_xprt, which
> > would be another horribly unpronouncable identifier(*) but would at
> > least be appropriately abstract and consistent with the client.
> > 
> > Then the naming would all be obvious and correct: svc_xprt_foo()
> > is a generic transport function, svc_sock_foo() is a more specific
> > socket-based transport function used as common code between TCP
> > and UDP transports.  Yay.
> > 
> > But it would be a much larger patch so I shied away.
> 
> Sensible.
> 
> > 
> > I'm happy to do the naming any way you want, just let me know.
> 
> I accept that "ipsock" is not accurate (as it is the 'sock' bit that
> is significant, the 'ip' is fairly irrelevant) but it is at least
> better than tcpip.  Another option is
>    svc_detach_sock / svc_free_sock
> 
> Which avoid mentioned "svc_sock", but still says what you want.
> 
> So go with that, unless you find it objectionable, in which case got
> with svc_ipsock_*.

I really like having the module at the start and the verb at the end,
so I'll go for svc_ipsock_foo().

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
