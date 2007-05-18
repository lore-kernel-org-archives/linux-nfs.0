From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 3/14] knfsd: prepare reply per transport
Date: Fri, 18 May 2007 13:16:30 +1000
Message-ID: <20070518031630.GB5104@sgi.com>
References: <20070517075342.GG27247@sgi.com>
	<7619F3097FAB384287CF636FF92D0CA10976B38B@exsvl01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: "Iyer, Rahul" <Rahul.Iyer@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HosxQ-0004ED-Rz
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 20:16:58 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1/sprDNwH1lwkAZzXO120l83K9GgT7iap0=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HosxS-0001Be-I8
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 20:16:47 -0700
In-Reply-To: <7619F3097FAB384287CF636FF92D0CA10976B38B@exsvl01.hq.netapp.com>
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

On Thu, May 17, 2007 at 02:16:46AM -0700, Iyer, Rahul wrote:
> Hi Greg,
> I like the idea of a transport switch for the server side. The way I see
> it, it's not just the server, it's also the "callback server" on the
> client that can benefit. 
> 
> I had a question. Maybe it's a dumb question, and I may be way off base,
> but I don't see why we need 2 transport switches - one for the client,
> one for the server? Why not have one? 

Two separate sets of code with different requirements.

> I've written some code to do NFSv4.1 callbacks and wound up implementing
> another "transport". Since in v4.1 it's actually possible for clients to
> send requests (fore-channel) and receive callbacks (back channel) over
> the same connection,

A very sensible thing to do, but hard to retrofit to the existing Linux
code without significant surgery.  As you've discovered, the server and
client code are two mostly-separate code bases (with mostly-separate
authors and maintainers) that happen to link into the same module.
Unifying these would be a major job.  I'd love to see it happen, for
example to unify the XDR buffering code, but it would be an uphill
battle technically and possibly politically also.  For some reason,
code (like lockd) that lives in both the server and client side tends
to be neglected by both camps.

> Given this, a unified transport switch would really rock. 
> [...] Maybe I'm oversimplifying, but this seems doable.

Yes...eventually.

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
