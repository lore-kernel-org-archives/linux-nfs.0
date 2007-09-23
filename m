From: kenneth johansson <ken@kenjo.org>
Subject: Re: lockd not responding
Date: Sun, 23 Sep 2007 20:52:40 +0200
Message-ID: <1190573560.7249.3.camel@duo>
References: <fc84aa$o11$1@sea.gmane.org>
	<20070912202721.d8f70ac1.jlayton@redhat.com>
	<1190407932.6721.42.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZWZd-0004mL-Lv
	for nfs@lists.sourceforge.net; Sun, 23 Sep 2007 11:52:57 -0700
Received: from 1-1-4-20a.ras.sth.bostream.se ([82.182.72.90]
	helo=garbo.kenjo.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IZWZh-0005LX-2X
	for nfs@lists.sourceforge.net; Sun, 23 Sep 2007 11:53:02 -0700
In-Reply-To: <1190407932.6721.42.camel@heimdal.trondhjem.org>
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


On Fri, 2007-09-21 at 16:52 -0400, Trond Myklebust wrote:
> On Wed, 2007-09-12 at 20:27 -0400, Jeff Layton wrote:
> > On Wed, 12 Sep 2007 07:26:02 +0000 (UTC)
> > kenneth johansson <ken@kenjo.org> wrote:
> > 
> > > Got a warning from the lock validating check again and
> > > later a unresponsive lockd with a backtrace this time
> > > actually at the same place the lock warning was on.
> > 
> > FWIW, I think I ran into the exact same problem recently. I opened a
> > BZ case for it so I wouldn't forget about it, but haven't had time to
> > track it down:
> > 
> > https://bugzilla.redhat.com/show_bug.cgi?id=280311
> > 
> > I'm not certain that lockd was stuck at the time, since I had some
> > other things going on with the box, but it may have been...
> 
> Does the attached patch help?

Yes it does. 

I tested Jeffs lock unlock loop and it got the lock warning in a minute
or two the three times I tested without the patch and has run for about
an hour now with with no warning.

So there is an Ack from me on this fix.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
