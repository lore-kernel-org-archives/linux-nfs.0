From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 22/33] svc: Move sk_lastrecv to svc_xprt
Date: Wed, 3 Oct 2007 20:10:34 +1000
Message-ID: <20071003101033.GK21388@sgi.com>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050220.12677.62957.stgit@dell3.ogc.int>
	<18172.33312.649312.820488@notabene.brown>
	<1190996177.10604.54.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id18B-0000vn-F6
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 03:07:03 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1/aQO+GXtFCyUoVugkslCGYze7xW16ykqw=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Id18G-0007Uf-Ed
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 03:07:08 -0700
In-Reply-To: <1190996177.10604.54.camel@trinity.ogc.int>
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

On Fri, Sep 28, 2007 at 11:16:17AM -0500, Tom Tucker wrote:
> On Fri, 2007-09-28 at 14:25 +1000, Neil Brown wrote:
> > On Thursday September 27, tom@opengridcomputing.com wrote:
> > > 
> > > This functionally trivial change moves the tranpsort independent sk_lastrecv 
> > > field to the svc_xprt structure. 
> > 
> > It would seem that sk_lastrecv is entirely unused (Well, a dprintk
> > prints it, but that isn't very interesting).
> 
> agreed.
> 
> > I think it used to be used to time out idle connections, but Greg's
> > mark/sweep does a better job without needing this field.  Shall we
> > just remove it?
> 
> I think so. Greg?

Sure, why not.  I have in the past found sk_lastrecv useful
forensically, but I could live without it.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
