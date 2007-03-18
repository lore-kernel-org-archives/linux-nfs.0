From: Neil Brown <neilb@suse.de>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Mon, 19 Mar 2007 10:49:17 +1100
Message-ID: <17917.53245.697560.272545@notabene.brown>
References: <17914.20117.186786.830574@notabene.brown>
	<20070316181047.GD4538@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>,
	richterd@citi.umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HT57w-0006Ol-Ps
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 16:49:28 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HT57y-0007YO-Ou
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 16:49:31 -0700
In-Reply-To: message from J. Bruce Fields on Friday March 16
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Friday March 16, bfields@fieldses.org wrote:
> On Fri, Mar 16, 2007 at 07:00:21PM +1100, Neil Brown wrote:
> > Statd currently does several very different things.
> > 1/ It listens for monitor requests from lockd and creates
> >    files in /var/lib/nfs/sm/HOST
> > 2/ It listens for notifications from peers and tells lockd
> >    that those peers have restarted.
> > 3/ It moves files from sm/ to sm.bak/ and then tries to 
> >    notify every host listed in sm.bak/
> > 
> > The first is very similar to what NFSv4 needs for state management,
> > though is somewhat simpler.  I would like to create a better
> > interface for the kernel to ask for state to be stored, and then use
> > if for NFSv4 and NLM, subsuming this function.
> 
> NFSv4 needs something like the third as well--knfsd needs to know on
> startup the list of clients that will be allowed to reclaim state from a
> previous boot instance.  (This is to protect clients that *think*
> they're still holding locks on the server, but (thanks to a network
> partition) don't realize that the server has actually rebooted twice.)

Similar... but different...

You would want to forget about clients who haven't reclaimed when the
'grace period' expires.  Yes?
So when the grace period starts, you move state from "current" to
"recovering".
Then when a client tries to recover, we check in 'recovering' and if
we find something, we recreate the state in 'current'.
Then when the grace period ends, we remove everything from
'recovering'.
So if the server reboots twice without actually completing a grace
period, the client would still be safe.

Does that fit your understanding?

Thanks for reminding me of that.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
