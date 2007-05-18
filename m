From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 3/14] knfsd: prepare reply per transport
Date: Fri, 18 May 2007 00:08:05 -0400
Message-ID: <20070518040805.GE30144@fieldses.org>
References: <20070517075342.GG27247@sgi.com>
	<7619F3097FAB384287CF636FF92D0CA10976B38B@exsvl01.hq.netapp.com>
	<20070518031630.GB5104@sgi.com>
	<20070518040137.GD30144@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	"Iyer,  Rahul" <Rahul.Iyer@netapp.com>,
	"Talpey,  Thomas" <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hotl9-0000Tb-L0
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 21:08:07 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HotlB-0003Or-UI
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 21:08:10 -0700
In-Reply-To: <20070518040137.GD30144@fieldses.org>
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

On Fri, May 18, 2007 at 12:01:37AM -0400, bfields wrote:
> On Fri, May 18, 2007 at 01:16:30PM +1000, Greg Banks wrote:
> > On Thu, May 17, 2007 at 02:16:46AM -0700, Iyer, Rahul wrote:
> > > I've written some code to do NFSv4.1 callbacks and wound up implementing
> > > another "transport". Since in v4.1 it's actually possible for clients to
> > > send requests (fore-channel) and receive callbacks (back channel) over
> > > the same connection,
> > 
> > A very sensible thing to do, but hard to retrofit to the existing Linux
> > code without significant surgery.  As you've discovered, the server and
> > client code are two mostly-separate code bases (with mostly-separate
> > authors and maintainers) that happen to link into the same module.
> > Unifying these would be a major job.  I'd love to see it happen, for
> > example to unify the XDR buffering code, but it would be an uphill
> > battle technically and possibly politically also.  For some reason,
> > code (like lockd) that lives in both the server and client side tends
> > to be neglected by both camps.
> > 
> > > Given this, a unified transport switch would really rock. 
> > > [...] Maybe I'm oversimplifying, but this seems doable.
> > 
> > Yes...eventually.
> 
> And the easiest approach may be to go ahead and introduce the completely
> separate server-side transport switch and then later find ways increase
> code sharing between the two in incremental steps....

(But I don't think people who are interested in doing this should be
scared off by "politics".  I'm sure careful patches would be welcomed by
everyone.  Care is required, though--small differences between the
assumptions made in the two code bases can tricky.  Anyway, that's my
lame excuse for why I ended up with such messy rpcsec_gss privacy code.)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
